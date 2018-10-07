import 'dart:typed_data';
import 'package:bmsce/course/course_dept_sem.dart';
import 'package:bmsce/map/building_constants.dart';
import 'package:bmsce/map/faculties_data.dart';
import 'package:bmsce/map/location.dart';
import 'package:bmsce/map/place_cat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:material_search/material_search.dart';
import 'package:tuple/tuple.dart';

class AddPlace extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddPlaceState();
  }
}

class AddPlaceState extends State<AddPlace> {
  Uint8List uint8list;
  String selectedLocationHR;
  PlaceCategory selectedCategory;
  String selectedDepartment;
  String selectedDesignation;
  String selectedLocationID;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailIdController = TextEditingController();
  TextEditingController roomNumberController = TextEditingController();
  TextEditingController labNameController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController detailsLinkController = TextEditingController();
  TextEditingController profilePicLinkController = TextEditingController();
  String blockName = "";
  final scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    uint8list = Uint8List(5);
  }

  @override
  Widget build(BuildContext context) {
    final placeCategories = PlaceCategory.values;
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        title: Text('Add missing place'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              String error = validate();
              if (error != null) {
                scaffoldState.currentState.showSnackBar(SnackBar(
                  content: Text(error),
                ));
                return;
              }
              publish();
            },
          )
        ],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push<Tuple3<Uint8List, String, Block>>(
                            MaterialPageRoute(builder: (context) {
                      return LocationMarker(
                        initLocationId: selectedLocationID,
                      );
                    })).then((onValue) async {
                      print(onValue);
                      if (onValue != null) {
                        List<String> list = onValue.item2.split("_D_");
                        blockName = BlockNameMap[onValue.item3];
                        setState(() {
                          uint8list = onValue.item1;
                          selectedLocationID = onValue.item2;
                          selectedLocationHR =
                              '${BlockNameMap[onValue.item3]}, ${FloorNameMap[list[1]]}';
                        });
                      }
                    });
                  },
                  child: SizedBox(
                    height: 150.0,
                    child: Stack(fit: StackFit.expand, children: [
                      Container(
                        foregroundDecoration: BoxDecoration(
                            color: Color.fromRGBO(105, 105, 105, 0.5)),
                        child: Image.memory(
                          uint8list,
                          width: 500.0,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      Center(
                          child: selectedLocationHR == null
                              ? Container(
                                  padding: EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white)),
                                  child: Text(
                                    "Mark Location on the Map",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : null),
                    ]),
                  ),
                ),
                Padding(
                    //TODO: seleted location in a ternary condn
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                        '${selectedLocationHR == null ? "" : selectedLocationHR}')),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Text(
                          'Category : ',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      DropdownButton(
                        hint: Text("Select Place Category"),
                        value: selectedCategory,
                        items: List.generate((placeCategories.length), (index) {
                          return DropdownMenuItem(
                            value: placeCategories[index],
                            child: Row(
                              children: <Widget>[
                                Text(PlaceCategoryMap[placeCategories[index]])
                              ],
                            ),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                    ]),
                Divider(),
                getPlaceForm(true),
              ])),
        ),
      ),
    );
  }

  Widget getPlaceForm(bool isPrimary) {
    List<Widget> children;
    if (selectedCategory == null) {
      return Container();
    }
    double padding = 8.0;
    switch (selectedCategory) {
      case PlaceCategory.FACULTY_CABIN:
        children = <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                  labelText: "Faculty Name",
                  suffix: IconButton(
                    icon: Icon(Icons.contacts),
                    onPressed: () {
                      Navigator.of(context)
                          .push(_buildMaterialSearchPage(context))
                          .then((onValue) {
                        if (onValue != null) {
                          setState(() {
                            nameController.text = onValue;
                            detailsLinkController.text =
                                INITIAL_FACULTY_DATA[onValue]["detailsLink"];
                            profilePicLinkController.text =
                                INITIAL_FACULTY_DATA[onValue]
                                    ["profilePictureLink"];
                          });
                        }
                      });
                    },
                  )),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: TextFormField(
              controller: emailIdController,
              decoration: InputDecoration(
                labelText: "Email ID (optional)",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: TextFormField(
                controller: detailsLinkController,
                decoration: InputDecoration(
                  labelText: "Profile Details Link (optional)",
                )),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: TextFormField(
              controller: profilePicLinkController,
              decoration: InputDecoration(
                labelText: "Profile Picture Link (optional)",
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: Row(mainAxisSize: MainAxisSize.max, children: [
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Text(
                  'Department : ',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              DropDownSelector(
                onItemChange: (value) {
                  selectedDepartment = value;
                },
                values: List.generate(Departments.length, (index) {
                  return Departments[index].item2;
                }),
                hint: "Select Department",
              )
            ]),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: Row(mainAxisSize: MainAxisSize.max, children: [
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Text(
                  'Designation : ',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              DropDownSelector(
                onItemChange: (value) {
                  selectedDesignation = value;
                },
                values: Designation,
                hint: "Select Designation",
              )
            ]),
          )
        ];
        break;
      case PlaceCategory.CLASS_ROOM:
        children = <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: TextFormField(
              controller: roomNumberController,
              decoration: InputDecoration(
                labelText: "Room Number/Name",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: Row(mainAxisSize: MainAxisSize.max, children: [
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Text(
                  'Department : ',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              DropDownSelector(
                onItemChange: (value) {
                  selectedDepartment = value;
                },
                values: List.generate(Departments.length, (index) {
                  return Departments[index].item2;
                }),
                hint: "Select Department",
              )
            ]),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: TextFormField(
              controller: capacityController,
              decoration: InputDecoration(
                labelText: "Capacity (optional)",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ];
        break;

      case PlaceCategory.LAB:
        children = <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: TextFormField(
              controller: labNameController,
              decoration: InputDecoration(
                labelText: "Lab Name",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: Row(mainAxisSize: MainAxisSize.max, children: [
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Text(
                  'Department : ',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              DropDownSelector(
                onItemChange: (value) {
                  selectedDepartment = value;
                },
                values: List.generate(Departments.length, (index) {
                  return Departments[index].item2;
                }),
                hint: "Select Department",
              )
            ]),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: TextFormField(
              controller: capacityController,
              decoration: InputDecoration(
                labelText: "Capacity (optional)",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ];
        break;
      case PlaceCategory.OTHER:
        children = [
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: Row(mainAxisSize: MainAxisSize.max, children: [
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Text(
                  'Department : ',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              DropDownSelector(
                onItemChange: (value) {
                  selectedDepartment = value;
                },
                values: List.generate(Departments.length, (index) {
                  return Departments[index].item2;
                }),
                hint: "Select Department",
              )
            ]),
          )
        ];

        break;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  String validate() {
    if (selectedLocationHR == null) {
      return "Please Mark the Location";
    }
    if (selectedCategory == null) {
      return "Please Select the Category";
    }
    switch (selectedCategory) {
      case PlaceCategory.CLASS_ROOM:
        if (roomNumberController.text.trim().isEmpty) {
          return "Please Enter the Room Number";
        }
        break;
      case PlaceCategory.FACULTY_CABIN:
        if (nameController.text.trim().isEmpty) {
          return "Please Enter the Faculty Name";
        }
        break;
      case PlaceCategory.LAB:
        if (labNameController.text.trim().isEmpty) {
          return "Please Enter the Lab Name";
        }
        if (selectedDepartment == null) {
          return "Please Enter the Department";
        }
        break;
      case PlaceCategory.OTHER:
        if (nameController.text.trim().isEmpty) {
          return "Please Enter the Name";
        }
    }
    return null;
  }

  publish() async {
    Map<String, dynamic> mapObj;
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    switch (selectedCategory) {
      case PlaceCategory.FACULTY_CABIN:
        final place = FacultyCabin(
            addedBy: user?.email,
            location: selectedLocationID,
            name: nameController.text.trim(),
            dept: selectedDepartment == "Other" ? null : selectedDepartment,
            designation:
                selectedDesignation == "Other" ? null : selectedDesignation,
            detailsLink: detailsLinkController.text.trim() == ""
                ? null
                : detailsLinkController.text.trim(),
            email: emailIdController.text.trim() == ""
                ? null
                : emailIdController.text.trim(),
            profilePictureLink: profilePicLinkController.text.trim() == ""
                ? null
                : profilePicLinkController.text.trim());
        mapObj = place.toMap();
        break;
      case PlaceCategory.CLASS_ROOM:
        final place = ClassRoom(
            addedBy: user?.email,
            blockName: blockName,
            location: selectedLocationID,
            dept: selectedDepartment == "Other" ? null : selectedDepartment,
            capacity: capacityController.text.trim() == ""
                ? null
                : int.parse(capacityController.text.trim()),
            name: roomNumberController.text.trim());
        mapObj = place.toMap();
        break;
      case PlaceCategory.LAB:
        final place = Lab(
            addedBy: user?.email,
            dept: selectedDepartment,
            name: labNameController.text.trim(),
            capacity: capacityController.text.trim() == ""
                ? null
                : int.parse(capacityController.text.trim()),
            location: selectedLocationID);
        mapObj = place.toMap();
        break;
      case PlaceCategory.OTHER:
        final place = Other(
            addedBy: user?.email,
            dept: selectedDepartment == "Other" ? null : selectedDepartment,
            location: selectedLocationID,
            name: nameController.text.trim());
        mapObj = place.toMap();
        break;
    }
    showDialog(
            context: context,
            builder: (context) {
              return PublishDialog(
                placeMapObj: mapObj,
              );
            },
            barrierDismissible: false)
        .then((onValue) {
      if (onValue == true) reset();
    }).catchError((onError) {});
  }

  reset() {
    setState(() {
      blockName = null;
      selectedDesignation = null;

      capacityController.clear();
      nameController.clear();

      detailsLinkController.clear();
      emailIdController.clear();
      labNameController.clear();
      roomNumberController.clear();
      profilePicLinkController.clear();
    });
  }

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
                return value.contains(
                    new RegExp(r"" + srch + "", caseSensitive: false));
              },
              onSelect: (dynamic value) => Navigator.of(context).pop(value),
              onSubmit: (String value) => Navigator.of(context).pop(value),
            ),
          );
        });
  }
}

class DropDownSelector extends StatefulWidget {
  final ValueChanged<String> onItemChange;
  final List values;
  final String hint;

  const DropDownSelector(
      {Key key,
      @required this.onItemChange,
      @required this.values,
      this.hint = ""})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DepartmentSelectorState();
  }
}

class DepartmentSelectorState extends State<DropDownSelector> {
  String selectedDept;
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      hint: Text(widget.hint),
      value: selectedDept,
      isDense: true,
      items: List.generate(widget.values.length, (index) {
        return DropdownMenuItem<String>(
          child: Text(
            widget.values[index],
            overflow: TextOverflow.ellipsis,
          ),
          value: widget.values[index],
        );
      }),
      onChanged: (value) {
        widget.onItemChange(value);
        setState(() {
          selectedDept = value;
        });
      },
    );
  }
}

class PublishDialog extends StatefulWidget {
  final Map<String, dynamic> placeMapObj;

  const PublishDialog({Key key, @required this.placeMapObj}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PublishDialogState();
  }
}

class PublishDialogState extends State<PublishDialog> {
  String title;
  String errorText;
  String successText;
  bool isUploading = true;
  bool isSucceeded = true;
  List<Widget> similarPlaces = [];

  addData() {
    Firestore.instance
        .collection("college_map")
        .add(widget.placeMapObj)
        .then((onValue) {
      setState(() {
        isSucceeded = true;
        isUploading = false;
        title = "Added ${widget.placeMapObj["searchName"]}";
        successText = "Successful";
      });
    }).catchError((onError) {
      setState(() {
        isSucceeded = false;
        isUploading = false;
        title = "${widget.placeMapObj["searchName"]}";
        errorText = 'Failed to Add.';
      });
    });
    setState(() {
      isUploading = true;
      similarPlaces.clear();
    });
  }

  @override
  void initState() {
    title = "Adding ${widget.placeMapObj["searchName"]}";
    errorText = "";
    successText = "";
    super.initState();
    Firestore.instance
        .collection("college_map")
        .where("name", isEqualTo: widget.placeMapObj["name"])
        .getDocuments()
        .then((placesSnap) {
      if (placesSnap.documents.isEmpty) {
        addData();
      } else {
        setState(() {
          isSucceeded = false;
          errorText = "";
          isUploading = false;
          title = "Were you trying to add any of these?";
          similarPlaces = List.generate(placesSnap.documents.length, (index) {
            final locHR = LocationMarker.getBlockFloorFrmLocationId(
                placesSnap.documents[index]['location']);
            return ListTile(
              title: Text(placesSnap.documents[index]["searchName"]),
              subtitle: Text(
                  '${BlockNameMap[locHR.item1]}, ${FloorNameMap[locHR.item2]}'),
              onTap: () {
                placesSnap.documents[index].reference
                    .setData(widget.placeMapObj)
                    .then((onValue) {
                  setState(() {
                    isSucceeded = true;
                    successText = "Successful!";
                    isUploading = false;
                    title = "Added ${widget.placeMapObj["searchName"]}";
                  });
                }).catchError((onError) {
                  setState(() {
                    isSucceeded = false;
                    isUploading = false;
                    errorText = 'Failed!';
                    title = "${widget.placeMapObj["searchName"]}";
                  });
                });
                setState(() {
                  isUploading = true;
                  similarPlaces.clear();
                });
              },
            );
          })
            ..add(ListTile(
              title: Text("No, It's different One"),
              onTap: () {
                addData();
              },
            ));
        });
      }
    }).catchError((onError) {
      setState(() {
        isSucceeded = false;
        isUploading = false;
        errorText = 'Failed to Add.';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(title),
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: isUploading
              ? CircularProgressIndicator()
              : isSucceeded ? Text(successText) : Text(errorText),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: isUploading
              ? null
              : FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context, isSucceeded);
                  },
                ),
        )
      ]..insertAll(1, similarPlaces),
    );
  }
}
