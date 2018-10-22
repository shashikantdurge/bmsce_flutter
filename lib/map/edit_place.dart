// TODO: Add faculty and Suggest an Edit have conflicts. After adding all the faculties data. Remove the textEditingController. and
//Set the initial value to place.{respective values}
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//TODO: Improper dialog  title for adding and editing
import 'dart:async';

import 'package:bmsce/course/course_dept_sem.dart';
import 'package:bmsce/map/faculties_data.dart';
import 'package:bmsce/map/location.dart';
import 'package:bmsce/map/place.dart';
import 'package:bmsce/map/publish_dialog.dart';
import 'package:bmsce/map/search_result.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_search/material_search.dart';

class EditPlace extends StatefulWidget {
  final String suggestionType;
  final Place place;
  const EditPlace({Key key, @required this.suggestionType, this.place})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    String title;
    if (suggestionType == 'edit')
      title = 'Suggest an edit';
    else
      title = 'Add a missing place';
    return EditPlaceState(title, place ?? Place());
  }
}

class EditPlaceState extends State<EditPlace> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String title;

  Place place;

  EditPlaceState(this.title, this.place);

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  bool _autovalidate = false;
  bool _formWasEdited = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController websiteController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
    } else if (place.placeCategory == null) {
      showInSnackBar('Please select category.');
    } else if (place.location == null) {
      showInSnackBar('Please mark location on the map.');
    } else {
      form.save();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return PublishDialog(
              placeMapObj: place.toMap(User.instance, widget.suggestionType),
            );
          });
    }
  }

  String _validateName(String value) {
    _formWasEdited = true;
    if (value.isEmpty) return 'Name is required.';
    final RegExp nameExp = RegExp(r'^[A-Za-z0-9. ]+$');
    if (!nameExp.hasMatch(value))
      return 'Please enter only alphabetical characters.';
    return null;
  }

  String _validatePhoneNumber(String value) {
    _formWasEdited = true;
    final RegExp phoneExp = RegExp(r'^(?=[0-9]*$)(?:.{0}|.{10})$');
    if (!phoneExp.hasMatch(value)) return 'Enter a valid phone number.';
    return null;
  }

  Future getFacultyDetails() async {
    final name =
        await Navigator.of(context).push(_buildMaterialSearchPage(context));
    if (name != null) {
      setState(() {
        nameController.text = name;
        websiteController.text = INITIAL_FACULTY_DATA[name]["detailsLink"];
        place.photoUrl = INITIAL_FACULTY_DATA[name]["profilePictureLink"];
      });
    }
  }

  Future getLocation() async {
    final location = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (context) {
      return LocationMarker(
        initLocationId: place.location,
      );
    }));
    if (location is String) {
      setState(() {
        place.location = location;
      });
    }
  }

  Future<bool> _warnUserAboutInvalidData() async {
    final FormState form = _formKey.currentState;
    if (form == null || !_formWasEdited || form.validate()) return true;

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('This form has errors'),
              content: const Text('Really leave this form?'),
              actions: <Widget>[
                FlatButton(
                  child: const Text('YES'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                FlatButton(
                  child: const Text('NO'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _handleSubmitted();
            },
          )
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: _formKey,
          autovalidate: _autovalidate,
          onWillPop: _warnUserAboutInvalidData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 24.0),
                TextFormField(
                  initialValue: place.name,
                  //controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      icon: Icon(Icons.nature_people),
                      hintText: 'Place/Faculty Name *',
                      labelText: 'Name *',
                      suffix: IconButton(
                        padding: EdgeInsets.all(0.0),
                        icon: Icon(Icons.contacts),
                        onPressed: () {
                          getFacultyDetails();
                        },
                      )),
                  onSaved: (String value) {
                    place.name = value;
                  },
                  validator: _validateName,
                ),
                const SizedBox(height: 24.0),
                ListTile(
                  leading: Icon(Icons.location_on),
                  contentPadding: EdgeInsets.all(0.0),
                  title: Text(
                      LocationMarker.getLocationHrFrmId(place.location) ??
                          'Address *'),
                  subtitle: Stack(
                    children: <Widget>[
                      Container(
                        height: 120.0,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(105, 105, 105, 0.5)),
                        child: Center(
                            child: FlatButton(
                          textColor: Colors.white,
                          shape: BeveledRectangleBorder(
                              side: BorderSide(color: Colors.white)),
                          child: Text(
                            'Mark location on the map',
                            textDirection: TextDirection.ltr,
                          ),
                          onPressed: () {
                            getLocation();
                          },
                        )),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                ListTile(
                  leading: Icon(Icons.category),
                  contentPadding: EdgeInsets.all(0.0),
                  title: Text('Category *',
                      style: Theme.of(context).textTheme.caption),
                  subtitle: DropdownButton(
                    hint: Text("Select Place Category"),
                    value: place.placeCategory,
                    items:
                        List.generate((PlaceCategory.values.length), (index) {
                      return DropdownMenuItem(
                        value: PlaceCategory.values[index],
                        child:
                            Text(PlaceCategoryMap[PlaceCategory.values[index]]),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        place.placeCategory = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24.0),
                ListTile(
                  leading: Icon(Icons.assignment_ind),
                  contentPadding: EdgeInsets.all(0.0),
                  title: Text('Designation',
                      style: Theme.of(context).textTheme.caption),
                  subtitle: DropdownButton(
                    hint: Text("Select Designation"),
                    value: place.designation,
                    items: List.generate((designations.length), (index) {
                      return DropdownMenuItem(
                        value: designations[index],
                        child: Text(designations[index]),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        place.designation = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24.0),
                ListTile(
                  leading: Icon(Icons.widgets),
                  contentPadding: EdgeInsets.all(0.0),
                  title: Text('Department',
                      style: Theme.of(context).textTheme.caption),
                  subtitle: DropdownButton(
                    hint: Text("Select Department"),
                    value: place.dept,
                    items: List.generate((Departments.length), (index) {
                      return DropdownMenuItem(
                        value: Departments[index].item1,
                        child: Text(Departments[index].item2),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        place.dept = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  initialValue: place.phoneNumber,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    filled: true,
                    icon: Icon(Icons.phone),
                    hintText: 'Primary phone number',
                    labelText: 'Phone Number',
                    prefixText: '+91',
                  ),
                  keyboardType: TextInputType.phone,
                  onSaved: (String value) {
                    place.phoneNumber = value;
                  },
                  validator: _validatePhoneNumber,
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  initialValue: place.email,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    filled: true,
                    icon: Icon(Icons.email),
                    hintText: 'Email ID',
                    labelText: 'E-mail',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (String value) {
                    place.email = value;
                  },
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  initialValue: place.website,
                  // controller: websiteController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    filled: true,
                    icon: Icon(Icons.public),
                    hintText: 'Official website',
                    labelText: 'Website',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (String value) {
                    place.website = value;
                  },
                ),
                const SizedBox(height: 24.0),
                ListTile(
                  leading: Icon(Icons.photo),
                  contentPadding: EdgeInsets.all(0.0),
                  title:
                      Text('Photo', style: Theme.of(context).textTheme.caption),
                  subtitle: Align(
                    alignment: Alignment.centerLeft,
                    child: ImageLoader(
                      gsPath: place.photoUrl,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                    '* indicates required field\nAdding photo is not supported',
                    style: Theme.of(context).textTheme.caption),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//#TODO: Remove for production
_buildMaterialSearchPage(BuildContext context) {
  return new MaterialPageRoute<String>(
      settings: new RouteSettings(
        name: 'material_search',
        isInitialRoute: false,
      ),
      builder: (BuildContext context) {
        return new Material(
          child: new MaterialSearch<String>(
            placeholder: 'Search Teacher, Clasroom, Office ...',
            results: INITIAL_FACULTY_DATA.keys
                .map((String v) => new MaterialSearchResult<String>(
                      icon: Icons.person,
                      value: v,
                      text: v,
                    ))
                .toList(),
            filter: (dynamic value, String criteria) {
              String srch = criteria.split(" ").join("\.*");
              return value
                  .contains(new RegExp(r"" + srch + "", caseSensitive: false));
            },
            onSelect: (dynamic value) => Navigator.of(context).pop(value),
            onSubmit: (String value) => Navigator.of(context).pop(value),
          ),
        );
      });
}
