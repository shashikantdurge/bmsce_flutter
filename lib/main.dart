import 'package:bmsce/authentication/sign_in.dart';
import 'package:bmsce/home_tabs/syllabus_tabs.dart' as syllabus;
import 'package:bmsce/map/college_map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Chat/Dummy.dart' as chat;
import 'TimeTable/Dummy.dart' as tt;

void main() async {
  final mainTheme = ThemeData(
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
    inputDecorationTheme:
        InputDecorationTheme(contentPadding: EdgeInsets.all(12.0)),
    buttonColor: const Color(0xFFE53935),
    primaryColor: Colors.red[500],
  );

  dynamic entryPage;
  FirebaseUser user = await FirebaseAuth.instance.currentUser();
  if (user != null) {
    entryPage = HomePage(user);
    print('${user.uid}');
  } else
    entryPage = Login();

  runApp(MaterialApp(
    title: 'BMSCE',
    theme: mainTheme,
    home: entryPage,
  ));
}

class HomePage extends StatefulWidget {
  final FirebaseUser user;
  HomePage(this.user) : assert(user != null);
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 2;
  dynamic currentHomeTab;

  @override
  void initState() {
    super.initState();
    currentHomeTab = CollegeMap();
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
                      currentHomeTab = CollegeMap();
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
