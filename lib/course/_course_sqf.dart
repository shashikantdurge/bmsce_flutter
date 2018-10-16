import 'package:meta/meta.dart';

class Course {
  int sem, l, t, p, s, totalCredits, lastModifiedOn;
  String courseName, courseCode, branch, content, codeVersion, lastModifiedBy;
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
  static getCourses() {}
}
