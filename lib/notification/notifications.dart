import 'package:bmsce/notification/noti_card.dart';
import 'package:bmsce/notification/notification_sqf.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  NotificationsState createState() => NotificationsState();
}

class NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: () {
                NotiSqf().deleteAll().then((onValue) {
                  setState(() {});
                });
              },
            )
          ],
        ),
        body: FutureBuilder<List<Map>>(
          future: NotiSqf().getAll(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                if (snapshot.hasData) {
                  if (snapshot.data.isEmpty)
                    return Center(child: Text('No notifications'));
                  return Scrollbar(
                      child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(snapshot.data.length, (i) {
                        return NotiCard(
                            notiMap: snapshot.data[i]['data'],
                            isUnRead: snapshot.data[i]['isUnRead']);
                      }),
                    ),
                  ));
                }
            }
          },
        ));
  }
}
