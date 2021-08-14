import 'package:cloud_photos_v2/constant.dart';
import 'package:cloud_photos_v2/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';
import 'package:path/path.dart';

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
  var photos = [];

  _ThumbnailBodyState() {
    getPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SafeArea(
        child: (photos.length > 0) ? Image.file(File(photos[0])) : Text("1"),
      ),
    );
  }

  Future getPhotos() async {
    List<AssetPathEntity> list = await PhotoManager.getAssetPathList();
    print(list);
    final assetList = await list[0].getAssetListRange(start: 0, end: 88);
    print(assetList);
    AssetEntity entity = assetList[0];
    var file = await entity.file;
    if (file == null) {
      return null;
    }
    print(await file.length());
    print(basename(file.path));
    String md5 = await getMD5FromFile(file);
    print(md5);
    setState(() {
      photos = [file.path.toString()];
    });
  }
}
