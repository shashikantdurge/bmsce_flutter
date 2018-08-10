import 'package:flutter/material.dart';

import 'SyllabusView.dart';

class PortionView extends StatefulWidget {
  PortionViewState createState() => PortionViewState();
}

class PortionViewState extends State<PortionView> {
  var portion = SyllabusViewState.syllabus;
  int wordsCount;
  var i;

  @override
  void initState() {
    super.initState();
    i=0;
    wordsCount = processSyllabus(portion);
    toggleHighlight = List(wordsCount)..fillRange(0, wordsCount, false);
    processHighlight();
  }

  @override
  Widget build(BuildContext context) {
    i=0;
    toggleHighlight.fillRange(56, 78, true);
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Structures ${portion.length}'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                showLtpsTable();
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Column(
            //TODO : List of Wraps (Each Wrap is a Unit's content)
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(syllabus.length, (index) {
              var headOrContent = syllabus[index];

              if (headOrContent is Heading) {
                return Container(
                  color:  toggleHighlight[i++] ? Colors.amber : null,
                  child: Text('${headOrContent.heading}'),
                );
              } else if (headOrContent is UnitContent) {
                return Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: headOrContent.unitContent.map((content) {
                    return Container(
                        color: toggleHighlight[i++] ? Colors.amber : null,
                        padding: EdgeInsets.all(2.0),
                        child: Text(content));
                  }).toList(),
                );
              }

            }),
          ),
        ),
      ),
    );
  }
  int processSyllabus(String course) {
    int wordsCount = 0;
    List<String> units = course.split(RegExp('UNIT-[0-9]'));
    var i = 1;
    units.forEach((unit) {
      if (unit.trim() != '') {
        syllabus.add(Heading('UNIT-${i++}'));
        wordsCount++;
        wordsCount += processUnit(unit);
      }
    });
    return wordsCount;
  }

  int processUnit(String unitContent) {
    int wordsCount = 0;
    unitContent.split('\n').forEach((unitContentPara) {
      if (unitContentPara.trim() != '') {
        final unitContentWords = unitContentPara.trim().split(' ');
        syllabus.add(UnitContent(unitContentWords));
        wordsCount += unitContentWords.length;
      }
    });
    return wordsCount;
  }

  showLtpsTable() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            //height: 100.0,
            child: BottomSheet(
                onClosing: () {},
                builder: (context) {
                  return GestureDetector(
                    child: Container(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Portion Details',
                        )),
                  );
                }),
          );
        });
  }

  processHighlight() {
    toggleHighlight.fillRange(0, 3, true);
  }
}

List<Syllabus> syllabus = [];
List<bool> toggleHighlight;

abstract class Syllabus {}

class Heading extends Syllabus {
  String heading;

  Heading(this.heading);
}

class UnitContent extends Syllabus {
  List<String> unitContent;

  UnitContent(this.unitContent);
}
