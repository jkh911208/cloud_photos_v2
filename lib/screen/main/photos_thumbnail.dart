import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_photos_v2/api.dart';
import 'package:cloud_photos_v2/constant.dart';
import 'package:cloud_photos_v2/database.dart';
import 'package:cloud_photos_v2/library_management.dart';
import 'package:cloud_photos_v2/screen/loading.dart';
import 'package:cloud_photos_v2/screen/main/photos_single_view.dart';
import 'package:cloud_photos_v2/storage.dart';
import 'package:cloud_photos_v2/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
  late StreamSubscription<FGBGType> subscription;
  Set<int> selected = Set();
  bool showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    getAllMedia();
    updateData();
    subscription = FGBGEvents.stream.listen((event) {
      if (event == FGBGType.foreground) {
        print("back to foreground");
        getAllMedia();
        updateData();
      }
    });
    scrollController
      ..addListener(() {
        if (scrollController.offset >= 200 && showScrollToTop == false) {
          setState(() {
            showScrollToTop = true;
          });
        } else if (scrollController.offset < 200 && showScrollToTop == true) {
          setState(() {
            showScrollToTop = false;
          });
        }
      });
  }

  @override
  void dispose() {
    subscription.cancel();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureBuilder(context),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return snapshot.data;
        }
        return Container();
      },
    );
  }

  Future<Widget> _futureBuilder(BuildContext context) async {
    return Scaffold(
        key: scaffoldKey,
        appBar: await buildAppBar(context),
        backgroundColor: CupertinoColors.black,
        body: thumbnailBody(),
        endDrawer: await buildEndDrawer());
  }

  Future<CupertinoNavigationBar> buildAppBar(BuildContext context) async {
    if (selected.length > 0) {
      return CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () async {
                  List<Map<String, dynamic>> data = [];
                  for (var i = 0; i < selected.length; i++) {
                    int index = selected.elementAt(i);
                    data.add(photos[index]);
                  }
                  List<String> paths = [];
                  for (var i = 0; i < data.length; i++) {
                    if (data[i]["localId"] != null) {
                      // if local file get path from asset file
                      AssetEntity? asset =
                          await AssetEntity.fromId(data[i]["localId"]);
                      if (asset != null) {
                        File? file = await asset.file;
                        if (file != null) {
                          paths.add(file.path);
                        }
                      }
                    } else {
                      // if cloud get cache
                      var file = await DefaultCacheManager()
                          .getFileFromCache("${data[i]["cloudId"]}-resize");
                      if (file != null) {
                        paths.add(file.file.path);
                      } else {
                        var fileInfo = await DefaultCacheManager().downloadFile(
                            "$baseUrl/api/v1/photo/${data[i]["cloudId"]}-resize.jpeg",
                            key: "${data[i]["cloudId"]}-resize",
                            authHeaders: {
                              "Authorization": "Bearer $token",
                              "X-Custom-Auth": issueJwtHS256(
                                  JwtClaim(otherClaims: {
                                    "timestamp":
                                        DateTime.now().millisecondsSinceEpoch
                                  }),
                                  secret)
                            });
                        paths.add(fileInfo.file.path);
                      }
                    }
                  }
                  print(paths);
                  Share.shareFiles(paths);
                },
                child: Icon(CupertinoIcons.share,
                    color: CupertinoColors.white, size: 25),
              ),
            ),
            GestureDetector(
                onTap: () async {
                  print("delete all slected");
                  print(selected);
                  bool decision = await customDialog(
                      context,
                      "Delete ${selected.length} selected photos",
                      "Photos will be removed from both device and Cloud",
                      "Do you still want to remove all ${selected.length} photos?",
                      "Delete");
                  if (decision) {
                    // build list
                    List<Map<String, dynamic>> data = [];
                    for (var i = 0; i < selected.length; i++) {
                      int index = selected.elementAt(i);
                      data.add(photos[index]);
                    }
                    //delete from device
                    int locallyDeleted = await deleteMultipleAssets(data);

                    // delete from cloud
                    int cloudDeleted = 0;
                    for (var i = 0; i < data.length; i++) {
                      if (data[i]["cloudId"] != null) {
                        Map<String, dynamic> result = await Api()
                            .delete("/api/v1/photo/${data[i]["cloudId"]}");
                        if (result["statudCode"] == 200) {
                          cloudDeleted++;
                        }
                      }
                    }
                    setState(() {
                      selected = Set();
                    });
                    await updatePhotosState();
                    Fluttertoast.showToast(
                        msg:
                            "Deleted $locallyDeleted photos locally and $cloudDeleted on Cloud",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 2,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
                child: Icon(CupertinoIcons.delete,
                    color: CupertinoColors.white, size: 25)),
          ],
        ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  selected = Set();
                });
              },
              child: Icon(CupertinoIcons.xmark,
                  color: CupertinoColors.white, size: 25),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  "${selected.length}",
                  style: TextStyle(color: CupertinoColors.white, fontSize: 23),
                ))
          ],
        ),
      );
    }
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
    return Stack(
      children: [
        SafeArea(
          bottom: false,
          child: DraggableScrollbar.rrect(
            labelTextBuilder: (double offset) {
              int currentLine = offset ~/ 100;
              List<String> date = DateTime.fromMillisecondsSinceEpoch(
                      photos[currentLine * 4]["createDateTime"])
                  .toString()
                  .split("-");
              try {
                return Text(date[1] + "/" + date[0]);
              } on Exception {
                return Text("N/A");
              }
            },
            scrollbarTimeToFade: Duration(seconds: 5),
            controller: scrollController,
            child: GridView.builder(
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
                controller: scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4),
                itemCount: photos.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                      onLongPress: () {
                        if (selected.length == 0) {
                          selected.add(index);
                          setState(() {
                            selected = selected;
                          });
                          HapticFeedback.heavyImpact();
                        }
                        print(selected);
                      },
                      onTap: () {
                        if (selected.length > 0) {
                          if (selected.contains(index)) {
                            selected.remove(index);
                            setState(() {
                              selected = selected;
                            });
                          } else {
                            selected.add(index);
                            setState(() {
                              selected = selected;
                            });
                          }
                          HapticFeedback.heavyImpact();
                        } else {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return SingleViewScreen(
                                index: index,
                                photos: photos,
                                baseUrl: baseUrl,
                                secret: secret,
                                token: token,
                                updatePhotosState: updatePhotosState);
                          }));
                        }
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width:
                                            selected.contains(index) ? 10 : 0,
                                        color: CupertinoColors.white),
                                  ),
                                  child: thumbnailBuilder(index))),
                          isVideo(index),
                          uploadStatus(index),
                          isSelected(index)
                        ],
                      ));
                }),
          ),
        ),
        Visibility(
          visible: showScrollToTop,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: GestureDetector(
                onTap: () {
                  scrollController.animateTo(0,
                      duration: Duration(seconds: 2),
                      curve: Curves.fastLinearToSlowEaseIn);
                },
                child: Container(
                  width: 150,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Constant.CloudPhotosYellow,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Center(child: Text("Scroll Back to Top")),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget isSelected(int index) {
    if (selected.contains(index)) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Icon(
              CupertinoIcons.check_mark,
              size: 20,
            ),
          ),
        ),
      );
    }
    return Container();
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

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Align(
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
    return CachedNetworkImage(
      imageUrl: "$baseUrl/api/v1/photo/$cloudId-thumbnail.jpeg",
      fit: BoxFit.cover,
      cacheKey: "$cloudId-thumbnail",
      placeholder: (context, url) =>
          Center(child: CupertinoActivityIndicator()),
      httpHeaders: {
        "Authorization": "Bearer $token",
        "X-Custom-Auth": issueJwtHS256(
            JwtClaim(otherClaims: {
              "timestamp": DateTime.now().millisecondsSinceEpoch
            }),
            secret)
      },
    );
  }

  Future<Widget> localThumbnailBuilder(int index) async {
    String id = photos[index]["localId"];
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

  Future<void> updatePhotosState() async {
    List<Map<String, dynamic>> assetList = await mediaTable.selectAll();
    setState(() {
      photos = assetList;
    });
  }

  Future<void> getAllMedia() async {
    await updateEntireLibrary();
    await updatePhotosState();

    // get new data from cloud
    await getFromCloud();
    await updatePhotosState();

    // upload new data to cloud
    int numUpload = await uploadPendingAssets();
    if (numUpload > 0) {
      await updatePhotosState();
    }
  }
}
