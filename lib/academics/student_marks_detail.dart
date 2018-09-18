import 'dart:async';

import 'package:bmsce/academics/semester_details.dart';
import 'package:bmsce/academics/student.dart';
import 'package:bmsce/academics/student_db_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cgpa_sgpa_chart.dart';
import 'dart:convert';

class StudentDetailView extends StatelessWidget {
  final String usn;
  final String name;

  const StudentDetailView({Key key, @required this.usn, @required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$name',
              overflow: TextOverflow.fade,
            ),
            Text(
              '$usn',
              overflow: TextOverflow.fade,
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<StudentAbstractDetail>(
          future: getStudentDetails(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.done:
                print(
                    "snapshot hasdata:${snapshot.hasData} has Error:${snapshot.hasError}");
                if (!snapshot.hasData || snapshot.hasError) {
                  return Center(
                    child: Text("Could not find the Data."),
                  );
                }
                if (snapshot.data == null) {
                  return Center(
                    child: Text("Could not find the Data."),
                  );
                }
                final studentDetail = StudentDetail.fromFirestoreObj(
                    json.decode(snapshot.data.detailDataJson),
                    snapshot.data.usn);
                return Column(
                  children: <Widget>[
                    GpaBarChart.fromStudentDetail(studentDetail),
                    getLastSemDetails(snapshot.data),
                    // getBacklogsWidget(
                    //     snapshot.data.numOfBackLogs, studentDetail),
                    SemesterDetails(
                      usn: usn,
                      semesters: studentDetail.semestersGps,
                    )
                  ],
                );
            }
          },
        ),
      ),
    );
  }

  Widget getLastSemDetails(StudentAbstractDetail abstractDetails) {
    TextStyle textStyle =
        TextStyle(fontSize: 16.0, wordSpacing: 2.0, letterSpacing: 1.4);
    List<Widget> abstractWidgets = [];
    abstractWidgets.add(Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Text(
        'Details of ${abstractDetails.approxSemester}',
        style: textStyle,
      ),
    ));
    abstractWidgets.add(Text(
      'CGPA  ${abstractDetails.cgpa.toStringAsFixed(2)}',
      style: textStyle,
    ));
    abstractWidgets.add(Text(
      'SGPA  ${abstractDetails.sgpa.toStringAsFixed(2)}',
      style: textStyle,
    ));

    abstractWidgets.add(Text(
      'Total Credits Earned   ${abstractDetails.cumulativeCreditsEarned}',
      style: textStyle,
    ));
    abstractWidgets.add(Text(
      'Total Credits Pending  ${abstractDetails.creditsPending}',
      style: textStyle,
    ));

    abstractWidgets.add(Text(
      'Backlogs ${abstractDetails.numOfBackLogs}',
      style: textStyle,
    ));

    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: abstractWidgets,
        ),
      ),
    );
  }

  Widget getBacklogsWidget(int numOfBackLogs, StudentDetail student) {
    TextStyle textStyle =
        TextStyle(fontSize: 16.0, wordSpacing: 2.0, letterSpacing: 2.0);
    List<Widget> abstractWidgets = [];
    abstractWidgets.add(Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Backlogs($numOfBackLogs)',
            style: textStyle,
          ),
          Text('Attempts')
        ],
      ),
      width: double.maxFinite,
      color: Colors.grey[200],
    ));
    student.backlogs.forEach((bl) {
      abstractWidgets.add(ListTileTheme(
        style: ListTileStyle.list,
        textColor: bl.isCleared ? Colors.grey[400] : Colors.black,
        child: ListTile(
          dense: false,
          leading: Text(
            '${bl.grade}',
            style: TextStyle(
              color: bl.isCleared ? Colors.grey[400] : Colors.black,
            ),
          ),
          title: Text(
            '${bl.name}',
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          subtitle: Text('${bl.code} (${bl.credits} credits)'),
          trailing: Text(
            '${bl.attempts}',
            style: TextStyle(
              color: bl.isCleared ? Colors.grey[400] : Colors.black,
            ),
          ),
        ),
      ));
    });
    return Card(
        child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: abstractWidgets));
  }

  Future<StudentAbstractDetail> getStudentDetails() async {
    var studentabstract = await StudentDbProvider().getStudentDetails(usn);
    if (studentabstract == null) {
      final firestoreObj = await Firestore.instance
          .collection('academic_marks')
          .document(usn)
          .get();
      if (firestoreObj.exists) {
        studentabstract = StudentAbstractDetail.fromFirestoreObj(
            firestoreObj.documentID, firestoreObj.data);
      }
    }
    return studentabstract;
  }
}
