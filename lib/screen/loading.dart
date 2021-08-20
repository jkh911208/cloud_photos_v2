import 'package:cloud_photos_v2/screen/library_permission.dart';
import 'package:cloud_photos_v2/screen/main/photos_thumbnail.dart';
import 'package:cloud_photos_v2/screen/privacy_notice.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
        future: getNextScreen(),
        builder: (context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data) {
              case 1:
                {
                  return ThumbnailScreen();
                }
              case 2:
                {
                  return PrivacyNotiveScreen();
                }
              case 3:
                {
                  return LibraryPermissionScreen();
                }
              default:
                {
                  return LibraryPermissionScreen();
                }
            }
          } else {
            return Center(
              child: CupertinoActivityIndicator(),
            );
          }
        });
  }
}

Future<int> getNextScreen() async {
  // if media library access is granted && token found => 1 go to Gallery
  // if media library access is granted && token not found => 2 go to sign up
  // if media library access is not granted => 3 to go library permission
  var permission = await Permission.storage.status;
  final storage = new FlutterSecureStorage();
  var token = await storage.read(key: "token");
  
  if (permission.isGranted && token != null) {
    return 1;
  } else if (permission.isGranted && token == null) {
    return 2;
  }
  return 3;
}
