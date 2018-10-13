import 'package:bmsce/map/location.dart';
import 'package:bmsce/map/place.dart';
import 'package:bmsce/map/suggestion_approve.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SuggestionList extends StatelessWidget {
  final suggestionIconMap = {
    "create": Icons.add_location,
    "edit": Icons.edit_location,
    "close": Icons.location_off,
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suggestions'),
      ),
      body: new StreamBuilder(
        stream: Firestore.instance
            .collection('college_map_suggestions')
            .where('isApproved', isNull: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return new Text('Loading...');
          return new ListView(
            children: snapshot.data.documents.map((document) {
              return new ListTile(
                leading: Icon(suggestionIconMap[document['suggestionType']]),
                title: new Text(document['searchName']),
                subtitle: new Text(
                    LocationMarker.getLocationHrFrmId(document['location'])),
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return SuggestionApprove(
                      place: Place.fromMap(document.data),
                      suggestionDocId: document.documentID,
                    );
                  }));
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
