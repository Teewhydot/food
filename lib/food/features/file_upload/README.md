# File Upload Feature

A comprehensive file upload system with configurable file types, size limits, and multiple picker options.

## Features

- ✅ **Multiple file types**: Images, Documents, Videos, Audio, Any file type
- ✅ **Configurable size limits**: MB or bytes
- ✅ **Multiple upload**: Support for uploading multiple files at once
- ✅ **Smart file picking**: Uses appropriate picker for each file type
- ✅ **Validation**: File type and size validation
- ✅ **Clean Architecture**: BLoC pattern with proper separation of concerns
- ✅ **Comprehensive testing**: Unit tests across all layers

## Quick Start

### 1. Super Simple - Just Get Files (No Upload)

```dart
BasicFileUploadWidget(
  fileType: FileUploadType.image,
  maxSizeInMB: 5,
  onFileSelected: (file) {
    print('Got file: ${file.path}');
  },
  onError: (error) {
    print('Error: $error');
  },
)
```

### 2. Simple - Auto Upload

```dart
SimpleFileUploadWidget(
  fileType: FileUploadType.image,
  maxSizeInMB: 5,
  folder: '/uploads/',
  onUploadSuccess: (url) {
    print('Uploaded: $url');
  },
  onUploadError: (error) {
    print('Error: $error');
  },
)
```

### 3. Direct Service Usage

```dart
final service = FileUploadService();

// Pick from gallery
final file = await service.pickImageFromGallery();

// Pick from camera  
final file = await service.pickImageFromCamera();

// Pick any file
final file = await service.pickFile(fileType: FileUploadType.document);

// Validate file
final isValid = service.validateFile(file, maxSizeInMB: 5);
```

### 4. Advanced Configuration (If Needed)

```dart
ConfigurableFileUploadWidget(
  config: const FileUploadConfig(
    fileType: FileUploadType.image,
    maxSizeInMB: 10,
    allowMultiple: true,
    folder: '/my-images/',
    tags: ['custom', 'upload'],
  ),
  onMultipleUploadSuccess: (urls) {
    print('${urls.length} files uploaded!');
  },
)
```

## File Type Support

### Images
- **Extensions**: jpg, jpeg, png, gif, bmp, webp, svg
- **Picker**: Image picker with camera/gallery options
- **Compression**: Configurable quality and dimensions

### Documents  
- **Extensions**: pdf, doc, docx, xls, xlsx, ppt, pptx, txt, csv
- **Picker**: File picker
- **Validation**: Extension and MIME type validation

### Videos
- **Extensions**: mp4, avi, mov, wmv, flv, mkv, webm
- **Picker**: Video picker with camera/gallery options

### Audio
- **Extensions**: mp3, wav, ogg, aac, wma, flac, m4a
- **Picker**: File picker

### Any File Type
- **Extensions**: No restrictions
- **Picker**: File picker
- **Validation**: Optional

## Configuration Options

```dart
FileUploadConfig(
  fileType: FileUploadType.image,          // Required
  maxSizeInMB: 5,                         // Optional: Size limit in MB
  maxSizeInBytes: 5242880,                // Optional: Size limit in bytes
  allowMultiple: false,                   // Optional: Multiple file selection
  customAllowedExtensions: ['jpg', 'png'], // Optional: Custom extensions
  customMimeTypes: ['image/jpeg'],        // Optional: Custom MIME types
  folder: '/uploads/',                    // Optional: Upload folder
  tags: ['images'],                       // Optional: File tags
  validateFileType: true,                 // Optional: Enable validation
  compressImage: true,                    // Optional: Image compression
  imageQuality: 85,                       // Optional: Compression quality (1-100)
  maxImageWidth: 1920,                    // Optional: Max image width
  maxImageHeight: 1080,                   // Optional: Max image height
)
```

## Presets

### Profile Picture
```dart
FileUploadConfig.profilePicture() // 5MB, single image, optimized
```

### Food Images
```dart
FileUploadConfig.foodImage() // 10MB, multiple images, food tags
```

### Document Upload
```dart
FileUploadConfig.document() // 20MB, single document
```

### Video Upload  
```dart
FileUploadConfig.videoUpload() // 100MB, single video
```

## Usage Examples

### Simple Widget (Flexible API)

```dart
FlexibleFileUploadWidget(
  fileType: FileUploadType.image,
  maxSizeInMB: 5,
  folder: '/simple-uploads/',
  onUploadSuccess: (url) => print('Success: $url'),
  onUploadError: (error) => print('Error: $error'),
)
```

### Advanced Widget (Configurable API)

```dart
ConfigurableFileUploadWidget(
  config: const FileUploadConfig(
    fileType: FileUploadType.any,
    maxSizeInMB: 25,
    allowMultiple: true,
    validateFileType: false,
    folder: '/general-files/',
  ),
  onMultipleUploadSuccess: (urls) {
    print('${urls.length} files uploaded: $urls');
  },
  onUploadError: (error) {
    print('Upload failed: $error');
  },
)
```

## Permissions

The file upload system automatically handles permissions with modern Android 13+ granular media permissions:

### **Permission Types**
- **Camera Permission**: Required for taking photos/videos with camera
- **Photos Permission**: Required for accessing images/videos (Android 13+)
- **Videos Permission**: Required for accessing video files (Android 13+)
- **Audio Permission**: Required for accessing audio files (Android 13+)
- **Storage Permission**: Fallback for older Android versions (API < 33)

### **Smart Permission Handling**
- **Android 13+**: Uses granular media permissions (READ_MEDIA_IMAGES, READ_MEDIA_VIDEO, READ_MEDIA_AUDIO)
- **Older Android**: Falls back to legacy storage permission (READ_EXTERNAL_STORAGE)
- **iOS**: Uses standard photos permission
- **Multi-tier Fallback**: If granular permissions fail, automatically falls back to storage permission

### **Permission Flow**
1. **Camera Selection** → Camera permission requested automatically
2. **Gallery Images** → Photos permission requested (with storage fallback)
3. **Video Files** → Videos permission requested (with storage fallback)
4. **Audio Files** → Audio permission requested (with storage fallback)
5. **General Files** → Storage permission requested
6. **Permission Denied** → Clear error message with guidance
7. **Platform Errors** → Automatic fallback to alternative picker methods

### **Automatic Permission Detection**
- Detects Android API level and requests appropriate permissions
- Handles permission state persistence in local database
- Provides detailed logging for debugging permission issues

## Environment Setup

Add to your `.env` file:

```env
IMAGEKIT_PUBLIC_KEY=your_imagekit_public_key
IMAGEKIT_PRIVATE_KEY=your_imagekit_private_key  
IMAGEKIT_URL_ENDPOINT=your_imagekit_url_endpoint
IMAGEKIT_DEFAULT_FOLDER=/food-app/
IMAGEKIT_MAX_FILE_SIZE=5242880
```

## Architecture

### **Simple Architecture** (Recommended)

```
lib/food/core/services/
└── file_upload_service.dart    # All file operations in one service

lib/food/features/file_upload/presentation/widgets/
├── basic_file_upload_widget.dart      # Ultra simple, no BLoC
└── simple_file_upload_widget.dart     # Simple with auto-upload
```

**Benefits:**
- ✅ **One service** handles everything
- ✅ **No complexity** - just call methods
- ✅ **Easy to use** - minimal setup
- ✅ **Permissions handled** automatically

### **Advanced Architecture** (If You Need Full Control)

```
lib/food/features/file_upload/
├── data/
│   ├── models/                  # ImageKit API models
│   ├── remote/data_sources/     # Remote data source
│   └── repositories/            # Repository implementation
├── domain/
│   ├── entities/                # Domain entities
│   ├── enums/                   # File type enums
│   ├── failures/                # Custom failures
│   ├── models/                  # Configuration models
│   ├── repositories/            # Repository interfaces
│   └── use_cases/              # Business logic
└── presentation/
    ├── manager/                 # BLoC state management
    ├── screens/                 # Example screens
    └── widgets/                 # Upload widgets (ConfigurableFileUploadWidget)
```

## Main Entry Point

Use the `generateLinkFromUploadedFile` function for programmatic uploads:

```dart
final result = await generateLinkFromUploadedFileUseCase(
  file: myFile,
  fileName: 'custom-name.jpg',
  folder: '/my-folder/',
  tags: ['custom'],
  transformations: ['w-300', 'h-200'],
);

result.fold(
  (failure) => print('Error: ${failure.failureMessage}'),
  (url) => print('Generated URL: $url'),
);
```