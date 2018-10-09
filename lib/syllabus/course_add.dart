import 'dart:async';
import 'dart:collection';

import 'package:bmsce/course/course.dart';
import 'package:bmsce/course/course_provider_sqf.dart';
import 'package:bmsce/course/course_dept_sem.dart';
import 'package:bmsce/syllabus/course_content_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCourse extends StatefulWidget {
  AddCourse();
  final CourseProviderSqf courseProviderSqf = CourseProviderSqf();
  final Firestore firestore = Firestore.instance;

  AddCourseState createState() => AddCourseState();
}

class AddCourseState extends State<AddCourse> {
  Set<String> localCourses = Set<String>();
  @override
  initState() {
    super.initState();
    widget.courseProviderSqf.getAllCourses().then((courseList) {
      courseList.forEach((course) {
        localCourses.add(course.courseCode);
      });
    });
  }

  String selectedBranch;
  String selectedSem;
  String semOrCycle;
  List<dynamic> semesters = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "X"];
  int totalSems = 8;
  final branchSemListQ = ListQueue<String>();
  final branchSemCourseGrpMap = HashMap<String, List<CourseGroup>>();
  dynamic fetchCourseFunct;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
      ),
      bottomNavigationBar: BottomAppBar(
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            DropdownButton(
              hint: Text('Branch'),
              items: List.generate(
                  Departments.where((dept) {
                    return dept.item3;
                  }).length, (index) {
                return DropdownMenuItem<String>(
                  child: Text(Departments[index].item2),
                  value: Departments[index].item1,
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
                  child: Text(semesters[index]),
                  value: semesters[index],
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
            ),
            Container(
              height: 5.0,
              color: Theme.of(context).primaryColorLight,
            )
          ],
        ),
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
                  return getCourseCatCard(snapshot.data[index], context);
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
      lessThanSem = semesters[semesters.indexOf(sem) + 1];
    } on RangeError {
      lessThanSem = "Z";
    }
    final courses = await widget.firestore
        .collection('courses')
        .where("registeredDepts." + dept, isGreaterThanOrEqualTo: sem)
        .where("registeredDepts." + dept, isLessThan: lessThanSem)
        .getDocuments()
        .catchError((error) {});
    final courseGrpMap = HashMap<String, CourseGroup>();
    courses.documents.forEach((courseDocument) {
      var courseCat; // is CourseGroup.courseGroup
      switch (courseDocument.data["registeredDepts"][dept].toString().length) {
        case 1:
          courseCat = CourseGroup.getCourseGroup(
              courseDocument.documentID.toString().substring(5, 7));
          break;
        default:
          courseCat = CourseGroup.getCourseGroup(courseDocument
              .data["registeredDepts"][dept]
              .toString()
              .replaceRange(0, 1, ""));
          break;
      }

      final course = Course(
          courseName: courseDocument.data["courseName"],
          courseCode: courseDocument.documentID,
          l: courseDocument.data["l"],
          t: courseDocument.data["t"],
          p: courseDocument.data["p"],
          s: courseDocument.data["s"],
          lastModifiedOn:
              courseDocument.data["lastModifiedOn"].millisecondsSinceEpoch,
          isInMyCourses: localCourses.contains(courseDocument.documentID));
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
          return CourseContentView(
            course: course,
          );
        }));
      },
      trailing: AnimatedCrossFade(
        firstChild: IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {
              widget.courseProviderSqf.insertCourse(course);
              CourseContentViewState.fetchCourseContent(
                  courseCode: course.courseCode,
                  courseLastModifiedOn: course.lastModifiedOn,
                  isFetchFromOnline: false);
              setState(() {
                course.isInMyCourses = true;
              });
            }),
        secondChild: IconButton(
          icon: Icon(
            Icons.done,
            size: 24.0,
          ),
          onPressed: null,
        ),
        crossFadeState: course.isInMyCourses
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  Card getCourseCatCard(CourseGroup courseGrp, BuildContext context) {
    return Card(
      // color:  Colors.white70,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: const Color(0xFFFFEBEE))),
      child: Column(
        children: List.generate(courseGrp.courses.length, (index) {
          return getCourseTile(courseGrp.courses[index], context);
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
