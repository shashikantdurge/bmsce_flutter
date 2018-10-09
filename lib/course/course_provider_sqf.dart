import 'dart:async';

import 'package:bmsce/course/course.dart';
import 'package:sqflite/sqflite.dart';

class CourseProviderSqf {
  final table = "coursesTable";
  final courseName = "courseName";
  final courseCode = "courseCode";
  final l = "l";
  final t = "t";
  final p = "p";
  final s = "s";
  final totalCredits = "totalCredits";
  final lastModifiedOn = "lastModifiedOn";
  Database db;

  Future open() async {
    final databasePath = await getDatabasesPath();
    final path = databasePath + table + "Path";
    db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE $table ($courseName text, $courseCode text, $l integer, $t integer, $p integer, $s integer, ${this.lastModifiedOn} integer, $totalCredits integer);');
    });
    assert(db != null);
  }

  Future close() async {
    await db.close();
  }

  Course courseFrmMap(Map courseMap) {
    return Course(
      courseName: courseMap[courseName],
      courseCode: courseMap[courseCode],
      l: courseMap[l],
      t: courseMap[t],
      p: courseMap[p],
      s: courseMap[s],
      lastModifiedOn: courseMap[lastModifiedOn],
      totalCredits: courseMap[totalCredits],
    );
  }

  Map<String, dynamic> courseToMap(Course course) {
    return {
      courseName: course.courseName,
      courseCode: course.courseCode,
      l: course.l,
      t: course.t,
      p: course.p,
      s: course.s,
      totalCredits: course.totalCredits,
      lastModifiedOn: course.lastModifiedOn
    };
  }

  Future<List<Course>> getAllCourses(
      {bool l: false,
      bool t: false,
      bool p: false,
      bool s: false,
      bool courseLastModifiedOn: false}) async {
    if (this.db == null) {
      await open();
    }
    final cols = [courseName, courseCode, totalCredits];
    l ? cols.add(this.l) : null;
    t ? cols.add(this.t) : null;
    p ? cols.add(this.p) : null;
    s ? cols.add(this.s) : null;
    courseLastModifiedOn ? cols.add(this.lastModifiedOn) : null;
    List<Map> coursesMap =
        await db.query(table, columns: cols, orderBy: courseName);
    List<Course> courses = [];
    coursesMap.forEach((courseMap) {
      courses.add(courseFrmMap(courseMap));
    });
    return courses;
  }

  Future<Course> getCourse(String courseCode, int courseLastModifiedOn) async {
    if (this.db == null) {
      await open();
    }
    final courseRes = await db.query(table,
        columns: [],
        where:
            " ${this.courseCode}='$courseCode' and ${this.lastModifiedOn}=$courseLastModifiedOn");
    return courseFrmMap(courseRes.first);
  }

  Future<void> insertCourse(Course course) async {
    if (this.db == null) {
      await open();
    }
    await db.insert(table, courseToMap(course));
  }

  Future removeCourse(String courseCode) async {
    if (this.db == null) {
      await open();
    }
    await db.delete(table, where: "${this.courseCode}='$courseCode'");
  }
}
