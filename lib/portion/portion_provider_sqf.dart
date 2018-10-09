import 'dart:async';

import 'package:sqflite/sqflite.dart';

class Portion {
  final String courseCode;
  final int courseLastModifiedOn;

  final int createdOn;
  final String createdBy;

  final String courseName;
  final String description;

  final String toggleColorIndexes;
  final String toggleBordColorIndexes;

  final int isOutdated;
  final int isTeacherSignature;

  Portion(
      {this.courseCode,
      this.courseLastModifiedOn,
      this.createdOn,
      this.createdBy,
      this.courseName,
      this.description,
      this.toggleColorIndexes,
      this.toggleBordColorIndexes,
      this.isOutdated,
      this.isTeacherSignature});
}

class PortionProvider {
  final String table = 'portionTable';
  final String courseCode = 'courseCode';
  final String createdBy = 'createdBy';
  final String courseName = 'courseName';
  final String description = 'description';
  final String toggleColorIndexes = 'toggleColorIndexes';
  final String toggleBordColorIndexes = 'toggleBordColorIndexes';
  final String courseLastModifiedOn = 'courseLastModifiedOn';
  final String createdOn = 'createdOn';
  final String isOutdated = 'isOutdated';
  final String isTeacherSignature = 'teacherSignature';
  Database db;

  Future open() async {
    final databasePath = await getDatabasesPath();
    final path = databasePath + table + "Path";
    db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          '''CREATE TABLE $table ($courseCode text, $createdBy text, $courseName text, $description text, $toggleColorIndexes text, $toggleBordColorIndexes text
          , $courseLastModifiedOn integer, $createdOn integer, $isOutdated integer, $isTeacherSignature integer);''');
    });
    assert(db != null);
  }

  Future close() async {
    await db.close();
  }

  Portion portionFrmMap(Map<String, dynamic> map) {
    return Portion(
      courseCode: map[courseCode],
      createdBy: map[createdBy],
      courseName: map[courseName],
      description: map[description],
      toggleColorIndexes: map[toggleColorIndexes],
      toggleBordColorIndexes: map[toggleBordColorIndexes],
      courseLastModifiedOn: map[courseLastModifiedOn],
      createdOn: map[createdOn],
      isOutdated: map[isOutdated],
      isTeacherSignature: map[isTeacherSignature],
    );
  }

  Map<String, dynamic> portionToMap(Portion portion) {
    return {
      courseCode: portion.courseCode,
      createdBy: portion.createdBy,
      courseName: portion.courseName,
      description: portion.description,
      toggleColorIndexes: portion.toggleColorIndexes,
      toggleBordColorIndexes: portion.toggleBordColorIndexes,
      courseLastModifiedOn: portion.courseLastModifiedOn,
      createdOn: portion.createdOn,
      isOutdated: portion.isOutdated,
      isTeacherSignature: portion.isTeacherSignature,
    };
  }

  Future<Portion> getPortion(String createdBy, int createdOn) async {
    if (this.db == null) {
      await open();
    }
    final portionRes = await db.query(table,
        columns: [
          this.createdBy,
          this.courseCode,
          this.createdBy,
          this.courseName,
          this.description,
          this.toggleColorIndexes,
          this.toggleBordColorIndexes,
          this.courseLastModifiedOn,
          this.createdOn,
          this.isOutdated,
          this.isTeacherSignature,
        ],
        where:
            " ${this.createdBy}='$createdBy' and ${this.createdOn}=$createdOn ");
    return portionRes.isEmpty ? null : portionFrmMap(portionRes.first);
  }

  Future<List<Portion>> getPortionsList() async {
    if (this.db == null) {
      await open();
    }
    final portionListRes = await db.query(table,
        columns: [
          this.createdBy,
          this.createdOn,
          this.courseName,
          this.description,
          this.isOutdated,
          this.isTeacherSignature,
          this.courseCode,
          this.courseLastModifiedOn
        ],
        orderBy: createdOn);
    List<Portion> portions = [];
    portionListRes.forEach((portionMap) {
      portions.add(portionFrmMap(portionMap));
    });
    return portions;
  }

  Future<void> insert(Portion portion) async {
    if (this.db == null) {
      await open();
    }
    await db.insert(table, portionToMap(portion));
  }

  Future remove(
      String courseCode, int courseLastModifiedOn, int createdOn) async {
    if (this.db == null) {
      await open();
    }
    await db.delete(table,
        where:
            "${this.courseCode}='$courseCode' AND ${this.courseLastModifiedOn}=$courseLastModifiedOn AND ${this.createdOn}=$createdOn");
  }
}
