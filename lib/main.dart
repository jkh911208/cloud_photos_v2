import 'package:cloud_photos_v2/screen/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  if (kDebugMode) {
    print("loading debug.env");
    await dotenv.load(fileName: "debug.env");
  } else if (kReleaseMode) {
    print("loading production.env");
    await dotenv.load(fileName: "production.env");
  }

  runApp(
    MaterialApp(
      home: CloudPhotos(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class CloudPhotos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return LoadingScreen();
  }
}
