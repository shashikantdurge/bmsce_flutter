import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bmsce/course/course_dept_sem.dart';

class SignUp extends StatefulWidget {
  final GoogleSignInAccount googleSignInAccount;

  const SignUp({Key key, @required this.googleSignInAccount}) : super(key: key);
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  TextEditingController usnController = TextEditingController();
  String deptValue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        persistentFooterButtons: <Widget>[],
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Sign Up'),
        ),
        body: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.amber,
                backgroundImage:
                    NetworkImage(widget.googleSignInAccount.photoUrl),
                radius: 40.0,
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: Text(widget.googleSignInAccount.displayName),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: Text(widget.googleSignInAccount.email),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: TextFormField(
                  controller: usnController,
                  decoration: InputDecoration(
                    labelText: 'USN',
                    border: OutlineInputBorder(),
                  ),
                  validator: (usn) {
                    if (!usn.contains(
                            RegExp(r'1[bB][mM]\d{2}[a-zA-Z]{2}\d{3}')) &&
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
                      value: Departments[index].item2,
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      deptValue = value;
                    });
                  },
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: RaisedButton(
                  //height: 48.0,
                  textColor: Colors.white,
                  //color: ,
                  child: Text('CREATE ACCOUNT'),
                  onPressed: () {
                    final accountDetails = Map<String, String>();
                    accountDetails['email'] = widget.googleSignInAccount.email;
                    accountDetails['name'] =
                        widget.googleSignInAccount.displayName;
                    usnController.text.isNotEmpty
                        ? accountDetails['usn'] = usnController.text
                        : null;
                    accountDetails['dept'] = deptValue;

                    _createAccount(accountDetails);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _createAccount(Map<String, String> accountDetails) async {
    GoogleSignInAuthentication googleSignInAuth =
        await widget.googleSignInAccount.authentication;

    FirebaseUser user = await FirebaseAuth.instance.signInWithGoogle(
        idToken: googleSignInAuth.idToken,
        accessToken: googleSignInAuth.accessToken);

    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .setData(accountDetails);
  }
}
