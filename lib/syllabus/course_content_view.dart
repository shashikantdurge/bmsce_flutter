import 'dart:async';
import 'package:bmsce/course/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bmsce/course/course_content_provider_sqf.dart';
import 'package:bmsce/course/course_provider_sqf.dart';

class CourseContentView extends StatefulWidget {
  CourseContentView(
      {Key key, @required this.course, this.isFetchFromOnline: true})
      : super(key: key);

  CourseContentViewState createState() => CourseContentViewState();
  final Course course;
  final bool isFetchFromOnline;
  final firestore = Firestore.instance;
  final CourseContentProvider contentProvider = CourseContentProvider();
}

class CourseContentViewState extends State<CourseContentView> {
  @override
  void initState() {
    super.initState();
    widget.contentProvider.open();
  }

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
          child: FutureBuilder<CourseContent>(
            future: fetchCourseContent(
                courseCode: widget.course.courseCode,
                version: widget.course.version,
                isFetchFromOnline: widget.isFetchFromOnline),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return Text(
                  snapshot.data.content,
                  textAlign: TextAlign.justify,
                  textScaleFactor: 1.1,
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

  static Future<CourseContent> fetchCourseContent(
      {@required String courseCode,
      @required int version,
      bool isFetchFromOnline: true}) async {
    CourseContent courseContent;
    Future<CourseContent> fetchFromFirestore() async {
      CourseContent courseContent;
      final courseSnapshot = await Firestore.instance
          .collection('course_content')
          .document(courseCode)
          .get();
      if (courseSnapshot.exists) {
        courseContent = CourseContent(
            courseSnapshot.documentID,
            courseSnapshot.data['version'],
            courseSnapshot.data['content'],
            courseSnapshot.data['lastModifiedBy']);
        if (!isFetchFromOnline) {
          CourseContentProvider().insert(courseContent);
        }
      } else {
        courseContent =
            CourseContent(courseCode, version, 'Syllabus unavailable', 'None');
      }
      return courseContent;
    }

    if (isFetchFromOnline) {
      courseContent = await fetchFromFirestore();
    } else {
      courseContent = (await CourseContentProvider()
              .getCourseContent(courseCode, version)) ??
          (await fetchFromFirestore());
    }

    return courseContent;
  }

  getCourseDetailsFrmOffline() async {
    CourseProviderSqf courseProviderSqf = CourseProviderSqf();
    return await courseProviderSqf.getCourse(
        widget.course.courseCode, widget.course.version);
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
                            'Last Modified ${DateTime.fromMillisecondsSinceEpoch(course.version*1000).toString().substring(0,10)}')
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
