import 'package:cloud_photos_v2/screen/auth/sign_up.dart';
import 'package:cloud_photos_v2/screen/library_permission.dart';
import 'package:cloud_photos_v2/screen/loading.dart';
import 'package:flutter/cupertino.dart';

void main() {
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
        'SignUp': (BuildContext context) {
          return SignUp();
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
