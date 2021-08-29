import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_photos_v2/api.dart';
import 'package:cloud_photos_v2/database.dart';
import 'package:cloud_photos_v2/library_management.dart';
import 'package:cloud_photos_v2/screen/main/single_video.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

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

  _SingleViewScreenState({required this.photos, required this.currentPosition});

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
    TransformationController _transformationController =
        TransformationController();
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          PageView.builder(
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
          buildFooter(context)
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
                file: file, pageController: widget.pageController);
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
      placeholder: (context, url) =>
          Center(child: CupertinoActivityIndicator()),
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

  Widget buildFooter(BuildContext context) {
    return Align(
      child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CupertinoButton(
                onPressed: () {},
                child: Icon(
                  CupertinoIcons.share,
                  size: 30,
                  color: CupertinoColors.white,
                ),
              ),
              CupertinoButton(
                onPressed: () {},
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
