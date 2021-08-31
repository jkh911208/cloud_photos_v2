import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class MediaTable {
  var db;
  int version = 2;
  String table = "media";

  Future<List<Map<String, dynamic>>> getPendingAssets() async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    int sevenDaysAgo =
        DateTime.now().subtract(Duration(days: 7)).millisecondsSinceEpoch;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        "select * from media where localId is not null AND cloudId is null AND duration = ? AND createDateTime > ? order by createDateTime ASC",
        [0, sevenDaysAgo]);

    return result;
  }

  Future<int> selectBiggstModifiedDateTimeLocal() async {
    if (db == null) {
      db = await getDatabaseObject();
    }
    final List<Map<String, dynamic>> result = await db.query(table,
        where: "localId is not ?",
        whereArgs: ["null"],
        limit: 1,
        orderBy: "modifiedDateTime DESC");
    if (result.length == 0) {
      return 0;
    }
    return result[0]["modifiedDateTime"];
  }

  Future<void> truncateTable() async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    await db.rawQuery("delete from media");
  }

  Future<void> removeLocalIdByMD5(String md5) async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    return await db
        .rawUpdate('UPDATE media SET localId = ? WHERE md5 = ?', [null, md5]);
  }

  Future<void> removeLocalIdByLocalId(String localId) async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    return await db.rawUpdate(
        'UPDATE media SET localId = ? WHERE localId = ?', [null, localId]);
  }

  Future<void> insert(Map<String, dynamic> data) async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<Map<String, dynamic>>> selectAll() async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    final List<Map<String, dynamic>> results =
        await db.query(table, orderBy: "createDateTime DESC");

    return results;
  }

  Future<Map<String, dynamic>> selectByMD5(String md5) async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    final List<Map<String, dynamic>> result =
        await db.query(table, where: "md5 = ?", whereArgs: [md5]);

    if (result.length > 0) {
      return result.first;
    }
    return {};
  }

  Future<void> deleteByMD5(String md5) async {
    if (db == null) {
      db = await getDatabaseObject();
    }
    await db.delete(table, where: 'md5 = ?', whereArgs: [md5]);
  }

  Future<void> deleteByLocalId(String localId) async {
    if (db == null) {
      db = await getDatabaseObject();
    }
    await db.delete(table, where: 'localId = ?', whereArgs: [localId]);
  }

  Future updateCloudId(String md5, String cloudId) async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    return await db.rawUpdate(
        'UPDATE media SET cloudId = ? WHERE md5 = ?', [cloudId, md5]);
  }

  Future<List<Map<String, dynamic>>> selectBycreateDateTime(
      int createTime) async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    final List<Map<String, dynamic>> results = await db
        .query(table, where: "createDateTime = ?", whereArgs: [createTime]);
    return results;
  }

  Future update(Map<String, dynamic> data, String whereArg) async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    return await db.update(
      table,
      data,
      where: 'md5 = ?',
      whereArgs: [whereArg],
    );
  }

  Future<Database> getDatabaseObject() async {
    String path = join(await getDatabasesPath(), 'CloudPhotosV$version.db');
    if (await databaseExists(path)) {
      return await openDatabase(path, version: version);
    }
    final database = await openDatabase(path, version: version,
        onCreate: (db, version) async {
      await db.execute("""
        CREATE TABLE if not exists media
        (
          md5 text primary key not null UNIQUE,
          duration integer not null,
          createDateTime datetime not null,
          modifiedDateTime datetime,
          cloudId text UNIQUE,
          localId text UNIQUE
        );
        """);

      await db.execute(
          "CREATE UNIQUE INDEX if not exists md5_index on media (md5);");

      await db.execute(
          "CREATE INDEX if not exists creation_time on media (createDateTime);");

      await db.execute(
          "CREATE INDEX if not exists modified_time on media (modifiedDateTime);");
    });
    return database;
  }

  Future<void> close() async {
    await db.close();
  }
}
