import 'dart:async';

import 'package:bmsce/course/course_dept_sem.dart';
import 'package:bmsce/roles/manage_dept_users.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RolesManagement extends StatelessWidget {
  final User user;

  const RolesManagement({Key key, @required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage User Roles'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: getRolesDocs(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('Loading...');
            case ConnectionState.waiting:
            case ConnectionState.active:
              return Container(
                  height: 50.0,
                  width: double.infinity,
                  child: Center(child: CircularProgressIndicator()));
            case ConnectionState.done:
              if (snapshot.hasData && snapshot.data.isNotEmpty) {
                return ListView(
                  children: List.generate(snapshot.data.length, (i) {
                    return ListTile(
                      title: Text(
                          deptNameFromPrefix(snapshot.data[i].documentID)
                              .item2),
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return ManageDeptUsers(
                            dept: snapshot.data[i].documentID,
                            user: user,
                            //deptRolesSnap: snapshot.data[i],
                          );
                        }));
                      },
                    );
                  }),
                );
              } else if (snapshot.hasData && snapshot.data.isEmpty) {
                return Center(child: Text('Data Not Found.'));
              } else {
                return Center(
                    child: Text('Something went wrong. Contact admin.'));
              }
          }
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> getRolesDocs() async {
    final rolesDocs =
        await Firestore.instance.collection('roles').getDocuments();
    return rolesDocs.documents;
  }
}
