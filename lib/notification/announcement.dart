import 'package:bmsce/course/course_dept_sem.dart';
import 'package:bmsce/notification/announcement_preview.dart';
import 'package:bmsce/notification/notification.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Announcement extends StatefulWidget {
  AnnouncementState createState() => AnnouncementState();
}

class AnnouncementState extends State<Announcement> {
  NotiBuilder notiBuilder = NotiBuilder();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode titleFocus = FocusNode();
  final FocusNode bodyFocus = FocusNode();
  final FocusNode linkFocus = FocusNode();

  String _validateName(String str) {
    if (str.trim().length < 3)
      return "Minimum 3 characters";
    else
      return null;
  }

  _showInSnack(String str) {
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(str)));
  }

  _handleFormSubmit() async {
    formKey.currentState.save();
    if (!formKey.currentState.validate()) return false;
    if (notiBuilder.deptType == null ||
        (notiBuilder.deptType == "department" &&
            notiBuilder.deptValue == null)) {
      _showInSnack('Select department');
      return false;
    }
    if (notiBuilder.userType == null) {
      _showInSnack('Select user type');
      return false;
    }
    if (notiBuilder.userType == "student" &&
        (notiBuilder.semesterType == null ||
            (notiBuilder.semesterType == "semester" &&
                notiBuilder.semesterValue == null))) {
      _showInSnack('Select semester');
      return false;
    }
    if (notiBuilder.userType == "student" &&
        notiBuilder.deptType == "department" &&
        notiBuilder.semesterType == "semester" &&
        (notiBuilder.sectionType == null ||
            (notiBuilder.sectionType == "section" &&
                notiBuilder.sectionValue == null))) {
      _showInSnack('Select section');
      return false;
    }
    if (notiBuilder.link.isNotEmpty && !await canLaunch(notiBuilder.link)) {
      _showInSnack('Invalid link');
      return false;
    }
    return true;
  }

  _unFocus() {
    titleFocus.unfocus();
    bodyFocus.unfocus();
    linkFocus.unfocus();
  }

  @override
  void initState() {
    super.initState();
    notiBuilder.notificationType = NotificationType.DEFAULT;
    notiBuilder.deptValue = User.instance.dept;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle =
        TextStyle(fontSize: 16.0, wordSpacing: 2.0, letterSpacing: 1.4);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Announcement'),
        actions: <Widget>[
          FlatButton(
            child: Text('Preview'),
            onPressed: () async {
              final valid = await _handleFormSubmit();
              if (valid)
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return AnnouncementPreview(
                    notiBuilder: notiBuilder,
                  );
                }));
            },
          )
        ],
      ),
      body: Scrollbar(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(children: [
                const SizedBox(height: 24.0),
                TextFormField(
                  autofocus: true,
                  focusNode: titleFocus,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    filled: true,
                    icon: Icon(Icons.title),
                    hintText: 'Notification title',
                    labelText: 'Title *',
                  ),
                  maxLength: 40,
                  onSaved: (value) {
                    notiBuilder.title = value.trim();
                  },
                  validator: _validateName,
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  autofocus: false,
                  focusNode: bodyFocus,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.short_text),
                    hintText: 'Notification body',
                    labelText: 'Message',
                  ),
                  maxLines: 7,
                  maxLength: 1500,
                  onSaved: (value) {
                    notiBuilder.body = value.trim();
                  },
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  focusNode: linkFocus,
                  textCapitalization: TextCapitalization.words,
                  autofocus: false,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    filled: true,
                    icon: Icon(Icons.link),
                    hintText: 'External form/website link',
                    labelText: 'Link',
                  ),
                  onSaved: (value) {
                    notiBuilder.link = value.trim();
                  },
                  maxLength: 300,
                ),
                const SizedBox(height: 24.0),
                Card(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.maxFinite,
                        padding: EdgeInsets.all(8.0),
                        color: Colors.grey[200],
                        child: Text(
                          'Department',
                          style: textStyle,
                        ),
                      ),
                      RadioListTile(
                        groupValue: notiBuilder.deptType,
                        onChanged: (String value) {
                          setState(() {
                            notiBuilder.deptType = value;
                          });
                        },
                        title: Text('Only department'),
                        value: 'department',
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.0, left: 72.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: DropdownButton(
                            hint: Text('Select Department'),
                            value: notiBuilder.deptValue,
                            items: List.generate(Departments.length, (index) {
                              return DropdownMenuItem(
                                child: Text(Departments[index].item2),
                                value: Departments[index].item1,
                              );
                            }),
                            onChanged: (value) {
                              _unFocus();
                              setState(() {
                                notiBuilder.deptType = "department";
                                notiBuilder.deptValue = value;
                              });
                            },
                          ),
                        ),
                      ),
                      RadioListTile(
                        groupValue: notiBuilder.deptType,
                        onChanged: (String value) {
                          setState(() {
                            notiBuilder.deptType = value;
                          });
                        },
                        title: Text('All departments'),
                        value: 'none',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                Card(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.maxFinite,
                        padding: EdgeInsets.all(8.0),
                        color: Colors.grey[200],
                        child: Text(
                          'User type',
                          style: textStyle,
                        ),
                      ),
                      RadioListTile(
                        groupValue: notiBuilder.userType,
                        onChanged: (String value) {
                          setState(() {
                            notiBuilder.userType = value;
                          });
                        },
                        title: Text('Only students'),
                        value: 'student',
                      ),
                      RadioListTile(
                        groupValue: notiBuilder.userType,
                        onChanged: (String value) {
                          setState(() {
                            notiBuilder.userType = value;
                          });
                        },
                        title: Text('Only faculties'),
                        value: 'faculty',
                      ),
                      RadioListTile(
                        groupValue: notiBuilder.userType,
                        onChanged: (String value) {
                          setState(() {
                            notiBuilder.userType = value;
                          });
                        },
                        title: Text('Everyone'),
                        value: 'none',
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: (notiBuilder.userType == "student") ? 1.0 : 0.0,
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.maxFinite,
                          padding: EdgeInsets.all(8.0),
                          color: Colors.grey[200],
                          child: Text(
                            'Semester',
                            style: textStyle,
                          ),
                        ),
                        RadioListTile(
                          groupValue: notiBuilder.semesterType,
                          onChanged: (String value) {
                            setState(() {
                              notiBuilder.semesterType = value;
                            });
                          },
                          title: Text('Only semester'),
                          value: 'semester',
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.0, left: 72.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: DropdownButton(
                              hint: Text('Select Semester'),
                              value: notiBuilder.semesterValue,
                              items: List.generate(Semesters.length, (index) {
                                return DropdownMenuItem(
                                  child: Text(Semesters[index]),
                                  value: Semesters[index],
                                );
                              }),
                              onChanged: (value) {
                                _unFocus();

                                setState(() {
                                  notiBuilder.semesterType = "semester";
                                  notiBuilder.semesterValue = value;
                                });
                              },
                            ),
                          ),
                        ),
                        RadioListTile(
                          groupValue: notiBuilder.semesterType,
                          onChanged: (String value) {
                            setState(() {
                              notiBuilder.semesterType = value;
                            });
                          },
                          title: Text('All semesters'),
                          value: 'none',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                AnimatedOpacity(
                  opacity: (notiBuilder.userType == "student" &&
                          notiBuilder.semesterType == "semester" &&
                          notiBuilder.deptType == "department")
                      ? 1.0
                      : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.maxFinite,
                          padding: EdgeInsets.all(8.0),
                          color: Colors.grey[200],
                          child: Text(
                            'Section',
                            style: textStyle,
                          ),
                        ),
                        RadioListTile(
                          groupValue: notiBuilder.sectionType,
                          onChanged: (String value) {
                            setState(() {
                              notiBuilder.sectionType = value;
                            });
                          },
                          title: Text('Only section'),
                          value: 'section',
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.0, left: 72.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: DropdownButton(
                              hint: Text('Select section'),
                              value: notiBuilder.sectionValue,
                              items: List.generate(Sections.length, (index) {
                                return DropdownMenuItem(
                                  child: Text(Sections[index]),
                                  value: Sections[index],
                                );
                              }),
                              onChanged: (value) {
                                _unFocus();

                                setState(() {
                                  notiBuilder.sectionType = "section";
                                  notiBuilder.sectionValue = value;
                                });
                              },
                            ),
                          ),
                        ),
                        RadioListTile(
                          groupValue: notiBuilder.sectionType,
                          onChanged: (String value) {
                            setState(() {
                              notiBuilder.sectionType = value;
                            });
                          },
                          title: Text('All sections'),
                          value: 'none',
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
