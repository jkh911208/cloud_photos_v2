import 'package:cloud_photos_v2/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_manager/photo_manager.dart';

import 'auth/sign_up.dart';

class LibraryPermissionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Constant.CloudPhotosYellow,
      child: LibraryPermissionBody(),
    );
  }
}

class LibraryPermissionBody extends StatefulWidget {
  const LibraryPermissionBody({Key? key}) : super(key: key);

  @override
  _LibraryPermissionBodyState createState() => _LibraryPermissionBodyState();
}

class _LibraryPermissionBodyState extends State<LibraryPermissionBody> {
  bool permission = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: true,
        bottom: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Icon(
                CupertinoIcons.photo,
                color: CupertinoColors.black,
                size: 150,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 30),
              child: Text(
                "Cloud Photos need full access to your media library",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 25),
              child: Text(
                "Cloud Photos app need permission to let you view and backup photos from this device",
                textAlign: TextAlign.center,
              ),
            ),
            Visibility(
              visible: !permission,
              child: CupertinoButton(
                  child: Text("Allow Access to all photos"),
                  onPressed: () async {
                    var result = await PhotoManager.requestPermissionExtend();
                    if (result == PermissionState.authorized) {
                      Navigator.of(context).pushReplacement(
                          CupertinoPageRoute(builder: (context) {
                        return SignUp();
                      }));
                    } else {
                      setState(() {
                        permission = !permission;
                        print(permission);
                      });
                    }
                  }),
            ),
            Visibility(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 12, right: 12, bottom: 20),
                    child: Text(
                      "Cloud Photos Don't have permission on this device, Please allow full access to photos in settings",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: CupertinoColors.systemRed),
                    ),
                  ),
                  CupertinoButton(
                      child: Text("Open Setting"),
                      onPressed: () {
                        PhotoManager.openSetting();
                      }),
                ],
              ),
              visible: permission,
            )
          ],
        ));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return GestureDetector(
  //     onTap: () {
  //       setState(() {
  //         count++;
  //         print(count);
  //       });
  //     },
  //     child: Center(child: Text("$count")),
  //   );
  // }
}
