import 'package:cloud_photos_v2/constant.dart';
import 'package:flutter/cupertino.dart';

class MainNav extends StatelessWidget {
  const MainNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Constant.CloudPhotosYellow,
      child: Center(
        child: Text("Main Nav"),
      ),
    );
  }
}
