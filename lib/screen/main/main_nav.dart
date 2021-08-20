import 'package:cloud_photos_v2/screen/main/photos_thumbnail.dart';
import 'package:flutter/cupertino.dart';

class MainNav extends StatelessWidget {
  const MainNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabView(
      builder: (context) {
        return ThumbnailScreen();
      },
    );
  }
}
