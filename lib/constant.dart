import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Constant {
  final storage = new FlutterSecureStorage();
  static const CloudPhotosYellow = Color(0xfff5df4d);
  static const CloudPhotosGrey = Color(0xff939597);

  Future<bool> isWifiOnly() async {
    var result = await storage.read(key: "wifiOnly");
    if (result == null || result == "true") {
      return true;
    }
    return false;
  }
}
