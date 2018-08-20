import 'package:meta/meta.dart';

class Course {
  String courseName, courseCode, branch;
  int version;
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
      @required this.version,
      this.isInMyCourses: false,
      this.totalCredits}) {
    if(totalCredits == null){
      this.totalCredits = l + t + p + s;
    }
  }

  void editSyllabus() {}

  void addCourse() {}

  void removeCourse() {}

  static void updateSyllabus(String courseCode, double oldVersion) {}
}
class CourseContent{
  final String courseCode;
  final int version;
  final String content;
  final String lastModifiedBy;

  CourseContent(this.courseCode, this.version, this.content, this.lastModifiedBy);
  
}
enum CourseOfferedFor { Dept, Cluster, Institute }
enum CourseType { Core, Elective, Lab, Mandatory }
