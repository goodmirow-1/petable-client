import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'package:myvef_app/intake/model/water.dart';

final String tableName = 'waterTable';

class WaterDBHelper {
  WaterDBHelper._();

  static final WaterDBHelper _db = WaterDBHelper._();

  factory WaterDBHelper() => _db;

  late Database _database;

  bool isInit = false;

  Future<Database> get database async {
    if (isInit) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'WaterDB.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      try {
        await db.execute("create table $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, petID INTEGER, amount DOUBLE, type INTEGER, time TEXT, intakeID INTEGER, snackIntakeID INTEGER)");
        isInit = true;
      } catch (e) {
        debugPrint(e.toString());
      }
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  Future<Water> insert(Water water) async {
    final db = await database;

    water.id = await db.insert(tableName, water.toMap());
    return water;
  }

  insertMulti(List<Water> waterList) async {
    if(waterList.isEmpty) return;

    final db = await database;

    for(int i = 0; i < waterList.length; i++){
      await db.insert(tableName, waterList[i].toMap());
    }
  }

  Future<List<Water>> getWaterList({required int petID, int id = 0}) async {
    final db = await database;

    List<Water> _waterList = [];

    List<Map> maps = await db.query(
      tableName,
      columns: ['id', 'petID', 'amount', 'type', 'time', 'intakeID', 'snackIntakeID'],
      where: 'petID = ? AND id > ?',
      whereArgs: [petID, id],
      orderBy: 'id DESC',
    );

    for (int i = 0; i < maps.length; i++) {
      _waterList.add(Water.fromMap(maps[i]));
    }

    return _waterList;
  }

  Future<int> getLastIntakeID() async {
    final db = await database;

    int _intakeID = 0;

    List<Map> maps = await db.query(
      tableName,
      columns: ['intakeID'],
      where: 'petID = ?',
      whereArgs: [GlobalData.mainPet.value.id],
      orderBy: 'intakeID DESC',
      limit: 1,
    );
    if (maps.length > 0) {
      _intakeID = maps[0]['intakeID'] as int;
    }

    return _intakeID;
  }

  Future<int> getLastSnackIntakeID() async {
    final db = await database;

    int _snackIntakeID = 0;

    List<Map> maps = await db.query(
      tableName,
      columns: ['snackIntakeID'],
      where: 'petID = ?',
      whereArgs: [GlobalData.mainPet.value.id],
      orderBy: 'snackIntakeID DESC',
      limit: 1,
    );
    if (maps.length > 0) {
      _snackIntakeID = maps[0]['snackIntakeID'] as int;
    }

    return _snackIntakeID;
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteByPetID(int petID) async {
    final db = await database;
    return await db.delete(tableName, where: 'petID = ?', whereArgs: [petID]);
  }

  Future<int> update(Water water) async {
    final db = await database;
    return await db.update(tableName, water.toMap(), where: 'id = ?', whereArgs: [water.id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }

  dropTable() async {
    final db = await database;
    await db.execute("DROP TABLE IF EXISTS $tableName");
    await db.execute("create table $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, petID INTEGER, amount DOUBLE, type INTEGER, time TEXT, intakeID INTEGER, snackIntakeID INTEGER)");
  }
}
