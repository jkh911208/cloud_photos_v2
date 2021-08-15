import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';
import 'package:cloud_photos_v2/util.dart';
import 'package:cloud_photos_v2/database.dart';

Future updateEntireLibrary() async {
  MediaTable mediaTable = new MediaTable();
  List<AssetPathEntity> albums =
      await PhotoManager.getAssetPathList(onlyAll: true);
  AssetPathEntity album = albums.first;

  final assetList =
      await album.getAssetListRange(start: 0, end: album.assetCount);
  for (var j = 0; j < assetList.length; j++) {
    AssetEntity entity = assetList[j];
    var file = await entity.file;

    
    if (file == null) {
      print("continue due to file is null");
      continue;
    }

    if (entity.duration > 0) {
      print("passing the video for now");
      continue;
    }

    Uint8List? thumbData = await entity.thumbDataWithSize(300, 300);
    if (thumbData == null) {
      print("continue due to thumbdata is null");
      continue;
    }

    var second = DateTime.now().millisecondsSinceEpoch;
    mediaTable.insert(Media(
        md5: await getMD5FromUint8List(thumbData),
        duration: entity.duration,
        createDateTime: entity.createDtSecond!,
        modifiedDateTime: entity.modifiedDateSecond!,
        cloudId: null,
        width: entity.width,
        height: entity.height,
        uri: file.path.toString(),
        thumbnailUri: null,
        thumbnail: null,
        localId: entity.id));
    print("time for insert");
    print(DateTime.now().millisecondsSinceEpoch - second);
  }
}
