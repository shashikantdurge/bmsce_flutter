import 'dart:async';

import 'package:bmsce/academics/student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SemesterDetails extends StatefulWidget {
  final List<StudentSemGpa> semesters;
  final String usn;

  const SemesterDetails({Key key, @required this.semesters, @required this.usn})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return SemesterDetailsState();
  }
}

class SemesterDetailsState extends State<SemesterDetails> {
  String semester = "";
  double cgpa = 0.0;
  double sgpa = 0.0;
  int selectedSem;
  CrossFadeState crossFadeState;
  Map<String, List<DocumentSnapshot>> semesterDocsMap = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedSem = -1;
    crossFadeState = CrossFadeState.showFirst;
    //crossFadeState = CrossFadeState.showSecond; //#
    // getSemesterTableFunct = getSemesterTable(widget.semesters.last.semKey); //#
  }

  dynamic getSemesterTableFunct;

  @override
  Widget build(BuildContext context) {
    final textStyle =
        TextStyle(fontSize: 16.0, wordSpacing: 2.0, letterSpacing: 1.4);
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 800),
      crossFadeState: crossFadeState,
      firstChild: ButtonTheme(
        minWidth: double.maxFinite,
        child: RaisedButton(
          textColor: Colors.white,
          child: Text('SHOW SEMESTER RESULTS'),
          onPressed: () {
            setState(() {
              crossFadeState = CrossFadeState.showSecond;
              final lastIndex = widget.semesters.length - 1;
              getSemesterTableFunct =
                  getSemesterTable(widget.semesters[lastIndex].semKey);
              semester = widget.semesters[lastIndex].sem;
              sgpa = widget.semesters[lastIndex].sgpa;
              cgpa = widget.semesters[lastIndex].cgpa;
              selectedSem = lastIndex;
            });
          },
        ),
      ),
      secondChild: Card(
        child: Column(
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: ButtonBar(
                children: List.generate(widget.semesters.length, (index) {
                  return FlatButton(
                    // color: index==selectedSem?Colors.grey[300],
                    shape: selectedSem == index
                        ? BeveledRectangleBorder(
                            side:
                                BorderSide(color: Colors.red[100], width: 0.4))
                        : null,
                    child: Text(widget.semesters[index].sem),
                    onPressed: () {
                      setState(() {
                        getSemesterTableFunct =
                            getSemesterTable(widget.semesters[index].semKey);
                        semester = widget.semesters[index].sem;
                        sgpa = widget.semesters[index].sgpa;
                        cgpa = widget.semesters[index].cgpa;
                        selectedSem = index;
                      });
                    },
                  );
                }),
              ),
            ),
            Divider(),
            Text(
              '$semester',
              style: textStyle,
            ),
            Text(
              'CGPA  ${cgpa.toStringAsFixed(2)}',
              style: textStyle,
            ),
            Text(
              'SGPA  ${sgpa.toStringAsFixed(2)}',
              style: textStyle,
            ),
            FutureBuilder<Widget>(
              future: getSemesterTableFunct,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text('Select a semester');
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    return SizedBox(
                      width: double.maxFinite,
                      height: 300.0,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  case ConnectionState.done:
                    if (!snapshot.hasData || snapshot.hasError) {
                      return SizedBox(
                        width: double.maxFinite,
                        height: 300.0,
                        child: Center(
                          child: Text("Could not find the Data."),
                        ),
                      );
                    }
                    if (snapshot.data == null) {
                      return SizedBox(
                        width: double.maxFinite,
                        height: 300.0,
                        child: Center(
                          child: Text("Could not find the Data."),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: snapshot.data,
                    );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Future<Widget> getSemesterTable(String semKey) async {
    Map courseKeyMap = {};
    List<String> sortedKeys = [];
    List<String> sortedCourseCodes = [];
    processSemesterResults() async {
      final semesterDocs = semesterDocsMap.containsKey(semKey)
          ? semesterDocsMap[semKey]
          : await getSemesterDocs(semKey);
      if (semesterDocs == null) return null;
      courseKeyMap["credits_D_code_D_course"] = {};

      semesterDocs.forEach((courseDoc) {
        courseDoc.data.forEach((key, value) {
          if (key.startsWith(RegExp(r'main|make_up'))) {
            courseKeyMap.putIfAbsent(key, () => {});
            courseKeyMap[key][courseDoc.documentID] = value;
          } else if (key == "GRADE") {
            courseKeyMap.putIfAbsent("odummy_D_GRADE_D_odummy", () => {});
            courseKeyMap["odummy_D_GRADE_D_odummy"][courseDoc.documentID] =
                value[0] ? value[1] : "";
          }
        });
        courseKeyMap["credits_D_code_D_course"][courseDoc.documentID] =
            "${courseDoc.data["courseName"]}\n ${courseDoc.documentID}(${courseDoc['credits']})";
        sortedCourseCodes.add(courseDoc.documentID);
      });
    }

    await processSemesterResults();
    if (sortedCourseCodes.isEmpty) return Text('Data Not Found');

    sortedKeys = courseKeyMap.keys.toList().cast<String>();
    sortedKeys.sort();
    sortedCourseCodes.sort();

    final valuationMap = {
      "valuation": "",
      "revaluation": "reval",
      "retotaling": "retotal",
      "challenge_valuation": "ch reval",
      "credits": "(credits)",
      "code": "Code",
      "course": "Course",
      "odummy": "",
      "main": "Main",
      "make_up": "Make Up",
      "cie": "CIE",
      "see": "SEE",
      "total": "Total",
      "grade": "Grade",
      "GRADE": "Grade Final"
    };

    TableRow heading = TableRow(
        decoration: BoxDecoration(color: Colors.grey[300]),
        children: List.generate(sortedKeys.length, (index) {
          final colHeadArr = sortedKeys[index].split('_D_');
          final text = valuationMap[colHeadArr[2]] +
              "\n" +
              valuationMap[colHeadArr[1]] +
              valuationMap[colHeadArr[0]];
          return TableCell(child: Text(text));
        }));

    Widget widget = Table(
      defaultColumnWidth: FixedColumnWidth(50.0),
      columnWidths: {0: FixedColumnWidth(200.0)},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border:
          TableBorder.all(style: BorderStyle.solid, color: Colors.grey[200]),
      children: List.generate(sortedCourseCodes.length, (rowIndex) {
        return TableRow(
            decoration: BoxDecoration(
                backgroundBlendMode: BlendMode.hardLight,
                color: rowIndex.isOdd ? Colors.grey[100] : Colors.white12),
            children: List.generate((sortedKeys.length), (colIndex) {
              return TableCell(
                child: Text(
                  '${courseKeyMap[sortedKeys[colIndex]][sortedCourseCodes[rowIndex]] ?? ' '}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              );
            }));
      })
        ..insert(0, heading),
    );
    return widget;
  }

  Future<List<DocumentSnapshot>> getSemesterDocs(String semKey) async {
    final QuerySnapshot documents = await Firestore.instance
        .collection('academic_marks')
        .document(widget.usn)
        .collection(semKey)
        .getDocuments();

    semesterDocsMap.putIfAbsent(semKey, () => documents.documents);
    return documents.documents;
  }
}
