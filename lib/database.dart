import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class MediaTable {
  var db;
  int version = 6;
  String table = "media";

  Future<int> selectBiggstModifiedDateTime() async {
    if (db == null) {
      db = await getDatabaseObject();
    }
    // Database _db = db;
    final List<Map<String, dynamic>> result =
        await db.query(table, limit: 1, orderBy: "modifiedDateTime DESC");
    if (result.length == 0) {
      return 0;
    }
    return result[0]["modifiedDateTime"];
  }

  Future<void> dropTable() async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    await db.rawQuery("delete from media");
  }

  Future<void> insert(Map<String, dynamic> data) async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
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

    final Map<String, dynamic> result =
        await db.query(table, where: "md5 = ?", whereArgs: [md5]);

    return result;
  }

  Future<void> deleteByMD5(Map<String, dynamic> data) async {
    if (db == null) {
      db = await getDatabaseObject();
    }
    await db.delete(table, where: 'md5 = ?', whereArgs: [data["md5"]]);
  }

  Future<void> update(Map<String, dynamic> data) async {
    if (db == null) {
      db = await getDatabaseObject();
    }

    await db.update(
      table,
      data,
      where: 'md5 = ?',
      whereArgs: [data["md5"]],
    );
  }

  Future<Database> getDatabaseObject() async {
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
}
