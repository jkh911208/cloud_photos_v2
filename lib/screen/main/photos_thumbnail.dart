import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_photos_v2/database.dart';
import 'package:cloud_photos_v2/library_management.dart';
import 'package:cloud_photos_v2/screen/loading.dart';
import 'package:cloud_photos_v2/screen/main/photos_single_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThumbnailScreen extends StatefulWidget {
  const ThumbnailScreen({Key? key}) : super(key: key);

  @override
  _ThumbnailScreenState createState() => _ThumbnailScreenState();
}

class _ThumbnailScreenState extends State<ThumbnailScreen> {
  List<Map<String, dynamic>> photos = [];
  ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool wifiOnly = true;
  final storage = new FlutterSecureStorage();

  _ThumbnailScreenState() {
    getAllMedia();
    updateWifiOnly();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: buildAppBar(),
        backgroundColor: CupertinoColors.black,
        body: thumbnailBody(),
        endDrawer: FutureBuilder(
          future: buildEndDrawer(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return snapshot.data;
            }
            return Container();
          },
        ));
  }

  CupertinoNavigationBar buildAppBar() {
    return CupertinoNavigationBar(
      backgroundColor: CupertinoColors.black,
      trailing: GestureDetector(
          onTap: () {
            setState(() {
              var currentState = scaffoldKey.currentState;
              if (currentState != null) {
                currentState.openEndDrawer();
              }
            });
          },
          child: Icon(Icons.settings, color: CupertinoColors.white, size: 25)),
      middle: Text(
        "Photos",
        style: TextStyle(color: CupertinoColors.white),
      ),
    );
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  Future<Widget> buildEndDrawer() async {
    final token = await storage.read(key: "token");
    String username = "";
    if (token != null) {
      final parts = token.split(".");
      final payload = _decodeBase64(parts[1]);
      final payloadMap = json.decode(payload);
      if (payloadMap.containsKey("username")) {
        username = payloadMap["username"];
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text("Hi! $username"),
            ),
            Divider(),
            ListTile(
                leading: CupertinoSwitch(
                    value: wifiOnly,
                    onChanged: (bool value) async {
                      storage.write(key: "wifiOnly", value: value.toString());
                      setState(() {
                        wifiOnly = value;
                      });
                    }),
                title: Text('Upload on Wifi Only ')),
            Divider(),
            ListTile(
              title: Text("Sign Out"),
              onTap: () async {
                await storage.deleteAll();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return LoadingScreen();
                }));
              },
            )
          ],
        ),
      ),
    );
  }

  Widget thumbnailBody() {
    return SafeArea(
      bottom: false,
      child: DraggableScrollbar.rrect(
        scrollbarTimeToFade: Duration(seconds: 5),
        controller: scrollController,
        child: GridView.builder(
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
            controller: scrollController,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
            itemCount: photos.length,
            itemBuilder: (BuildContext context, int index) {
              return thumbnailBuilder(index);
            }),
      ),
    );
  }

  Widget thumbnailBuilder(int index) {
    if (photos[index]["localId"] != null) {
      return FutureBuilder(
          future: localThumbnailBuilder(index),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return snapshot.data;
            }
            return Center(
              child: CupertinoActivityIndicator(),
            );
          });
    }
    return Text("Cloud data");
  }

  Future<Widget> localThumbnailBuilder(int index) async {
    String id = photos[index]["localId"];
    AssetEntity? asset = await AssetEntity.fromId(id);
    if (asset != null) {
      Uint8List? thumbnail = await asset.thumbData;
      if (thumbnail != null) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return SingleViewScreen(index: index, photos: photos);
            }));
          },
          child: Stack(children: [
            Positioned.fill(
                child: Image.memory(
              thumbnail,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            )),
            isVideo(index)
          ]),
        );
      }
    }
    return Center(
      child: CupertinoActivityIndicator(),
    );
  }

  Widget isVideo(int index) {
    if (photos[index]["duration"] > 0) {
      String min = (photos[index]["duration"] ~/ 60).toString();
      String seconds = photos[index]["duration"].remainder(60).toString();
      if (min.length == 1) {
        min = "0" + min;
      }
      if (seconds.length == 1) {
        seconds = "0" + seconds;
      }
      return Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            child: Row(children: [
              Icon(
                CupertinoIcons.play,
                color: CupertinoColors.black,
              ),
              Text("$min:$seconds")
            ]),
          ));
    }
    return Container();
  }

  Future<void> updateWifiOnly() async {
    final _wifiOnly = await storage.read(key: "wifiOnly");
    if (_wifiOnly != null) {
      if (_wifiOnly == "true") {
        setState(() {
          wifiOnly = true;
        });
        return;
      }

      setState(() {
        wifiOnly = false;
      });
      return;
    }
    setState(() {
      wifiOnly = true;
    });
    return;
  }

  Future<void> getAllMedia() async {
    await updateEntireLibrary();
    print("get all media");
    final MediaTable mediaTable = new MediaTable();
    final List<Map<String, dynamic>> assetList = await mediaTable.selectAll();

    setState(() {
      photos = assetList;
    });

    // get new data from cloud

    // set state if new data downloaded

    // upload new data to cloud
    int numberOfUpload = await uploadPendingAssets();
    print("uploaded $numberOfUpload photos to cloud");
  }
}
