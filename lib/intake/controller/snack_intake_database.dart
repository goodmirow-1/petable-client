import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'package:myvef_app/intake/model/snack_intake.dart';

final String tableName = 'snackIntakeTable';

class SnackDBHelper {
  SnackDBHelper._();

  static final SnackDBHelper _db = SnackDBHelper._();

  factory SnackDBHelper() => _db;

  late Database _database;

  bool isInit = false;

  Future<Database> get database async {
    if (isInit) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'SnackDB.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      try {
        await db.execute("create table $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, snackIntakeID INTEGER, petID INTEGER, snackID INTEGER, weight DOUBLE, time TEXT, createdAt TEXT, updatedAt TEXT)");
        isInit = true;
      } catch (e) {
        debugPrint(e.toString());
      }
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  Future<SnackIntake> insert(SnackIntake snackIntake) async {
    final db = await database;

    snackIntake.id = await db.insert(tableName, snackIntake.toMap());
    return snackIntake;
  }

  insertMulti(List<SnackIntake> snackIntakeList) async {
    if(snackIntakeList.isEmpty) return;

    final db = await database;

    for(int i = 0; i < snackIntakeList.length; i++){
      await db.insert(tableName, snackIntakeList[i].toMap());
    }
  }

  Future<SnackIntake> getSnack(int id) async {
    final db = await database;
    List<Map> maps = await db.query(tableName, columns: ['snackIntakeID', 'petID', 'snackID', 'weight', 'time', 'createdAt', 'updatedAt'], where: 'snackIntakeID = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return SnackIntake.fromMap(maps.first);
    }
    return SnackIntake(id: nullInt, petID: nullInt, snackID: nullInt, weight: nullDouble, time: '', updatedAt: '', createdAt: '');
  }

  Future<List<SnackIntake>> getSnackList({required int petID, int id = 0}) async {
    final db = await database;

    List<SnackIntake> _snackIntakeList = [];

    List<Map> maps = await db.query(
      tableName,
      columns: ['snackIntakeID', 'petID', 'snackID', 'weight', 'time', 'createdAt', 'updatedAt'],
      where: 'petID = ? AND snackIntakeID > ?',
      whereArgs: [petID, id],
      orderBy: 'snackIntakeID DESC',
    );

    for (int i = 0; i < maps.length; i++) {
      _snackIntakeList.add(SnackIntake.fromMap(maps[i]));
    }

    return _snackIntakeList;
  }

  getLastSnackID(int petID) async {
    final db = await database;
    int lastSnackID = 0;
    List<Map> maps = await db.query(
      tableName,
      columns: ['snackIntakeID', 'petID', 'snackID', 'weight', 'time', 'createdAt', 'updatedAt'],
      where: 'petID = ?',
      whereArgs: [petID],
      orderBy: 'snackIntakeID DESC',
      limit: 1,
    );
    if (maps.length > 0) {
      SnackIntake tmp = SnackIntake.fromMap(maps.first);
      lastSnackID = tmp.id;
    }
    return lastSnackID;
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(tableName, where: 'snackIntakeID = ?', whereArgs: [id]);
  }

  Future<int> deleteByPetID(int petID) async {
    final db = await database;
    return await db.delete(tableName, where: 'petID = ?', whereArgs: [petID]);
  }

  Future<int> update(SnackIntake snackIntake) async {
    final db = await database;
    return await db.update(tableName, snackIntake.toMap(), where: 'snackIntakeID = ?', whereArgs: [snackIntake.id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }

  dropTable() async {
    final db = await database;
    await db.execute("DROP TABLE IF EXISTS $tableName");
    db.execute("create table $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, snackIntakeID INTEGER, petID INTEGER, snackID INTEGER, weight DOUBLE, time TEXT, createdAt TEXT, updatedAt TEXT)");
  }
}
