import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class City{
  //City();
  String name; String state; String country; bool capital; int population;

// Initialize all fields of a city
  City(
    this.name ,
    this.state,
    this.country,
    this.capital,
    this.population,
  );

  static Map<String,dynamic> toMap(
      name ,
      state,
      country,
      capital,
      population){
    return <String,dynamic>{
      'name':name,
      'state':state,
      'country':country,
      'capital':capital,
      'population':population,
    };
  }
}


Future<void> main() async {
  DateTime.now();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'test',
    options: const FirebaseOptions(
      googleAppID: '1:131447312475:android:c4c1a65536326ae6',
      gcmSenderID: '131447312475',
      apiKey: 'AIzaSyCmjqBV_OzUO8wQ01mSC8BSYLcP8v4jV4s',
      projectID: 'bmsce-flutter',
    ),
  );

  final Firestore firestore = new Firestore(app: app);

  runApp(new MaterialApp(

      title: 'Firestore Example', home: new MyFirestorePage(firestore: firestore)));
}


class MyFirestorePage extends StatefulWidget{
  Firestore firestore;
  MyFirestorePage({this.firestore});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyFirestorePageState();
  }

}

class MyFirestorePageState extends State<MyFirestorePage>{

  _addData(){
    WriteBatch writeBatch = widget.firestore.batch();
    writeBatch.setData(widget.firestore.collection('cities').document("SF"), City.toMap("San Francisco", "CA", "USA", false, 860000));
    writeBatch.setData(widget.firestore.collection('cities').document("SF"), City.toMap("San Francisco", "CA", "USA", false, 860000));
    writeBatch.setData(widget.firestore.collection('cities').document("LA"), City.toMap("Los Angeles", "CA", "USA", false, 3900000));
    writeBatch.setData(widget.firestore.collection('cities').document("DC"), City.toMap("Washington D.C.", null, "USA", true, 68000));
    writeBatch.setData(widget.firestore.collection('cities').document("TO"), City.toMap("Tokyo", null, "Japan", true, 9000000));
    writeBatch.setData(widget.firestore.collection('cities').document("BJ"), City.toMap("Beijing", null, "China", true, 21500000));
    writeBatch.commit();
  }

  _getDocument() {
    //Query query = widget.firestore.collection('cities').where('capital',isEqualTo: true);
    print(DateTime.now());
    //query.getDocuments().then((value){print(value.documents.first.data?.toString() ?? 'Data Doesn\'t Exist');});
    widget.firestore.collection('courses').where("registeredDepts.IS",isGreaterThanOrEqualTo:  "5").getDocuments().then((value){
      print(value.documents.first.data.toString());
    });
    print(DateTime.now());
    //print(documentSnapshot.data?.toString() ?? 'Data Doesn\'t Exist');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('Firestore Demo'),),
      body: Column(
        children: <Widget>[
          RaisedButton(onPressed: (){_addData();},child: Text('Add Data'),),
          RaisedButton(onPressed: (){_getDocument();},child: Text('Get Data'),),
          RaisedButton(onPressed: (){}),

        ],
      ),
    );
  }

}
