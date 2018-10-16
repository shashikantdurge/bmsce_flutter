import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

class Course {
  String courseName, courseCode, branch, content, codeVersion, lastModifiedBy;
  int lastModifiedOn;
  int sem, l, t, p, s, totalCredits;
  bool isInMyCourses, isOutdated;

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
      this.totalCredits,
      this.content,
      this.codeVersion,
      this.isOutdated: false,
      this.lastModifiedBy}) {
    if (totalCredits == null) {
      this.totalCredits = l + t + p + s;
    }
  }

  factory Course.fromMap(Map<String, dynamic> snap, String id) {
    return Course(
      courseName: snap["courseName"],
      courseCode: id,
      l: snap["l"],
      t: snap["t"],
      p: snap["p"],
      isOutdated: false,
      s: snap["s"],
      lastModifiedOn: snap["lastModifiedOn"].millisecondsSinceEpoch,
      codeVersion: snap["codeVersion"],
      lastModifiedBy: snap["lastModifiedBy"],
    );
  }

  ///call only while saving Course `Offline`
  Future<bool> setContent() async {
    if (this.content != null) return true;
    bool isMatch;
    final content = await Firestore.instance
        .collection('course_content')
        .document(this.courseCode)
        .get()
        .then((onValue) {
      if (!onValue.exists)
        return null;
      else {
        if (onValue.data['codeVersion'] == this.codeVersion)
          isMatch = true;
        else
          isMatch = false;
        return onValue['content'];
      }
    }).catchError((err) {
      return null;
    });
    if (content == null || !isMatch)
      return false;
    else {
      this.content = content;
      return true;
    }
  }

  void editSyllabus() {}

  void addCourse() {}

  void removeCourse() {}

  static void updateSyllabus(
      String courseCode, double oldCourseLastModifiedOn) {}
}

enum CourseOfferedFor { Dept, Cluster, Institute }
enum CourseType { Core, Elective, Lab, Mandatory }
