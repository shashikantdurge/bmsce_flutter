import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bmsce/utils.dart';

class NotiCard extends StatelessWidget {
  final Map<String, dynamic> notiMap;
  final bool isUnRead;

  openLink() async {
    if (await canLaunch(notiMap['link'])) {
      launch(notiMap['link']);
    }
  }

  const NotiCard({Key key, this.notiMap, this.isUnRead = false})
      : super(key: key);
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
                    notiMap["title"] ?? "No Title",
                    style: Theme.of(context).textTheme.title,
                    softWrap: true,
                  ),
                ),
                FlatButton.icon(
                  // child: Text('VIEW'),
                  shape: Border.all(color: Colors.grey[300]),
                  label: Text('Open'),
                  icon: Icon(Icons.open_in_browser),

                  onPressed: notiMap['link'].toString().isNotEmpty
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
              child: Text(notiMap['message'] ?? "No message",
                  style: isUnRead
                      ? Theme.of(context).textTheme.body2
                      : Theme.of(context).textTheme.body1),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(notiMap['senderName']),
                Text(toHrTime(notiMap['serverTimestamp'])),
              ],
            )
          ],
        ),
      ),
    );
  }
}
