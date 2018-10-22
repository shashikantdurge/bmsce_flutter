import 'package:meta/meta.dart';

abstract class User {
  static User instance;
  final String displayName, photoUrl, email;
  final bool isAdmin;
  final Role whoAmI;
  String usn, dept, semester, section;
  final List<Activity> permittedActivities;
  final List<Role> subRoles;

  User(this.displayName, this.photoUrl, this.email, this.dept, this.isAdmin,
      this.permittedActivities, this.subRoles, this.whoAmI,
      {this.usn, this.semester, this.section});
  // get isAdmin() => isAdmin;
  bool isPermittedFor(Activity activity) {
    return this.permittedActivities.contains(activity);
  }

  factory User.fromRole(String role,
      {@required String displayName,
      @required String photoUrl,
      @required String email,
      @required String dept,
      String usn,
      String semester,
      String section}) {
    switch (role) {
      case 'admin':
      case 'hod':
        return HodOrAdmin(displayName, photoUrl, email, dept);
      case 'teacher':
        return Teacher(displayName, photoUrl, email, dept);
      case 'super_student':
        return SuperStudent(
            displayName, photoUrl, email, dept, usn, semester, section);
      default:
        if (usn != null && usn.isNotEmpty)
          return Student(
              displayName, photoUrl, email, dept, usn, semester, section);
        else
          return DefaultUser(displayName, photoUrl, email, dept);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "name": this.displayName,
      "dept": this.dept,
      "photoUrl": this.photoUrl,
      "usn": this.usn,
      "semester": this.semester,
      "section": this.section
    };
  }
}

class Student extends User {
  static final List<Activity> myActivities = [Activity.ACADEMIC_STUDENT_VIEW];
  static final List<Role> mySubRoles = [];
  Student(String displayName, String photoUrl, String email, String dept,
      String usn, String semester, String section,
      [List<Activity> myActivities, List<Role> mySubRoles, Role role])
      : super(
          displayName,
          photoUrl,
          email,
          dept,
          false,
          myActivities ?? Student.myActivities,
          mySubRoles ?? Student.mySubRoles,
          role ?? Role.STUDENT,
          usn: usn,
          section: section,
          semester: semester,
        );
}

class Teacher extends User {
  static final List<Activity> myActivities = [
    Activity.COLLEGE_MAP,
    Activity.ROLE_MANAGE,
    Activity.ACADEMIC_PROCTOR_VIEW,
    Activity.PORTION_SEND
  ];
  static final List<Role> mySubRoles = [Role.SUPER_STUDENT];
  Teacher(String displayName, String photoUrl, String email, String dept,
      [bool isAdmin,
      List<Activity> myActivities,
      List<Role> mySubRoles,
      Role role])
      : super(
            displayName,
            photoUrl,
            email,
            dept,
            isAdmin ?? false,
            myActivities ?? Teacher.myActivities,
            mySubRoles ?? Teacher.mySubRoles,
            role ?? Role.TEACHER);
}

class HodOrAdmin extends Teacher {
  static final List<Activity> myActivities = [
    Activity.COLLEGE_MAP,
    Activity.ROLE_MANAGE,
    Activity.ACADEMIC_PROCTOR_VIEW,
    Activity.PORTION_SEND,
    Activity.BROADCAST_MESSAGE
  ];
  static final List<Role> mySubRoles = [
    Role.HOD_ADMIN,
    Role.SUPER_STUDENT,
    Role.TEACHER
  ];
  HodOrAdmin(String displayName, String photoUrl, String email, String dept)
      : super(displayName, photoUrl, email, dept, dept == "ADMIN", myActivities,
            mySubRoles, Role.HOD_ADMIN);
}

class SuperStudent extends Student {
  static final List<Activity> myActivities = [
    Activity.COLLEGE_MAP,
    Activity.PORTION_SEND,
    Activity.ACADEMIC_STUDENT_VIEW
  ];
  static final List<Role> mySubRoles = [];
  SuperStudent(String displayName, String photoUrl, String email, String dept,
      String usn, String semester, String section)
      : super(displayName, photoUrl, email, dept, usn, semester, section,
            myActivities);
}

class DefaultUser extends User {
  static final List<Activity> myActivities = [];
  static final List<Role> mySubRoles = [];
  DefaultUser(String displayName, String photoUrl, String email, String dept)
      : super(displayName, photoUrl, email, dept, false, myActivities,
            mySubRoles, Role.SUPER_STUDENT);
}

enum Role { STUDENT, SUPER_STUDENT, TEACHER, HOD_ADMIN, DEFAULT }
const Map<Role, String> RoleValueMap = {
  Role.HOD_ADMIN: "hod",
  Role.TEACHER: "teacher",
  Role.SUPER_STUDENT: "super_student",
  Role.STUDENT: "student",
  Role.DEFAULT: "default",
};
Role getRoleFrmString(String role) {
  if (role == "admin")
    return Role.HOD_ADMIN;
  else
    return RoleValueMap.entries.firstWhere((entry) {
      return entry.value == role;
    }).key;
}

enum Activity {
  COLLEGE_MAP,
  ROLE_MANAGE,
  ACADEMIC_PROCTOR_VIEW,
  ACADEMIC_STUDENT_VIEW,
  PORTION_SEND,
  BROADCAST_MESSAGE,
}
