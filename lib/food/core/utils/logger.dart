import 'package:flutter/foundation.dart';

enum ColorLogger {
  black("30"),
  red("31"),
  green("32"),
  yellow("33"),
  blue("34"),
  magenta("35"),
  cyan("36"),
  white("37");

  final String code;
  const ColorLogger(this.code);

  void log(dynamic text) {
    if (kDebugMode) {
      print('\x1B[${code}m$text\x1B[0m');
    }
  }
}

class Logger {
  static void logBasic(String message, {String? tag}) {
    if (kDebugMode) {
      ColorLogger.blue.log("[ 📌📌📌 ${tag ?? 'No tag'}: $message]");
    }
  }

  static void logError(String message, {String? tag}) {
    if (kDebugMode) {
      ColorLogger.red.log("[ 🚨🚨🚨 ${tag ?? 'No tag'}: $message]");
    }
  }

  static void logSuccess(String message, {String? tag}) {
    if (kDebugMode) {
      ColorLogger.green.log("[✅✅✅ ${tag ?? 'No tag'}: $message]");
    }
  }

  static void logWarning(String message, {String? tag}) {
    if (kDebugMode) {
      ColorLogger.yellow.log("""
        [⚡⚡⚡ ${tag ?? 'No tag'} :$message]""");
    }
  }
}
