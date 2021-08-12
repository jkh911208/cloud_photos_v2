import 'package:cloud_photos_v2/screen/library_permission.dart';
import 'package:flutter/cupertino.dart';

class SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: CupertinoButton(
            child: Text("Signup"),
            onPressed: () {
              Navigator.of(context)
                  .pushReplacement(CupertinoPageRoute(builder: (context) {
                return LibraryPermissionScreen();
              }));
            }),
      ),
    );
  }
}
