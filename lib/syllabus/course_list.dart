import 'package:bmsce/course/course.dart' as dataCourse;
import 'package:bmsce/course/course.dart';
import 'package:bmsce/syllabus/course_content_view.dart';
import 'package:flutter/material.dart';
import 'package:bmsce/course/course_provider_sqf.dart';

class MyCourse extends StatefulWidget {
  MyCourseState createState() => MyCourseState();
  final courseSqf = CourseProviderSqf();
}

class MyCourseState extends State<MyCourse> {
  List<dataCourse.Course> courses;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Course>>(
        future: widget.courseSqf.getAllCourses(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return Center(
                child: Text('Loading...'),
              );
              break;
            case ConnectionState.done:
              if (snapshot.hasData) {
                if (snapshot.data.isNotEmpty) {
                  return ListView(
                    children: List.generate(snapshot.data.length, (index) {
                      return getCourseTile(snapshot.data[index]);
                    }),
                  );
                } else if (snapshot.data.isEmpty) {
                  return Center(
                    child: Text('Chill!!!'),
                  );
                }
              } else {
                return Center(
                  child: Text('Something is wrong? ${snapshot.hasError}'),
                );
              }
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data.isNotEmpty) {
              return ListView(
                children: List.generate(snapshot.data.length, (index) {
                  return getCourseTile(snapshot.data[index]);
                }),
              );
            } else if (snapshot.hasData && snapshot.data.isEmpty) {
              return Center(
                child: Text('Chill!!!'),
              );
            } else {
              return Center(
                child: Text('Something is wrong!!! ${snapshot.hasData}'),
              );
            }
          } else {
            return Center(
              child: Text('Loading...'),
            );
          }
        });
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
