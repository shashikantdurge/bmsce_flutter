import 'package:bmsce/home_tabs/syllabus_tabs.dart';
import 'package:bmsce/map/college_map.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:bmsce/user_profile/user_profile.dart';
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
                      currentHomeTab = CollegeMap();
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
                    icon: Icon(Icons.map), title: Text('map')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle), title: Text('user')),
              ]),
        )
      ],
    );
  }
}