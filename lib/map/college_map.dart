import 'dart:async';

import 'package:bmsce/map/add_missing_place.dart';
import 'package:bmsce/map/block_widget.dart';
import 'package:bmsce/map/building_constants.dart';
import 'package:bmsce/map/college_map_widget.dart';
import 'package:bmsce/map/search_result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_search/material_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollegeMap extends StatefulWidget {
  CollegeMapState createState() => CollegeMapState();
}

class CollegeMapState extends State<CollegeMap> {
  final _names = [
    '5001',
    'Dr. Umadevi V',
    'Mallikarjun, Principal',
    'Selva Kumar',
    'Saritha',
    'Internet Lab',
    'HOD Office, CS',
    'Library',
    'Meghana S Vastramath',
  ];

  List<String> longList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    longList = [];
    getSearchNames(fromOnline: false).then((onValue) {
      setState(() {
        longList = onValue;
      });
    });
  }

  static Future<List<String>> getSearchNames({bool fromOnline = true}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final offlineSearchNames = preferences.getStringList('searchNames');
    if (offlineSearchNames == null ||
        offlineSearchNames.isEmpty ||
        fromOnline) {
      final searchNamesDoc = await Firestore.instance
          .collection('college_map_secondary')
          .document('all_places_summary')
          .get();

      List<dynamic> array = searchNamesDoc.data['searchNames'];
      preferences.setStringList('searchNames', array.cast<String>());
      print('Online hai re baba');
      return array.cast<String>();
    } else {
      print('Offline hai re baba');
      return offlineSearchNames;
    }
  }

  final ValueNotifier<List<String>> notifier = ValueNotifier([]);
  final ScrollController controller = ScrollController();

  final stateKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    double zoom = 2.2;
    return Scaffold(
        key: stateKey,
        appBar: AppBar(
          title: Text('Map'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(_buildMaterialSearchPage(context));
              },
            ),
            IconButton(
              icon: Icon(Icons.add_location),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return AddPlace();
                }));
              },
            )
          ],
        ),
        body: CollegeMapWidget(
          zoom: zoom,
          notifier: notifier,
        ));
  }

  _buildMaterialSearchPage(BuildContext context) {
    return new MaterialPageRoute<String>(
        settings: new RouteSettings(
          name: 'material_search',
          isInitialRoute: false,
        ),
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return new Material(
            child: new MaterialSearch<String>(
              placeholder: 'Search Teacher, Clasroom, Office ...',
              limit: 25,
              results: longList
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
              onSelect: (dynamic value) => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return SearchFutureWidget(searchValue: value);
                  })),
              onSubmit: (String value) => Navigator.of(context).pop(value),
            ),
          );
        });
  }
}
//TODO: Map notes
//Any points that comes after a search should be of any one floor. For now no washrooms and all.
