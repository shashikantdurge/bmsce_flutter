import 'package:bmsce/course/course_dept_sem.dart';
import 'package:bmsce/main.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn extends StatefulWidget {
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  bool isSigningIn = false;
  final GoogleSignIn _googleSignIn = new GoogleSignIn(
    //hostedDomain: "bmsce.ac.in",
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future _handleSignIn() async {
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      final userDoc = await _isUserExists(googleSignInAccount.email);
      GoogleSignInAuthentication googleAuthentication =
          await googleSignInAccount.authentication;
      FirebaseUser fireUser = await FirebaseAuth.instance.signInWithGoogle(
          idToken: googleAuthentication.idToken,
          accessToken: googleAuthentication.accessToken);
      if (userDoc.exists) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
          return Splash(
            from: 'sign_in',
            userDetails: userDoc.data,
          );
        }));
      } else {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
          return ProfileEdit(
            user: DefaultUser(
                fireUser.displayName, fireUser.photoUrl, fireUser.email, null),
          );
        }));
      }
      //#TODO:if(!googleSignInAccount.email.endsWith("@bmsce.ac.in"))return;
      //_googleSignIn.signOut();

    } catch (err) {}
  }

  Future<DocumentSnapshot> _isUserExists(String email) async {
    DocumentSnapshot snapshot =
        await Firestore.instance.collection('users').document(email).get();
    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Theme.of(context).primaryColorDark.withAlpha(0),
              Theme.of(context).primaryColorDark.withAlpha(50),
              Theme.of(context).primaryColorDark.withAlpha(100),
              Theme.of(context).primaryColorDark.withAlpha(150),
              Theme.of(context).primaryColorDark.withAlpha(200),
              Theme.of(context).primaryColorDark.withAlpha(250),
              Theme.of(context).primaryColorDark.withAlpha(255),
            ],
          ),
        ),
        padding: EdgeInsets.all(40.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: 'bmsce_logo',
                  child: Image.asset('assets/images/bmsce_logo.png',
                      height: 56.0, width: 56.0),
                ),
                Text(
                  'BMSCE',
                  style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 50.0,
                      fontStyle: FontStyle.normal),
                )
              ],
            ),
            const SizedBox(height: 56.0),
            ButtonTheme(
              minWidth: double.maxFinite,
              child: FlatButton(
                shape: BeveledRectangleBorder(
                    side: BorderSide(color: Colors.white70),
                    borderRadius: BorderRadius.all(Radius.circular(3.0))),
                color: Theme.of(context).primaryColorDark.withAlpha(20),
                textColor: Colors.white70,
                child: isSigningIn
                    ? SizedBox(
                        height: 24.0,
                        width: 24.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.6,
                        ),
                      )
                    : Text(
                        'Continue with Google',
                        style: TextStyle(fontFamily: 'Ubuntu', fontSize: 16.0),
                      ),
                onPressed: () {
                  setState(() {
                    isSigningIn = true;
                  });
                  _handleSignIn().whenComplete(() {
                    setState(() {
                      isSigningIn = false;
                    });
                  });
                },
              ),
            ),
            Align(
              child: Text(
                'Note: sign in with \'@bmsce.ac.in\'',
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(fontStyle: FontStyle.italic),
              ),
              alignment: Alignment.bottomLeft,
            )
          ],
        ),
      ),
    );
  }
}

class ProfileEdit extends StatefulWidget {
  final User user;

  const ProfileEdit({Key key, @required this.user}) : super(key: key);
  ProfileEditState createState() => ProfileEditState();
}

class ProfileEditState extends State<ProfileEdit> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _validateUsn(String usn) {
    if (!usn.contains(RegExp(r'^1[bB][mM]\d{2}[a-zA-Z]{2}\d{3}$')) &&
        usn.isNotEmpty)
      return 'Invalid USN';
    else
      return null;
  }

  _handleSubmit() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      final res = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return UpdateDialog(
              userMap: widget.user.toMap(),
              email: widget.user.email,
            );
          });
      if (res == true) {
        //TODO: remove until splash screen
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
          return Splash(
            from: 'sign_in',
            userDetails: widget.user.toMap(),
          );
        }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update profile'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              _handleSubmit();
            },
            tooltip: 'Update',
          )
        ],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 24.0),
              ListTile(
                leading: Icon(Icons.person),
                contentPadding: EdgeInsets.all(0.0),
                title: Text('Name', style: Theme.of(context).textTheme.caption),
                subtitle: Text(widget.user.displayName),
              ),
              const SizedBox(height: 24.0),
              ListTile(
                leading: Icon(Icons.person),
                contentPadding: EdgeInsets.all(0.0),
                title:
                    Text('Email', style: Theme.of(context).textTheme.caption),
                subtitle: Text(widget.user.email),
              ),
              const SizedBox(height: 24.0),
              ListTile(
                leading: Icon(Icons.widgets),
                contentPadding: EdgeInsets.all(0.0),
                title: Text('Department *',
                    style: Theme.of(context).textTheme.caption),
                subtitle: DropdownButton(
                  hint: Text("Select Department"),
                  value: widget.user.dept,
                  items: List.generate((Departments.length), (index) {
                    return DropdownMenuItem(
                      value: Departments[index].item1,
                      child: Text(Departments[index].item2),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      widget.user.dept = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24.0),
              Form(
                key: formKey,
                child: TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  initialValue: widget.user.usn,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    filled: true,
                    icon: Icon(Icons.assignment_ind),
                    hintText: 'Enter your USN',
                    labelText: 'USN',
                  ),
                  maxLength: 10,
                  onSaved: (value) {
                    widget.user.usn = value.trim();
                  },
                  validator: _validateUsn,
                ),
              ),
              const SizedBox(height: 24.0),
              ListTile(
                leading: Icon(Icons.bubble_chart),
                contentPadding: EdgeInsets.all(0.0),
                title: Text('Semester',
                    style: Theme.of(context).textTheme.caption),
                subtitle: DropdownButton(
                  hint: Text("Select Semester"),
                  value: widget.user.semester, //
                  items: List.generate((Semesters.length), (index) {
                    return DropdownMenuItem(
                      value: Semesters[index],
                      child: Text(Semesters[index]),
                    );
                  })
                    ..add(DropdownMenuItem(
                      value: null,
                      child: Text("NA"),
                    )),
                  onChanged: (value) {
                    setState(() {
                      widget.user.semester = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24.0),
              ListTile(
                leading: Icon(null),
                contentPadding: EdgeInsets.all(0.0),
                title:
                    Text('Section', style: Theme.of(context).textTheme.caption),
                subtitle: DropdownButton(
                  hint: Text("Select Section"),
                  value: widget.user.section, //
                  items: List.generate((Sections.length), (index) {
                    return DropdownMenuItem(
                      value: Sections[index],
                      child: Text(Sections[index]),
                    );
                  })
                    ..add(DropdownMenuItem(
                      value: null,
                      child: Text("NA"),
                    )),
                  onChanged: (value) {
                    setState(() {
                      widget.user.section = value;
                    });
                  },
                ),
              ),
              Align(
                child: Text(
                  'NA-Not Applicable',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                alignment: Alignment(-1.0, -1.0),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateDialog extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String email;

  const UpdateDialog({Key key, @required this.userMap, @required this.email})
      : super(key: key);
  UpdateDialogState createState() => UpdateDialogState();
}

class UpdateDialogState extends State<UpdateDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: FutureBuilder<bool>(
        future: _update(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
            case ConnectionState.active:
              return Row(
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text('Updating your profile')
                ],
              );
            case ConnectionState.done:
              if (snapshot.hasData && snapshot.data) {
                WidgetsBinding.instance.addPostFrameCallback((duration) async {
                  Future.delayed(Duration(milliseconds: 800), () {
                    Navigator.of(context).pop(true);
                  });
                });
                return Row(
                  children: <Widget>[
                    Icon(Icons.check),
                    Text('Update successful')
                  ],
                );
              } else {
                return Row(
                  children: <Widget>[
                    Icon(Icons.warning),
                    Expanded(child: Text('Update failed. Please try again.'))
                  ],
                );
              }
          }
        },
      ),
    );
  }

  Future<bool> _update() async {
    return await Firestore.instance
        .collection('users')
        .document(widget.email)
        .setData(widget.userMap)
        .then((onValue) {
      return true;
    }).catchError((onError) {
      return false;
    });
  }
}
