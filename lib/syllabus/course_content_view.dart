import 'dart:async';
import 'package:bmsce/course/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bmsce/course/course_provider_sqf.dart';

class CourseContentView extends StatefulWidget {
  CourseContentView(
      {Key key, @required this.course, this.isFetchFromOnline: true})
      : super(key: key);

  CourseContentViewState createState() => CourseContentViewState();
  final Course course;
  final bool isFetchFromOnline;
  final firestore = Firestore.instance;
}

class CourseContentViewState extends State<CourseContentView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.course.courseName,
          overflow: TextOverflow.fade,
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                showLtpsTable();
              })
        ],
      ),
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: FutureBuilder<String>(
            future: getCourseContent(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return Text(
                  snapshot.data,
                  textAlign: TextAlign.justify,
                  textScaleFactor: 1.1,
                  style: TextStyle(fontFamily: 'OpenSans',fontSize: 14.0,letterSpacing: 0.8),
                );
              } else {
                print(
                    'PortionCreate ${snapshot.connectionState} hasData:${snapshot.hasData} hasError:${snapshot.hasError}');
                return Text(
                    'PortionCreate ${snapshot.connectionState} hasData:${snapshot.hasData} hasError:${snapshot.hasError}');
              }
            },
          ),
        ),
      ),
    );
  }

  Future<String> getCourseContent() async {
    if (widget.isFetchFromOnline) {
      await widget.course.setContent();
      return widget.course.content;
    }

    return await CourseProviderSqf()
        .getOnlyContent(widget.course.courseCode, widget.course.codeVersion);
  }

//ONLY course content
  // static Future<String> fetchCourseContent(
  //     {@required String courseCode,
  //     @required String codeVersion,
  //     bool isFetchFromOnline: true}) async {
  //   String courseContent;
  //   Future<String> fetchFromFirestore() async {
  //     String courseContent;
  //     final courseSnapshot = await Firestore.instance
  //         .collection('course_content')
  //         .document(courseCode)
  //         .get();
  //     if (courseSnapshot.exists) {
  //       courseContent = courseSnapshot.data['content'];
  //       //TODO: save offline
  //       // if (!isFetchFromOnline) {
  //       //   CourseContentProvider().insert(courseContent);
  //       // }
  //     } else {
  //       courseContent = 'Syllabus unavailable';
  //     }
  //     return courseContent;
  //   }

  //   if (isFetchFromOnline) {
  //     courseContent = await fetchFromFirestore();
  //   } else {
  //     courseContent =
  //         (await CourseProviderSqf().getCourse(courseCode, codeVersion))
  //                 ?.content ??
  //             (await fetchFromFirestore());
  //   }

  //   return courseContent;
  // }

  getCourseDetailsFrmOffline() async {
    CourseProviderSqf courseProviderSqf = CourseProviderSqf();
    return await courseProviderSqf.getCourse(
        widget.course.courseCode, widget.course.codeVersion);
  }

  showLtpsTable() async {
    Course course = widget.isFetchFromOnline
        ? widget.course
        : await getCourseDetailsFrmOffline();
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            //height: 100.0,
            child: BottomSheet(
                //TODO: Animation Controller
                onClosing: () {},
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(course.courseName),
                        Text(course.courseCode),
                        Table(
                          border: TableBorder.all(color: Colors.black38),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            getTableRow(['L', 'T', 'P', 'S']),
                            getTableRow([
                              course.l.toString(),
                              course.t.toString(),
                              course.p.toString(),
                              course.s.toString(),
                            ])
                          ],
                        ),
                        Text(
                            'Updated on ${DateTime.fromMillisecondsSinceEpoch(course.lastModifiedOn).toString()}')
                      ],
                    ),
                  );
                }),
          );
        });
  }

  TableRow getTableRow(List<String> data) {
    assert(data.length == 4);
    return TableRow(
        children: List.generate(data.length, (index) {
      return TableCell(
          child: Text(
        data[index],
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0),
      ));
    }));
  }
}
