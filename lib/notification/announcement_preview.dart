import 'package:bmsce/course/course_dept_sem.dart';
import 'package:flutter/material.dart';
import 'package:bmsce/notification/notification.dart';
import 'package:url_launcher/url_launcher.dart';

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
            onPressed: () {},
          )
        ],
      ),
      body: Column(children: [
        NotiCard(
          noti: notiBuilder.getMyNotificationObj(),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: 'Note:', style: TextStyle(fontStyle: FontStyle.italic)),
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
}

class NotiCard extends StatelessWidget {
  final MyNotification noti;

  openLink() async {
    if (await canLaunch(noti.data['link'])) {
      launch(noti.data['link']);
    }
  }

  const NotiCard({Key key, this.noti}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    noti.title,
                    style: Theme.of(context).textTheme.title,
                    softWrap: true,
                  ),
                ),
                FlatButton.icon(
                  // child: Text('VIEW'),
                  shape: Border.all(color: Colors.grey[300]),
                  label: Text('Open'),
                  icon: Icon(Icons.open_in_browser),

                  onPressed: noti.data['link'].toString().isNotEmpty
                      ? () {
                          openLink();
                        }
                      : null,
                )
              ],
            ),
            Divider(),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                noti.data['message'],
                style: Theme.of(context)
                    .textTheme
                    .body2, //body1 read, body2 unread
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(noti.data['senderName']),
                Text(DateTime.parse(noti.data['serverTimestamp'].toString())
                    .toIso8601String())
              ],
            )
          ],
        ),
      ),
    );
  }
}
