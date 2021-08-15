import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class Api {
  String baseUrl = dotenv.get('API_URL', fallback: 'http://localhost');
  String secret = dotenv.get('SECRET', fallback: 'yoursecret');
  http.Client client = new http.Client();
  Map<String, String> header = {"Content-Type": "application/json"};

  Api() {
    header["Authorization"] = secret;
  }

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    var url = Uri.parse(baseUrl + path);
    var response =
        await client.post(url, headers: header, body: json.encode(body));
    print(response.body);
    Map<String, dynamic> result = {"statusCode": response.statusCode};
    try {
      result["json"] = jsonDecode(response.body);
    } on Exception {
      result["json"] = {};
    }
    return result;
  }

  Future<Map<String, dynamic>> multipart(
      String path, Map<String, dynamic> body) async {
    header["Content"] = "multipart/form-data";
    var url = Uri.parse(baseUrl + path);
    var request = http.MultipartRequest('POST', url);
    body.forEach((key, value) {
      request.fields[key] = value;
    });
    var response = await request.send();
    Map<String, dynamic> result = {"statusCode": response.statusCode};
    try {
      result["json"] = jsonDecode(await response.stream.bytesToString());
    } on Exception {
      result["json"] = {};
    }
    return result;
  }
}