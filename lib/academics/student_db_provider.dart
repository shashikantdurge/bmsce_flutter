import 'dart:async';

import 'package:bmsce/academics/student.dart';
import 'package:sqflite/sqflite.dart';
import 'cgpa_sgpa_chart.dart';

class StudentDbProvider {
  final tableDb = "studentDb";
  Database db;

  final studentNameDb = "studentNameDb";
  final usnDb = "usnDb";
  final detailDataJsonDb = "detailDataJsonDb";
  final approxSemesterDb = "approxSemesterDb";
  final cgpaDb = "cgpaDb";
  final sgpaDb = "sgpaDb";
  final numOfBackLogsDb = "numOfBackLogsDb";
  final num5thAttemptCoursesDb = "num5thAttemptCoursesDb";
  final cumulativeCreditsEarnedDb = "cumulativeCreditsEarnedDb";
  final creditsPendingDb = "creditsPendingDb";
  final isYearBackDb = "isYearBackDb"; //0 or 1. bool

  Future open() async {
    final databasePath = await getDatabasesPath();
    final path = databasePath + tableDb + "Path";
    db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE $tableDb ($studentNameDb text, $usnDb text PRIMARY KEY, $detailDataJsonDb text, $approxSemesterDb text, $cgpaDb real, $sgpaDb real, $numOfBackLogsDb integer, $num5thAttemptCoursesDb integer,$cumulativeCreditsEarnedDb integer, $creditsPendingDb integer, $isYearBackDb integer);');
    });
    assert(db != null);
  }

  Future close() async {
    await db.close();
  }

  Map<String, dynamic> studentToMap(StudentAbstractDetail student) {
    return {
      studentNameDb: student.name,
      usnDb: student.usn,
      approxSemesterDb: student.approxSemester,
      cgpaDb: student.cgpa,
      sgpaDb: student.sgpa,
      numOfBackLogsDb: student.numOfBackLogs,
      num5thAttemptCoursesDb: student.num5thAttemptCourses,
      cumulativeCreditsEarnedDb: student.cumulativeCreditsEarned,
      creditsPendingDb: student.creditsPending,
      isYearBackDb: student.isYearBack ? 1 : 0,
      detailDataJsonDb: student.detailDataJson
    };
  }

  StudentAbstractDetail studentFrmMap(Map<String, dynamic> student) {
    return StudentAbstractDetail(
      name: student[studentNameDb],
      usn: student[usnDb],
      approxSemester: student[approxSemesterDb],
      cgpa: student[cgpaDb],
      sgpa: student[sgpaDb],
      numOfBackLogs: student[numOfBackLogsDb],
      num5thAttemptCourses: student[num5thAttemptCoursesDb],
      cumulativeCreditsEarned: student[cumulativeCreditsEarnedDb],
      creditsPending: student[creditsPendingDb],
      isYearBack: student[isYearBackDb] == 1 ? true : false,
      detailDataJson: student[detailDataJsonDb],
    );
  }

  Future insertStudents(List<StudentAbstractDetail> students,
      List<Student> deleteStudents) async {
    if (this.db == null) {
      await open();
    }
    // db.rawDelete(
    //     "DELETE FROM $tableDb WHERE $usnDb NOT IN ${retainStudentsUsn.toList()}");

    Batch batch = db.batch();
    deleteStudents.forEach((student) {
      batch.delete(tableDb, where: "$usnDb = ?", whereArgs: [student.usn]);
    });
    students.forEach((student) {
      batch.insert(tableDb, studentToMap(student));
    });
    return await batch.commit();
  }

  Future<StudentAbstractDetail> getStudentDetails(String usn) async {
    if (this.db == null) {
      await open();
    }
    final studentsMapList = await db.query(tableDb,
        columns: [
          studentNameDb,
          usnDb,
          approxSemesterDb,
          cgpaDb,
          sgpaDb,
          numOfBackLogsDb,
          num5thAttemptCoursesDb,
          cumulativeCreditsEarnedDb,
          creditsPendingDb,
          isYearBackDb,
          detailDataJsonDb
        ],
        where: "$usnDb = ? ",
        whereArgs: [usn]);
    if (studentsMapList.isEmpty) return null;
    return studentFrmMap(studentsMapList[0]);
  }

  Future<List<StudentAbstractDetail>> getAllStudents() async {
    if (this.db == null) {
      await open();
    }
    final studentsMapList = await db.query(tableDb, columns: [
      studentNameDb,
      usnDb,
      approxSemesterDb,
      cgpaDb,
      sgpaDb,
      numOfBackLogsDb,
      num5thAttemptCoursesDb,
      cumulativeCreditsEarnedDb,
      creditsPendingDb,
      isYearBackDb
    ]);
    List<StudentAbstractDetail> students = [];
    studentsMapList.forEach((studentMap) {
      students.add(studentFrmMap(studentMap));
    });
    return students;
  }
}
