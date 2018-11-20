import 'package:bmsce/academics/student.dart';
import 'package:bmsce/academics/student_marks_detail.dart';
import 'package:bmsce/academics/students_academics.dart';
import 'package:bmsce/authentication/sign_in1.dart';
import 'package:bmsce/course/course_dept_sem.dart';
import 'package:bmsce/main.dart';
import 'package:bmsce/notification/announcement.dart';
import 'package:bmsce/notification/notifications.dart';
import 'package:bmsce/roles/manage_dept_users.dart';
import 'package:bmsce/roles/roles_management.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatelessWidget {
  UserProfile({Key key}) : super(key: key);
  final bool debugMode = false;
  final stateKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: stateKey,
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(User.instance.photoUrl),
            ),
            Text(
              '  ${User.instance.displayName}',
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return Notifications();
              }));
            },
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'logout') logout(context);
              if (value == "edit_profile")
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return ProfileEdit(
                    user: User.instance,
                  );
                }));
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child:
                      Row(children: [Icon(Icons.edit), Text('Edit profile')]),
                  value: 'edit_profile',
                ),
                PopupMenuItem(
                  child: Row(
                      children: [Icon(Icons.exit_to_app), Text('Sign out')]),
                  value: 'logout',
                ),
              ];
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            getUserDetailsCard(User.instance, context),
            getAccessibilityCard(User.instance),
            getAboutUsCard()
          ],
        ),
      ),
    );
  }

  logout(context) async {
    await FirebaseAuth.instance.signOut().then((onValue) {
      SharedPreferences.getInstance().then((pref) {
        pref.clear();
      });
    });
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return Splash(from: 'main');
    }));
  }

  Widget getUserDetailsCard(User user, context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.email),
            title: Text(user.email ?? 'Email Not Available'),
            // subtitle: Text('Email'),
          ),
          ListTile(
            leading: Icon(Icons.widgets),
            title: user.dept != null
                ? Text(deptNameFromPrefix(user.dept).item2)
                : Text(
                    'Department Not Set',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).textTheme.caption.color),
                  ),
            // subtitle: Text('Department'),
          ),
          user.usn != null
              ? ListTile(
                  leading: Icon(Icons.assignment_ind), title: Text(user.usn)
                  // subtitle: Text('Department'),
                  )
              : Padding(padding: EdgeInsets.all(0.0)),
        ],
      ),
    );
  }

  getAboutUsCard() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('About us'),
        trailing: Icon(Icons.keyboard_arrow_right),
      ),
    );
  }

  getAccessibilityCard(User user) {
    return Card(
      child: Column(
        children: [
          User.instance.isPermittedFor(Activity.ACADEMIC_STUDENT_VIEW) ||
                  debugMode
              ? ListTile(
                  title: Text('Academic Record'),
                  leading: Icon(Icons.school),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(stateKey.currentContext)
                        .push(MaterialPageRoute(builder: (context) {
                      return StudentDetailView(
                        name: 'Academic Record',
                        usn: user.usn ?? '1BM14XX000',
                      );
                    }));
                  },
                )
              : Padding(padding: EdgeInsets.all(0.0)),
          User.instance.isPermittedFor(Activity.ACADEMIC_PROCTOR_VIEW) ||
                  debugMode
              ? ListTile(
                  title: Text('My Students'),
                  leading: Icon(Icons.school),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(stateKey.currentContext)
                        .push(MaterialPageRoute(builder: (context) {
                      return StudentDataTable();
                    }));
                  },
                )
              : Padding(padding: EdgeInsets.all(0.0)),
          User.instance.isPermittedFor(Activity.ROLE_MANAGE) || debugMode
              ? ListTile(
                  title: Text('Role Management'),
                  leading: Icon(Icons.supervisor_account),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(stateKey.currentContext)
                        .push(MaterialPageRoute(builder: (context) {
                      return User.instance.isAdmin
                          ? RolesManagement(user: User.instance)
                          : ManageDeptUsers(
                              user: User.instance, dept: User.instance.dept);
                    }));
                  },
                )
              : Padding(padding: EdgeInsets.all(0.0)),
          User.instance.isPermittedFor(Activity.BROADCAST_MESSAGE) || debugMode
              ? ListTile(
                  title: Text('Announcement'),
                  leading: Icon(Icons.ac_unit),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(stateKey.currentContext)
                        .push(MaterialPageRoute(builder: (context) {
                      return Announcement();
                    }));
                  },
                )
              : Padding(padding: EdgeInsets.all(0.0)),
          StudentUsnChecker(
            debug: debugMode,
          )
        ],
      ),
    );
  }
}

class StudentUsnChecker extends StatefulWidget {
  final bool debug;

  const StudentUsnChecker({Key key, this.debug = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StudentUsnCheckerState();
  }
}

class StudentUsnCheckerState extends State<StudentUsnChecker> {
  TextEditingController controller = TextEditingController(text: '1BM');
  String helperText = "";
  StudentAbstractDetail studentDetails;

  @override
  Widget build(BuildContext context) {
    return User.instance.isPermittedFor(Activity.BROADCAST_MESSAGE) ||
            widget.debug
        ? ListTile(
            contentPadding: EdgeInsets.all(4.0),
            title: TextFormField(
              autovalidate: true,
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                  hintText: 'Enter USN', helperText: helperText),
//              validator: (str) {
//                if (str.length == 10)
//                  checkUsn();
//                else if (helperText.isNotEmpty) {
//
//                }
//              },
            ),
            leading: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(Icons.school),
            ),
            trailing: IconButton(
              padding: EdgeInsets.all(0.0),
              icon: Icon(Icons.keyboard_arrow_right),
              onPressed: checkUsn,
            ),
          )
        : Padding(padding: EdgeInsets.all(0.0));
  }

  checkUsn() async {
    setState(() {
      helperText = "Checking USN...";
    });
    studentDetails = await StudentDetailView.getStudentDetails(controller.text);
    if (studentDetails == null) {
      WidgetsBinding.instance.addPostFrameCallback((d) {
        setState(() {
          helperText = "Not found";
        });
      });
    } else {
      setState(() {
        helperText = "";
      });
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return StudentDetailView(usn: studentDetails.usn, name: studentDetails.name);
      }));
    }
  }
}
