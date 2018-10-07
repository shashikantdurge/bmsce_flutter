import 'dart:async';

import 'package:bmsce/academics/student_marks_detail.dart';
import 'package:bmsce/academics/students_academics.dart';
import 'package:bmsce/authentication/sign_in.dart';
import 'package:bmsce/roles/manage_dept_users.dart';
import 'package:bmsce/roles/roles_management.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatelessWidget {
  final FirebaseUser firebaseUser;
  UserProfile({Key key, @required this.firebaseUser}) : super(key: key);
  final stateKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: stateKey,
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 40.0,
            backgroundImage: NetworkImage(firebaseUser.photoUrl),
          ),
          Text(firebaseUser.displayName),
          FutureBuilder<User>(
            future: getUser(),
            builder: (context, user) {
              switch (user.connectionState) {
                case ConnectionState.none:
                  return Spacer();
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return CircularProgressIndicator();
                case ConnectionState.done:
                  if (user.hasData)
                    return buildProfileEnv(user.data);
                  else
                    return Spacer();
              }
            },
          ),
          Spacer(),
          FlatButton(
            child: Text('LOG OUT'),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((onValue) {
                SharedPreferences.getInstance().then((pref) {
                  pref.clear();
                });
              });
              //TODO:remove all data. ISSUE IS THERE. its not getting replaced
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) {
                return Login();
              }));
            },
          )
        ],
      ),
    );
  }

  Future<User> getUser() async {
    final preferences = await SharedPreferences.getInstance();
    final role = preferences.getString('user_property_role');
    User user = User.fromRole(role,
        dept: preferences.getString('user_property_dept'),
        displayName: firebaseUser.displayName,
        email: firebaseUser.email,
        photoUrl: firebaseUser.photoUrl,
        usn: preferences.getString('user_property_usn'));
    return user;
  }

  getUsn(user) {
    if (user is Student) {
      return Text('USN   : ${user?.usn ?? 'NA'}');
    }
  }

  getStudentAcademicRecord(String usn) {
    return ListTile(
      title: Text('Academic Record'),
      onTap: () {
        Navigator.of(stateKey.currentContext)
            .push(MaterialPageRoute(builder: (context) {
          return StudentDetailView(
            name: 'Academic Record',
            usn: usn ?? 'USN is Empty',
          );
        }));
      },
    );
  }

  getAcademicRecord(User user) {
    if (user.isPermittedFor(Activity.ACADEMIC_PROCTOR_VIEW)) {
      return ListTile(
        title: Text('My Students'),
        onTap: () {
          Navigator.of(stateKey.currentContext)
              .push(MaterialPageRoute(builder: (context) {
            return StudentDataTable();
          }));
        },
      );
    }
  }

  getRolesManagement(User user) {
    if (user.isPermittedFor(Activity.ROLE_MANAGE)) {
      return ListTile(
        title: Text('Role Management'),
        onTap: () {
          Navigator.of(stateKey.currentContext)
              .push(MaterialPageRoute(builder: (context) {
            return user.isAdmin
                ? RolesManagement(user: user)
                : ManageDeptUsers(user: user, dept: user.dept);
          }));
        },
      );
    }
  }

  Widget buildProfileEnv(User user) {
    return Column(
      children: <Widget>[
        Text('Email : ${user.email}'),
        Text('Dept : ${user?.dept ?? 'NA'}'),
        getUsn(user) ?? Text(''),
        user is Student ? getStudentAcademicRecord(user.usn) : Text(''),
        getAcademicRecord(user) ?? Text(''),
        getRolesManagement(user) ?? Text('')
        // ,Row(
        //   children: <Widget>[
        //     Text('Email'),
        //     Text(user.displayName)
        //   ],
        // )
      ],
    );
  }
}
