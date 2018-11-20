import 'package:bmsce/course/course_dept_sem.dart';
import 'package:bmsce/notification/noti_card.dart';
import 'package:flutter/material.dart';
import 'package:bmsce/notification/notification_provider.dart';
import 'package:tuple/tuple.dart';

class AnnouncementPreview extends StatelessWidget {
  final NotiBuilder notiBuilder;

  const AnnouncementPreview({Key key, @required this.notiBuilder})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: AppBar(
        title: Text('Anncouncement Preview'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              sendNotification(context);
            },
          )
        ],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(children: [
            NotiCard(notiMap: notiBuilder.getMyNotificationObj().data),
            Divider(),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: 'Note:',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  TextSpan(text: '  This will be sent to '),
                  TextSpan(text: getTargetUserDetails(), style: textStyle),
                  TextSpan(
                      text: notiBuilder.userType == 'none' ? ' from ' : ' of '),
                  TextSpan(
                      text: notiBuilder.deptType == 'department'
                          ? deptNameFromPrefix(notiBuilder.deptValue).item2 +
                              ' Dept'
                          : "All departments",
                      style: textStyle),
                ]),
                style: TextStyle(fontSize: 16.0),
              ),
            )
          ]),
        ),
      ),
    );
  }

  String getTargetUserDetails() {
    if (notiBuilder.userType == "student") {
      return "${notiBuilder.semesterType == 'semester' ? getNumberText(notiBuilder.semesterValue) + ' sem' : ''} " +
          "${notiBuilder.sectionType == 'section' ? '  ' + notiBuilder.sectionValue + ' section  ' : ''} Students";
    } else if (notiBuilder.userType == "faculty") {
      return 'Faculties';
    } else {
      return 'Everyone';
    }
  }

  void sendNotification(context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return NotiUploadDialog(
              myNotification: notiBuilder.getMyNotificationObj());
        });
  }
}

class NotiUploadDialog extends StatelessWidget {
  final MyNotification myNotification;

  const NotiUploadDialog({Key key, @required this.myNotification})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: FutureBuilder<Tuple2>(
        future: myNotification.publish(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
            case ConnectionState.active:
              return Row(
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text('  Sending Notification')
                ],
              );
            case ConnectionState.done:
              if (snapshot.hasData) {
                WidgetsBinding.instance.addPostFrameCallback((duration) async {
                  Future.delayed(Duration(milliseconds: 1200), () {
                    Navigator.of(context).pop(true);
                  });
                });
                return Row(
                  children: <Widget>[
                    Icon(snapshot.data.item1 ? Icons.check : Icons.warning),
                    Text('  ' + snapshot.data.item2)
                  ],
                );
              } else {
                return Row(
                  children: <Widget>[
                    Icon(Icons.warning),
                    Expanded(child: Text('  Failed to send notification.'))
                  ],
                );
              }
          }
        },
      ),
    );
  }
}
