import 'dart:collection' as coll;

import 'package:bmsce/course/course.dart';

class CourseGroup {
  String coursesType, courseOfferedFor, courseGroup;
  List<Course> courses;

  CourseGroup({this.courseGroup, this.courses});

  static String getCourseGroup(String offeredForAndType) {
    if (offeredForAndType.toUpperCase().trim() == 'CC') return 'C Cycle';
    if (offeredForAndType.toUpperCase().trim() == 'PC') return 'P Cycle';

    String offeredFor, type;
    switch (offeredForAndType[0].toUpperCase()) {
      case 'D':
        offeredFor = "Dept";
        break;
      case 'G':
        offeredFor = "Cluster";
        break;
      case 'I':
        offeredFor = "Institute";
        break;
      default:
        offeredFor = offeredForAndType[0].toUpperCase();
    }
    switch (offeredForAndType[1].toUpperCase()) {
      case 'C':
        type = "Core";
        break;
      case 'E':
        type = "Elective";
        break;
      case 'L':
        type = "Lab";
        break;
      case 'M':
        type = "Mandatory";
        break;
      default:
        type = offeredForAndType[1].toUpperCase();
    }
    return '$offeredFor $type ${offeredForAndType.replaceRange(0, 2, '')}'
        .trim();
  }
}

final depts = coll.SplayTreeMap.from(<String, String>{
  "CS": "Computer Science",
  "IS": "Information Science",
  "AT": "Architecture"
});

final semesters = coll.SplayTreeMap.from(<String, String>{
  "1": "1",
  "2": "2",
  "3": "3",
  "4": "4",
  "5": "5",
  "6": "6",
  "7": "7",
  "8": "8",
  "9": "9",
  "X": "X",
});
