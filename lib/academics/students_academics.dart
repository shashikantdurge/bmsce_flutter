import 'package:bmsce/academics/manage_students.dart';
import 'package:bmsce/academics/student.dart';
import 'package:bmsce/academics/student_db_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class StudentDataSource extends DataTableSource {
  List<StudentAbstractDetail> _students = <StudentAbstractDetail>[];

  void addStudents(List<StudentAbstractDetail> students) {
    _students.addAll(students);
    notifyListeners();
  }

  void _sort<T>(Comparable<T> getField(StudentAbstractDetail d),
      bool ascending) {
    _students.sort((StudentAbstractDetail a, StudentAbstractDetail b) {
      if (!ascending) {
        final StudentAbstractDetail c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _students.length) return null;
    final StudentAbstractDetail student = _students[index];
    return DataRow.byIndex(
        index: index,
        selected: student.selected,
        onSelectChanged: (bool value) {
          if (student.selected != value) {
            _selectedCount += value ? 1 : -1;
            assert(_selectedCount >= 0);
            student.selected = value;
            notifyListeners();
          }
        },
        cells: <DataCell>[
          DataCell(Text('${student.name}')),
          DataCell(Text('${student.usn}')),
          DataCell(Text('${student.cgpa}')),
          DataCell(Text('${student.numOfBackLogs}')),
          DataCell(Text('${student.num5thAttemptCourses}')),
          DataCell(Text('${student.cumulativeCreditsEarned}')),
          DataCell(Text('${student.creditsPending}')),
          DataCell(Text('${student.approxSemester}')),
        ]);
  }

  @override
  int get rowCount => _students.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void _selectAll(bool checked) {
    for (StudentAbstractDetail student in _students)
      student.selected = checked;
    _selectedCount = checked ? _students.length : 0;
    notifyListeners();
  }

  void dataChanged() {
    StudentDbProvider().getAllStudents().then((students) {
      _students.clear();
      addStudents(students);
    });
  }
}

enum StudentsPopup { manage, update }

class StudentDataTable extends StatefulWidget {
  static const String routeName = '/material/data-table';

  @override
  _DataTableDemoState createState() => _DataTableDemoState();
}

class _DataTableDemoState extends State<StudentDataTable> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  final StudentDataSource _studentsDataSource = StudentDataSource();
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  void _sort<T>(Comparable<T> getField(StudentAbstractDetail d),
      int columnIndex, bool ascending) {
    _studentsDataSource._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  _updateAcademics() async {
    final updatingSnack = scaffoldState.currentState
        .showSnackBar(SnackBar(content: Text('Updating...')));
    final db = StudentDbProvider();
    final students = _studentsDataSource._students;
    final List<StudentAbstractDetail> updates = [];
    for (int i = 0, l = students.length; i < l; i++) {
      await Firestore.instance
          .collection('academic_marks')
          .document(students[i].usn)
          .get()
          .then((onValue) {
        final newDetails = StudentAbstractDetail.fromFirestoreObj(
            onValue.documentID, onValue.data);
        updates.add(newDetails);
      });
    }
    await db.insertStudents(updates, students);
    setState(() {
      _studentsDataSource._students.clear();
      _studentsDataSource.addStudents(updates);
    });
    updatingSnack.close();
    scaffoldState.currentState.showSnackBar(SnackBar(content: Text('Updated')));

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    StudentDbProvider().getAllStudents().then((students) {
      _studentsDataSource.addStudents(students);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
        appBar: AppBar(title: const Text('My Students')),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(5.0),
            child: PaginatedDataTable(
                actions: <Widget>[
                  PopupMenuButton(
                    onSelected: (selected) async {
                      switch (selected) {
                        case StudentsPopup.manage:
                          bool isChanged = await Navigator.of(context)
                              .push<bool>(MaterialPageRoute(
                              builder: (context) =>
                                  ManageStudents(
                                      offlineStudents: _studentsDataSource
                                          ._students
                                          .cast<Student>())));
                          if (isChanged == null) isChanged = false;
                          if (isChanged) {
                            _studentsDataSource.dataChanged();
                          }
                          break;
                        case StudentsPopup.update:
                          _updateAcademics();
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<StudentsPopup>>[
                        const PopupMenuItem<StudentsPopup>(
                          value: StudentsPopup.manage,
                          child: const Text('Add/Remove'),
                        ),
                        const PopupMenuItem<StudentsPopup>(
                          value: StudentsPopup.update,
                          child: const Text('Update results'),
                        ),
                      ];
                    },
                  )
                ],
                header: const Text('Students Academics'),
                rowsPerPage: _rowsPerPage,
                onRowsPerPageChanged: (int value) {
                  setState(() {
                    _rowsPerPage = value;
                  });
                },
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                onSelectAll: _studentsDataSource._selectAll,
                columns: <DataColumn>[
                  DataColumn(
                      label: const Text('Name'),
                      onSort: (int columnIndex, bool ascending) =>
                          _sort<String>((StudentAbstractDetail d) => d.name,
                              columnIndex, ascending)),
                  DataColumn(
                      label: const Text('USN'),
                      tooltip: 'University Serial Number',
                      numeric: false,
                      onSort: (int columnIndex, bool ascending) =>
                          _sort<String>((StudentAbstractDetail d) => d.name,
                              columnIndex, ascending)),
                  DataColumn(
                      label: const Text('CGPA'),
                      numeric: true,
                      onSort: (int columnIndex, bool ascending) =>
                          _sort<num>(
                                  (StudentAbstractDetail d) => d.cgpa,
                              columnIndex,
                              ascending)),
                  DataColumn(
                      label: const Text('Backlogs'),
                      tooltip: 'Number of Backlogs.',
                      numeric: true,
                      onSort: (int columnIndex, bool ascending) =>
                          _sort<num>(
                                  (StudentAbstractDetail d) => d.numOfBackLogs,
                              columnIndex,
                              ascending)),
                  DataColumn(
                      label: const Text('5th Attempt'),
                      tooltip: 'Number of Subjects with 5th attempt.',
                      numeric: true,
                      onSort: (int columnIndex, bool ascending) =>
                          _sort<num>(
                                  (StudentAbstractDetail d) =>
                              d.num5thAttemptCourses,
                              columnIndex,
                              ascending)),
                  DataColumn(
                      label: const Text('Credits Earned'),
                      tooltip: 'Total Credits Earned.',
                      numeric: true,
                      onSort: (int columnIndex, bool ascending) =>
                          _sort<num>(
                                  (StudentAbstractDetail d) =>
                              d.cumulativeCreditsEarned,
                              columnIndex,
                              ascending)),
                  DataColumn(
                      label: const Text('Credits Pending'),
                      tooltip: 'Total Credits Pending.',
                      numeric: true,
                      onSort: (int columnIndex, bool ascending) =>
                          _sort<num>(
                                  (StudentAbstractDetail d) => d.creditsPending,
                              columnIndex,
                              ascending)),
                  DataColumn(
                      label: const Text('Semester'),
                      tooltip: 'The data shown is of the mentioned Semester.',
                      numeric: false,
                      onSort: (int columnIndex, bool ascending) =>
                          _sort<String>(
                                  (StudentAbstractDetail d) => d.approxSemester,
                              columnIndex,
                              ascending)),
                ],
                source: _studentsDataSource)));
  }
}
