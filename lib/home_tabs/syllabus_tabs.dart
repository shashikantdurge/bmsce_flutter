import 'package:bmsce/course/course.dart';
import 'package:bmsce/my_widgets/portion_for_description.dart';
import 'package:bmsce/syllabus/course_add.dart';
import 'package:bmsce/syllabus/course_list.dart';
import 'package:bmsce/syllabus/portion_create.dart';
import 'package:flutter/material.dart';
import 'package:bmsce/syllabus/notes.dart';
import 'package:bmsce/syllabus/portion_list.dart';

class SyllabusTabs extends StatefulWidget {
  const SyllabusTabs({
    Key key,
  }) : super(key: key);

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
        MyCourseList(),
        PortionList(),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          switch (tabController.index) {
            case 0:
              break;
            case 1:
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return AddCourse();
              }));
              break;
            case 2:
              Course course = await showModalBottomSheet<Course>(
                context: context,
                builder: (BuildContext context) {
                  return MyCourseList(
                    isDirectToPortionCreate: true,
                  );
                },
              );
              if (course == null) return;
              String description = await showModalBottomSheet<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return PortionDescriptionList();
                  });
              if (description == null) return;
              if (description == 'Other...') {
                description = await showDialog<String>(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return PortionDescriptionDialog();
                    });
              }
              if (description == null) return;
              print(description);
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PortionCreate(
                  course: course,
                  description: description,
                );
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
