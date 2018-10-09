import 'package:bmsce/course/course.dart';
import 'package:bmsce/syllabus/course_content_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bmsce/course/course_provider_sqf.dart';

class MyCourseList extends StatefulWidget {
  MyCourseList({Key key, this.isDirectToPortionCreate: false})
      : super(key: key);

  MyCourseStateList createState() => MyCourseStateList();

  final isDirectToPortionCreate;
}

class MyCourseStateList extends State<MyCourseList> {
  final courseSqf = CourseProviderSqf();
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
        future: courseSqf.getAllCourses(courseLastModifiedOn: true),
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
                  return RefreshIndicator(
                    onRefresh: () async {
                      await updateCourses(snapshot.data);
                    },
                    child: ListView(
                      children: List.generate(snapshot.data.length, (index) {
                        return getCourseTile(snapshot.data[index]);
                      }),
                    ),
                  );
                } else if (snapshot.data.isEmpty) {
                  return Center(
                    child: Text('Empty'),
                  );
                }
              } else {
                return Center(
                  child: Text('Something is wrong? ${snapshot.hasError}'),
                );
              }
          }
        });
  }

  updateCourse(Course myCOurse) async {
    Course course;
    final doc = await Firestore.instance
        .collection('courses')
        .where('courseCodeSuffix',
            isEqualTo: myCOurse.courseCode.substring(2, 10))
        .getDocuments();
    if (doc.documents.isEmpty) {
      courseSqf.removeCourse(myCOurse.courseCode);
    } else if (doc.documents.length >= 1) {
      doc.documents.sort((courseSnap1, courseSnap2) {
        if (courseSnap1.data["lastModifiedOn"] >
            courseSnap2.data["lastModifiedOn"]) return 1;
        if (courseSnap1.data["lastModifiedOn"] <
            courseSnap2.data["lastModifiedOn"])
          return -1;
        else
          return 0;
      });
      final courseSnap = doc.documents.first;
      course = Course(
          courseName: courseSnap.data["courseName"],
          courseCode: courseSnap.documentID,
          l: courseSnap.data["l"],
          t: courseSnap.data["t"],
          p: courseSnap.data["p"],
          s: courseSnap.data["s"],
          lastModifiedOn:
              courseSnap.data["lastModifiedOn"].millisecondsSinceEpoch,
          isInMyCourses: true);
    }
    if (course != null && myCOurse.lastModifiedOn < course?.lastModifiedOn) {
      await courseSqf.removeCourse(myCOurse.courseCode);
      await courseSqf.insertCourse(course);
      CourseContentViewState.fetchCourseContent(
          courseCode: course.courseCode,
          courseLastModifiedOn: course.lastModifiedOn,
          isFetchFromOnline: false);
      return true;
    }
    return false;
  }

  updateCourses(List<Course> myCourses) async {
    bool isUpdated = false;
    for (int i = 0; i < myCourses.length; i++) {
      if (await updateCourse(myCourses[i])) {
        isUpdated = true;
      }
    }
    if (isUpdated) {
      setState(() {});
    }
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
      trailing: PopupMenuButton(
        onSelected: (item) {
          if (item == "remove")
            courseSqf.removeCourse(course.courseCode).then((onValue) {
              setState(() {});
            });
        },
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
              child: Text('Remove'),
              value: 'remove',
            )
          ];
        },
      ),
      onTap: () {
        if (widget.isDirectToPortionCreate) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(course);
          }
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return CourseContentView(
              course: course,
              isFetchFromOnline: false,
            );
          }));
        }
      },
    );
  }
}
