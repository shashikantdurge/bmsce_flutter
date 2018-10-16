import 'dart:async';

import 'package:bmsce/authentication/sign_in.dart';
import 'package:bmsce/home.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final mainTheme = ThemeData(
    primarySwatch: const MaterialColor(
      0xFF0097A7,
      const <int, Color>{
        50: const Color(0xFFFFEBEE),
        100: const Color(0xFFFFCDD2),
        200: const Color(0xFFEF9A9A),
        300: const Color(0xFFE57373),
        400: const Color(0xFFEF5350),
        500: const Color(0xFF0097A7),
        600: const Color(0xFFE53935),
        700: const Color(0xFFD32F2F),
        800: const Color(0xFFC62828),
        900: const Color(0xFFB71C1C),
      },
    ),
    inputDecorationTheme:
        InputDecorationTheme(contentPadding: EdgeInsets.all(12.0)),
    buttonColor: const Color(0xFFE53935),
    primaryColor: Colors.cyan[500],
  );

  runApp(MaterialApp(
    title: 'BMSCE',
    theme: mainTheme,
    // home: SearchDemo(),
    home: Splash(from: 'main'),
  ));
}

class Splash extends StatefulWidget {
  final String from;
  final Map userDetails;

  const Splash({Key key, @required this.from, this.userDetails})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return SplashState();
  }
}

class SplashState extends State<Splash> {
  SharedPreferences pref;
  // AnimationController animationController;
  @override
  void initState() {
    super.initState();
    // animationController = AnimationController(
    //     vsync: this, duration: Duration(milliseconds: 10000))
    //   ..repeat();
  }

  @override
  void dispose() {
    // animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: process(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return Image.asset(
                  'assets/images/bmsce_logo.png',
                  scale: 3.0,
                );
                break;
              case ConnectionState.done:
                if (snapshot.data == null || snapshot.hasError) {
                  WidgetsBinding.instance.addPostFrameCallback((d) {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return Login();
                    }));
                  });
                  return Image.asset(
                    'assets/images/bmsce_logo.png',
                    scale: 3.0,
                  );
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((d) {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (BuildContext context) {
                      User.instance = snapshot.data;
                      return HomePage(User.instance);
                    }));
                  });
                  return Image.asset(
                    'assets/images/bmsce_logo.png',
                    scale: 3.0,
                  );
                }
            }
          },
        ),
      ),
    );
  }

  // load() {
  //   return Stack(
  //     fit: StackFit.expand,
  //     alignment: AlignmentDirectional.center,
  //     children: <Widget>[
  //       RotationTransition(
  //         turns: animationController,
  //         child: Image.asset(
  //           'assets/images/bmsce_logo_outer_2.png',
  //           scale: 3.0,
  //         ),
  //       ),
  //       Image.asset(
  //         'assets/images/bmsce_logo_inner.png',
  //         scale: 3.0,
  //       )
  //     ],
  //   );
  // }

  process() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    if (firebaseUser == null)
      return null;
    else {
      pref = await SharedPreferences.getInstance();
      return await getUser(firebaseUser);
    }
  }

  Future<String> getRoleInfo(String email, String dept) async {
    return await Firestore.instance
        .collection('roles')
        .document(dept)
        .get()
        .then((doc) {
      if (doc.data.containsKey(email))
        return doc.data[email]['role'];
      else
        return 'default';
    }).catchError((err) {
      return 'default';
    });
  }

  setDataOffline(String role) {
    widget.userDetails.forEach((key, value) {
      if (value is String) {
        pref.setString("user_property_" + key, value);
      }
    });
    pref.setString('user_property_role', role);
  }

  Future<User> getUser(FirebaseUser firebaseUser) async {
    String role, dept, usn;
    if (widget.from == 'sign_in') {
      role = await getRoleInfo(firebaseUser.email, widget.userDetails['dept']);
      dept = widget.userDetails['dept'];
      usn = widget.userDetails['usn'];
      setDataOffline(role);
    } else {
      role = pref.getString('user_property_role');
      dept = pref.getString('user_property_dept');
      usn = pref.getString('user_property_usn');
    }

    final user = User.fromRole(role,
        dept: dept,
        displayName: firebaseUser.displayName,
        email: firebaseUser.email,
        photoUrl: firebaseUser.photoUrl,
        usn: usn);
    return user;
  }
}
