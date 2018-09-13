import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCourse extends StatefulWidget {
  final bool isAdd;
  final String branch;
  

  const ManageCourse({Key key, @required this.isAdd}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ManageCourseState();
  }
}

class ManageCourseState extends State<ManageCourse> {
  final TextEditingController codeEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String wait = "Please wait...";

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(12.0),
      title: widget.isAdd ? Text('Add') : Text('Delete'),
      children: <Widget>[
        Form(
          key: _formKey,
          autovalidate: true,
          child: TextFormField(
            autofocus: true,
            controller: codeEditingController,
            autovalidate: true,
            decoration: InputDecoration(
                labelStyle: TextStyle(color: Colors.black),
                labelText: 'Course Code'),
            validator: (courseCode) {
              if (courseCode.trim().length == 10) {
                getCourseName(courseCode);
              }else{
                wait = "Please wait...";
              }
              return courseCode.trim().length != 10
                  ? 'Course Code cannot be Empty'
                  : wait;
            },
            onFieldSubmitted: (courseCode) {
              if (_formKey.currentState.validate()) {
                print('Valid');
                //Navigator.of(context).pop(codeEditingController.text);
              } else {
                print('InValid');
              }
            },
          ),
        ),
        ButtonBar(
          children: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: widget.isAdd ? Text('Add') : Text('Delete'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  print('Valid');
                  //Navigator.of(context).pop(codeEditingController.text);
                } else {
                  print('InValid');
                }
              },
            ),
          ],
        )
      ],
    );
  }

  getCourseName(String courseCode) async {
    Firestore.instance
        .collection('courses')
        .document(courseCode)
        .get()
        .then((course) {
      setState(() {
        if (course.exists)
          wait = course.data['courseName'];
        else
          wait = "Not found.";
      });
    });
  }
}
