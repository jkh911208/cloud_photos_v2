import 'package:cloud_photos_v2/constant.dart';
import 'package:cloud_photos_v2/screen/main/main_nav.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InitConfigScreen extends StatelessWidget {
  const InitConfigScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Constant.CloudPhotosYellow,
      child: InitConfigBody(),
    );
  }
}

class InitConfigBody extends StatefulWidget {
  const InitConfigBody({Key? key}) : super(key: key);

  @override
  _InitConfigBodyState createState() => _InitConfigBodyState();
}

class _InitConfigBodyState extends State<InitConfigBody> {
  bool wifiOnly = true;
  final storage = new FlutterSecureStorage();

  _InitConfigBodyState() {
    setConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Icon(
              CupertinoIcons.settings,
              color: CupertinoColors.black,
              size: 120,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 4),
                  child: CupertinoSwitch(
                      value: wifiOnly,
                      onChanged: (bool value) {
                        setState(() {
                          wifiOnly = value;
                        });
                      }),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      "Upload Photos using wifi only",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
              child: Text("Accept & Continue"),
              onPressed: () async {
                setConfig();
                Navigator.of(context)
                    .pushReplacement(CupertinoPageRoute(builder: (context) {
                  return MainNav();
                }));
              }),
        ],
      )),
    );
  }

  Future<void> setConfig() async {
    await storage.write(key: "wifiOnly", value: wifiOnly.toString());
  }
}
