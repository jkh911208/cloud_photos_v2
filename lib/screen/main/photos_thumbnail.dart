import 'dart:typed_data';
import 'package:cloud_photos_v2/constant.dart';
import 'package:cloud_photos_v2/database.dart';
import 'package:cloud_photos_v2/library_management.dart';
import 'package:cloud_photos_v2/screen/main/photos_single_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

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
  List<Map<String, dynamic>> photos = [];

  _ThumbnailBodyState() {
    getAllMedia();
  }

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    return SafeArea(
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
            Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
                fullscreenDialog: true,
                builder: (context) {
                  return SingleViewScreen(photos: photos, index: index);
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
