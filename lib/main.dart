import 'package:cloud_photos_v2/screen/auth/sign_up.dart';
import 'package:cloud_photos_v2/screen/library_permission.dart';
import 'package:cloud_photos_v2/screen/loading.dart';
import 'package:cloud_photos_v2/screen/privacy_notice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
    CupertinoApp(
      home: CloudPhotos(),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        'Loading': (BuildContext context) {
          return LoadingScreen();
        },
        'LibraryPermission': (BuildContext context) {
          return LibraryPermissionScreen();
        },
        'PrivacyNotice': (BuildContext context) {
          return PrivacyNotiveScreen();
        },
        'SignUp': (BuildContext context) {
          return SignUpScreen();
        },
      },
    ),
  );
}

class CloudPhotos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(builder: (context) {
      return LoadingScreen();
    });
  }
}
