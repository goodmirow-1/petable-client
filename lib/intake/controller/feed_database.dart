
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:myvef_app/Data/global_data.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../model/feed.dart';

final String TableName = "FeedLogs";

class FeedDBHelper {

  FeedDBHelper._();

  static final FeedDBHelper _db = FeedDBHelper._();

  factory FeedDBHelper() => _db;

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
    String path = join(documentsDirectory.path, 'FeedDB.db');

    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          try{
            await db.execute("CREATE TABLE $TableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, userID INTEGER, petID INTEGER, brandName STRING, koreaName STRING, englishName STRING, perFat DOUBLE, perProtein DOUBLE, carbohydrate DOUBLE, calorie INT)");
          }
          catch(e){
            debugPrint(e.toString());
          }

        },
        onUpgrade: (db, oldVersion, newVersion){}
    );
  }

  createData(Feed feed) async {
    final db = await database;

    var res = await db.rawInsert("INSERT INTO $TableName(userID, petID, brandName, koreaName, englishName, perFat, perProtein, carbohydrate, calorie) VALUES(?,?,?,?,?,?,?,?,?)",
        [
          feed.userID,
          feed.petID,
          feed.brandName,
          feed.koreaName,
          feed.englishName,
          feed.perFat,
          feed.perProtein,
          feed.crudeFiber,
          feed.calorie,
        ]
    );

    debugPrint("TABLE SIZE " + res.toString());

    return res;
  }

  readFeed(int id, int isRead) async {
    final db = await database;

    var res = await db.rawUpdate('''
      UPDATE $TableName
      SET isRead = ?
      WHERE id = ?
      ''',
        [isRead, id]);
  }

  Future<List<Feed>> getAllData() async {
    final db = await database;

    var res = await db.rawQuery('SELECT * from $TableName');

    List<Feed> list  = res.isNotEmpty ?
    res.map((c) => Feed(
      userID: c['userID'] as int,
      petID: c['petID'] as int,
      brandName: c['brandName'] as String,
      koreaName: c['koreaName'] as String,
      englishName: c['englishName'] as String,
      perFat: c['perFat'] as double,
      perProtein: c['perProtein'] as double,
      crudeFiber: c['carbohydrate'] as double,
      calorie: c['calorie'] as int,
    )).toList()
        : [];

    return list.reversed.toList();
  }

  Future<Feed> getFeedData(int petID) async{
    final db = await database;

  var res = await db.rawQuery('SELECT * from $TableName WHERE petID = ?', [petID]);


  Feed feed  = res.isNotEmpty ?
    Feed(
      userID: res[0]['userID'] as int,
      petID: res[0]['petID'] as int,
      brandName: res[0]['brandName'].toString(),
      koreaName: res[0]['koreaName'].toString(),
      englishName: res[0]['englishName'].toString(),
      perFat: res[0]['perFat'] as double,
      perProtein: res[0]['perProtein'] as double,
      crudeFiber: res[0]['carbohydrate'] as double,
      calorie: res[0]['calorie'] as int,
    ): Feed();

    return feed;
  }

  deleteData(int petID) async{
    final db = await database;
    var res = db.rawDelete('DELETE FROM $TableName where petID = ?', [petID]);
    return res;
  }

  dropTable() async{
    final db = await database;
    db.execute("DROP TABLE IF EXISTS $TableName");
    await db.execute("CREATE TABLE $TableName(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, userID INTEGER, petID INTEGER, brandName STRING, koreaName STRING, englishName STRING, perFat DOUBLE, perProtein DOUBLE, carbohydrate DOUBLE, calorie INT)");
  }
}