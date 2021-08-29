import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/cupertino.dart';

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

Future<bool> customDialog(BuildContext context, String title, String body,
    String subBody, String trueText) async {
  bool decision = false;
  await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: CupertinoColors.destructiveRed),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(body),
                Text(subBody),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                decision = false;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                trueText,
                style: TextStyle(color: CupertinoColors.destructiveRed),
              ),
              onPressed: () {
                decision = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });

  return decision;
}
