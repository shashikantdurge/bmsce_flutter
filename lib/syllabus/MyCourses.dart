import 'package:bmsce/dataClasses/Course.dart' as dataCourse;
import 'package:flutter/material.dart';

import 'SyllabusView.dart';

class MyCourse extends StatefulWidget {
  MyCourseState createState() => MyCourseState();
}

class MyCourseState extends State<MyCourse> {
  List<dataCourse.Course> courses;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    courses = dataCourse.courses;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: List.generate(courses.length, (index) {
      return ListTile(
        title: Text(
          courses[index].courseName,
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              courses[index].courseCode,
            ),
            Text('credits: ${courses[index].totalCredits}'),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return SyllabusView();
          }));
        },
      );
    })
          ..add(ListTile()));
  }
}
