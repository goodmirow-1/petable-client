
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:myvef_app/Notification/model/notification.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

final String TableName = "NotiLogs";

class NotiDBHelper {

  NotiDBHelper._();

  static final NotiDBHelper _db = NotiDBHelper._();

  factory NotiDBHelper() => _db;

  late Database _database;

  bool isInit = false;

  Future<Database> get database async {
    if(isInit) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    isInit = true;

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'NotiDB.db');

    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          try{
            await db.execute("CREATE TABLE $TableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, userID INTEGER, targetID INTEGER, type STRING, tableIndex INTEGER, subIndex STRING, isRead BOOLEAN, isSend BOOLEAN, time String)");
          }
          catch(e){
            debugPrint(e.toString());
          }

        },
        onUpgrade: (db, oldVersion, newVersion){}
    );
  }

  createData(NotificationModel model) async {
    final db = await database;

    var isHave = await db.rawQuery("Select * from $TableName where id = ?", [model.id]);

    var res;
    if(isHave.isEmpty){
      res = await db.rawInsert("INSERT INTO $TableName(id, userID, targetID, type, tableIndex, subIndex, isRead, isSend, time) VALUES(?,?,?,?,?,?,?,?,?)",
          [
            model.id,
            model.from,
            model.to,
            model.type,
            model.tableIndex,
            model.subIndex,
            model.isRead,
            model.isSend,
            model.createdAt
          ]
      );

      debugPrint("TABLE SIZE" + res.toString());
    }else{
      res = 0;
    }


    return res;
  }

  readNoti(int id, int isRead) async {
    final db = await database;

    var res = await db.rawUpdate('''
      UPDATE $TableName
      SET isRead = ?
      WHERE id = ?
      ''',
        [isRead, id]);
  }

  Future<List<NotificationModel>> getAllData() async {
    final db = await database;

    var res = await db.rawQuery('SELECT * from $TableName');
    List<NotificationModel> list = [];
    try{
       list = res.isNotEmpty ?
      res.map((c) => NotificationModel(
        id: c['id'] as int,
        from: c['userID'] as int,
        to: c['targetID'] as int,
        type: c['type'] as String,
        tableIndex: c['tableIndex'] as int,
        subIndex: c['subIndex'] as String,
        isRead: c['isRead']  == 0 ? false : true,
        isSend: c['isSend'] == 0 ? false : true,
        createdAt: c['time'] as String,
        updatedAt: c['time'] as String,
      )).toList()
          : [];
    }catch(err){
      debugPrint(err.toString());

      list.clear();
      dropTable();
    }

    return list.reversed.toList();
  }

  deleteData(int id) async{
    final db = await database;
    var res = await db.rawDelete('DELETE FROM $TableName where id = ?', [id]);
    return res;
  }

  dropTable() async{
    final db = await database;
    db.execute("DROP TABLE IF EXISTS $TableName");
    await db.execute("CREATE TABLE $TableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, userID INTEGER, targetID INTEGER, type STRING, tableIndex INTEGER, subIndex STRING, isRead BOOLEAN, isSend BOOLEAN, time String)");
  }
}