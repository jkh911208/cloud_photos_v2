import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_photos_v2/api.dart';
import 'package:cloud_photos_v2/constant.dart';
import 'package:cloud_photos_v2/database.dart';
import 'package:cloud_photos_v2/library_management.dart';
import 'package:cloud_photos_v2/screen/main/single_video.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:exif/exif.dart';

class SingleViewScreen extends StatefulWidget {
  final int index;
  final List<Map<String, dynamic>> photos;
  late final PageController pageController;
  final String baseUrl;
  final String secret;
  final String token;
  final Function updatePhotosState;

  SingleViewScreen(
      {Key? key,
      required this.updatePhotosState,
      required this.index,
      required this.photos,
      required this.secret,
      required this.baseUrl,
      required this.token})
      : super(key: key) {
    pageController = PageController(initialPage: index);
  }

  @override
  _SingleViewScreenState createState() =>
      _SingleViewScreenState(currentPosition: index, photos: photos);
}

class _SingleViewScreenState extends State<SingleViewScreen> {
  int currentPosition;
  List<Map<String, dynamic>> photos;
  TransformationController _transformationController =
      TransformationController();
  ScrollPhysics _pageViewPsysics = PageScrollPhysics();

  _SingleViewScreenState(
      {required this.photos, required this.currentPosition}) {
    _transformationController.addListener(() {
      if (_transformationController.value[0] != 1.0 &&
          _transformationController.value[5] != 1.0 &&
          _transformationController.value[10] != 1.0 &&
          _pageViewPsysics is PageScrollPhysics) {
        setState(() {
          _pageViewPsysics = NeverScrollableScrollPhysics();
        });
      } else if (_transformationController.value[0] == 1.0 &&
          _transformationController.value[5] == 1.0 &&
          _transformationController.value[10] == 1.0 &&
          _pageViewPsysics is NeverScrollableScrollPhysics) {
        setState(() {
          _pageViewPsysics = PageScrollPhysics();
        });
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CupertinoColors.black,
        body: FutureBuilder(
          future: buildPageView(context),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return snapshot.data;
            }
            return Center(
              child: CupertinoActivityIndicator(),
            );
          },
        ));
  }

  Future<Widget> buildPageView(BuildContext context) async {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          PageView.builder(
              physics: _pageViewPsysics,
              onPageChanged: (int newPosition) {
                setState(() {
                  currentPosition = newPosition;
                });
              },
              controller: widget.pageController,
              allowImplicitScrolling: true, // allows caching next page
              itemCount: photos.length,
              itemBuilder: (_, position) {
                return FutureBuilder(
                    future: buildSingleView(position),
                    builder: (_, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return InteractiveViewer(
                          transformationController: _transformationController,
                          child: GestureDetector(
                            onDoubleTap: () {
                              if (_transformationController.value !=
                                  Matrix4.identity()) {
                                _transformationController.value =
                                    Matrix4.identity();
                              } else {
                                _transformationController.value = Matrix4(
                                  2.5,
                                  0,
                                  0,
                                  0,
                                  0,
                                  2.5,
                                  0,
                                  0,
                                  0,
                                  0,
                                  2.5,
                                  0,
                                  -250,
                                  -500,
                                  0,
                                  1,
                                );
                              }
                            },
                            child: snapshot.data,
                          ),
                          maxScale: 5,
                          minScale: 1,
                        );
                      }
                      return Center(
                        child: CupertinoActivityIndicator(),
                      );
                    });
              }),
          assetDetails(),
          await buildFooter(context)
        ],
      ),
    );
  }

  Widget assetDetails() {
    IconData _currentIcon = Icons.cloud_done_outlined;
    if (photos[currentPosition]["localId"] == null) {
      _currentIcon = Icons.cloud_download_outlined;
    } else if (photos[currentPosition]["localId"] != null &&
        photos[currentPosition]["cloudId"] == null) {
      if (photos[currentPosition]["createDateTime"] >
          DateTime.now().subtract(Duration(days: 7)).millisecondsSinceEpoch) {
        _currentIcon = Icons.cloud_upload_outlined;
      } else {
        _currentIcon = Icons.cloud_off_outlined;
      }
    }
    if (photos[currentPosition]["duration"] > 0) {
      _currentIcon = Icons.cloud_off_outlined;
    }

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  DateTime.fromMillisecondsSinceEpoch(
                          photos[currentPosition]["createDateTime"])
                      .toString()
                      .substring(0, 16),
                  style: TextStyle(color: CupertinoColors.white),
                ),
              ),
              Icon(
                _currentIcon,
                size: 20,
                color: CupertinoColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Widget> buildSingleView(int position) async {
    if (photos[position]["localId"] != null) {
      AssetEntity? asset =
          await AssetEntity.fromId(photos[position]["localId"]);
      if (asset != null) {
        File? file = await asset.file;
        if (file != null) {
          if (photos[position]["duration"] == 0) {
            return Image.file(file);
          } else {
            return SingleVideo(
                currentPage: position,
                file: file,
                pageController: widget.pageController);
          }
        }
      }
      return Center(
        child: CupertinoActivityIndicator(),
      );
    }
    String cloudId = photos[position]["cloudId"];
    return CachedNetworkImage(
      imageUrl: "${widget.baseUrl}/api/v1/photo/$cloudId-resize.jpeg",
      fit: BoxFit.contain,
      cacheKey: "$cloudId-resize",
      errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return Center(
            child: CircularProgressIndicator(value: downloadProgress.progress));
      },
      httpHeaders: {
        "Authorization": "Bearer ${widget.token}",
        "X-Custom-Auth": issueJwtHS256(
            JwtClaim(otherClaims: {
              "timestamp": DateTime.now().millisecondsSinceEpoch
            }),
            widget.secret)
      },
    );
  }

  Future<Widget> buildFooter(BuildContext context) async {
    return Align(
      child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CupertinoButton(
                onPressed: () async {
                  if (photos[currentPosition]["localId"] != null) {
                    // local image
                    AssetEntity? asset = await AssetEntity.fromId(
                        photos[currentPosition]["localId"]);
                    if (asset != null) {
                      File? _file = await asset.file;
                      if (_file != null) {
                        await Share.shareFiles([_file.path]);
                      }
                    }
                  } else {
                    // network image get from cache
                    var file = await DefaultCacheManager().getFileFromCache(
                        "${photos[currentPosition]["cloudId"]}-resize");
                    if (file != null) {
                      Share.shareFiles([file.file.path]);
                    }
                  }
                },
                child: Icon(
                  CupertinoIcons.share,
                  size: 30,
                  color: CupertinoColors.white,
                ),
              ),
              CupertinoButton(
                onPressed: () async {
                  File? _file;
                  if (photos[currentPosition]["localId"] != null) {
                    AssetEntity? asset = await AssetEntity.fromId(
                        photos[currentPosition]["localId"]);
                    if (asset != null) {
                      _file = await asset.file;
                    }
                  } else {
                    var tempFile = await DefaultCacheManager().getFileFromCache(
                        "${photos[currentPosition]["cloudId"]}-resize");
                    if (tempFile != null) {
                      _file = tempFile.file;
                    }
                  }
                  final data = await readExifFromFile(_file);
                  String width = data["Image ImageWidth"].toString();
                  String height = data["Image ImageLength"].toString();
                  String make = data["Image Make"].toString();
                  String model = data["Image Model"].toString();
                  int fileLength = await _file!.length();
                  String size = (fileLength / 1024 / 1024).toStringAsFixed(2);
                  String datetime = data["Image DateTime"].toString();

                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: MediaQuery.of(context).size.height / 2,
                          decoration:
                              BoxDecoration(color: CupertinoColors.black),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: datetime != "null",
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      datetime,
                                      style: TextStyle(
                                          color: Constant.CloudPhotosGrey),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: datetime != "null",
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    child: Divider(
                                      color: Constant.CloudPhotosGrey,
                                    ),
                                  ),
                                ),
                                Text(
                                  "Details",
                                  style: TextStyle(
                                      color: Constant.CloudPhotosGrey),
                                ),
                                ListTile(
                                  leading: Icon(
                                    CupertinoIcons.photo,
                                    color: Constant.CloudPhotosGrey,
                                  ),
                                  title: Text(
                                    "$width x $height $size MB",
                                    style: TextStyle(
                                        color: Constant.CloudPhotosGrey),
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(
                                    CupertinoIcons.camera,
                                    color: Constant.CloudPhotosGrey,
                                  ),
                                  title: Text(
                                    "$make $model",
                                    style: TextStyle(
                                        color: Constant.CloudPhotosGrey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: Icon(
                  CupertinoIcons.info_circle,
                  size: 30,
                  color: CupertinoColors.white,
                ),
              ),
              CupertinoButton(
                onPressed: () async {
                  // alert user deleting file
                  bool delete = true;
                  if (photos[currentPosition]["localId"] == null) {
                    delete = await _confirmDeleteDialog();
                  }
                  if (delete) {
                    print(delete);
                    // remove from local db and local storage
                    bool locallyDeleted =
                        await deleteSigleAsset(photos[currentPosition]);
                    if (locallyDeleted == false) {
                      return;
                    }

                    // remove from cloud if cloudId exist
                    if (photos[currentPosition]["cloudId"] != null) {
                      await Api().delete(
                          "/api/v1/photo/${photos[currentPosition]["cloudId"]}");
                    }

                    // update state
                    widget.updatePhotosState();
                    var newAsset = await MediaTable().selectAll();
                    setState(() {
                      photos = newAsset;
                    });
                  } else {
                    return;
                  }
                },
                child: Icon(
                  CupertinoIcons.trash,
                  size: 30,
                  color: CupertinoColors.white,
                ),
              ),
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Icon(
                  CupertinoIcons.back,
                  size: 30,
                  color: CupertinoColors.white,
                ),
              )
            ],
          ),
          color: CupertinoColors.black,
          height: 60,
          width: double.infinity),
      alignment: Alignment(0, 1),
    );
  }

  Future<bool> _confirmDeleteDialog() async {
    bool decision = false;
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Deleting Photo',
              style: TextStyle(color: CupertinoColors.destructiveRed),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('Photo will be deleted from both device and cloud'),
                  Text('Do you still want to delete it?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  decision = false;
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(color: CupertinoColors.destructiveRed),
                ),
                onPressed: () {
                  decision = true;
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });

    return decision;
  }
}
