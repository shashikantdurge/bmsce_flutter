import 'dart:async';

import 'package:bmsce/course/course.dart';
import 'package:bmsce/course/course_provider_sqf.dart';
import 'package:bmsce/my_widgets/color_radio_button.dart';
import 'package:bmsce/portion/portion_provider_sqf.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:flutter/material.dart';
import 'dart:collection';

final List<Color> highlightColors = [
  Colors.amber[100],
  Colors.pink[100],
  Colors.cyan[100],
  Colors.deepOrange[100],
  Colors.indigo[100]
];

class PortionCreate extends StatelessWidget {
  final Course course;
  final String description;
  PortionCreate({Key key, @required this.course, @required this.description})
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
              '${course.courseName}',
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
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                save(context);
              }),
        ],
      ),
      body: FutureBuilder<List<CourseContentPart>>(
        future: processSyllabus(course.courseCode, course.codeVersion),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          print(
              'PortionCreate ${snapshot.connectionState} hasData:${snapshot.hasData} hasError:${snapshot.hasError}');
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData)
            return PortionEditEnv(
              courseContent: snapshot.data,
            );
          else
            return Center(child: CircularProgressIndicator());
        },
      ),
    );
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
        wordsCount += processUnit(units[i]);
      }
    }
    UnitContent.totalWordsCount = wordsCount;
    return courseContentParts;
  }

  Future<void> save(BuildContext context) async {
    final toggleHighlight = PortionEditEnvState.toggleHighlight;
    List<int> saveToggleBorderIndexes = [0];
    List<int> toggleColorIndexes = [];
    for (var i = 1; i < UnitContent.totalWordsCount; i++) {
      if (toggleHighlight[i] == toggleHighlight[i - 1])
        continue;
      else {
        saveToggleBorderIndexes.add(i);
        toggleColorIndexes.add(highlightColors.indexOf(toggleHighlight[i - 1]));
      }
    }
    saveToggleBorderIndexes.add(UnitContent.totalWordsCount);
    toggleColorIndexes.add(highlightColors
        .indexOf(toggleHighlight[UnitContent.totalWordsCount - 1]));
    String toggleBordIndexesStr = saveToggleBorderIndexes.join(",");
    String toggleColorIndexesStr = toggleColorIndexes.join(",");
    await PortionProvider().insert(Portion(
        courseCode: course.courseCode,
        courseName: course.courseName,
        codeVersion: course.codeVersion,
        createdBy: User.instance.displayName,
        createdOn: DateTime.now().millisecondsSinceEpoch,
        description: description,
        isOutdated: 0,
        isTeacherSignature: 0,
        toggleBordColorIndexes: toggleBordIndexesStr,
        toggleColorIndexes: toggleColorIndexesStr));
    Navigator.of(context).pop();
  }
}

class PortionEditEnv extends StatefulWidget {
  final List<CourseContentPart> courseContent;

  const PortionEditEnv({Key key, this.courseContent}) : super(key: key);
  PortionEditEnvState createState() => PortionEditEnvState();
}

class PortionEditEnvState extends State<PortionEditEnv>
    with SingleTickerProviderStateMixin {
  static const double editToolKitHeight = 110.0;
  static List<Color> toggleHighlight;
  int highlightIndex;
  Color curHighlightColor = highlightColors[2];
  bool isLongPressed = false;
  bool isStackEmpty = true;

  @override
  void initState() {
    super.initState();
    toggleHighlight = List<Color>(UnitContent.totalWordsCount);
    toggleHighlight.fillRange(
        0, UnitContent.totalWordsCount, Colors.transparent);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        buildCourseContent(),
        Positioned(
          child: Container(
            height: editToolKitHeight,
            child: buildEditKit(),
            decoration: BoxDecoration(
                color: Colors.white, border: Border.all(color: Colors.grey)),
          ),
          bottom: 1.0,
          left: 1.0,
          right: 1.0,
        )
      ],
    );
  }

  Widget buildEditKit() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(highlightColors.length, (index) {
                return ColorRadioButton(
                  color: highlightColors[index],
                  groupColor: curHighlightColor,
                  onChanged: (Color value) {
                    setState(() {
                      curHighlightColor = highlightColors[index];
                    });
                  },
                );
              })),
        ),
        ButtonTheme(
          minWidth: 88.0,
          child: Padding(
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
                    while (isLongPressed &&
                        highlightIndex < UnitContent.totalWordsCount) {
                      await Future.delayed(
                          Duration(milliseconds: 222), forwardSelection());
                    }
                  },
                  onPointerUp: (up) {
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
          ),
        )
      ],
    );
  }

  Widget buildCourseContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(widget.courseContent.length, (index) {
              final contentOrDivider = widget.courseContent[index];
              var lastToggleIndex = index;
              var curFirstWordIndex = 0;
              while (lastToggleIndex > 0) {
                final lastContentOrDivider =
                    widget.courseContent[--lastToggleIndex];
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
            })
              ..add(Container(height: editToolKitHeight))),
      ),
    );
  }

  reset() {
    setState(() {
      toggleHighlight.fillRange(
          0, UnitContent.totalWordsCount, Colors.transparent);
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
      if (HighlightStack.stack.length > 0) isStackEmpty = false;
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

abstract class CourseContentPart {}

class UnitDivider extends CourseContentPart {
  String divider;

  UnitDivider(this.divider);
}

class UnitContent extends CourseContentPart {
  static int totalWordsCount;
  List<String> unitContent;

  UnitContent(this.unitContent);
}
