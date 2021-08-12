import 'package:flutter/cupertino.dart';

import 'auth/sign_up.dart';

class LibraryPermissionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: CupertinoButton(
            child: Text("library permission"),
            onPressed: () {
              Navigator.of(context)
                  .pushReplacement(CupertinoPageRoute(builder: (context) {
                return SignUp();
              }));
            }),
      ),
    );
  }
}
