import 'dart:async';

import 'package:bmsce/map/college_map_widget.dart';
import 'package:bmsce/map/location.dart';
import 'package:bmsce/map/place.dart';
import 'package:bmsce/map/search_result.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SuggestionApprove extends StatelessWidget {
  final Place place;
  final String suggestionDocId;
  final GlobalKey<ScaffoldState> stateKey = GlobalKey<ScaffoldState>();

  SuggestionApprove(
      {Key key, @required this.place, @required this.suggestionDocId})
      : super(key: key);

  getTextField(String primary, String secondary, IconData icon, String hint) {
    if (primary == secondary || secondary == null) secondary = null;

    return TextFormField(
      enabled: false,
      initialValue: primary ?? " ",
      decoration: InputDecoration(
          border: UnderlineInputBorder(),
          icon: Icon(icon),
          labelText: hint,
          helperStyle: TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.black54,
          ),
          helperText: secondary),
    );
  }

  Future<Place> getOriginalPlaceDetails() async {
    if (place.suggestionType == 'create' || place.suggestionType == 'close')
      return Place();
    return await Firestore.instance
        .collection('college_map')
        .document(place.collegeMapDocRef)
        .get()
        .then((placeSnap) {
      if (placeSnap.exists)
        return Place.fromMap(placeSnap.data);
      else
        return Place();
    }).catchError((err) {
      return Place();
    });
  }

  Future<String> updateUggestionDoc(bool isApproved) async {
    return await Firestore.instance
        .collection('college_map_suggestions')
        .document(suggestionDocId)
        .updateData({
      "isApproved": isApproved,
      "approvedByName": User.instance.displayName,
      "approvedByEmail": User.instance.email,
      "approvedByDept": User.instance.dept,
    }).then((onValue) {
      return "Successful";
    }).catchError((err) {
      if (err.toString().contains('PERMISSION'))
        return "Permission denied";
      else
        return "Failed";
    });
  }

  handleApprove(bool isApproved, context) async {
    if (isApproved) {
      final proceed = await showDialog(
          context: context,
          builder: (context) {
            return ApproveDialogState(
              suggestionType: place.suggestionType,
              name: place.name,
            );
          });
      if (proceed != true) return;
    }
    final snack = stateKey.currentState.showSnackBar(SnackBar(
      content: Text('Processing your request...'),
    ));

    updateUggestionDoc(isApproved).then((onValue) {
      snack.close();
      stateKey.currentState.showSnackBar(SnackBar(
        content: Text(onValue),
      ));
      if (onValue == 'Successful') {
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.pop(context);
        });
      }
    });

    return;
  }

  differenceView(Place secondary) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          switch (index) {
            case 0:
              return getTextField(place.name, secondary.name,
                  Icons.nature_people, 'Place/Faculty name');

            case 1:
              return ListTile(
                leading: Icon(Icons.place),
                contentPadding: EdgeInsets.all(0.0),
                title: FlatButton.icon(
                  icon: Icon(Icons.map),
                  label:
                      Text(LocationMarker.getLocationHrFrmId(place.location)),
                  onPressed: () {
                    showLocationDialog(place.location, context);
                  },
                ),
                subtitle: place.location == secondary.location ||
                        secondary.location == null
                    ? null
                    : FlatButton.icon(
                        icon: Icon(Icons.map),
                        label: Text(
                          LocationMarker.getLocationHrFrmId(secondary.location),
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.black54,
                          ),
                        ),
                        onPressed: () {
                          showLocationDialog(secondary.location, context);
                        },
                      ),
              );
            case 2:
              return getTextField(
                  PlaceCategoryMap[place.placeCategory],
                  PlaceCategoryMap[secondary.placeCategory],
                  Icons.category,
                  'Category');
            case 3:
              return getTextField(place.designation, secondary.designation,
                  Icons.assignment_ind, 'Designation');
            case 4:
              return getTextField(
                  place.dept, secondary.dept, Icons.widgets, 'Department');
            case 5:
              return getTextField(place.phoneNumber, secondary.phoneNumber,
                  Icons.phone, 'Phone number');
            case 6:
              return getTextField(
                  place.email, secondary.email, Icons.email, 'E-mail');
            case 7:
              return getTextField(
                  place.website, secondary.website, Icons.public, 'Website');
            case 8:
              return ListTile(
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
              );

            default:
              return Text('Out of Index');
          }
        },
        itemCount: 9,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
            height: 25.0,
          );
        },
      ),
    );
  }

  showLocationDialog(String location, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          final ValueNotifier<List<String>> notifier = ValueNotifier([]);
          WidgetsBinding.instance.addPostFrameCallback((callback) {
            notifier.value = [location];
          });
          return AlertDialog(
            title: Text(LocationMarker.getLocationHrFrmId(location)),
            content: SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.height * 0.8,
              child: CollegeMapWidget(notifier: notifier),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: stateKey,
        appBar: AppBar(
          backgroundColor: place.suggestionType == 'close'
              ? Colors.red
              : place.suggestionType == "create"
                  ? Colors.lightGreen
                  : Colors.yellow,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${place.searchName}',
                overflow: TextOverflow.fade,
              ),
              Text(
                '${place.suggestionType.toUpperCase()}',
                overflow: TextOverflow.fade,
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        persistentFooterButtons: <Widget>[
          FlatButton(
            padding: EdgeInsets.only(left: 22.0, right: 22.0),
            textTheme: ButtonTextTheme.normal,
            child:
                Text(place.suggestionType == "close" ? "Let it be" : "Decline"),
            onPressed: () {
              handleApprove(false, context);
            },
          ),
          FlatButton(
            padding: EdgeInsets.only(left: 22.0, right: 22.0),
            color: place.suggestionType == "close"
                ? Colors.red
                : Colors.lightGreen,
            textColor: Colors.white,
            child: Text(place.suggestionType == "close"
                ? "Close the place"
                : "Approve"),
            onPressed: () {
              handleApprove(true, context);
            },
          ),
        ],
        body: FutureBuilder(
          future: getOriginalPlaceDetails(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return Text('Loading...');
              case ConnectionState.done:
                return differenceView(snapshot.data);
            }
          },
        ));
  }
}

class ApproveDialogState extends StatelessWidget {
  final String suggestionType, name;

  const ApproveDialogState({Key key, this.suggestionType, this.name})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    String title, yes, no = "Cancel";
    if (suggestionType == "edit") {
      title = "Approve edits to \"$name\"?";
      yes = "APPROVE";
    }
    if (suggestionType == "create") {
      title = "Approve creation of \"$name\"?";
      yes = "APPROVE";
    }
    if (suggestionType == "close") {
      title = "Close \"$name\"?";
      yes = "CLOSE";
    }
    return AlertDialog(
      title: Text(title),
      actions: <Widget>[
        FlatButton(
          child: Text(no),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        FlatButton(
          color: Theme.of(context).primaryColorLight,
          child: Text(yes),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
