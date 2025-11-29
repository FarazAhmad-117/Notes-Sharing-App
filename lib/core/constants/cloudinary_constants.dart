/// Cloudinary configuration constants
class CloudinaryConstants {
  // Get these from your Cloudinary dashboard: https://cloudinary.com/console
  static const String cloudName = 'dcferxegi';
  static const String apiKey = '374136732641478';
  static const String apiSecret = 'W9jPG-RpL6ks9DJIfLvisb9h38Y';
  static const String uploadPreset =
      'ml_default'; // Optional, for unsigned uploads

  // Base URL for Cloudinary uploads
  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/upload';

  static String get imageUploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  static String get rawUploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/raw/upload';

  // Resource types
  static const String resourceTypeImage = 'image';
  static const String resourceTypeRaw = 'raw'; // For PDFs and other files
  static const String resourceTypeAuto = 'auto';
}
