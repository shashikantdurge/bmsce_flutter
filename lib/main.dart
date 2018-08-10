import 'package:bmsce/homeTabs/syllabusTabs.dart' as syllabus;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Chat/Dummy.dart' as chat;
import 'Map/Dummy.dart' as map;
import 'TimeTable/Dummy.dart' as tt;
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  final app =await FirebaseApp.configure(
    name: 'test',
    options: const FirebaseOptions(
      googleAppID: '1:131447312475:android:c4c1a65536326ae6',
      gcmSenderID: '131447312475',
      apiKey: 'AIzaSyCmjqBV_OzUO8wQ01mSC8BSYLcP8v4jV4s',
      projectID: 'bmsce-flutter',
    ),
  );
  final Firestore firestore = Firestore(app: app);
  runApp(MyApp(firestore: firestore,));
}

class MyApp extends StatelessWidget {
  final Firestore firestore;
  MyApp({this.firestore}):assert(firestore!=null);
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'BMSCE',
      theme: new ThemeData(
        /*primaryColor: Colors.red[400],
        buttonColor: Colors.red[400],
        accentColor: Colors.red[300],
        canvasColor: Colors.grey[50],*/
        //brightness: Brightness.light,
        primarySwatch: const MaterialColor(
          0xFFF44336,
          const <int, Color>{
            50: const Color(0xFFFFEBEE),
            100: const Color(0xFFFFCDD2),
            200: const Color(0xFFEF9A9A),
            300: const Color(0xFFE57373),
            400: const Color(0xFFEF5350),
            500: const Color(0xFFF44336),
            600: const Color(0xFFE53935),
            700: const Color(0xFFD32F2F),
            800: const Color(0xFFC62828),
            900: const Color(0xFFB71C1C),
          },
        ),
        primaryColor: Colors.red[500],

        //primarySwatch: Colors.red[400],
      ),
      home: MyBottomNavBar(),
    );
  }
}

class MyBottomNavBar extends StatefulWidget {
  MyBottomNavBar();
  MyBottomNavBarState createState() => MyBottomNavBarState();
}

class MyBottomNavBarState extends State<MyBottomNavBar>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  dynamic currentHomeTab;

  @override
  void initState() {
    super.initState();
    currentHomeTab = syllabus.SyllabusTabs();
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
                canvasColor: Colors.red[400],
              ),
          child: BottomNavigationBar(
              onTap: (botNavBarIndex) {
                setState(() {
                  currentIndex = botNavBarIndex;
                  switch (currentIndex) {
                    case 0:
                      currentHomeTab = syllabus.SyllabusTabs();
                      break;
                    case 1:
                      currentHomeTab = tt.DummyTabs();
                      break;
                    case 2:
                      currentHomeTab = map.DummyTabs();
                      break;
                    case 3:
                      currentHomeTab = chat.DummyTabs();
                      break;
                  }
                });
              },
              currentIndex: currentIndex,
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.book), title: Text('syllabus')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.access_time), title: Text('time table')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.map), title: Text('map')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.chat), title: Text('chat')),
              ]),
        )
      ],
    );
  }
}
