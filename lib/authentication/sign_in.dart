import 'dart:async';
import 'package:bmsce/authentication/sign_up.dart';
import 'package:bmsce/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignIn extends StatefulWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  GoogleSignIn _googleSignIn = new GoogleSignIn(
   //hostedDomain: "bmsce.ac.in",
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(18.0),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: <Widget>[
              Image.asset('assets/images/bmsce_logo.png',height: 80.0,width: 80.0,),
              //Text('BMSCE',style: TextStyle(fontSize: 20.0),),
              IndexedStack(
                children: <Widget>[
                  
                ],
              ),
              Padding(
                padding: EdgeInsets.all( 12.0),
                child: MaterialButton(
                  height: 48.0,
                  textColor: Colors.white,
                  child: Text('SIGN IN WITH BMSCE ACCOUNT'),
                  onPressed: () {
                    _handleGoogleSignIn();
                  },
                  minWidth: double.infinity,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> _handleGoogleSignIn() async {
    try {
      GoogleSignInAccount googleAccount = await _googleSignIn.signIn();
      //#TODO:if(!googleAccount.email.endsWith("@bmsce.ac.in"))return;
      //_googleSignIn.signOut();

      //check if user is signing for the first time
      final firstTimeUser =await isFirstTimeSignIn(googleAccount.email);
      if (firstTimeUser) {
        Navigator
            .of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
          return SignUp(googleSignInAccount: googleAccount);
        }));
      } else {
        GoogleSignInAuthentication googleAuthentication =
            await googleAccount.authentication;
        final user = await widget.auth.signInWithGoogle(
            idToken: googleAuthentication.idToken,
            accessToken: googleAuthentication.accessToken);
        Navigator
            .of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
          return HomePage(user);
        }));
      }
    } catch (error) {
      print(error);
    }
  }

  Future<bool> isFirstTimeSignIn(String email) async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .getDocuments();
    if (snapshot.documents.length == 0)
      return true;
    else
      return false;
  }
}
