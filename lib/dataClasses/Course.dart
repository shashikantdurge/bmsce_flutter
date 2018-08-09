import 'package:meta/meta.dart';

class Course {
  String courseName, courseCode, branch;
  int version;
  int sem, l, t, p, s, totalCredits;

  Course(
      {@required this.courseName,
      this.branch,
      this.sem,
      @required this.courseCode,
      @required this.l,
      @required this.t,
      @required this.p,
      @required this.s,
      @required this.version}) {
    this.totalCredits = l + t + p + s;
  }

  void editSyllabus() {}

  void addCourse() {}

  void removeCourse() {}

  static void updateSyllabus(String courseCode, double oldVersion) {}
}

enum CourseOfferedFor { Dept, Cluster, Institute }
enum CourseType { Core, Elective, Lab, Mandatory }

final courses = [
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
  Course(
      courseName: 'Data Structures',
      courseCode: '10CS3DCDST',
      l: 3,
      t: 0,
      p: 1,
      s: 0),
];
