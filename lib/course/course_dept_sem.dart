import 'package:bmsce/course/course.dart';
import 'package:tuple/tuple.dart';

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

getNumberText(str) {
  switch (str.toString()) {
    case "1":
      return '1st';
    case "2":
      return '2nd';
    case "3":
      return '3rd';
    default:
      return '${str}th';
  }
}

const List<String> Semesters = [
  "1", //st
  "2", //nd
  "3", //rd
  "4", //th
  "5",
  "6",
  "7",
  "8",
  "9",
  "X"
];
const List<dynamic> Sections = ["A", "B", "C", "D"];
//IMPORTANT NOTE: true comes FIRST, false comes LAST. 3rd item indicates if it is a Branch
const Departments = [
  Tuple3("AT", "Architecture", true),
  Tuple3("BT", "Bio-Technology", true),
  Tuple3("CE", "Civil Engineering", true),
  Tuple3("CH", "Chemical Engineering", true),
  Tuple3("MCA", "Computer Applications", true),
  Tuple3("CS", "Computer Science & Engg", true),
  Tuple3("EC", "Electronics & Communication Engg", true),
  Tuple3("EE", "Electrical & Electronics Engg", true),
  Tuple3("IS", "Information Science & Engg", true),
  Tuple3("IE", "Industrial Engg & Management", true),
  Tuple3("MBA", "Management studies & Research Center", true),
  Tuple3("ME", "Mechanical Engineering", true),
  Tuple3("ML", "Medical Electronics", true),
  Tuple3("TE", "Telecommunication Engineering", true),
  Tuple3("PY", "Physics", false),
  Tuple3("CY", "Chemistry", false),
  Tuple3("MA", "Mathematics", false),
  Tuple3("ADMIN", "Administration", false),
  Tuple3(null, "Other", false),
];

Tuple3 deptNameFromPrefix(String deptId) => Departments.firstWhere((tuple) {
      return tuple.item1 == deptId;
    });
