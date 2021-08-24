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
import 'package:package_info/package_info.dart';

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
      leading: Container(),
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
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

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
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return LoadingScreen();
                }));
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                  "Version: ${packageInfo.version}+${packageInfo.buildNumber}"),
            ),
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
                  child: Stack(
                    children: [
                      Positioned.fill(child: thumbnailBuilder(index)),
                      isVideo(index),
                      uploadStatus(index)
                    ],
                  ));
            }),
      ),
    );
  }

  Widget uploadStatus(int index) {
    IconData _currentIcon = Icons.cloud_done_outlined;
    Color _color = CupertinoColors.activeGreen;

    if (photos[index]["localId"] == null) {
      // downloaded from cloud
      _currentIcon = Icons.cloud_download_outlined;
      _color = CupertinoColors.activeBlue;
    } else if (photos[index]["localId"] != null &&
        photos[index]["cloudId"] == null) {
      if (photos[index]["createDateTime"] >
          DateTime.now().subtract(Duration(days: 7)).millisecondsSinceEpoch) {
        // pending upload
        _currentIcon = Icons.cloud_upload_outlined;
        _color = CupertinoColors.activeOrange;
      } else {
        // older than 7 days
        _currentIcon = Icons.cloud_off_outlined;
        _color = CupertinoColors.black;
      }
    }
    if (photos[index]["duration"] > 0) {
      // video
      _currentIcon = Icons.cloud_off_outlined;
      _color = CupertinoColors.black;
    }

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Icon(
          _currentIcon,
          size: 20,
          color: _color,
        ),
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
              "timestamp": DateTime.now().millisecondsSinceEpoch
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
        return Image.memory(
          thumbnail,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
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
            width: MediaQuery.of(context).size.width / 4 * 0.55,
            decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Row(children: [
              Icon(CupertinoIcons.play, color: CupertinoColors.black, size: 15),
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
    List<Map<String, dynamic>> assetList = await mediaTable.selectAll();
    setState(() {
      photos = assetList;
    });

    // get new data from cloud
    await getFromCloud();
    assetList = await mediaTable.selectAll();
    setState(() {
      photos = assetList;
    });

    // upload new data to cloud
    await uploadPendingAssets();
    assetList = await mediaTable.selectAll();
    setState(() {
      photos = assetList;
    });
  }
}
