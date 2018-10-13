import 'dart:convert';

class Student {
  final String usn, name;

  Student({
    this.usn,
    this.name,
  });
}

class StudentAbstractDetail extends Student {
  String detailDataJson;
  String approxSemester;
  double cgpa, sgpa;
  int numOfBackLogs,
      num5thAttemptCourses,
      cumulativeCreditsEarned,
      creditsPending;
  bool isYearBack;
  bool selected = false;

  StudentAbstractDetail(
      {String usn,
      String name,
      this.approxSemester,
      this.cgpa,
      this.sgpa,
      this.num5thAttemptCourses,
      this.creditsPending,
      this.cumulativeCreditsEarned,
      this.isYearBack,
      this.numOfBackLogs,
      this.detailDataJson})
      : super(usn: usn, name: name);

//TODO:fix name field
  StudentAbstractDetail.fromFirestoreObj(
      String id, Map<String, dynamic> firestoreObj)
      : super(name: firestoreObj[StudentDetail.NAME], usn: id) {
    final maxSemKey =
        _getMaxSemester(firestoreObj[StudentDetail.APPROX_SEM_MAP] as Map);
    if (maxSemKey == null) {
      this.approxSemester = '-';
      this.cgpa = 0.0;
      this.sgpa = 0.0;
      this.num5thAttemptCourses = 0;
      this.creditsPending = 0;
      this.cumulativeCreditsEarned = 0;
      this.isYearBack = false;
      this.numOfBackLogs = 0;
    } else {
      this.detailDataJson =
          json.encode(firestoreObj, toEncodable: (value) => value.toString());
      this.approxSemester =
          firestoreObj[StudentDetail.APPROX_SEM_MAP][maxSemKey];
      this.cgpa = firestoreObj[StudentDetail.CGPA_MAP][maxSemKey] * 1.0;
      this.cgpa = double.parse(cgpa.toStringAsFixed(2));
      this.sgpa = firestoreObj[StudentDetail.SGPA_MAP][maxSemKey] * 1.0;
      this.cumulativeCreditsEarned =
          firestoreObj[StudentDetail.TOT_CREDITS_ERND];
      final backLogDetails =
          _getBacklogsDetail(firestoreObj[StudentDetail.BACKLOGS_MAP]);
      this.numOfBackLogs = backLogDetails[0];
      this.num5thAttemptCourses = backLogDetails[1];
      this.creditsPending = backLogDetails[2];
      this.isYearBack =
          _isYearBackStudent(firestoreObj[StudentDetail.APPROX_SEM_MAP]);
    }
  }

  static List<int> _getBacklogsDetail(Map backLogsMap) {
    //[numOfBacklogs,5thattempts, creditsPending]
    int a = 0, b = 0, c = 0;
    backLogsMap.keys.forEach((bl) {
      if (!backLogsMap[bl]["isCleared"]) {
        a++;
        if (backLogsMap[bl]["attempts"] > 4) b++;
        c += backLogsMap[bl]["credits"];
      }
    });
    return [a, b, c];
  }

  static String _getMaxSemester(Map firestoreObj) {
    if (firestoreObj.isEmpty) return null;
    final list = firestoreObj.keys.toList().cast<String>();
    list.sort();
    return list.last;
  }

  static bool _isYearBackStudent(Map firestoreObj) {
    Set semesters = Set();
    bool yb = false;
    firestoreObj.values.forEach((sem) {
      if (!semesters.add(sem)) {
        yb = true;
      }
    });
    return yb;
  }
}

class StudentDetail extends Student {
  static const NAME = "name";
  static const CGPA_MAP = "cgpaMap";
  static const SGPA_MAP = "sgpaMap";
  static const BACKLOGS_MAP = "backLogsMap";
  static const UPDATED_ON = "updatedOn";
  static const APPROX_SEM_MAP = "approxSemesterMap";
  static const TOT_CREDITS_ERND = "cumulativeCreditsEarned";
  bool isOffline;
  List<StudentSemGpa> semestersGps = [];
  List<BackLog> backlogs = [];

  StudentDetail.fromFirestoreObj(Map<String, dynamic> firestoreObj, String id,
      {this.isOffline: false})
      : super(name: firestoreObj[NAME], usn: id) {
    final cgpaMap = firestoreObj[CGPA_MAP] as Map;
    final sgpaMap = firestoreObj[SGPA_MAP] as Map;
    final approxSemesterMap = firestoreObj[APPROX_SEM_MAP] as Map;
    final backLogsMap = firestoreObj[BACKLOGS_MAP] as Map;

    final sortedKeys = sortOnKeys(approxSemesterMap);
    sortedKeys.forEach((key) {
      this.semestersGps.add(StudentSemGpa(
          cgpa: cgpaMap[key] * 1.0,
          sem: approxSemesterMap[key],
          semKey: key,
          sgpa: sgpaMap[key] * 1.0));
    });
    backLogsMap.values.forEach((bl) {
      this.backlogs.add(BackLog.fromMap(bl));
    });
    backlogs.sort((a, b) {
      if (a.isCleared) {
        return 1;
      } else {
        return -1;
      }
    });
  }

  static List<String> sortOnKeys(Map firestoreObj) {
    if (firestoreObj.isEmpty) return [];
    final list = firestoreObj.keys.toList().cast<String>();
    list.sort();
    return list;
  }
}

class StudentSemGpa {
  double cgpa;
  double sgpa;
  String sem;
  String semKey;
  StudentSemGpa({this.cgpa, this.sem, this.semKey, this.sgpa});
}

class BackLog {
  String code, name, grade;
  bool isCleared;
  int attempts, credits;
  BackLog(
      {this.attempts,
      this.code,
      this.credits,
      this.grade,
      this.isCleared,
      this.name});

  BackLog.fromMap(Map map)
      : attempts = map["attempts"],
        code = map["code"],
        name = map["name"],
        credits = map["credits"],
        grade = map["grade"],
        isCleared = map["isCleared"];
}
