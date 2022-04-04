import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Data/global_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'package:myvef_app/intake/model/intake.dart';

final String tableName = 'intakeTable';

class IntakeDBHelper {
  IntakeDBHelper._();

  static final IntakeDBHelper _db = IntakeDBHelper._();

  factory IntakeDBHelper() => _db;

  late Database _database;

  bool isInit = false;

  Future<Database> get database async {
    if (isInit) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'IntakeDB.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      try {
        await db.execute(
            "create table $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, intakeID INTEGER, petID INTEGER, foodID INTEGER, weight DOUBLE, state INTEGER,type INTEGER, createdAt TEXT, updatedAt TEXT)");
        isInit = true;
      } catch (e) {
        debugPrint(e.toString());
      }
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  Future<Intake> insert(Intake intake) async {
    final db = await database;

    intake.id = await db.insert(tableName, intake.toMap());
    return intake;
  }

  insertMulti(List<Intake> intakeList) async {
    if(intakeList.isEmpty) return;

    final db = await database;

    for(int i = 0; i < intakeList.length; i++){
      await db.insert(tableName, intakeList[i].toMap());
    }
  }

  Future<Intake> getIntake(int id) async {
    final db = await database;
    List<Map> maps = await db.query(tableName, columns: ['intakeID', 'petID', 'weight', 'state', 'type', 'createdAt', 'updatedAt'], where: 'intakeID = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return Intake.fromMap(maps.first);
    }
    return Intake(id: nullInt, petID: nullInt, foodID: nullInt, weight: nullDouble, state: nullInt, type: nullInt, updatedAt: '', createdAt: '');
  }

  Future<List<Intake>> getIntakeList({required int petID, required int type, int id = 0}) async {
    final db = await database;

    List<Intake> _intakeList = [];

    List<Map> maps = await db.query(
      tableName,
      columns: ['intakeID', 'petID', 'foodID', 'weight', 'state', 'type', 'createdAt', 'updatedAt'],
      where: 'petID = ? AND type = ? AND intakeID > ?',
      whereArgs: [petID, type, id],
      orderBy: 'intakeID DESC',
    );

    for (int i = 0; i < maps.length; i++) {
      _intakeList.add(Intake.fromMap(maps[i]));
    }

    return _intakeList;
  }

  getLastIntakeID(int petID) async {
    final db = await database;
    int lastIntakeID = 0;
    List<Map> maps = await db.query(
      tableName,
      columns: ['intakeID', 'petID', 'foodID', 'weight', 'state', 'type', 'createdAt', 'updatedAt'],
      where: 'petID = ?',
      whereArgs: [petID],
      orderBy: 'intakeID DESC',
      limit: 1,
    );
    if (maps.length > 0) {
      Intake tmp = Intake.fromMap(maps.first);
      lastIntakeID = tmp.id;
    }
    return lastIntakeID;
  }

  // 오늘 먹은 사료 가져오기 (g)
  Future<List<Intake>> getTodayFeedIntakeList(DateTime dateTime) async{
    final db = await database;

    List<Intake> _intakeList = [];

    List<Map> maps = await db.query(
      tableName,
      columns: ['intakeID', 'petID', 'foodID', 'weight', 'state', 'type', 'createdAt', 'updatedAt'],
      where: 'petID = ? AND type = ? AND createdAt LIKE ?',
      whereArgs: [GlobalData.mainPet.value.id, INTAKE_TYPE_FOOD, '%${dateTime.toString().substring(0, 10)}%'],
      orderBy: 'intakeID DESC',
    );

    for (int i = 0; i < maps.length; i++) {
      _intakeList.add(Intake.fromMap(maps[i]));
    }

    return _intakeList;
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(tableName, where: 'intakeID = ?', whereArgs: [id]);
  }

  Future<int> deleteByPetID(int petID) async {
    final db = await database;
    return await db.delete(tableName, where: 'petID = ?', whereArgs: [petID]);
  }

  Future<int> update(Intake intake) async {
    final db = await database;
    return await db.update(tableName, intake.toMap(), where: 'intakeID = ?', whereArgs: [intake.id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }

  dropTable() async {
    final db = await database;
    await db.execute("DROP TABLE IF EXISTS $tableName");
    db.execute(
        "create table $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, intakeID INTEGER, petID INTEGER, foodID INTEGER, weight DOUBLE, state INTEGER,type INTEGER, createdAt TEXT, updatedAt TEXT)");
  }
}
