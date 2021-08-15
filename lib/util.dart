import 'dart:typed_data';
import 'package:crypto/crypto.dart';

Future<String> getMD5FromUint8List(Uint8List data) async {
  Digest md5Result = md5.convert(data);
  return md5Result.toString();
}

