import 'package:cloud_photos_v2/constant.dart';
import 'package:cloud_photos_v2/screen/auth/sign_up.dart';
import 'package:cloud_photos_v2/screen/init_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_photos_v2/api.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Constant.CloudPhotosYellow,
      child: SignInBody(),
    );
  }
}

class SignInBody extends StatefulWidget {
  const SignInBody({Key? key}) : super(key: key);

  @override
  _SignInBodyState createState() => _SignInBodyState();
}

class _SignInBodyState extends State<SignInBody> {
  String username = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SafeArea(
          top: true,
          bottom: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Icon(
                  CupertinoIcons.person_crop_circle_badge_checkmark,
                  color: CupertinoColors.black,
                  size: 100,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 25),
                child: CupertinoTextField(
                  autocorrect: false,
                  placeholder: "Username",
                  placeholderStyle: TextStyle(color: CupertinoColors.black),
                  style: TextStyle(color: CupertinoColors.black),
                  decoration: BoxDecoration(
                      color: Constant.CloudPhotosYellow,
                      border: Border(
                          bottom: BorderSide(
                              color: CupertinoColors.black, width: 1))),
                  onChanged: (String value) {
                    setState(() {
                      username = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 25),
                child: CupertinoTextField(
                  autocorrect: false,
                  placeholder: "Password",
                  obscureText: true,
                  placeholderStyle: TextStyle(color: CupertinoColors.black),
                  style: TextStyle(color: CupertinoColors.black),
                  decoration: BoxDecoration(
                      color: Constant.CloudPhotosYellow,
                      border: Border(
                          bottom: BorderSide(
                              color: CupertinoColors.black, width: 1))),
                  onChanged: (String value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
              ),
              CupertinoButton(
                  child: Text("Sign In"),
                  onPressed: () async {
                    if (username.length > 0 && password.length > 0) {
                      print("make http request to login $username");
                      var response = await Api().multipart("/api/v1/user/login",
                          {'username': username, 'password': password});
                      print(response);
                      if (response["statusCode"] == 200) {
                        final storage = new FlutterSecureStorage();
                        await storage.write(
                            key: "token",
                            value: response["json"]["access_token"]);
                        print("navigate to config screen");
                        Navigator.of(context).pushReplacement(
                            CupertinoPageRoute(builder: (context) {
                          return InitConfigScreen();
                        }));
                      } else {
                        setState(() {
                          error = "Username/password not match";
                        });
                      }
                    } else {
                      setState(() {
                        error = "Username/Password is empty";
                      });
                    }
                  }),
              CupertinoButton(
                  child: Text("Don't have account? Sign up"),
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacement(CupertinoPageRoute(builder: (context) {
                      return SignUpScreen();
                    }));
                  }),
            ],
          )),
    );
  }
}
