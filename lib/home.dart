import 'package:bmsce/home_tabs/syllabus_tabs.dart';
import 'package:bmsce/map/search.dart';
import 'package:bmsce/notification/notification_sqf.dart';
import 'package:bmsce/notification/notifications.dart';
import 'package:bmsce/portion/portion_provider_sqf.dart';
import 'package:bmsce/syllabus/portion_view.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:bmsce/user_profile/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final User user;
  HomePage(this.user) : assert(user != null);
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 1;
  dynamic currentHomeTab;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  // final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    print('user @ home ${widget.user.dept}');
    currentHomeTab = Search();
    _retrieveDynamicLink();
    configureFcm();
  }

  push(screen) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return screen;
    }));
  }

  Future<void> _retrieveDynamicLink() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.retrieveDynamicLink();
    final Uri deepLink = data?.link;

    if (deepLink == null) return;
    // switch (deepLink.path.split("/")[1]) {
    //   case "portions":
    if (deepLink.queryParameters['link'].startsWith('portions')) {
      final portionSnap = await Firestore.instance
          .document(deepLink.queryParameters['link'])
          .get();
      if (portionSnap != null && portionSnap.exists) {
        portionSnap.data['dynamicLink'] = deepLink.queryParameters['link'];
        await PortionProvider().insert(portionMap: portionSnap.data);
        push(PortionView.fromPortionObj(
            PortionProvider().portionFrmMap(portionSnap.data)));
      }

      // }
    }
  }

  configureFcm() async {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        NotiSqf().insert(message['data'] ?? message);
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        final notiData = message['data'] ?? message;
        NotiSqf().insert(notiData);
        _handleNotiLaunch(notiData['type']);
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        NotiSqf().insert(message['data'] ?? message);
        print("onResume: $message");
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  _handleNotiLaunch(String type) {
    switch (type) {
      default:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return Notifications();
        }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: currentHomeTab,
        ),
        BottomNavigationBar(
            onTap: (botNavBarIndex) {
              setState(() {
                currentIndex = botNavBarIndex;
                switch (currentIndex) {
                  case 0:
                    currentHomeTab = SyllabusTabs();
                    break;
                  case 1:
                    currentHomeTab = Search();
                    break;
                  case 2:
                    currentHomeTab = UserProfile();
                    break;
                }
              });
            },
            currentIndex: currentIndex,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.book), title: Text('syllabus')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), title: Text('search')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle), title: Text('user')),
            ]),
      ],
    );
  }
}
