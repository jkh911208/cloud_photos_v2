import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_photos_v2/api.dart';
import 'package:cloud_photos_v2/database.dart';
import 'package:cloud_photos_v2/library_management.dart';
import 'package:cloud_photos_v2/screen/loading.dart';
import 'package:cloud_photos_v2/screen/main/photos_single_view.dart';
import 'package:cloud_photos_v2/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

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
  final MediaTable mediaTable = new MediaTable();
  final Api api = Api();
  String baseUrl = dotenv.get('API_URL', fallback: 'http://localhost');
  String secret = dotenv.get('SECRET', fallback: 'yoursecret');
  String token = "";

  _ThumbnailScreenState() {
    getAllMedia();
    updateData();
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
                      await setWifiOnly(value);
                      setState(() {
                        wifiOnly = value;
                      });
                    }),
                title: Text('Upload on Wifi Only ')),
            Divider(),
            ListTile(
              title: Text("Sign Out"),
              onTap: () async {
                // delete local store
                await storage.deleteAll();

                // delete all data in db
                await mediaTable.truncateTable();

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
              return GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return SingleViewScreen(
                        index: index,
                        photos: photos,
                        baseUrl: baseUrl,
                        secret: secret,
                        token: token,
                      );
                    }));
                  },
                  child: thumbnailBuilder(index));
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
    return FutureBuilder(
        future: cloudThumbnailBuilder(index),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return snapshot.data;
          }
          return Center(
            child: CupertinoActivityIndicator(),
          );
        });
  }

  Future<Widget> cloudThumbnailBuilder(int index) async {
    String cloudId = photos[index]["cloudId"];
    return Image.network(
      "$baseUrl/api/v1/photo/$cloudId-thumbnail.jpeg",
      headers: {
        "Authorization": "Bearer $token",
        "X-Custom-Auth": issueJwtHS256(
            JwtClaim(otherClaims: {
              "requested_time": DateTime.now().millisecondsSinceEpoch.toString()
            }),
            secret)
      },
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );
  }

  Future<Widget> localThumbnailBuilder(int index) async {
    String id = photos[index]["localId"];
    // print(photos[index]);
    AssetEntity? asset = await AssetEntity.fromId(id);
    if (asset != null) {
      Uint8List? thumbnail = await asset.thumbData;
      if (thumbnail != null) {
        return Stack(children: [
          Positioned.fill(
              child: Image.memory(
            thumbnail,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          )),
          isVideo(index)
        ]);
      }
    }
    return Container();
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

  Future<void> updateData() async {
    final bool _wifiOnly = await getWifiOnly();
    setState(() {
      wifiOnly = _wifiOnly;
    });
    String? _token = await storage.read(key: "token");
    if (_token != null) {
      token = _token;
    }
  }

  Future<void> getAllMedia() async {
    await updateEntireLibrary();
    print("get all media");
    final List<Map<String, dynamic>> assetList = await mediaTable.selectAll();

    setState(() {
      photos = assetList;
    });

    // get new data from cloud
    await getFromCloud();

    // set state if new data downloaded
    final List<Map<String, dynamic>> assetListAfterDownload =
        await mediaTable.selectAll();
    if (assetList.length != assetListAfterDownload.length) {
      print("new data downloaded from cloud");
      setState(() {
        photos = assetListAfterDownload;
      });
      assetListAfterDownload.forEach((element) {
        if (element["localId"] == null) {
          print(element);
        }
      });
    }

    // upload new data to cloud
    int numberOfUpload = await uploadPendingAssets();
    print("uploaded $numberOfUpload photos to cloud");
  }
}
