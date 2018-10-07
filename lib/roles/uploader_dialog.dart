import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class UploaderDialog extends StatefulWidget {
  final List<Tuple6> users;

  const UploaderDialog({Key key, @required this.users}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return UploaderDialogState(users.length);
  }
}

class UploaderDialogState extends State<UploaderDialog> {
  final int totalUsers;
  int usersProcessed;
  List<Tuple6> successfulUsers, failedUsers;

  UploaderDialogState(this.totalUsers);
  @override
  void initState() {
    super.initState();
    usersProcessed = 0;
    successfulUsers = [];
    failedUsers = [];
    process();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(8.0),
      title: Row(
        children: <Widget>[
          CircularProgressIndicator(
            value: usersProcessed / totalUsers,
          ),
          Text('Processing... $usersProcessed/$totalUsers')
        ],
      ),
    );
  }

  Future<bool> addUser(Tuple6 user) async {
    if (!user.item5 || user.item4 == null) return false;
    final Map<String, dynamic> data = {};
    if (user.item4 != "DELETE")
      data[user.item2.toString()] = {"name": user.item3, "role": user.item4};
    else
      data[user.item2.toString()] = FieldValue.delete();
    bool isSuccessful;
    await Firestore.instance
        .collection('roles')
        .document(user.item1)
        .setData(data, merge: true)
        .then((onValue) {
      isSuccessful = true;
    }).catchError((err) {
      isSuccessful = false;
    });
    return isSuccessful;
  }

  void process() async {
    for (int i = 0; i < widget.users.length; i++) {
      if (await addUser(widget.users[i])) {
        successfulUsers.add(widget.users[i]);
      } else {
        failedUsers.add(widget.users[i]);
      }
      setState(() {
        usersProcessed = i + 1;
      });
    }
    Navigator.of(context).pop([successfulUsers, failedUsers]);
  }
}
