import 'package:bmsce/home_tabs/syllabus_tabs.dart';
import 'package:bmsce/portion/portion_provider_sqf.dart';
import 'package:bmsce/syllabus/portion_view.dart';
import 'package:bmsce/temp/search.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:bmsce/user_profile/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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
  // final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    print('user @ home ${widget.user.dept}');
    currentHomeTab = SearchDemo();
    _retrieveDynamicLink();
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
        Theme(
          data: Theme.of(context).copyWith(
              //canvasColor: Colors.red[400],
              ),
          child: BottomNavigationBar(
              onTap: (botNavBarIndex) {
                setState(() {
                  currentIndex = botNavBarIndex;
                  switch (currentIndex) {
                    case 0:
                      currentHomeTab = SyllabusTabs();
                      break;
                    case 1:
                      currentHomeTab = SearchDemo();
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
        )
      ],
    );
  }
}
