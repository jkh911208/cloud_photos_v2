import 'dart:io';
import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

// text primary key not null UNIQUE,
// duration DOUBLE not null,
// creationTime datetime not null,
// cloud_id text UNIQUE,
// width integer not null,
// height integer not null,
// uri text not null,
// thumbnail_uri text not null,
// local_id text UNIQUE

class Media {
  final String md5;
  final int duration;
  final int createDateTime;
  final int modifiedDateTime;
  final String? cloudId;
  final int width;
  final int height;
  final String uri;
  final String? thumbnailUri;
  final Uint8List? thumbnail;
  final String? localId;

  Media(
      {required this.md5,
      required this.duration,
      required this.createDateTime,
      required this.modifiedDateTime,
      required this.cloudId,
      required this.width,
      required this.height,
      required this.uri,
      required this.thumbnailUri,
      required this.thumbnail,
      required this.localId});

  Map<String, dynamic> toMap() {
    return {
      "md5": md5,
      "duration": duration,
      "createDateTime": createDateTime,
      "modifiedDateTime": modifiedDateTime,
      "cloudId": cloudId,
      "width": width,
      "height": height,
      "uri": uri,
      "thumbnailUri": thumbnailUri,
      "thumbnail": thumbnail,
      "localId": localId
    };
  }
}

Media mediaFromMap(Map<String, dynamic> data) {
  return Media(
    md5: data['md5'],
    duration: data['duration'],
    createDateTime: data['createDateTime'],
    modifiedDateTime: data['modifiedDateTime'],
    cloudId: data['cloudId'],
    width: data['width'],
    height: data['height'],
    uri: data['uri'],
    thumbnailUri: data['thumbnailUri'],
    thumbnail: data['thumbnail'],
    localId: data['localId'],
  );
}

class MediaTable {
  var db;
  int version = 4;
  String table = "media";

  Future<void> insert(Media media) async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    var first = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> data = media.toMap();
    if (data["thumbnail"] != null) {
      String temp = "";
      for (var k = 0; k < data["thumbnail"].length; k++) {
        temp = temp + data["thumbnail"][k].toString() + ",";
      }
      temp = temp.substring(0, temp.length - 1);
      data["thumbnail"] = temp;
    }
    print("convert list int to string");
    print(DateTime.now().millisecondsSinceEpoch - first);

    var second = DateTime.now().millisecondsSinceEpoch;
    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("actual insert operation");
    print(DateTime.now().millisecondsSinceEpoch - second);
  }

  Future<List<Media>> selectAll() async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    final List<Map<String, dynamic>> results =
        await db.query(table, orderBy: "createDateTime DESC");
    List<Media> finalResult = [];
    for (var i = 0; i < results.length; i++) {
      Map<String, dynamic> temp = Map.from(results[i]);
      if (results[i]["thumbnail"] != null) {
        List<String> tempString = results[i]["thumbnail"].split(",");
        Uint8List newList = new Uint8List(tempString.length + 1);
        for (var j = 0; j < tempString.length; j++) {
          newList[j] = int.parse(tempString[j]);
        }
        temp["thumbnail"] = newList;
      }
      if (!File(temp["uri"]).existsSync()) {
        continue;
      }
      finalResult.add(mediaFromMap(temp));
    }
    return finalResult;
  }

  Future<Media> selectByMD5(String md5) async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    final Map<String, dynamic> result =
        await db.query(table, where: "md5 = ?", whereArgs: [md5]);
    return mediaFromMap(result);
  }

  Future<void> delete(Media media) async {
    if (db == null) {
      db = await getDatabaseObject();
    }
    await db.delete(table, where: 'md5 = ?', whereArgs: [media.md5]);
  }

  Future update(Media media) async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    await db.update(
      table,
      media.toMap(),
      where: 'md5 = ?',
      whereArgs: [media.md5],
    );
  }

  Future getDatabaseObject() async {
    final database = await openDatabase(
        join(await getDatabasesPath(), 'CloudPhotosV$version.db'),
        version: version, onCreate: (db, version) async {
      await db.execute("""
        CREATE TABLE media
        (
          md5 text primary key not null UNIQUE, 
          duration integer not null, 
          createDateTime datetime not null,
          modifiedDateTime datetime not null,
          cloudId text UNIQUE,
          width integer not null,
          height integer not null,
          uri text not null,
          thumbnailUri text,
          thumbnail text,
          localId text UNIQUE
        );
        """);

      await db.execute(
          "CREATE UNIQUE INDEX if not exists md5_index on media (md5);");

      await db.execute(
          "CREATE INDEX if not exists creationtime on media (createDateTime);");

      await db.execute(
          "CREATE INDEX if not exists creationtime on media (modifiedDateTime);");
    });
    return database;
  }
}
