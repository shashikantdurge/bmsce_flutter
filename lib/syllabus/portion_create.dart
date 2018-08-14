import 'dart:async';

import 'package:bmsce/my_widgets/color_radio_button.dart';
import 'package:flutter/material.dart';
import 'dart:collection';
import 'course_content_view.dart';

class PortionCreate extends StatefulWidget {
  PortionCreateState createState() => PortionCreateState();
}

final List<Color> highlightColors = [
  Colors.amber[100],
  Colors.pink[100],
  Colors.cyan[100],
  Colors.deepOrange[100],
  Colors.indigo[100]
];

class PortionCreateState extends State<PortionCreate>
    with SingleTickerProviderStateMixin {
  final List<CourseContent> syllabus = [];
  List<Color> toggleHighlight;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int highlightIndex;
  int wordsCount;
  Color curHighlightColor = highlightColors[2];
  bool isLongPressed = false;
  bool isStackEmpty = true;
  @override
  void initState() {
    super.initState();
    final courseContent = SyllabusViewState.syllabus;
    wordsCount = processSyllabus(courseContent);
    toggleHighlight = List(wordsCount);
    toggleHighlight.fillRange(0, wordsCount, Colors.transparent);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Data Structure'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.info_outline), onPressed: () {})
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(highlightColors.length, (index) {
                    return ColorRadioButton(
                      value: highlightColors[index],
                      groupValue: curHighlightColor,
                      onChanged: (Color value) {
                        setState(() {
                          curHighlightColor = highlightColors[index];
                        });
                      },
                    );
                  })),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  OutlineButton(
                    onPressed: isStackEmpty
                        ? null
                        : () {
                            undo();
                          },
                    child: Icon(Icons.undo),
                  ),
                  Listener(
                    onPointerDown: (down) async {
                      print('down listener');
                      if (highlightIndex == null) return;
                      isLongPressed = true;
                      while (isLongPressed && highlightIndex < wordsCount) {
                        await Future.delayed(
                            Duration(milliseconds: 234), forwardSelection());
                      }
                    },
                    onPointerUp: (down) {
                      print('Up listener');
                      isLongPressed = false;
                    },
                    child: OutlineButton(
                      onPressed: highlightIndex == null ? null : () {},
                      child: Icon(
                        Icons.chevron_right,
                      ),
                    ),
                  ),
                  FlatButton(
                    child: Text('RESET'),
                    onPressed: () {
                      reset();
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      //TODO: make it FutureBuilder
      body: buildCourseContent(),
    );
  }

Widget buildCourseContent(){
  return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(syllabus.length, (index) {
                final contentOrDivider = syllabus[index];
                var lastToggleIndex = index;
                var curFirstWordIndex = 0;
                while (lastToggleIndex > 0) {
                  final lastContentOrDivider = syllabus[--lastToggleIndex];
                  if (lastContentOrDivider is UnitContent)
                    curFirstWordIndex = curFirstWordIndex +
                        lastContentOrDivider.unitContent.length;
                }
                if (contentOrDivider is UnitDivider) {
                  return Text('${contentOrDivider.heading}');
                } else if (contentOrDivider is UnitContent) {
                  return Wrap(
                    children: List.generate(contentOrDivider.unitContent.length,
                        (index) {
                      return GestureDetector(
                        onTap: () {
                          onTextTap(curFirstWordIndex + index);
                        },
                        child: Container(
                            color: toggleHighlight[curFirstWordIndex + index],
                            padding: EdgeInsets.all(2.0),
                            child: Text(contentOrDivider.unitContent[index])),
                      );
                    }),
                  );
                }
              })),
        ),
      );
}
  reset() {
    setState(() {
      toggleHighlight.fillRange(0, wordsCount, Colors.transparent);
      highlightIndex = null;
      HighlightStack.stack.clear();
      isStackEmpty = true;
    });
  }

  onTextTap(int tapIndex) {
    HighlightStack.push(HighlightStack(FunctionName.ON_TEXT_TAP, tapIndex,
        toggleHighlight[tapIndex], highlightIndex));
    setState(() {
      if (toggleHighlight[tapIndex] != Colors.transparent) {
        toggleHighlight[tapIndex] = Colors.transparent;
        highlightIndex = null;
      } else {
        toggleHighlight[tapIndex] = curHighlightColor;
        highlightIndex = ++tapIndex;
      }
      if (HighlightStack.stack.length == 1) isStackEmpty = false;
    });
  }

  forwardSelection() {
    HighlightStack.push(HighlightStack(FunctionName.FORWARD_SELECTION, null,
        toggleHighlight[highlightIndex], highlightIndex));
    setState(() {
      toggleHighlight[highlightIndex++] = curHighlightColor;
      if (HighlightStack.stack.length == 1) isStackEmpty = false;
    });
  }

  undo() {
    HighlightStack lastoperation = HighlightStack.pop();
    if (HighlightStack.stack.isEmpty) {
      setState(() {
        isStackEmpty = true;
      });
    }
    if (lastoperation == null) return;
    switch (lastoperation.functionName) {
      case FunctionName.ON_TEXT_TAP:
        setState(() {
          toggleHighlight[lastoperation.tapIndex] =
              lastoperation.highlightColor;
          highlightIndex = lastoperation.highlightIndex;
        });
        break;
      case FunctionName.FORWARD_SELECTION:
        setState(() {
          toggleHighlight[lastoperation.highlightIndex] =
              lastoperation.highlightColor;
          highlightIndex = lastoperation.highlightIndex;
        });
    }
  }

  int processSyllabus(String courseContent) {
    int wordsCount = 0;
    List<String> units =
        courseContent.split(RegExp(r'[\n]{1,}[\s]{0,}[\n]{1,}'));
    for (var i = 0; i < units.length; i++) {
      if (units[i].trim() != '') {
        syllabus.add(UnitDivider('\n'));
        wordsCount += processUnit(units[i]);
      }
    }
    return wordsCount;
  }

  int processUnit(String unitContent) {
    int wordsCount = 0;
    unitContent.split(RegExp(r'[\n]{1,}')).forEach((unitContentPara) {
      if (unitContentPara.trim() != '') {
        final unitContentWords =
            unitContentPara.trim().split(RegExp(r'[\s]{1,}'));
        syllabus.add(UnitContent(unitContentWords));
        wordsCount += unitContentWords.length;
      }
    });
    return wordsCount;
  }
}

enum FunctionName { ON_TEXT_TAP, FORWARD_SELECTION }

class HighlightStack {
  static ListQueue<HighlightStack> stack = ListQueue<HighlightStack>(10);
  final FunctionName functionName;
  final int tapIndex;
  final Color highlightColor;
  final int highlightIndex;

  HighlightStack(this.functionName, this.tapIndex, this.highlightColor,
      this.highlightIndex);
  static push(HighlightStack hs) {
    if (stack.length == 10) stack.removeFirst();
    stack.addLast(hs);
  }

  static HighlightStack pop() {
    if (stack.isEmpty) return null;
    return stack.removeLast();
  }
}

abstract class CourseContent {}

class UnitDivider extends CourseContent {
  String heading;

  UnitDivider(this.heading);
}

class UnitContent extends CourseContent {
  List<String> unitContent;

  UnitContent(this.unitContent);
}
