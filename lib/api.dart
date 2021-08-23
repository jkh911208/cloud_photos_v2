import 'dart:io';
import 'package:mime_type/mime_type.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:http_parser/http_parser.dart' as type;

class Api {
  String baseUrl = dotenv.get('API_URL', fallback: 'http://localhost');
  String secret = dotenv.get('SECRET', fallback: 'yoursecret');
  http.Client client = new http.Client();
  Map<String, String> header = {"Content-Type": "application/json"};

  Future<void> setupAuthHeader([String? contentType]) async {
    // set up content type
    if (contentType != null) {
      header["Content-Type"] = contentType;
    }

    // user token
    final storage = new FlutterSecureStorage();
    final token = await storage.read(key: "token");
    if (token != null) {
      header["Authorization"] = "Bearer $token";
    }

    // frontend verification token
    header["X-Custom-Auth"] = issueJwtHS256(
        JwtClaim(otherClaims: {
          "requested_time": DateTime.now().millisecondsSinceEpoch.toString()
        }),
        secret);
  }

  Future<Map<String, dynamic>> get(String path) async {
    await setupAuthHeader();
    var url = Uri.parse(baseUrl + path);
    var response = await client.get(url, headers: header);
    Map<String, dynamic> result = {"statusCode": response.statusCode};
    try {
      result["json"] = jsonDecode(response.body);
    } on Exception {
      result["body"] = response.body;
    }
    return result;
  }

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    await setupAuthHeader();
    var url = Uri.parse(baseUrl + path);
    var response =
        await client.post(url, headers: header, body: json.encode(body));
    Map<String, dynamic> result = {"statusCode": response.statusCode};
    try {
      result["json"] = jsonDecode(response.body);
    } on Exception {
      result["json"] = {};
    }
    return result;
  }

  Future<Map<String, dynamic>> multipart(String path, Map<String, String> body,
      [File? file]) async {
    await setupAuthHeader("multipart/form-data");
    var url = Uri.parse(baseUrl + path);
    var request = http.MultipartRequest('POST', url);
    if (file != null) {
      String? contentType = mime(body["filename"]);
      List typeList = contentType!.split("/");
      request.files.add(await http.MultipartFile.fromPath("file", file.path,
          filename: body["filename"],
          contentType: type.MediaType(typeList[0], typeList[1])));
    }
    body.forEach((key, value) {
      request.fields[key] = value;
    });
    request.headers.addAll(header);
    var response;
    response = await request.send();
    Map<String, dynamic> result = {"statusCode": response.statusCode};
    try {
      result["json"] = jsonDecode(await response.stream.bytesToString());
    } on Exception {
      result["json"] = {};
    }
    return result;
  }
}
