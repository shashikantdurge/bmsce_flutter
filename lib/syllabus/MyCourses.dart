import 'package:bmsce/dataClasses/Course.dart' as dataCourse;
import 'package:flutter/material.dart';
import 'package:bmsce/dataClasses/Course.dart';
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
      return getCourseTile(courses[index]);
    })
          ..add(ListTile()));
  }

  ListTile getCourseTile(Course course) {
    return ListTile(
      title: Text(
        course.courseName,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            course.courseCode,
          ),
          Text('credits: ${course.totalCredits}'),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return SyllabusView();
        }));
      },
    );
  }
}
