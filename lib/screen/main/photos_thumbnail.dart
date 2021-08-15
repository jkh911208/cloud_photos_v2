import 'package:cloud_photos_v2/constant.dart';
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

  _ThumbnailBodyState() {
    getAllMedia();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4),
          itemCount: photos.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: const EdgeInsets.all(1),
                child: AssetThumbnail(asset: photos, index: index));
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
  }
}

class AssetThumbnail extends StatelessWidget {
  final List<AssetEntity> asset;
  final int index;

  AssetThumbnail({required this.asset, required this.index});

  @override
  Widget build(BuildContext context) {
    // We're using a FutureBuilder since thumbData is a future
    return FutureBuilder(
        future: asset[index].thumbData,
        builder: (context, AsyncSnapshot snapshot) {
          final bytes = snapshot.data;
          // If we have no data, display a spinner
          if (snapshot.hasData)
            // If there's data, display it as an image
            return GestureDetector(
                onTap: () async {
                  if (asset[index].duration > 0) {
                    print("this is video");
                  } else {
                    print("this is photo");
                  }
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
