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
                      await checkForUpdates(snapshot.data);
                    },
                    child: ListView(
                      children: List.generate(snapshot.data.length, (index) {
                        return getCourseTile(snapshot.data[index]);
                      }),
                    ),
                  );
                } else if (snapshot.data.isEmpty) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Opacity(
                          opacity: 0.4,
                          child: Image.asset('assets/images/minion_sad.png')),
                      Text(
                        'I got to go, add some courses please!!',
                        style: TextStyle(
                            fontFamily: 'Ubuntu',
                            color: Theme.of(context).textTheme.caption.color,
                            fontSize:
                                Theme.of(context).textTheme.subhead.fontSize),
                      )
                    ]),
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

//TODO: CODE_VERSION //PY2ICPHY_D_1539608763657
  checkForUpdates(List<Course> myCourses) async {
    for (Course course in myCourses) {
      final curTimeInEpoch = DateTime.now().millisecondsSinceEpoch.toString();
      final codeSuffix = course.codeVersion.split('_D_').first;
      final docs = await Firestore.instance
          .collection('courses')
          .where('codeVersion', isGreaterThan: course.codeVersion)
          .where('codeVersion', isLessThan: codeSuffix + '_D_' + curTimeInEpoch)
          .orderBy('codeVersion', descending: true)
          .getDocuments();
      if (docs != null && docs.documents.length > 0) {
        final latestDoc = docs.documents.first;
        final latestCourse =
            Course.fromMap(latestDoc.data, latestDoc.documentID);
        await latestCourse.setContent().then((onValue) async {
          if (onValue) {
            await CourseProviderSqf().insertCourse(latestCourse);
            await CourseProviderSqf().processExit(course);
          }
        });
      }
    }
    setState(() {});
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
