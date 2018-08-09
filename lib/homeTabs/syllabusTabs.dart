import 'package:flutter/material.dart';

import 'package:bmsce/syllabus/MyCourses.dart';
import 'package:bmsce/syllabus/Notes.dart';
import 'package:bmsce/syllabus/Portion.dart';

class SyllabusTabs extends StatefulWidget {
  SyllabusTabsState createState() => SyllabusTabsState();
}

class SyllabusTabsState extends State<SyllabusTabs>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this,initialIndex: 2);
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
        onPressed: () {},
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
