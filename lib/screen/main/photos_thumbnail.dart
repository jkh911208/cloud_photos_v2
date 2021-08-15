import 'dart:io';

import 'package:cloud_photos_v2/constant.dart';
import 'package:cloud_photos_v2/screen/main/photos_single_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ThumbnailScreen extends StatelessWidget {
  const ThumbnailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: Constant.CloudPhotosGrey, child: ThumbnailBody());
  }
}

class ThumbnailBody extends StatefulWidget {
  const ThumbnailBody({Key? key}) : super(key: key);

  @override
  _ThumbnailBodyState createState() => _ThumbnailBodyState();
}

class _ThumbnailBodyState extends State<ThumbnailBody> {
  List<AssetEntity> photos = [];
  List<Widget> singleViewPhotos = [];

  _ThumbnailBodyState() {
    getAllMedia();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: GridView.builder(
          // gridDelegate: SliverGridDelegate(cross),
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
          itemCount: photos.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: const EdgeInsets.all(1),
                child: AssetThumbnail(
                  asset: photos,
                  index: index,
                  singleViewPhotos: singleViewPhotos,
                ));
          }),
    );
  }

  Future<void> getAllMedia() async {
    List<AssetPathEntity> albums =
        await PhotoManager.getAssetPathList(onlyAll: true);
    AssetPathEntity album = albums.first;

    final assetList =
        await album.getAssetListRange(start: 0, end: album.assetCount);

    setState(() {
      photos = assetList;
    });

    // List<Widget> tempList = [];
    // int length = assetList.length;
    // for (var i = 0; i < assetList.length; i++) {
    //   var first = DateTime.now().millisecondsSinceEpoch;
    //   File? file = await assetList[i].file;
    //   print("file load");
    //   print(DateTime.now().millisecondsSinceEpoch - first);
    //   if (file == null) {
    //     continue;
    //   }
    //   print("$i out of $length");
    //   var second = DateTime.now().millisecondsSinceEpoch;
    //   tempList.add(Image.file(file));
    //   print("add to list");
    //   print(DateTime.now().millisecondsSinceEpoch - second);
    // }
    // setState(() {
    //   singleViewPhotos = tempList;
    // });

    // print("finish set single view photos");
  }
}

class AssetThumbnail extends StatelessWidget {
  final List<AssetEntity> asset;
  final int index;
  final List<Widget> singleViewPhotos;

  AssetThumbnail(
      {required this.asset,
      required this.index,
      required this.singleViewPhotos});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: asset[index].thumbData,
        builder: (context, AsyncSnapshot snapshot) {
          final bytes = snapshot.data;
          if (snapshot.hasData)
            return GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true)
                      .push(CupertinoPageRoute(
                          fullscreenDialog: true,
                          builder: (context) {
                            return SingleViewScreen(
                                asset: asset,
                                photos: singleViewPhotos,
                                index: index);
                          }));
                },
                child: Stack(children: [
                  Positioned.fill(
                      child: Image.memory(bytes, fit: BoxFit.cover)),
                  isVideo(asset[index])
                ]));
          return CircularProgressIndicator();
        });
  }

  Widget isVideo(AssetEntity asset) {
    if (asset.duration > 0) {
      return Center(
          child: Icon(
        CupertinoIcons.play,
        color: CupertinoColors.systemRed,
      ));
    }
    return Container();
  }
}
