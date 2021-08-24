import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<bool> hasConnectivity() async {
  try {
    String baseUrl = dotenv.get('API_URL', fallback: 'http://localhost');
    final result = await InternetAddress.lookup(baseUrl);
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on Exception {
    return false;
  }
  return false;
}
