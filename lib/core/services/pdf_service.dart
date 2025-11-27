import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../utils/logger.dart';

/// Service for generating PDFs from images and text
class PdfService {
  /// Generate PDF from a list of image files
  Future<File> generatePdfFromImages(
    List<File> imageFiles, {
    String? title,
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    try {
      AppLogger.info('Generating PDF from ${imageFiles.length} images');
      
      final pdf = pw.Document();
      
      for (final imageFile in imageFiles) {
        try {
          final imageBytes = await imageFile.readAsBytes();
          final image = pw.MemoryImage(imageBytes);
          
          pdf.addPage(
            pw.Page(
              pageFormat: format,
              build: (pw.Context context) {
                return pw.Center(
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                );
              },
            ),
          );
        } catch (e) {
          AppLogger.error('Failed to add image to PDF: ${imageFile.path}', e);
          // Continue with other images
        }
      }
      
      // Save PDF to temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = title != null
          ? '${title.replaceAll(RegExp(r'[^\w\s-]'), '_')}_$timestamp.pdf'
          : 'document_$timestamp.pdf';
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(await pdf.save());
      
      AppLogger.info('PDF generated successfully: ${file.path}');
      return file;
    } catch (e, stackTrace) {
      AppLogger.error('Error generating PDF from images', e, stackTrace);
      rethrow;
    }
  }
  
  /// Generate PDF from text
  Future<File> generatePdfFromText(
    String text, {
    String? title,
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    try {
      AppLogger.info('Generating PDF from text');
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  if (title != null) pw.SizedBox(height: 20),
                  pw.Text(
                    text,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      );
      
      // Save PDF to temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = title != null
          ? '${title.replaceAll(RegExp(r'[^\w\s-]'), '_')}_$timestamp.pdf'
          : 'document_$timestamp.pdf';
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(await pdf.save());
      
      AppLogger.info('PDF generated successfully: ${file.path}');
      return file;
    } catch (e, stackTrace) {
      AppLogger.error('Error generating PDF from text', e, stackTrace);
      rethrow;
    }
  }
}

