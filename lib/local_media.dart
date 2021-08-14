import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';
import 'package:cloud_photos_v2/util.dart';
import 'package:cloud_photos_v2/database.dart';

Future updateEntireLibrary() async {
  MediaTable mediaTable = new MediaTable();
  List<AssetPathEntity> album = await PhotoManager.getAssetPathList();
  for (var i = 0; i < album.length; i++) {
    final assetList =
        await album[0].getAssetListRange(start: 0, end: album[0].assetCount);
    for (var j = 0; j < assetList.length; j++) {
      AssetEntity entity = assetList[j];
      var file = await entity.file;
      if (file == null) {
        continue;
      }

      Uint8List? thumbData = await entity.thumbData;
      if (thumbData == null) {
        continue;
      }

      await mediaTable.insert(Media(
          md5: await getMD5FromFile(file),
          duration: entity.duration,
          createDateTime: entity.createDtSecond!,
          modifiedDateTime: entity.modifiedDateSecond!,
          cloudId: null,
          width: entity.width,
          height: entity.height,
          uri: file.path,
          thumbnailUri: null,
          thumbnail: thumbData,
          localId: entity.id));
    }
  }
}
