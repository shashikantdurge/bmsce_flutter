import 'dart:async';
import 'dart:collection';

import 'package:bmsce/dataClasses/Course.dart';
import 'package:bmsce/dataClasses/DeptSemCourses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'SyllabusView.dart';

class AddCourse extends StatefulWidget {
  AddCourse({this.firestore});
  final Firestore firestore;
  AddCourseState createState() => AddCourseState();
}

class AddCourseState extends State<AddCourse> {
  AddCourseState();

  String selectedBranch;
  String selectedSem;
  String semOrCycle;
  List<dynamic> branches = depts.values.toList();
  List<dynamic> branchKeys = depts.keys.toList();
  List<dynamic> semValues = semesters.values.toList();
  List<dynamic> semKeys = semesters.keys.toList();
  int totalSems = 8;
  final branchSemListQ = ListQueue<String>();
  final branchSemCourseGrpMap = HashMap<String, List<CourseGroup>>();
  dynamic fetchCourseFunct;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'addCourse',
      theme: new ThemeData(
        /*primaryColor: Colors.red[400],
        buttonColor: Colors.red[400],
        accentColor: Colors.red[300],
        canvasColor: Colors.grey[50],*/
        //brightness: Brightness.light,
        primarySwatch: const MaterialColor(
          0xFFF44336,
          const <int, Color>{
            50: const Color(0xFFFFEBEE),
            100: const Color(0xFFFFCDD2),
            200: const Color(0xFFEF9A9A),
            300: const Color(0xFFE57373),
            400: const Color(0xFFEF5350),
            500: const Color(0xFFF44336),
            600: const Color(0xFFE53935),
            700: const Color(0xFFD32F2F),
            800: const Color(0xFFC62828),
            900: const Color(0xFFB71C1C),
          },
        ),
        primaryColor: Colors.red[500],

        //primarySwatch: Colors.red[400],
      ),
      home: Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              DropdownButton(
                hint: Text('Branch'),
                items: List.generate(depts.length, (index) {
                  return DropdownMenuItem<String>(
                    child: Text(branches[index]),
                    value: branchKeys[index],
                  );
                }),
                onChanged: (t) {
                  setState(() {
                    selectedBranch = t;
                    if (t == "AT") {
                      totalSems = 10;
                    } else {
                      totalSems = 8;
                    }
                  });
                  if (selectedSem != null)
                    fetchCourseFunct = fetchCourse(selectedBranch, selectedSem);
                },
                value: selectedBranch,
              ),
              DropdownButton(
                hint: Text('Sem'),
                items: List.generate(totalSems, (index) {
                  return DropdownMenuItem<String>(
                    child: Text(semValues[index]),
                    value: semKeys[index],
                  );
                }),
                onChanged: (t) {
                  setState(() {
                    selectedSem = t;
                  });
                  if (selectedBranch != null)
                    fetchCourseFunct = fetchCourse(selectedBranch, selectedSem);
                },
                value: selectedSem,
              )
            ],
          ),
        ),
        appBar: AppBar(
          title: Text('Add Course'),
        ),
        body: FutureBuilder<List<CourseGroup>>(
          key: futureKey,
          future: fetchCourseFunct,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Center(child: Text('Please select Branch and Sem'));
                break;
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
                break;
              case ConnectionState.active:
                break;
              case ConnectionState.done:
                break;
            }
            if (snapshot.hasData && snapshot.data.isNotEmpty) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(snapshot.data.length, (index) {
                    return getCourseCatCard(snapshot.data[index],context);
                  }),
                ),
              );
            } else if (snapshot.hasData && snapshot.data.isEmpty) {
              return Center(child: Text('Not Available'));
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  final futureKey = ValueKey("futureBuilder");

  Future<List<CourseGroup>> fetchCourse(String dept, String sem) async {
    assert(dept != null);
    assert(sem != null);
    if (branchSemCourseGrpMap.containsKey(dept + sem))
      return branchSemCourseGrpMap[dept + sem];
    var lessThanSem;
    try {
      lessThanSem = semKeys[semKeys.indexOf(sem) + 1];
    } on RangeError {
      lessThanSem = "Z";
    }
    final courses = await widget.firestore
        .collection('courses')
        .where("registeredDepts." + dept, isGreaterThanOrEqualTo: sem)
        .where("registeredDepts." + dept, isLessThan: lessThanSem)
        .getDocuments()
        .catchError((error) {
    });
    final courseGrpMap = HashMap<String, CourseGroup>();
    courses.documents.forEach((courseDocument) {
      var courseCat; // is CourseGroup.courseGroup
      switch (courseDocument.data["registeredDepts"][dept].toString().length) {
        case 1:
          courseCat = CourseGroup.getCourseGroup(
              courseDocument.documentID.toString().substring(5, 7));
          break;
        default:
          courseCat = CourseGroup.getCourseGroup(
              courseDocument.data["registeredDepts"][dept].toString());
          break;
      }

      final course = Course(
        courseName: courseDocument.data["courseName"],
        courseCode: courseDocument.documentID,
        l: courseDocument.data["l"],
        t: courseDocument.data["t"],
        p: courseDocument.data["p"],
        s: courseDocument.data["s"],
        version: courseDocument.data["version"],
      );
      var courseGrp = courseGrpMap[courseCat] ??
          CourseGroup(courseGroup: courseCat, courses: []);
      courseGrp.courses.add(course);
      courseGrpMap[courseCat] = courseGrp;
    });
    if (branchSemListQ.length == 8) {
      branchSemCourseGrpMap.remove(branchSemListQ.first);
      branchSemListQ.removeFirst();
    }
    branchSemListQ.addLast(dept + sem);
    branchSemCourseGrpMap.putIfAbsent(dept + sem, () {
      return courseGrpMap.values.toList();
    });
    return branchSemCourseGrpMap[dept + sem];
  }

  ListTile getCourseTile(Course course, BuildContext context) {
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

  Card getCourseCatCard(CourseGroup courseGrp, BuildContext context) {
    return Card(
      // color:  Colors.white70,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: const Color(0xFFFFEBEE))),
      child: Column(
        children: List.generate(courseGrp.courses.length, (index) {
          return getCourseTile(courseGrp.courses[index],context);
        })
          ..insert(
            0,
            Container(
              child: Text(
                courseGrp.courseGroup,
                style: TextStyle(letterSpacing: 2.0),
              ),
              alignment: AlignmentDirectional.center,
              height: 48.0,
            ),
          ),
      ),
    );
  }
}
