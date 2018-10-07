import 'package:bmsce/academics/student.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bmsce/academics/student_db_provider.dart';

class ManageStudents extends StatefulWidget {
  static Map<String, Student> studentsMap = {};
  static Set notFoundUsns = Set();
  final List<Student> offlineStudents;

  const ManageStudents({Key key, @required this.offlineStudents})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ManageStudentsState();
  }
}

//It should be in Firestore obj
class ManageStudentsState extends State<ManageStudents> {
  bool dataChanged = false;
  // List<Student> students = [
  //   StudentAbstractDetail(
  //       approxSemester: "sem 4",
  //       cgpa: 6.6,
  //       creditsPending: 24,
  //       cumulativeCreditsEarned: 148,
  //       isYearBack: true,
  //       name: "Poornesh V",
  //       num5thAttemptCourses: 1,
  //       numOfBackLogs: 2,
  //       sgpa: 7.08,
  //       usn: "1BM14CS070"),
  //   StudentAbstractDetail(
  //       approxSemester: "sem 3",
  //       cgpa: 8.6,
  //       creditsPending: 2,
  //       cumulativeCreditsEarned: 148,
  //       isYearBack: false,
  //       name: "SHASHIKANT",
  //       num5thAttemptCourses: 0,
  //       numOfBackLogs: 1,
  //       sgpa: 8.08,
  //       usn: "1BM14CS084"),
  // ]; //students list comes from the offline db
  List<TextEditingController> usnControllers = [];
  CrossFadeState crossFadeState;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.offlineStudents.forEach((st) {
      usnControllers.add(TextEditingController(text: st?.usn ?? "usn"));
      ManageStudents.studentsMap[st.usn] = st;
    });
    crossFadeState = CrossFadeState.showFirst;
  }

  save() {
    dataChanged = true;
    setState(() {
      crossFadeState = CrossFadeState.showSecond;
    });
    Set<String> insertStudentsUsn = Set<String>();
    Set<Student> retainStudents = Set();

    List<StudentAbstractDetail> insStudentsList = [];
    usnControllers.forEach((usnController) {
      if (ManageStudents.studentsMap.containsKey(usnController.text)) {
        if (ManageStudents.studentsMap[usnController.text]
            is StudentAbstractDetail) {
          if (insertStudentsUsn.add(usnController.text))
            insStudentsList.add(ManageStudents.studentsMap[usnController.text]);
        } else {
          retainStudents.add(ManageStudents.studentsMap[usnController.text]);
        }
      }
    });
    final db = StudentDbProvider();
    widget.offlineStudents.removeWhere((student) {
      return retainStudents.contains(student);
    });
    db.insertStudents(insStudentsList, widget.offlineStudents).then((onValue) {
      setState(() {
        crossFadeState = CrossFadeState.showFirst;
      });
      Navigator.pop(context, dataChanged);
    });
    //
  }

  returnBack() {}

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add/Remove Student'),
        actions: <Widget>[
          AnimatedCrossFade(
            crossFadeState: crossFadeState,
            duration: Duration(microseconds: 500),
            firstChild: IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                save();
              },
            ),
            secondChild: CircularProgressIndicator(),
          )
        ],
      ),
      body: ListView(
        children: List.generate(usnControllers.length + 1, (index) {
          if (index == usnControllers.length) {
            return ListTile(
              trailing: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    usnControllers.add(TextEditingController(text: '1BM'));
                  });
                },
              ),
            );
          } else {
            return SizedBox(
                height: 80.0,
                child: UsnTextField(
                  controller: usnControllers[index],
                  isDelete: (delete) {
                    setState(() {
                      usnControllers.removeAt(index);
                    });
                  },
                ));
          }
        }),
      ),
    );
  }
}

class UsnTextField extends StatefulWidget {
  final ValueChanged<bool> isDelete;
  final TextEditingController controller;

  UsnTextField({Key key, this.isDelete, this.controller}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return UsnTextFieldState();
  }
}

class UsnTextFieldState extends State<UsnTextField> {
  String studentName = "";
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      //contentPadding: EdgeInsets.only(bottom: 5.0),
      title: Form(
        key: formKey,
        child: TextFormField(
          //TODO: name appears below the editing box hen usn is entered. the documnet is saved in a Map<string,student> obj.
          //TODO: remove the red color from this textfield

          autovalidate: true,
          //initialValue: students[index]?.usn ?? "",

          controller: widget.controller,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            // prefixText: '1BM',
            labelText: 'USN',
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12)),
            focusedErrorBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent[100])),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black12),
            ),
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            errorStyle: TextStyle(
              color: Colors.black26,
            ),
          ),
          validator: (usn) {
            if (usn.contains(RegExp(r'1[bB][mM]\d{2}[a-zA-Z]{2}\d\d\d$'))) {
              if (ManageStudents.studentsMap.containsKey(usn)) {
                return ManageStudents.studentsMap[usn].name;
              }
              if (ManageStudents.notFoundUsns.contains(usn)) {
                return "Not Found";
              }
              Firestore.instance
                  .collection('academic_marks')
                  .document(usn)
                  .get()
                  .then((onValue) {
                if (onValue.exists) {
                  final student = StudentAbstractDetail.fromFirestoreObj(
                      onValue.documentID, onValue.data);
                  ManageStudents.studentsMap[usn] = student;
                  formKey.currentState.validate();
                } else {
                  ManageStudents.notFoundUsns.add(usn);
                  formKey.currentState.validate();
                }
              }).catchError((onError) {
                print(onError);
              });
            }
          },
        ),
      ),

      trailing: IconButton(
        icon: Icon(Icons.remove),
        onPressed: () {
          widget.isDelete(true);
        },
      ),
    );
  }
}
