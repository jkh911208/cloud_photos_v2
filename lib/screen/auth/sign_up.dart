import 'package:cloud_photos_v2/api.dart';
import 'package:cloud_photos_v2/screen/auth/sign_in.dart';
import 'package:cloud_photos_v2/screen/init_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_photos_v2/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Constant.CloudPhotosYellow,
      child: SignUpBody(),
    );
  }
}

class SignUpConstant {
  final int maxLength = 30;
  final int minLength = 7;
}

class SignUpBody extends StatefulWidget {
  const SignUpBody({Key? key}) : super(key: key);

  @override
  _SignUpBodyState createState() => _SignUpBodyState();
}

class _SignUpBodyState extends State<SignUpBody> {
  final int maxLength = SignUpConstant().maxLength;
  final int minLength = SignUpConstant().minLength;
  String username = "";
  String password1 = "";
  String password2 = "";
  bool helper1 = false;
  bool helper2 = false;
  bool helper3 = false;
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: SafeArea(
          top: true,
          bottom: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Icon(
                  CupertinoIcons.person_badge_plus,
                  color: CupertinoColors.black,
                  size: 100,
                ),
              ),
              Visibility(
                  visible: helper1,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(isMinLength(username, minLength)
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.xmark),
                          ),
                          Text("Username at least $minLength characters"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(isMaxLength(username, maxLength)
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.xmark),
                          ),
                          Text("Username shorter than $maxLength characters"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(isNotContainsWhiteSpace(username)
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.xmark),
                          ),
                          Text("Username not have white space"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(isStartsWithAlpha(username)
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.xmark),
                          ),
                          Text("Username start with alphabet"),
                        ],
                      )
                    ],
                  )),
              FocusScope(
                child: Focus(
                  onFocusChange: (focus) {
                    setState(() {
                      helper1 = focus;
                      error = "";
                    });
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 8, right: 8, bottom: 25),
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
                ),
              ),
              Visibility(
                  visible: helper2,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(isMinLength(password1, minLength)
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.xmark),
                          ),
                          Text("Password at least $minLength characters"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(isMaxLength(password1, maxLength)
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.xmark),
                          ),
                          Text("Password shorter than $maxLength characters"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(isContainsLowerCase(password1)
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.xmark),
                          ),
                          Text("Password contains 1 lower case"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(isContainsUpperCase(password1)
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.xmark),
                          ),
                          Text("Password contains 1 upper case"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(isContainsNumber(password1)
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.xmark),
                          ),
                          Text("Password contains 1 number"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(isContainsSpecialChar(password1)
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.xmark),
                          ),
                          Text(r'Password contains one of !@#$%^&*'),
                        ],
                      ),
                    ],
                  )),
              FocusScope(
                child: Focus(
                  onFocusChange: (focus) {
                    setState(() {
                      helper2 = focus;
                      error = "";
                    });
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 8, right: 8, bottom: 25),
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
                          password1 = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Visibility(
                  visible: helper3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(password1 == password2
                            ? CupertinoIcons.check_mark
                            : CupertinoIcons.xmark),
                      ),
                      Text("Password Match"),
                    ],
                  )),
              FocusScope(
                child: Focus(
                  onFocusChange: (focus) {
                    setState(() {
                      helper3 = focus;
                      error = "";
                    });
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 8, right: 8, bottom: 40),
                    child: CupertinoTextField(
                      autocorrect: false,
                      placeholder: "Confirm Password",
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
                          password2 = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              CupertinoButton(
                  child: Text("Sign Up"),
                  onPressed: () async {
                    bool usernameCheck = isUsernameGood(username);
                    bool passwordCheck = isPasswordGood(password1);
                    bool confirmPassword = password1 == password2;
                    if (usernameCheck && passwordCheck && confirmPassword) {
                      print("make http request to create user");
                      var response = await Api().post("/api/v1/user/signup",
                          {'username': username, 'password': password1});
                      if (response["statusCode"] == 201) {
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
                          error = "Please use different username or try later";
                        });
                      }
                    } else {
                      setState(() {
                        error = "Username/Password doesn't meet requirements";
                      });
                    }
                  }),
              CupertinoButton(
                  child: Text("Already have account? Sign in"),
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacement(CupertinoPageRoute(builder: (context) {
                      return SignInScreen();
                    }));
                  }),
              Visibility(
                  visible: (error.length > 0),
                  child: Text(
                    error,
                    style: TextStyle(color: CupertinoColors.systemRed),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

bool isMinLength(String testValue, int testLength) {
  if (testValue.length >= testLength) {
    return true;
  }
  return false;
}

bool isMaxLength(String testValue, int testLength) {
  if (testValue.length < testLength) {
    return true;
  }
  return false;
}

bool isNotContainsWhiteSpace(String testValue) {
  if (testValue.contains(" ")) {
    return false;
  }
  return true;
}

bool isStartsWithAlpha(String testValue) {
  if (testValue.startsWith(RegExp(r'[a-zA-z]'))) {
    return true;
  }
  return false;
}

bool isContainsLowerCase(String testValue) {
  if (testValue.contains(RegExp(r'[a-z]'))) {
    return true;
  }
  return false;
}

bool isContainsUpperCase(String testValue) {
  if (testValue.contains(RegExp(r'[A-Z]'))) {
    return true;
  }
  return false;
}

bool isContainsNumber(String testValue) {
  if (testValue.contains(RegExp(r'[0-9]'))) {
    return true;
  }
  return false;
}

bool isContainsSpecialChar(String testValue) {
  if (testValue.contains(RegExp(r'[!@#$%^&*]'))) {
    return true;
  }
  return false;
}

bool isUsernameGood(String testValue) {
  if (!isMinLength(testValue, SignUpConstant().minLength)) {
    return false;
  }
  if (!isMaxLength(testValue, SignUpConstant().maxLength)) {
    return false;
  }
  if (!isNotContainsWhiteSpace(testValue)) {
    return false;
  }
  if (!isStartsWithAlpha(testValue)) {
    return false;
  }
  return true;
}

bool isPasswordGood(String testValue) {
  if (!isMinLength(testValue, SignUpConstant().minLength)) {
    return false;
  }
  if (!isMaxLength(testValue, SignUpConstant().maxLength)) {
    return false;
  }
  if (!isContainsLowerCase(testValue)) {
    return false;
  }
  if (!isContainsUpperCase(testValue)) {
    return false;
  }
  if (!isContainsNumber(testValue)) {
    return false;
  }
  if (!isContainsSpecialChar(testValue)) {
    return false;
  }
  return true;
}
