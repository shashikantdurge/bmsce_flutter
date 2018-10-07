import 'dart:async';

import 'package:bmsce/course/course_dept_sem.dart';
import 'package:bmsce/roles/add_user_roles.dart';
import 'package:bmsce/roles/upload_result.dart';
import 'package:bmsce/roles/uploader_dialog.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class ManageDeptUsers extends StatefulWidget {
  final User user;
  final DocumentSnapshot deptRolesSnap;
  final String dept;

  const ManageDeptUsers(
      {Key key, @required this.user, this.deptRolesSnap, @required this.dept})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    final users =
        deptRolesSnap != null ? deptRolesSnap.data.entries.toList() : null;
    return ManageDeptUsersState(users);
  }
}

class ManageDeptUsersState extends State<ManageDeptUsers> {
  List<MapEntry<String, dynamic>> users;
  ManageDeptUsersState(this.users);
  final stateKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (users != null) {
      body = _widgetListView();
    } else {
      body = FutureBuilder<DocumentSnapshot>(
        future: getUsers(),
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
              if (snapshot.hasData && snapshot.data.exists) {
                users = snapshot.data.data.entries.toList();
                return _widgetListView();
              } else if (!snapshot.data.exists) {
                return Center(child: Text('Data Not Found.'));
              } else {
                return Center(
                    child: Text('Something went wrong. Contact admin.'));
              }
          }
        },
      );
    }
    return Scaffold(
      key: stateKey,
      appBar: AppBar(
        title: Text(deptNameFromPrefix(widget.dept).item2),
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return AddUserRoles(
              user: widget.user,
            );
          }));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  _widgetListView() {
    return ListView(
      children: List.generate(users.length, (index) {
        return ListTile(
          title: Text(users[index].value['name']),
          subtitle: Text(
              '${users[index].key}\n${users[index].value['role'].toString().toUpperCase()}'),
          trailing: PopupMenuButton(
            onSelected: (item) {
              if (item == 'edit')
                widgetEditRole(widget.dept, users[index].key,
                    users[index].value['name'], users[index].value['role']);
              if (item == 'remove')
                removeRole(
                    widget.dept, users[index].key, users[index].value['name']);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Edit'),
                  value: 'edit',
                  enabled: widget.user.subRoles
                      .contains(getRoleFrmString(users[index].value['role'])),
                ),
                PopupMenuItem(
                  child: Text('Remove'),
                  value: 'remove',
                  enabled: widget.user.subRoles
                      .contains(getRoleFrmString(users[index].value['role'])),
                ),
              ];
            },
          ),
        );
      }),
    );
  }

  removeRole(String dept, String email, String name) async {
    final tuple = Tuple6(dept, email, name, "DELETE", true, null);
    final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return UploaderDialog(
            users: <Tuple6>[tuple],
          );
        });
    if (result is List<List<Tuple6>>)
      showDialog(
          context: context,
          builder: (context) {
            return UploadResult(
              failedUsers: result[1],
              successfulUsers: result[0],
            );
          });
  }

  widgetEditRole(String dept, String email, String name, String role) async {
    final result = await showDialog(
        context: context,
        builder: (context) {
          return EditRoleDialog(dept, email, name, role, widget.user.subRoles);
        });
    if (result is Tuple6) {
      if (!result.item5) {
        //Role not changes
        stateKey.currentState.showSnackBar(SnackBar(
          content: Text('Role not changed'),
          duration: Duration(milliseconds: 800),
        ));
      } else {
        final result2 = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return UploaderDialog(
                users: <Tuple6>[result],
              );
            });
        if (result2 is List<List<Tuple6>>)
          showDialog(
              context: context,
              builder: (context) {
                return UploadResult(
                  failedUsers: result2[1],
                  successfulUsers: result2[0],
                );
              });
      }
    }
  }

  Future<DocumentSnapshot> getUsers() async {
    final usersSnap = await Firestore.instance
        .collection('roles')
        .document(widget.dept)
        .get();
    return usersSnap;
  }
}

class EditRoleDialog extends StatefulWidget {
  final String dept, email, name, role;
  final List<Role> subRoles;

  const EditRoleDialog(
      this.dept, this.email, this.name, this.role, this.subRoles,
      {Key key})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return EditRoleDialogState();
  }
}

class EditRoleDialogState extends State<EditRoleDialog> {
  String role;
  @override
  void initState() {
    super.initState();
    role = widget.role;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.name),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        FlatButton(
          child: Text('Change'),
          onPressed: () {
            final value = Tuple6(widget.dept, widget.email, widget.name,
                this.role, widget.role != this.role, null);
            Navigator.pop(context, value);
          },
        ),
      ],
      content: DropdownButton(
        hint: Text('Select Role'),
        value: role,
        items: List.generate(widget.subRoles.length, (index) {
          return DropdownMenuItem(
            child: Text(RoleValueMap[widget.subRoles[index]].toUpperCase()),
            value: RoleValueMap[widget.subRoles[index]],
          );
        }),
        onChanged: (value) {
          setState(() {
            role = value;
          });
        },
      ),
    );
  }
}
