import 'dart:async';

import 'package:bmsce/map/building_constants.dart';
import 'package:bmsce/map/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        .collection("college_map_suggestions")
        .add(widget.placeMapObj)
        .then((onValue) {
      setState(() {
        isSucceeded = true;
        isUploading = false;
        title = "Added ${widget.placeMapObj["name"]}";
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

  Future<List<DocumentSnapshot>> checkIfExists() async {
    return await Firestore.instance
        .collection("college_map")
        .where("name", isEqualTo: widget.placeMapObj["name"])
        .getDocuments()
        .then((docs) {
      if (docs.documents.isEmpty)
        return null;
      else
        return docs.documents;
    }).catchError((err) {
      return null;
    });
  }

  populateSimilarPlaces(List<DocumentSnapshot> documents) {
    setState(() {
      isSucceeded = false;
      errorText = "";
      isUploading = false;
      title = "Are you trying to add any of these?";
      similarPlaces = List.generate(documents.length, (index) {
        final locHR = LocationMarker.getBlockFloorFrmLocationId(
            documents[index]['location']);
        return ListTile(
          title: Text(documents[index]["searchName"]),
          subtitle: Text(
              '${BlockNameMap[locHR.item1]}, ${FloorNameMap[locHR.item2]}'),
          onTap: () {
            widget.placeMapObj['collegeMapDocRef'] =
                documents[index].documentID;
            widget.placeMapObj['suggestionType'] = "edit";
            addData();
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

  @override
  void initState() {
    title = "Adding ${widget.placeMapObj["searchName"]}";
    errorText = "";
    successText = "";
    super.initState();
    if (widget.placeMapObj["suggestionType"] == 'create')
      checkIfExists().then((docs) {
        if (docs == null)
          addData();
        else
          populateSimilarPlaces(docs);
      });
    else
      addData();
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
