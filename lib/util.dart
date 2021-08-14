import 'dart:io';
import 'package:crypto/crypto.dart';

Future<String> getMD5FromFile(File file) async {
  Digest md5Result = md5.convert(await file.readAsBytes());
  return md5Result.toString();
}
