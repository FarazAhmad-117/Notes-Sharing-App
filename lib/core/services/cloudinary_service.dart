import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../constants/cloudinary_constants.dart';
import '../utils/logger.dart';

/// Service for uploading files and images to Cloudinary
class CloudinaryService {
  /// Upload a single image to Cloudinary with progress tracking
  /// Uses signed uploads for reliability
  Future<String> uploadImage(
    File imageFile, {
    String? folder,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      AppLogger.info('Uploading image to Cloudinary: ${imageFile.path}');

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Parameters for signature (exclude api_key and signature itself)
      final paramsForSignature = <String, String>{
        'timestamp': timestamp,
        'resource_type': CloudinaryConstants.resourceTypeImage,
      };

      if (folder != null) {
        paramsForSignature['folder'] = folder;
      }

      // Generate signature from params (without api_key)
      final signature = _generateSignature(paramsForSignature);

      // All parameters for the request (including api_key and signature)
      final params = <String, String>{
        'timestamp': timestamp,
        'api_key': CloudinaryConstants.apiKey,
        'resource_type': CloudinaryConstants.resourceTypeImage,
        'signature': signature,
      };

      if (folder != null) {
        params['folder'] = folder;
      }

      final uri = Uri.parse(CloudinaryConstants.uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      // Add all parameters
      request.fields.addAll(params);

      // Add file
      final fileLength = await imageFile.length();
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Calculate total size (approximate)
      int totalSize = fileLength;
      for (final field in request.fields.entries) {
        totalSize += utf8.encode('${field.key}=${field.value}').length;
      }
      // Add overhead for multipart boundaries (approximate)
      totalSize += 500;

      // Send request with progress tracking
      final streamedResponse = await _sendWithProgress(
        request,
        totalSize,
        onProgress,
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final url = data['secure_url'] as String? ?? data['url'] as String;
        AppLogger.info('Image uploaded successfully: $url');
        return url;
      } else {
        final errorBody = response.body;
        AppLogger.error('Failed to upload image: ${response.statusCode}');
        AppLogger.error('Error response: $errorBody');
        throw Exception(
          'Failed to upload image: ${response.statusCode}. $errorBody',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error uploading image to Cloudinary', e, stackTrace);
      rethrow;
    }
  }

  /// Upload multiple images to Cloudinary with progress tracking
  Future<List<String>> uploadImages(
    List<File> imageFiles, {
    String? folder,
    void Function(int current, int total, int sent, int totalBytes)? onProgress,
  }) async {
    final urls = <String>[];
    final totalFiles = imageFiles.length;

    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final file = imageFiles[i];
        final fileLength = await file.length();

        final url = await uploadImage(
          file,
          folder: folder,
          onProgress: onProgress != null
              ? (sent, total) {
                  // Calculate overall progress
                  final filesCompleted = i;
                  final totalBytesSent = (filesCompleted * fileLength) + sent;
                  final totalBytes = totalFiles * fileLength;
                  onProgress(i + 1, totalFiles, totalBytesSent, totalBytes);
                }
              : null,
        );
        urls.add(url);
      } catch (e) {
        AppLogger.error('Failed to upload image: ${imageFiles[i].path}', e);
        // Continue with other images even if one fails
      }
    }
    return urls;
  }

  /// Helper method to send multipart request with progress tracking
  Future<http.StreamedResponse> _sendWithProgress(
    http.MultipartRequest request,
    int totalSize,
    void Function(int sent, int total)? onProgress,
  ) async {
    // Finalize the request to get the byte stream
    final requestBytes = request.finalize();

    // Track bytes sent
    int bytesSent = 0;
    final progressStream = requestBytes.transform(
      StreamTransformer<List<int>, List<int>>.fromHandlers(
        handleData: (data, sink) {
          bytesSent += data.length;
          if (onProgress != null) {
            onProgress(bytesSent, totalSize);
          }
          sink.add(data);
        },
      ),
    );

    // Create a new streamed request with the progress stream
    final newRequest = http.StreamedRequest(request.method, request.url)
      ..headers.addAll(request.headers);

    // Pipe the progress stream to the new request
    final completer = Completer<void>();
    progressStream.listen(
      (data) {
        newRequest.sink.add(data);
      },
      onDone: () {
        newRequest.sink.close();
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onError: (error) {
        newRequest.sink.addError(error);
        newRequest.sink.close();
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
      cancelOnError: false,
    );

    // Wait a bit for the stream to start, then send the request
    await Future.delayed(const Duration(milliseconds: 10));

    // Send the request and return the response
    final client = http.Client();
    final responseFuture = client.send(newRequest);

    // Ensure the stream completes
    completer.future.then((_) {}).catchError((_) {});

    return await responseFuture;
  }

  /// Generate signature for signed uploads
  /// According to Cloudinary docs: signature = SHA1(all_params_sorted + api_secret)
  /// Excludes: api_key, file, and signature itself
  ///
  /// The params map should NOT include api_key, signature, or file
  /// Format: param1=value1&param2=value2...api_secret
  String _generateSignature(Map<String, String> params) {
    // Sort parameters alphabetically by key (required by Cloudinary)
    final sortedKeys = params.keys.toList()..sort();

    // Build signature string: param1=value1&param2=value2... + api_secret
    final signatureParts = <String>[];
    for (final key in sortedKeys) {
      signatureParts.add('$key=${params[key]}');
    }
    final signatureString =
        signatureParts.join('&') + CloudinaryConstants.apiSecret;

    // Generate SHA1 hash
    final bytes = utf8.encode(signatureString);
    final digest = sha1.convert(bytes);

    AppLogger.debug(
      'Signature string: ${signatureString.replaceAll(CloudinaryConstants.apiSecret, '[SECRET]')}',
    );
    AppLogger.debug('Generated signature: $digest');

    return digest.toString();
  }

  /// Upload a PDF or document file to Cloudinary with progress tracking
  /// Uses signed uploads by default (more reliable than upload presets)
  Future<String> uploadFile(
    File file, {
    String? folder,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      AppLogger.info('Uploading file to Cloudinary: ${file.path}');

      // Use signed upload directly (more reliable)
      return await _uploadFileSigned(
        file,
        folder: folder,
        onProgress: onProgress,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error uploading file to Cloudinary', e, stackTrace);
      rethrow;
    }
  }

  /// Upload file using signed upload (with API key and signature)
  Future<String> _uploadFileSigned(
    File file, {
    String? folder,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      AppLogger.info('Trying signed upload for file: ${file.path}');

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Parameters for signature (exclude api_key and signature itself)
      final paramsForSignature = <String, String>{
        'timestamp': timestamp,
        'resource_type': CloudinaryConstants.resourceTypeRaw,
      };

      if (folder != null) {
        paramsForSignature['folder'] = folder;
      }

      // Generate signature from params (without api_key)
      final signature = _generateSignature(paramsForSignature);

      // All parameters for the request (including api_key and signature)
      final params = <String, String>{
        'timestamp': timestamp,
        'api_key': CloudinaryConstants.apiKey,
        'resource_type': CloudinaryConstants.resourceTypeRaw,
        'signature': signature,
      };

      if (folder != null) {
        params['folder'] = folder;
      }

      final uri = Uri.parse(CloudinaryConstants.uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      // Add all parameters
      request.fields.addAll(params);

      // Add file
      final fileLength = await file.length();
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Calculate approximate total size
      int totalSize = fileLength;
      for (final field in request.fields.entries) {
        totalSize += utf8.encode('${field.key}=${field.value}').length;
      }
      // Add overhead for multipart boundaries (approximate)
      totalSize += 500;

      // Send request with progress tracking
      final streamedResponse = await _sendWithProgress(
        request,
        totalSize,
        onProgress,
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final url = data['secure_url'] as String? ?? data['url'] as String;
        AppLogger.info('File uploaded successfully (signed): $url');
        return url;
      } else {
        final errorBody = response.body;
        AppLogger.error(
          'Failed to upload file (signed): ${response.statusCode}',
        );
        AppLogger.error('Error response: $errorBody');
        throw Exception(
          'Failed to upload file: ${response.statusCode}. $errorBody',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error in signed upload', e, stackTrace);
      rethrow;
    }
  }

  /// Get optimized image URL from Cloudinary URL
  String getOptimizedImageUrl(
    String cloudinaryUrl, {
    int? width,
    int? height,
    String? format,
  }) {
    // This is a simple implementation - you can enhance it with transformations
    return cloudinaryUrl;
  }
}
