import 'package:cloud_photos_v2/library_management.dart';
import 'package:cloud_photos_v2/screen/auth/sign_up.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constant.dart';

class PrivacyNotiveScreen extends StatefulWidget {
  PrivacyNotiveScreen() {
    updateEntireLibrary();
  }

  @override
  _PrivacyNotiveScreenState createState() => _PrivacyNotiveScreenState();
}

class _PrivacyNotiveScreenState extends State<PrivacyNotiveScreen> {
  bool first = false;
  bool second = false;
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.CloudPhotosYellow,
      body: buildPrivacyNotiveBody(),
    );
  }

  Widget buildPrivacyNotiveBody() {
    return Center(
      child: SingleChildScrollView(
        child: SafeArea(
          top: true,
          bottom: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Icon(
                  CupertinoIcons.lock,
                  color: CupertinoColors.black,
                  size: 150,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "Privacy Notice",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 12, right: 12),
                child: Text(
                  "- Cloud Photos will collect user photos and upload to server",
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 12, right: 12),
                child: Text(
                  "- Photos will not be automatically removed until further user request",
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 12, right: 12),
                child: Text(
                  "- Cloud Photos will never sell user uploaded Photos",
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 4),
                      child: CupertinoSwitch(
                          value: first,
                          onChanged: (bool value) {
                            setState(() {
                              first = value;
                              error = false;
                            });
                          }),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          "I agree to backup my photos to Cloud Photos",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 4),
                      child: CupertinoSwitch(
                          value: second,
                          onChanged: (bool value) {
                            setState(() {
                              second = value;
                              error = false;
                            });
                          }),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          "I understand and agree that photos will be uploaded and stored in Cloud Photos server",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              CupertinoButton(
                  child: Text(
                    "Privacy Policy",
                    style: TextStyle(color: Constant.CloudPhotosGrey),
                  ),
                  onPressed: () async {
                    await launch("https://www.cloudphotos.net/#/privacy");
                  }),
              CupertinoButton(
                  child: Text("Accept & Continue"),
                  onPressed: () {
                    if (first && second) {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                        return SignUpScreen();
                      }));
                    } else {
                      setState(() {
                        error = true;
                      });
                    }
                  }),
              Visibility(
                  visible: error,
                  child: Text(
                    "Please agree to all user consents to continue",
                    style: TextStyle(color: CupertinoColors.systemRed),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
