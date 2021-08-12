import 'package:cloud_photos_v2/screen/auth/sign_up.dart';
import 'package:cloud_photos_v2/screen/library_permission.dart';
import 'package:flutter/cupertino.dart';

class LoadingScreen extends StatelessWidget {
  // if media library access is granted && token found => go to Gallery
  // if media library access is granted && token not found => go to sign up
  // if media library access is not granted => to go library permission
  final int test = 1;

  Widget getNextScreen(i) {
    return i == 0 ? LibraryPermissionScreen() : SignUp();
  }

  @override
  Widget build(BuildContext context) {
    return getNextScreen(test);
  }
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
          child: CupertinoButton(
              child: Text("data"),
              onPressed: () {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return SettingsScreen();
                }));
              }),
        ),
      );
    });
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Center(
      child: Text("SettingsScreen"),
    ));
  }
}
