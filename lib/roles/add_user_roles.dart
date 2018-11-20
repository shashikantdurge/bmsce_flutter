import 'package:bmsce/course/course_dept_sem.dart';
import 'package:bmsce/roles/upload_result.dart';
import 'package:bmsce/roles/uploader_dialog.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class AddUserRoles extends StatefulWidget {
  final String dept;
  final User user;

  const AddUserRoles({Key key, this.dept, @required this.user})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddUserRolesState();
  }
}

class AddUserRolesState extends State<AddUserRoles> {
  List<UniqueKey> usersKeys = [];
  Set<Tuple6> usersToBeAdded = Set<Tuple6>();
  ValueNotifier<bool> uploadNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    usersKeys.add(UniqueKey());
  }

  @override
  void dispose() {
    uploadNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Add User Roles'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              usersToBeAdded.clear();
              uploadNotifier.value = !uploadNotifier.value;
              final result = await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return UploaderDialog(
                      users: usersToBeAdded.toList(),
                    );
                  });
              if (result != null && result is List<List<Tuple6>>) {
                setState(() {
                  result[0].forEach((tuple) {
                    usersKeys.remove(tuple.item6);
                  });
                });
                showDialog(
                    context: context,
                    builder: (context) {
                      return UploadResult(
                        failedUsers: result[1],
                        successfulUsers: result[0],
                      );
                    });
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(usersKeys.length, (index) {
            return AddUserWidget(
              dept: widget.user.dept,
              key: usersKeys[index],
              isAdmin: widget.user.isAdmin,
              onClose: () {
                setState(() {
                  usersKeys.removeAt(index);
                });
              },
              subRoles: widget.user.subRoles,
              notifier: uploadNotifier,
              onNotify: (tuple) {
                if (usersKeys.contains(tuple.item6)) usersToBeAdded.add(tuple);
              },
            );
          })
            ..add(Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                iconSize: 42.0,
                onPressed: () {
                  setState(() {
                    usersKeys.add(UniqueKey());
                  });
                },
                icon: Icon(
                  Icons.add_circle_outline,
                ),
              ),
            )),
        ),
      ),
    );
  }
}

/// Tuple6 user
/// @item1 dept
/// @item2 email
/// @item3 name
/// @item4 role
/// @item5 validUser
/// @item6 Widget key
class AddUserWidget extends StatefulWidget {
  final VoidCallback onClose;
  final List<Role> subRoles;
  final bool isAdmin;
  final String dept;
  final ValueNotifier<bool> notifier;
  final ValueChanged<Tuple6> onNotify;

  const AddUserWidget(
      {Key key,
      @required this.onClose,
      @required this.subRoles,
      this.isAdmin = false,
      @required this.dept,
      @required this.notifier,
      @required this.onNotify})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddUserWidgetState();
  }
}

class AddUserWidgetState extends State<AddUserWidget>
    with SingleTickerProviderStateMixin {
  String role;
  AnimationController animationController;
  TextEditingController emailController;
  String name, dept;
  bool validUser;
  String errText, helperText;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 3),
    );
    emailController = TextEditingController();
    validUser = false;
    widget.notifier.addListener(() {
      widget.onNotify(Tuple6(dept, emailController.text.trim(), name, role,
          validUser, widget.key));
    });
  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('${widget.key.toString()}');
    return Card(
      shape: BeveledRectangleBorder(),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                DropdownButton(
                  hint: Text('Select Role'),
                  value: role,
                  items: List.generate(widget.subRoles.length, (index) {
                    return DropdownMenuItem(
                      child: Text(
                          RoleValueMap[widget.subRoles[index]].toUpperCase()),
                      value: RoleValueMap[widget.subRoles[index]],
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      role = value;
                    });
                  },
                ),
                Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      widget.onClose();
                    },
                  ),
                ),
              ],
            ),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'User Email address',
                    border: UnderlineInputBorder(),
                    filled: true,

//                    labelText: 'E-mail',
                    helperText: helperText,
                    suffixIcon: AnimatedCrossFade(
                      crossFadeState: validUser
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 500),
                      firstChild: Icon(Icons.check),
                      secondChild: Icon(
                        Icons.error,
                        color: Theme.of(context).errorColor,
                      ),
                    ),
                    errorText: errText,
//                    suffixText: '@bmsce.ac.in',
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.all(0.0),
                icon: RotationTransition(
                  child: Icon(Icons.refresh),
                  turns: animationController,
                ),
                onPressed: () {
                  if (emailController.text.trim() != '') getUserInfo();
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  getUserInfo() {
    setState(() {
      animationController.repeat();
    });
    Firestore.instance
        .collection('users')
        .document(emailController.text)
        .get()
        .catchError((err) {
      setState(() {
        dept = "UNKNOWN";
        name = "UNKNOWN";
        animationController.reset();
        validUser = false;
        helperText = null;
        errText = 'Something went wrong';
      });
    }).then((userDoc) {
      setState(() {
        animationController.reset();
        if (userDoc.exists) {
          dept = userDoc.data['dept'];
          name = userDoc.data['name'];
          validUser =
              widget.isAdmin ? true : widget.dept == userDoc.data["dept"];
          helperText =
              '${userDoc.data['name']}, ${deptNameFromPrefix(userDoc.data['dept']).item2} Dept';
          errText = null;
        } else {
          dept = "UNKNOWN";
          name = "UNKNOWN";
          validUser = false;
          helperText = null;
          errText = 'User Not Found';
        }
      });
    });
  }
}
