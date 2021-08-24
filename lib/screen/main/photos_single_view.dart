import 'dart:io';
import 'package:cloud_photos_v2/screen/main/single_photo.dart';
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

  SingleViewScreen(
      {Key? key,
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
      _SingleViewScreenState(currentPosition: index);
}

class _SingleViewScreenState extends State<SingleViewScreen> {
  int currentPosition;

  _SingleViewScreenState({required this.currentPosition});

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
          assetDetails(),
          PageView.builder(
              onPageChanged: (int newPosition) {
                setState(() {
                  currentPosition = newPosition;
                });
              },
              controller: widget.pageController,
              allowImplicitScrolling: true, // allows caching next page
              itemCount: widget.photos.length,
              itemBuilder: (_, position) {
                return FutureBuilder(
                    future: buildSingleView(position),
                    builder: (_, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data;
                      }
                      return Center(
                        child: CupertinoActivityIndicator(),
                      );
                    });
              }),
          customFooter(context)
        ],
      ),
    );
  }

  Widget assetDetails() {
    IconData _currentIcon = Icons.cloud_done_outlined;
    if (widget.photos[currentPosition]["localId"] == null) {
      _currentIcon = Icons.cloud_download_outlined;
    } else if (widget.photos[currentPosition]["localId"] != null &&
        widget.photos[currentPosition]["cloudId"] == null) {
      if (widget.photos[currentPosition]["createDateTime"] >
          DateTime.now().subtract(Duration(days: 7)).millisecondsSinceEpoch) {
        _currentIcon = Icons.cloud_upload_outlined;
      } else {
        _currentIcon = Icons.cloud_off_outlined;
      }
    }
    if (widget.photos[currentPosition]["duration"] > 0) {
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
                          widget.photos[currentPosition]["createDateTime"])
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
    if (widget.photos[position]["localId"] != null) {
      AssetEntity? asset =
          await AssetEntity.fromId(widget.photos[position]["localId"]);
      if (asset != null) {
        File? file = await asset.file;
        if (file != null) {
          if (widget.photos[position]["duration"] == 0) {
            return SinglePhoto(file: file);
          } else {
            return SingleVideo(
                file: file, pageController: widget.pageController);
          }
        }
      }
    }
    String cloudId = widget.photos[position]["cloudId"];
    return Image.network(
      "${widget.baseUrl}/api/v1/photo/$cloudId-resize.jpeg",
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "X-Custom-Auth": issueJwtHS256(
            JwtClaim(otherClaims: {
              "timestamp": DateTime.now().millisecondsSinceEpoch
            }),
            widget.secret)
      },
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );
  }

  Widget customFooter(BuildContext context) {
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
                onPressed: () {
                  print(widget.pageController.page);
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
}
