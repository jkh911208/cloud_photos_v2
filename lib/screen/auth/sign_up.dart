import 'package:flutter/cupertino.dart';

import 'package:cloud_photos_v2/constant.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Constant.CloudPhotosYellow,
      child: SignUpBody(),
    );
  }
}

class SignUpBody extends StatefulWidget {
  const SignUpBody({Key? key}) : super(key: key);

  @override
  _SignUpBodyState createState() => _SignUpBodyState();
}

class _SignUpBodyState extends State<SignUpBody> {
  String username = "";
  String password1 = "";
  String password2 = "";
  bool helper1 = false;
  bool helper2 = false;
  bool helper3 = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: true,
        bottom: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(visible: helper1, child: Text("helper1")),
              FocusScope(
                child: Focus(
                  onFocusChange: (focus) {
                    setState(() {
                      helper1 = focus;
                    });
                  },
                  child: CupertinoTextField(
                    onTap: () {
                      setState(() {
                        helper1 = true;
                      });
                    },
                    autocorrect: false,
                    placeholder: "Username",
                    onChanged: (String value) {
                      setState(() {
                        username = value;
                      });
                    },
                  ),
                ),
              ),
              CupertinoTextField(
                obscureText: true,
                onSubmitted: (value) {
                  setState(() {
                    helper2 = false;
                  });
                },
                onEditingComplete: () {
                  setState(() {
                    helper2 = false;
                  });
                },
                onTap: () {
                  setState(() {
                    helper2 = true;
                  });
                },
                autocorrect: false,
                placeholder: "Password",
                onChanged: (String value) {
                  setState(() {
                    password1 = value;
                  });
                },
              )
            ],
          ),
        ));
  }
}
