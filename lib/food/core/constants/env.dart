import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String? mapsKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
}
