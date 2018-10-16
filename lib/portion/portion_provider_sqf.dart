import 'dart:async';

import 'package:sqflite/sqflite.dart';

class Portion {
  final String courseCode;
  final String codeVersion;

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
      this.codeVersion,
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
  final String codeVersion = 'codeVersion';
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
          , $codeVersion integer, $createdOn integer, $isOutdated integer, $isTeacherSignature integer);''');
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
      codeVersion: map[codeVersion],
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
      codeVersion: portion.codeVersion,
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
          this.codeVersion,
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
          this.codeVersion
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

  Future remove(String courseCode, String codeVersion, int createdOn,
      String createdBy) async {
    if (this.db == null) {
      await open();
    }
    await db.delete(table,
        where:
            "${this.courseCode}='$courseCode' AND ${this.codeVersion}='$codeVersion' AND ${this.createdOn}=$createdOn AND ${this.createdBy}='$createdBy'");
  }

  Future<int> setOutDated(String courseCode, String codeVersion) async {
    if (this.db == null) {
      await open();
    }
    return await db.update(table, {isOutdated: 1},
        where:
            "${this.courseCode}='$courseCode' AND ${this.codeVersion} = '$codeVersion'");
  }
}
