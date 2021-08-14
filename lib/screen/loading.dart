import 'package:cloud_photos_v2/database.dart';
import 'package:cloud_photos_v2/screen/library_permission.dart';
import 'package:cloud_photos_v2/screen/main/main_nav.dart';
import 'package:cloud_photos_v2/screen/privacy_notice.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoadingScreen extends StatelessWidget {
  LoadingScreen() {
    // Create Database table
    MediaTable mediaTable = MediaTable();
    mediaTable.getDatabaseObject();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
        future: getNextScreen(),
        builder: (context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data) {
              case 1:
                {
                  return MainNav();
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
            // TODO splash screen
            return Text("");
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

  print(token);
  print(permission);

  if (permission.isGranted && token != null) {
    return 1;
  } else if (permission.isGranted && token == null) {
    return 2;
  }
  return 3;
}

class LoadingScreen1 extends StatelessWidget {
  Widget getPage(i) {
    if (i == 0) {
      return photosPageScaffold();
    } else if (i == 2) {
      return settingsPageScaffold();
    }
    return photosPageScaffold();
  }

  Widget cupertinoTabScaffold() => CupertinoTabScaffold(
        tabBuilder: (context, i) => CupertinoPageScaffold(
          child: Center(
            child: getPage(i),
          ),
        ),
        tabBar: CupertinoTabBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.photo), label: "Photos"),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.collections), label: "Collection"),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings), label: "Settings")
          ],
        ),
      );

  Widget photosPageScaffold() => CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text("Photos"),
            ),
            SliverFillRemaining(
              child: Center(
                child: Text("Thumbnail goes here"),
              ),
            )
          ],
        ),
      );

  Widget settingsPageScaffold() => CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text("Settings"),
            ),
            SliverFillRemaining(
              child: Center(
                child: Text("Settings goes here"),
              ),
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(builder: (context) {
      return CupertinoPageScaffold(
        child: Center(
          child: CupertinoButton(child: Text("data"), onPressed: () {}),
        ),
      );
    });
  }
}
