import 'dart:io';
import 'package:cloud_photos_v2/screen/main/single_photo.dart';
import 'package:cloud_photos_v2/screen/main/single_video.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class SingleViewScreen extends StatelessWidget {
  final int index;
  final List<Map<String, dynamic>> photos;
  late final PageController pageController;

  SingleViewScreen({Key? key, required this.index, required this.photos})
      : super(key: key) {
    pageController = PageController(initialPage: index);
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
    return Stack(children: [
      SafeArea(
        child: PageView.builder(
            controller: pageController,
            allowImplicitScrolling: true, // allows caching next page
            itemCount: photos.length,
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
      ),
      customFooter(context)
    ]);
  }

  Future<Widget> buildSingleView(int position) async {
    if (photos[position]["localId"] != null) {
      AssetEntity? asset =
          await AssetEntity.fromId(photos[position]["localId"]);
      if (asset != null) {
        File? file = await asset.file;
        if (file != null) {
          if (photos[position]["duration"] == 0) {
            return SinglePhoto(file: file);
          } else {
            return SingleVideo(file: file, pageController: pageController);
          }
        }
      }
    }
    return Center(
      child: Text(
        "$position",
        style: TextStyle(color: CupertinoColors.activeBlue),
      ),
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
                  print(pageController.page);
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
