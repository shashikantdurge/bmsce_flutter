import 'dart:async';

import 'package:bmsce/course/course.dart';
import 'package:bmsce/portion/portion_provider_sqf.dart';
import 'package:sqflite/sqflite.dart';

class CourseProviderSqf {
  final table = "coursesTable";
  final courseName = "courseName";
  final courseCode = "courseCode";
  final isOutdated = "isOutdated";
  final l = "l";
  final t = "t";
  final p = "p";
  final s = "s";
  final totalCredits = "totalCredits";
  final lastModifiedOn = "lastModifiedOn";
  final lastModifiedBy = "lastModifiedBy";
  final content = "content";
  final codeVersion = "codeVersion";
  Database db;

  Future open() async {
    final databasePath = await getDatabasesPath();
    final path = databasePath + table + "Path";
    db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE $table ($courseName text, $courseCode text, $l integer, $t integer, $p integer, $s integer,' +
              ' ${this.lastModifiedOn} integer, $totalCredits integer,$lastModifiedBy text, $content text, $codeVersion text, $isOutdated integer);');
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
        isOutdated: courseMap[isOutdated] == 1,
        lastModifiedOn: courseMap[lastModifiedOn],
        totalCredits: courseMap[totalCredits],
        codeVersion: courseMap[codeVersion],
        content: courseMap[content],
        lastModifiedBy: courseMap[lastModifiedBy]);
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
      lastModifiedOn: course.lastModifiedOn,
      lastModifiedBy: course.lastModifiedBy,
      content: course.content,
      isOutdated: course.isOutdated ? 1 : 0,
      codeVersion: course.codeVersion
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
    final cols = [courseName, courseCode, totalCredits, codeVersion];
    if (l) cols.add(this.l);
    if (t) cols.add(this.t);
    if (p) cols.add(this.p);
    if (s) cols.add(this.s);
    if (courseLastModifiedOn) cols.add(this.lastModifiedOn);
    List<Map> coursesMap =
        await db.query(table, columns: cols, where: "$isOutdated=0");
    List<Course> courses = [];
    coursesMap.forEach((courseMap) {
      courses.add(courseFrmMap(courseMap));
    });
    return courses;
  }

  Future<Course> getCourse(String courseCode, String codeVersion) async {
    if (this.db == null) {
      await open();
    }
    final courseRes = await db.query(table,
        columns: null,
        where:
            " ${this.courseCode}='$courseCode' and ${this.codeVersion}='$codeVersion'");
    return courseFrmMap(courseRes.first);
  }

  Future<String> getOnlyContent(String courseCode, String codeVersion) async {
    return (await getCourse(courseCode, codeVersion)).content;
  }

  Future<void> insertCourse(Course course) async {
    if (this.db == null) {
      await open();
    }
    await db.insert(table, courseToMap(course));
  }

  /// if any portion is dependent on it updates `isOutdated=1`
  /// else `deletes` the course(outdated course)
  Future<void> processExit(Course course) async {
    if (this.db == null) {
      await open();
    }
    final numOfPortions = await PortionProvider()
        .setOutDated(course.courseCode, course.codeVersion);
    if (numOfPortions > 0)
      await db.update(table, {isOutdated: 1},
          where:
              "$courseCode = '${course.courseCode}' AND $codeVersion='${course.codeVersion}'");
    else
      await db.delete(table,
          where:
              "$courseCode = '${course.courseCode}' AND $codeVersion='${course.codeVersion}'");
  }

  Future removeCourse(String courseCode) async {
    if (this.db == null) {
      await open();
    }
    await db.delete(table, where: "${this.courseCode}='$courseCode'");
  }
}
