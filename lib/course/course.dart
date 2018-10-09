import 'package:meta/meta.dart';

class Course {
  String courseName, courseCode, branch;
  int lastModifiedOn;
  int sem, l, t, p, s, totalCredits;
  bool isInMyCourses;

  Course(
      {@required this.courseName,
      this.branch,
      this.sem,
      @required this.courseCode,
      @required this.l,
      @required this.t,
      @required this.p,
      @required this.s,
      @required this.lastModifiedOn,
      this.isInMyCourses: false,
      this.totalCredits}) {
    if (totalCredits == null) {
      this.totalCredits = l + t + p + s;
    }
  }

  void editSyllabus() {}

  void addCourse() {}

  void removeCourse() {}

  static void updateSyllabus(
      String courseCode, double oldCourseLastModifiedOn) {}
}

class CourseContent {
  final String courseCode;
  final int lastModifiedOn;
  final String content;
  final String lastModifiedBy;

  CourseContent(
      this.courseCode, this.lastModifiedOn, this.content, this.lastModifiedBy);
}

enum CourseOfferedFor { Dept, Cluster, Institute }
enum CourseType { Core, Elective, Lab, Mandatory }
