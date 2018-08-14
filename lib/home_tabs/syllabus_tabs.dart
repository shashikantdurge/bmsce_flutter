import 'package:bmsce/syllabus/course_add.dart';
import 'package:bmsce/syllabus/course_list.dart';
import 'package:bmsce/syllabus/portion_create.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bmsce/syllabus/notes.dart';
import 'package:bmsce/syllabus/portion_list.dart';

class SyllabusTabs extends StatefulWidget {
  const SyllabusTabs({Key key,}):super(key: key);

  SyllabusTabsState createState() => SyllabusTabsState();

}

class SyllabusTabsState extends State<SyllabusTabs>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(controller: tabController, tabs: [
          Tab(
            text: 'Notes',
          ),
          Tab(
            text: 'My Course',
          ),
          Tab(
            text: 'Portion',
          ),
        ]),
      ),
      body: TabBarView(controller: tabController, children: [
        Notes(),
        MyCourse(),
        Portion(),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          switch (tabController.index) {
            case 0:
              break;
            case 1:
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return AddCourse(firestore: Firestore.instance);
              }));
              break;
            case 2:
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PortionCreate();
              }));
              break;
          }
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.add,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
/*
* TabBar(controller: tabController, tabs: [
          Tab(
            text: 'Notes',
          ),
          Tab(
            text: 'My Course',
          ),
          Tab(
            text: 'Portion',
          ),
        ]),*/

/*TabBarView(controller: tabController, children: [
        Text('Notes'),
        Text('My Courses'),
        Text('Portion'),
      ]),*/
