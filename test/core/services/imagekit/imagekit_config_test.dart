import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/core/services/imagekit/imagekit_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('ImageKitConfig', () {
    setUp(() {
      // Clear dotenv for clean testing
      dotenv.testLoad(fileInput: '');
    });

    tearDown(() {
      dotenv.clean();
    });

    test('should be a singleton', () {
      // Act
      final instance1 = ImageKitConfig();
      final instance2 = ImageKitConfig();

      // Assert
      expect(instance1, same(instance2));
    });

    test('should return empty strings when environment variables are not set', () {
      // Act
      final config = ImageKitConfig();

      // Assert
      expect(config.publicKey, isEmpty);
      expect(config.privateKey, isEmpty);
      expect(config.urlEndpoint, isEmpty);
      expect(config.defaultFolder, equals('/food-app/'));
      expect(config.isConfigured, isFalse);
    });

    test('should return correct values when environment variables are set', () {
      // Arrange
      dotenv.testLoad(fileInput: '''
IMAGEKIT_PUBLIC_KEY=test_public_key
IMAGEKIT_PRIVATE_KEY=test_private_key
IMAGEKIT_URL_ENDPOINT=https://ik.imagekit.io/test
IMAGEKIT_DEFAULT_FOLDER=/custom-folder/
IMAGEKIT_MAX_FILE_SIZE=10485760
''');

      // Act
      final config = ImageKitConfig();

      // Assert
      expect(config.publicKey, equals('test_public_key'));
      expect(config.privateKey, equals('test_private_key'));
      expect(config.urlEndpoint, equals('https://ik.imagekit.io/test'));
      expect(config.defaultFolder, equals('/custom-folder/'));
      expect(config.maxFileSizeInBytes, equals(10485760)); // 10MB
      expect(config.isConfigured, isTrue);
    });

    test('should return default max file size when not specified', () {
      // Act
      final config = ImageKitConfig();

      // Assert
      expect(config.maxFileSizeInBytes, equals(5 * 1024 * 1024)); // 5MB default
    });

    test('should return allowed file types', () {
      // Act
      final config = ImageKitConfig();

      // Assert
      expect(config.allowedFileTypes, isA<List<String>>());
      expect(config.allowedFileTypes, contains('image/jpeg'));
      expect(config.allowedFileTypes, contains('image/png'));
      expect(config.allowedFileTypes, contains('image/webp'));
      expect(config.allowedFileTypes, hasLength(5));
    });

    test('should return auth parameters when configured', () {
      // Arrange
      dotenv.testLoad(fileInput: '''
IMAGEKIT_PUBLIC_KEY=test_public_key
IMAGEKIT_PRIVATE_KEY=test_private_key
IMAGEKIT_URL_ENDPOINT=https://ik.imagekit.io/test
''');

      // Act
      final config = ImageKitConfig();
      final authParams = config.getAuthParams();

      // Assert
      expect(authParams, isA<Map<String, String>>());
      expect(authParams['publicKey'], equals('test_public_key'));
      expect(authParams['urlEndpoint'], equals('https://ik.imagekit.io/test'));
      expect(authParams, hasLength(2));
    });

    test('should throw exception when getting auth params with incomplete config', () {
      // Arrange
      dotenv.testLoad(fileInput: '''
IMAGEKIT_PUBLIC_KEY=test_public_key
# Missing private key and url endpoint
''');

      // Act
      final config = ImageKitConfig();

      // Assert
      expect(() => config.getAuthParams(), throwsA(isA<ImageKitConfigException>()));
    });
  });

  group('ImageKitConfigException', () {
    test('should create exception with message', () {
      // Arrange
      const message = 'Test error message';

      // Act
      const exception = ImageKitConfigException(message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.toString(), contains(message));
      expect(exception.toString(), contains('ImageKitConfigException'));
    });
  });
}