import 'dart:convert';

import 'package:sqflite/sqflite.dart';

class NotiSqf {
  final String table = 'notificationsTable';
  final String serverTimestamp = 'serverTimestamp';
  final String data = 'data';
  final String isUnRead = 'isUnRead';
  Database db;

  Future open() async {
    final databasePath = await getDatabasesPath();
    final path = databasePath + table + "Path";
    db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          '''CREATE TABLE $table ($serverTimestamp integer, $data text, $isUnRead integer);''');
    });
    assert(db != null);
  }

  Future<List<Map>> getAll() async {
    if (db == null) {
      await open();
    }
    final notis = await db.query(table, orderBy: serverTimestamp);
    final decodedNoti = notis.map((noti) {
      return {isUnRead: noti[isUnRead] == 1, data: json.decode(noti[data])};
    });
    return decodedNoti.toList();
  }

  Future insert(notiData) async {
    if (db == null) {
      await open();
    }
    await db.insert(table, {
      data: json.encode(notiData),
      serverTimestamp: int.parse(notiData[serverTimestamp]),
      isUnRead: 1
    });
  }

  Future deleteAll() async {
    if (db == null) {
      await open();
    }
    await db.delete(table);
  }

  Future markAsRead() async {
    if (db == null) {
      await open();
    }
    db.update(table, {isUnRead: 0});
  }
}
