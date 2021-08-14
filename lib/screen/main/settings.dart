import 'package:cloud_photos_v2/screen/loading.dart';
import 'package:cloud_photos_v2/screen/privacy_notice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoButton(
          child: Text("return to loading"),
          onPressed: () {
            Navigator.of(context)
                .pushReplacement(CupertinoPageRoute(builder: (context) {
              return LoadingScreen();
            }));
          },
        ),
        CupertinoButton(
          child: Text("return to Privacy Notice"),
          onPressed: () {
            Navigator.of(context)
                .pushReplacement(CupertinoPageRoute(builder: (context) {
              return PrivacyNotiveScreen();
            }));
          },
        ),
        CupertinoButton(
          child: Text("delete token"),
          onPressed: () {
            final storage = new FlutterSecureStorage();
            storage.deleteAll();
          },
        ),
      ],
    ));
  }
}
