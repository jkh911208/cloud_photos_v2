import 'dart:convert';
import 'dart:io';
import 'package:cloud_photos_v2/storage.dart';
import 'package:path/path.dart';
import 'package:cloud_photos_v2/api.dart';
import 'package:crypto/crypto.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:cloud_photos_v2/database.dart';

Future<void> getFromCloud() async {
  final MediaTable mediaTable = new MediaTable();

  // get biggest modified
  int biggestCloudCreated = await getCloudCreatedEpoch();
  print("cloud biggest created $biggestCloudCreated");

  // make api call to get list of images
  Map<String, dynamic> response =
      await Api().get("/api/v1/photo/list/$biggestCloudCreated");

  // write to db
  if (response["statusCode"] == 200) {
    for (var i = 0; i < response["json"]["result"].length; i++) {
      Map<String, dynamic> current = response["json"]["result"][i];
      print(current);
      if ((await mediaTable.selectByMD5(current["md5"])).length == 0) {
        mediaTable.insert({
          "md5": current["md5"],
          "duration": current["duration"].toInt(),
          "createDateTime": current["original_datetime"],
          "modifiedDateTime": null,
          "cloudId": current["id"],
          "localId": null
        });
      }
      await writeCloudCreatedEpoch(current["created"]);
    }
  }
}

Future<void> updateEntireLibrary() async {
  final MediaTable mediaTable = new MediaTable();
  final int biggestmodified =
      await mediaTable.selectBiggstModifiedDateTimeLocal();
  print("current biggest modified $biggestmodified");

  final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      filterOption: FilterOptionGroup(
          orders: [OrderOption(asc: true, type: OrderOptionType.updateDate)],
          updateTimeCond: DateTimeCond(
              min: DateTime.fromMillisecondsSinceEpoch(biggestmodified),
              max: DateTime.now())));
  if (albums.length == 0) {
    return;
  }
  final AssetPathEntity album = albums.first;
  if (album.assetCount == 0) {
    return;
  }
  final List<AssetEntity> assetList =
      await album.getAssetListRange(start: 0, end: album.assetCount);

  assetList.forEach((asset) {
    final String epoch =
        asset.modifiedDateTime.millisecondsSinceEpoch.toString();
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
