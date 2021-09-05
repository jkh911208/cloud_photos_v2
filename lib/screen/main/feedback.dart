import 'package:cloud_photos_v2/api.dart';
import 'package:cloud_photos_v2/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FeedBackScreen extends StatefulWidget {
  const FeedBackScreen({Key? key}) : super(key: key);

  @override
  _FeedBackScreenState createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> {
  String feedback = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: buildFeedBackScreen(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return snapshot.data;
        }
        return Container();
      },
    );
  }

  Future<Widget> buildFeedBackScreen() async {
    return Scaffold(
      backgroundColor: Constant.CloudPhotosYellow,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Give Feedback"),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (String value) {
                    if (error.length > 0) {
                      setState(() {
                        error = "";
                      });
                    }
                    setState(() {
                      feedback = value;
                    });
                  },
                  maxLines: null,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      "${feedback.length}/1000",
                      style: TextStyle(
                          color: feedback.length > 1000
                              ? CupertinoColors.systemRed
                              : CupertinoColors.black),
                    ),
                  )
                ],
              ),
              TextButton(
                  onPressed: () async {
                    if (feedback.length == 0) {
                      setState(() {
                        error = "Please enter your feedback";
                      });
                    } else if (feedback.length > 1000) {
                      setState(() {
                        error = "Feedback is too long";
                      });
                    } else {
                      Api().post("/api/v1/feedback", {'feedback': feedback});
                      Fluttertoast.showToast(
                          msg: "Thank you for your feedback",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 2,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("Submit")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: CupertinoColors.systemRed),
                  )),
              Visibility(
                  visible: error.length > 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      "$error",
                      style: TextStyle(color: CupertinoColors.systemRed),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
