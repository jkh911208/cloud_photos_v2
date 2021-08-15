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
    return GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
        itemCount: photos.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
              padding: const EdgeInsets.all(1),
              child: FutureBuilder(
                  future: photos[index].thumbData,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return Image.memory(snapshot.data, fit: BoxFit.cover);
                    }
                    return CircularProgressIndicator();
                  }));
        });
  }

  Future<void> getAllMedia() async {
    //   List<Media> newList = await MediaTable().selectAll();
    //   print(newList[0].uri);
    //   setState(() {
    //     photos = newList;
    //   });
    // }

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
