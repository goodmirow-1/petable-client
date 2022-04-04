import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'package:myvef_app/intake/model/calorie.dart';

final String tableName = 'calorieTable';

class CalorieDBHelper {
  CalorieDBHelper._();

  static final CalorieDBHelper _db = CalorieDBHelper._();

  factory CalorieDBHelper() => _db;

  late Database _database;

  bool isInit = false;

  Future<Database> get database async {
    if (isInit) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'CalorieDB.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      try {
        await db.execute("create table $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, petID INTEGER, amount DOUBLE, type INTEGER, time TEXT, intakeID INTEGER, snackIntakeID INTEGER)");
        isInit = true;
      } catch (e) {
        debugPrint(e.toString());
      }
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  Future<Calorie> insert(Calorie calorie) async {
    final db = await database;

    calorie.id = await db.insert(tableName, calorie.toMap());
    
    return calorie;
  }

  insertMulti(List<Calorie> calorieList) async {
    if(calorieList.isEmpty) return;

    final db = await database;

    for(int i = 0; i < calorieList.length; i++){
      await db.insert(tableName, calorieList[i].toMap());
    }
  }

  Future<List<Calorie>> getCalorieList({required int petID, int id = 0}) async {
    final db = await database;

    List<Calorie> _calorieList = [];

    List<Map> maps = await db.query(
      tableName,
      columns: ['id', 'petID', 'amount', 'type', 'time', 'intakeID', 'snackIntakeID'],
      where: 'petID = ? AND id > ?',
      whereArgs: [petID, id],
      orderBy: 'id DESC',
    );

    for (int i = 0; i < maps.length; i++) {
      _calorieList.add(Calorie.fromMap(maps[i]));
    }

    return _calorieList;
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

  Future<int> update(Calorie calorie) async {
    final db = await database;
    return await db.update(tableName, calorie.toMap(), where: 'id = ?', whereArgs: [calorie.id]);
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
