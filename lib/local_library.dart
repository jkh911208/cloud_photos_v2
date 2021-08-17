import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:cloud_photos_v2/database.dart';

Future updateEntireLibrary() async {
  final MediaTable mediaTable = new MediaTable();
  final int biggestmodified = await mediaTable.selectBiggstModifiedDateTime();

  final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      filterOption: FilterOptionGroup(
          orders: [OrderOption(asc: true, type: OrderOptionType.updateDate)],
          updateTimeCond: DateTimeCond(
              min: DateTime.fromMillisecondsSinceEpoch(biggestmodified * 1000),
              max: DateTime.now())));
  final AssetPathEntity album = albums.first;
  final List<AssetEntity> assetList =
      await album.getAssetListRange(start: 0, end: album.assetCount);

  assetList.forEach((asset) {
    final String epoch = asset.createDtSecond.toString();
    final String id = asset.id;
    final List<int> bytes = utf8.encode("CloudPhotos,id:$id,epoch:$epoch");
    final String md5Digest = md5.convert(bytes).toString();

    mediaTable.insert({
      "md5": md5Digest,
      "duration": asset.duration,
      "createDateTime": asset.createDtSecond,
      "modifiedDateTime": asset.modifiedDateSecond,
      "cloudId": null,
      "localId": asset.id
    });
  });
}
