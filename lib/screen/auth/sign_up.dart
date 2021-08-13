import 'package:flutter/cupertino.dart';

import 'package:cloud_photos_v2/constant.dart';
import 'package:flutter/material.dart';

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
                            child: Icon(username.length >= 7
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.xmark),
                          ),
                          Text("Username at least 7 characters"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(username.length < 30
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.xmark),
                          ),
                          Text("Username shorter than 30 characters"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(!username.contains(" ")
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
                            child: Icon(username.startsWith(RegExp(r'[a-zA-Z]'))
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
                            child: Icon(password1.length >= 7
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.xmark),
                          ),
                          Text("Password at least 7 characters"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(password1.length < 30
                                ? CupertinoIcons.check_mark
                                : CupertinoIcons.xmark),
                          ),
                          Text("Password shorter than 30 characters"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(password1.contains(RegExp(r'[a-z]'))
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
                            child: Icon(password1.contains(RegExp(r'[A-Z]'))
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
                            child: Icon(password1.contains(RegExp(r'[0-9]'))
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
                            child: Icon(
                                password1.contains(RegExp(r'[!@#$%^&*]'))
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
              CupertinoButton(child: Text("Sign Up"), onPressed: () {}),
              CupertinoButton(
                  child: Text("Already have account? Sign in"),
                  onPressed: () {})
            ],
          ),
        ));
  }
}
