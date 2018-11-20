import 'dart:async';

import 'package:bmsce/course/course_provider_sqf.dart';
import 'package:bmsce/notification/announcement_preview.dart';
import 'package:bmsce/notification/notification_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';
import 'package:bmsce/portion/portion_provider_sqf.dart';
import 'package:bmsce/syllabus/portion_create.dart';
import 'package:flutter/material.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share/share.dart';

class PortionView extends StatelessWidget {
  final String courseName;
  final String createdBy;
  final int createdOn;
  final String description;
  final Portion portion;

  PortionView(
      {Key key,
      this.createdBy,
      this.createdOn,
      this.portion,
      @required this.courseName,
      @required this.description})
      : assert(createdOn != null && createdBy != null || portion != null),
        super(key: key);

  factory PortionView.fromPortionObj(Portion portion) {
    return PortionView(
      courseName: portion.courseName,
      description: portion.description,
      portion: portion,
    );
  }

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
          IconButton(
              tooltip: 'Share with link',
              icon: Icon(Icons.share),
              onPressed: () {
                _share(context);
              }),
          IconButton(
              tooltip: 'Send portion notification',
              icon: Icon(Icons.send),
              onPressed: () {
                _share(context, sendNoti: true);
              })
        ],
      ),
      body: FutureBuilder<Tuple2<List<CourseContentPart>, List<Color>>>(
        future: processPortion(),
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

  _share(BuildContext context, {bool sendNoti = false}) async {
    final portion = await PortionProvider().getPortion(createdBy, createdOn);
    final link = await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            // height: 100.0,
            // width: MediaQuery.of(context).size.width * 0.6,
            // padding: EdgeInsets.all(15.0),
            content: FutureBuilder(
              future: getLink(portion),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  WidgetsBinding.instance.addPostFrameCallback((d) {
                    Navigator.of(context).pop(snapshot.data);
                  });
                  return Text(snapshot.data);
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return Text('Something went wrong.');
                } else {
                  return Row(
                    children: [
                      CircularProgressIndicator(),
                      Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Text('Creating link...'))
                    ],
                  );
                }
              },
            ),
          );
        });
    if (link is String && !sendNoti)
      Share.share(
          'Portion for ${portion.courseName}\n${portion.description}\n$link');
    else if (link is String && sendNoti)
      _sendNotification(context, portion, link);
  }

  void _sendNotification(context, Portion portion, String link) {
    NotiBuilder notiBuilder = NotiBuilder();
    notiBuilder.link = link;
    notiBuilder.notificationType = NotificationType.PORTION;
    notiBuilder.title = "${portion.courseName}, ${portion.description} portion";
    notiBuilder.body =
        "${portion.courseName} portion for ${portion.description}. All the best.";
    notiBuilder.topic = portion.courseCode;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return NotiUploadDialog(
              myNotification: notiBuilder.getMyNotificationObj());
        });
  }

//IOS DYNAMIC LINK SETUP
  Future<String> getLink(Portion portion) async {
    final link = portion.dynamicLink != null
        ? portion.dynamicLink
        : (await Firestore.instance
                .collection('portions')
                .add(PortionProvider().portionToMap(portion)))
            .path;
    if (portion.dynamicLink == null) {
      portion.dynamicLink = link;
      PortionProvider().updateDynamicLink(portion);
    }
    final linkParams = DynamicLinkParameters(
      domain: 'bmsce.page.link',
      link: Uri.parse(
          'https://bmsce.ac.in/?link=$link&st=${portion.courseName}&sd=${portion.description}'),
      androidParameters: AndroidParameters(
          packageName: 'com.shashikant.bmsce', minimumVersion: 0),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
    );
    final longUrl = await linkParams.buildUrl();
    final ShortDynamicLink shortenedLink =
        await DynamicLinkParameters.shortenUrl(
      longUrl,
      new DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );

    return shortenedLink.shortUrl.toString();
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

  Future<Tuple2<List<CourseContentPart>, List<Color>>> processPortion() async {
    //TODO: get portion  include courseCode in where
    final portion = this.portion != null
        ? this.portion
        : await PortionProvider().getPortion(createdBy, createdOn);
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
