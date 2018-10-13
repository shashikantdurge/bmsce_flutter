import 'dart:async';

import 'package:bmsce/map/edit_place.dart';
import 'package:bmsce/map/search_result.dart';
import 'package:bmsce/map/suggestions_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_search/material_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollegeMap extends StatefulWidget {
  CollegeMapState createState() => CollegeMapState();
}

class CollegeMapState extends State<CollegeMap> {
  List<String> longList = [];

  @override
  void initState() {
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
    return Scaffold(
      key: stateKey,
      appBar: AppBar(
        title: Text('Map'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'add_place')
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return EditPlace(
                    suggestionType: 'create',
                  );
                }));
              else if (value == 'suggestions')
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return SuggestionList();
                }));
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.add_location),
                      Text('Add missing place')
                    ],
                  ),
                  value: 'add_place',
                ),
                PopupMenuItem(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.view_list),
                      Text('Suggestions')
                    ],
                  ),
                  value: 'suggestions',
                )
              ];
            },
          ),
        ],
      ),
      body: Center(child: Text('Search Teacher, Class room, Lab etc...')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(_buildMaterialSearchPage(context));
        },
        child: Icon(Icons.search),
      ),
    );
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
