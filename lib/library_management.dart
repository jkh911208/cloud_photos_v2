import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:cloud_photos_v2/api.dart';
import 'package:crypto/crypto.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:cloud_photos_v2/database.dart';

Future<void> updateEntireLibrary() async {
  final MediaTable mediaTable = new MediaTable();
  final int biggestmodified = await mediaTable.selectBiggstModifiedDateTime();
  print("current biggest modified $biggestmodified");

  final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      filterOption: FilterOptionGroup(
          orders: [OrderOption(asc: true, type: OrderOptionType.updateDate)],
          updateTimeCond: DateTimeCond(
              min: DateTime.fromMillisecondsSinceEpoch(biggestmodified),
              max: DateTime.now())));
  final AssetPathEntity album = albums.first;
  if (album.assetCount == 0) {
    return;
  }
  final List<AssetEntity> assetList =
      await album.getAssetListRange(start: 0, end: album.assetCount);

  assetList.forEach((asset) {
    final String epoch =
        asset.modifiedDateTime.millisecondsSinceEpoch.toString();
    print("new modified $epoch");
    final String id = asset.id;
    final List<int> bytes = utf8.encode("CloudPhotos,id:$id,epoch:$epoch");
    final String simpleMD5 = md5.convert(bytes).toString();

    mediaTable.insert({
      "md5": simpleMD5,
      "duration": asset.duration,
      "createDateTime": asset.createDateTime.millisecondsSinceEpoch,
      "modifiedDateTime": asset.modifiedDateTime.millisecondsSinceEpoch,
      "cloudId": null,
      "localId": asset.id
    });
  });
}

Future<int> uploadPendingAssets() async {
  final MediaTable mediaTable = new MediaTable();
  List<Map<String, dynamic>> pendingAssets =
      await mediaTable.getPendingAssets();
  // print(pendingAssets);

  // start upload file using api
  int uploadNumber = 0;
  pendingAssets.forEach((pending) async {
    AssetEntity? asset = await AssetEntity.fromId(pending["localId"]);
    if (asset != null) {
      File? file = await asset.file;
      if (file != null) {
        // build payload data
        Map<String, String> data = {
          "md5": pending["md5"],
          "size": file.lengthSync().toString(),
          "filename": basename(file.path),
          "creationTime":
              asset.createDateTime.millisecondsSinceEpoch.toString(),
          "height": asset.height.toString(),
          "width": asset.width.toString(),
          "duration": asset.duration.toString()
        };

        // call api
        try {
          Map<String, dynamic> response =
              await Api().multipart("/api/v1/photo/", data, file);
          if (response["statusCode"] == 201) {
            // update cloud id
            print(response);

            await mediaTable.updateCloudId(
                pending["md5"], response["json"]["id"]);
            uploadNumber++;
          }
        } on Exception {
          print("error uploading");
        }
      }
    }
  });
  return uploadNumber;
}
