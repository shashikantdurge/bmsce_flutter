import 'dart:async';

import 'package:bmsce/course/course.dart';
import 'package:sqflite/sqflite.dart';

class CourseContentProvider {
  final table = 'courseContentTable';
  final lastModifiedOn = 'lastModifiedOn';
  Database db;
  final String courseCode = 'courseCode';
  final String content = 'content';
  final String lastModifiedBy = 'lastModifiedBy';

  Future open() async {
    print('${DateTime.now()} open(START)');
    final databasePath = await getDatabasesPath();
    final path = databasePath + table + "Path";
    db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE $table ($courseCode text, ${this.lastModifiedOn} integer, $content text, $lastModifiedBy text);');
    });
    assert(db != null);
    print('${DateTime.now()} open(END)');
  }

  Future close() async {
    await db.close();
  }

  Map<String, dynamic> courseContentToMap(CourseContent courseContent) {
    return {
      courseCode: courseContent.courseCode,
      lastModifiedOn: courseContent.lastModifiedOn,
      content: courseContent.content,
      lastModifiedBy: courseContent.lastModifiedBy
    };
  }

  Future<CourseContent> getCourseContent(
      String courseCode, int courseLastModifiedOn) async {
    if (this.db == null) {
      await open();
    }
    print('${DateTime.now()} getCourseContent(START)');
    final contentRes = await db.query(table,
        columns: [content, lastModifiedBy],
        where:
            " ${this.courseCode}='$courseCode' and ${this.lastModifiedOn}=$courseLastModifiedOn");
    print('${DateTime.now()} getCourseContent(END)');
    return contentRes.isNotEmpty
        ? CourseContent(courseCode, courseLastModifiedOn,
            contentRes.first['content'], contentRes.first['lastModifiedBy'])
        : null;
  }

  Future insert(CourseContent courseContent) async {
    if (this.db == null) {
      await open();
    }
    await db.insert(table, courseContentToMap(courseContent));
  }
}
