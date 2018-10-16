import 'dart:async';

import 'package:bmsce/course/course_provider_sqf.dart';
import 'package:tuple/tuple.dart';
import 'package:bmsce/portion/portion_provider_sqf.dart';
import 'package:bmsce/syllabus/portion_create.dart';
import 'package:flutter/material.dart';

class PortionView extends StatelessWidget {
  final String courseName;
  final String createdBy;
  final int createdOn;
  final String description;

  PortionView(
      {Key key,
      @required this.createdBy,
      @required this.createdOn,
      @required this.courseName,
      @required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$courseName',
              overflow: TextOverflow.fade,
            ),
            Text(
              '$description',
              overflow: TextOverflow.fade,
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<Tuple2<List<CourseContentPart>, List<Color>>>(
        future: processPortion(createdBy, createdOn),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                return buildCourseContent(
                    snapshot.data.item1, snapshot.data.item2);
              } else {
                return Center(
                  child: Text('Something is wrong? ${snapshot.hasError}'),
                );
              }
          }
        },
      ),
    );
  }

  buildCourseContent(
      List<CourseContentPart> courseContent, List<Color> toggleHighlight) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(courseContent.length, (index) {
              final contentOrDivider = courseContent[index];
              var lastToggleIndex = index;
              var curFirstWordIndex = 0;
              while (lastToggleIndex > 0) {
                final lastContentOrDivider = courseContent[--lastToggleIndex];
                if (lastContentOrDivider is UnitContent)
                  curFirstWordIndex = curFirstWordIndex +
                      lastContentOrDivider.unitContent.length;
              }
              if (contentOrDivider is UnitDivider) {
                return Text('${contentOrDivider.divider}');
              } else if (contentOrDivider is UnitContent) {
                return Wrap(
                  children: List.generate(contentOrDivider.unitContent.length,
                      (index) {
                    return Container(
                        color: toggleHighlight[curFirstWordIndex + index],
                        padding: EdgeInsets.all(2.0),
                        child: Text(contentOrDivider.unitContent[index]));
                  }),
                );
              }
            })),
      ),
    );
  }

  Future<Tuple2<List<CourseContentPart>, List<Color>>> processPortion(
      String createdBy, int createdOn) async {
    final portion = await PortionProvider().getPortion(createdBy, createdOn);
    final courseContentParts =
        await processSyllabus(portion.courseCode, portion.codeVersion);
    List<int> toggleBordColorIndexes = [];
    portion.toggleBordColorIndexes.split(",").forEach((i) {
      toggleBordColorIndexes.add(int.parse(i));
    });
    List<int> toggleColorIndexes = [];
    portion.toggleColorIndexes.split(",").forEach((i) {
      toggleColorIndexes.add(int.parse(i));
    });
    final List<Color> toggleHighlight =
        List<Color>(UnitContent.totalWordsCount);
    for (var i = 1; i < toggleBordColorIndexes.length; i++) {
      Color color = toggleColorIndexes[i - 1] != -1
          ? highlightColors[toggleColorIndexes[i - 1]]
          : Colors.transparent;
      toggleHighlight.fillRange(
          toggleBordColorIndexes[i - 1], toggleBordColorIndexes[i], color);
    }
    return Tuple2(courseContentParts, toggleHighlight);
  }

  Future<List<CourseContentPart>> processSyllabus(
      String courseCode, String codeVersion) async {
    String courseContent =
        (await CourseProviderSqf().getOnlyContent(courseCode, codeVersion));
    final List<CourseContentPart> courseContentParts = [];

    int processUnit(String unitContent) {
      int wordsCount = 0;
      unitContent.split(RegExp(r'[\n]{1,}')).forEach((unitContentPara) {
        if (unitContentPara.trim() != '') {
          final unitContentWords =
              unitContentPara.trim().split(RegExp(r'[\s]{1,}'));
          courseContentParts.add(UnitContent(unitContentWords));
          wordsCount += unitContentWords.length;
        }
      });
      return wordsCount;
    }

    int wordsCount = 0;
    List<String> units =
        courseContent.split(RegExp(r'[\n]{1,}[\s]{0,}[\n]{1,}'));
    for (var i = 0; i < units.length; i++) {
      if (units[i].trim() != '') {
        courseContentParts.add(UnitDivider('\n'));
        //wordsCount++;
        wordsCount += processUnit(units[i]);
      }
    }
    UnitContent.totalWordsCount = wordsCount;
    return courseContentParts;
  }
}
