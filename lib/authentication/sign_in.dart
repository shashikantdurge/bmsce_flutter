import 'dart:async';

import 'package:bmsce/authentication/entry_exit.dart';
import 'package:bmsce/course/course_dept_sem.dart';
import 'package:bmsce/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  final firestore = Firestore.instance;
  final auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn(
    //hostedDomain: "bmsce.ac.in",
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> with TickerProviderStateMixin {
  AnimationController butHtController;
  Animation<double> butHtanimation;
  AnimationController contController;
  Animation<double> contAnimation;
  AnimationController fadeAnimation;
  String photoUrl = "";
  CrossFadeState fadeState = CrossFadeState.showFirst;
  TextEditingController usnController = TextEditingController();
  String deptValue;
  GoogleSignInAccount googleSignInAccount;

  Widget btChild = Text('SIGN IN WITH BMSCE ACCOUNT');
  Widget proceedBtChild = Text('CREATE ACCOUNT');
  int stackIndex = 0;

  @override
  void initState() {
    super.initState();
    butHtController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    butHtanimation = Tween(begin: 1.0, end: 0.0).animate(butHtController);
    contController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    contAnimation = Tween(begin: 0.1, end: 1.0).animate(contController);
    fadeAnimation = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      persistentFooterButtons: <Widget>[],
      body: Padding(
        padding: EdgeInsets.all(18.0),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(12.0),
                child: AnimatedCrossFade(
                  firstChild: Image.asset(
                    'assets/images/bmsce_logo.png',
                    height: 80.0,
                    width: 80.0,
                  ),
                  secondChild: CircleAvatar(
                    radius: 40.0,
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  crossFadeState: fadeState,
                  duration: Duration(milliseconds: 500),
                ),
              ),
              //Text('BMSCE',style: TextStyle(fontSize: 20.0),),
              IndexedStack(
                index: stackIndex,
                children: <Widget>[
                  SizeTransition(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: MaterialButton(
                        height: 48.0,
                        textColor: Colors.white,
                        child: btChild,
                        onPressed: () {
                          _handleGoogleSignIn();
                        },
                        minWidth: double.infinity,
                        color: Colors.red,
                      ),
                    ),
                    sizeFactor: butHtanimation,
                  ),
                  SizeTransition(
                      sizeFactor: contAnimation, child: widgetUserSignUp())
                ],
              ),
              FadeTransition(
                opacity: fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.0, top: 12.0),
                  child: RaisedButton(
                    //height: 48.0,
                    textColor: Colors.white,
                    //color: ,
                    child: proceedBtChild,
                    onPressed: () async {
                      final accountDetails = Map<String, String>();
                      accountDetails['email'] = googleSignInAccount.email;
                      accountDetails['name'] = googleSignInAccount.displayName;
                      if (usnController.text.isNotEmpty)
                        accountDetails['usn'] =
                            usnController.text.toUpperCase();
                      accountDetails['dept'] = deptValue ?? "ZZ";
                      setState(() {
                        proceedBtChild = CircularProgressIndicator();
                      });
                      FirebaseUser user = await _createAccount(accountDetails);
                      if (user != null)
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return HomePage(user);
                        }));
                      else
                        setState(() {
                          proceedBtChild = Text('CREATE ACCOUNT');
                        });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget widgetUserSignUp() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.red)),
      //height: 300.0,
      width: double.infinity,
      //color: Colors.red,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 12.0,
            ),
            child: Text(googleSignInAccount?.displayName ?? "Name"),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 12.0,
            ),
            child: Text(googleSignInAccount?.email ?? "Email"),
          ),
          SizedBox(
            width: 250.0,
            child: TextFormField(
              autovalidate: true,
              controller: usnController,
              decoration: InputDecoration(
                labelText: 'USN',
                //border: OutlineInputBorder(),
              ),
              validator: (usn) {
                if (!usn.contains(
                        RegExp(r'^1[bB][mM]\d{2}[a-zA-Z]{2}\d{3}$')) &&
                    usn.isNotEmpty) return 'Invalid USN';
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 12.0,
            ),
            child: DropdownButton(
              hint: Text('Select Department'),
              value: deptValue,
              items: List.generate(Departments.length, (index) {
                return DropdownMenuItem(
                  child: Text(Departments[index].item2),
                  value: Departments[index].item1,
                );
              }),
              onChanged: (value) {
                setState(() {
                  deptValue = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Null> _handleGoogleSignIn() async {
    setState(() {
      btChild = CircularProgressIndicator(
        valueColor: ColorTween(begin: Colors.blue, end: Colors.blue)
            .animate(contController),
      );
    });

    try {
      googleSignInAccount = await widget._googleSignIn.signIn();
      //#TODO:if(!googleSignInAccount.email.endsWith("@bmsce.ac.in"))return;
      //_googleSignIn.signOut();

      //check if user is signing for the first time
      final userSnap = await getUserData(googleSignInAccount.email);
      if (!userSnap.exists) {
        //FIRST TIME USER
        setState(() {
          photoUrl = googleSignInAccount.photoUrl;
        });
        butHtController.forward().whenComplete(() {
          setState(() {
            fadeState = CrossFadeState.showSecond;
            stackIndex = 1;
          });
          contController.forward().whenComplete(() {
            fadeAnimation.forward();
          });
        });
      } else {
        //USER ACCOUNT EXISTS

        GoogleSignInAuthentication googleAuthentication =
            await googleSignInAccount.authentication;
        final user = await widget.auth.signInWithGoogle(
            idToken: googleAuthentication.idToken,
            accessToken: googleAuthentication.accessToken);
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
          return HomePage(user);
        })).then(setEntryUserData(userSnap.data, googleSignInAccount.email));
      }
    } catch (error) {
      print(error);
      setState(() {
        btChild = Text('SIGN IN WITH BMSCE ACCOUNT');
      });
    }
  }

  Future<DocumentSnapshot> getUserData(String email) async {
    DocumentSnapshot snapshot =
        await Firestore.instance.collection('users').document(email).get();
    return snapshot;
  }

  Future<FirebaseUser> _createAccount(
      Map<String, String> accountDetails) async {
    GoogleSignInAuthentication googleSignInAuth =
        await googleSignInAccount.authentication;

    FirebaseUser user = await FirebaseAuth.instance.signInWithGoogle(
        idToken: googleSignInAuth.idToken,
        accessToken: googleSignInAuth.accessToken);

    await Firestore.instance
        .collection('users')
        .document(user.email)
        .setData(accountDetails);
    setEntryUserData(accountDetails, user.email);

    return user;
  }
}

class ColorTween extends Tween<Color> {
  ColorTween({Color begin, Color end}) : super(begin: begin, end: end);

  /// Returns the value this variable has at the given animation clock value.
  @override
  Color lerp(double t) => Color.lerp(begin, end, t);
}
