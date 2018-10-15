import 'package:bmsce/academics/student_marks_detail.dart';
import 'package:bmsce/academics/students_academics.dart';
import 'package:bmsce/authentication/sign_in.dart';
import 'package:bmsce/course/course_dept_sem.dart';
import 'package:bmsce/roles/manage_dept_users.dart';
import 'package:bmsce/roles/roles_management.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatelessWidget {
  UserProfile({Key key}) : super(key: key);
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
              User.instance.displayName,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'logout') logout(context);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Logout'),
                  value: 'logout',
                )
              ];
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          getUserDetailsCard(User.instance, context),
          getAccessibilityCard(User.instance),
          getAboutUsCard()
        ],
      ),
    );
  }

  logout(context) {
    FirebaseAuth.instance.signOut().then((onValue) {
      SharedPreferences.getInstance().then((pref) {
        pref.clear();
      });
    });
    //TODO:remove all data. ISSUE IS THERE. its not getting replaced
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return Login();
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
                : Text('Dept Not Available'),
            // subtitle: Text('Department'),
          ),
          ListTile(
              leading: Icon(Icons.assignment_ind),
              title: user.usn != null
                  ? Text(user.usn)
                  : Text(
                      'USN not set',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).textTheme.caption.color,
                      ),
                    )
              // subtitle: Text('Department'),
              ),
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
          User.instance.isPermittedFor(Activity.ACADEMIC_STUDENT_VIEW)
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
          User.instance.isPermittedFor(Activity.ACADEMIC_PROCTOR_VIEW)
              ? ListTile(
                  title: Text('My Students'),
                  leading: Icon(Icons.people),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.of(stateKey.currentContext)
                        .push(MaterialPageRoute(builder: (context) {
                      return StudentDataTable();
                    }));
                  },
                )
              : Padding(padding: EdgeInsets.all(0.0)),
          User.instance.isPermittedFor(Activity.ROLE_MANAGE)
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
              : Padding(padding: EdgeInsets.all(0.0))
        ],
      ),
    );
  }
}
