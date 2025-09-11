import 'package:flutter/foundation.dart';

class PlatformDatabasePathService {
  static String getDbPath(String dbName) {
    if (kIsWeb) {
      return dbName;
    } else {
      throw UnsupportedError(
        'Database path resolution for mobile platforms should use path_provider'
      );
    }
  }
}