import 'package:cloud_photos_v2/screen/main/photos_thumbnail.dart';
import 'package:cloud_photos_v2/screen/main/settings.dart';
import 'package:flutter/cupertino.dart';

class MainNav extends StatelessWidget {
  const MainNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBuilder: (context, i) => getPage(i),
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.photo), label: "Photos"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings), label: "Settings")
        ],
      ),
    );
  }

  Widget getPage(i) {
    if (i == 0) {
      return CupertinoTabView(builder: (context) {
        return ThumbnailScreen();
      });
    } else if (i == 1) {
      return CupertinoTabView(
        builder: (context) {
          return SettingsScreen();
        },
      );
    }
    return Text("1");
  }
}
