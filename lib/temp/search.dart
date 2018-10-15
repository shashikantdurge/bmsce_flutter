// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:bmsce/map/edit_place.dart';
import 'package:bmsce/map/search_result.dart';
import 'package:bmsce/map/suggestions_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchDemo extends StatefulWidget {
  static const String routeName = '/material/search';

  @override
  _SearchDemoState createState() => _SearchDemoState();
}

class _SearchDemoState extends State<SearchDemo> {
  _SearchDemoSearchDelegate _delegate = _SearchDemoSearchDelegate();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('College search'),
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
        onPressed: () async {
          showSearch<String>(
            context: context,
            delegate: _delegate,
          );
        },
        child: Icon(Icons.search),
      ),
    );
  }
}

class _SearchDemoSearchDelegate extends SearchDelegate<String> {
  List<String> _data = ["BMSCE"];
  List<String> _history = [];
  bool fetxhing = false;

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  addSearchItems(context) async {
    final list = await _SearchDemoState.getSearchNames(fromOnline: false);
    print(list.toString());
    _data.addAll(list);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (!fetxhing) {
      fetxhing = true;
      addSearchItems(context);
    }
    String srch = query.split(" ").join("\.*");
    final Iterable<String> suggestions = query.isEmpty
        ? _history
        : _data.where((String i) =>
            i.contains(new RegExp(r"" + srch + "", caseSensitive: false)));

    return _SuggestionList(
      query: query,
      suggestions: suggestions.toList(),
      onSelected: (String suggestion) {
        query = suggestion;
        showResults(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // return Text('RESULTS');
    String searched = query;
    if (searched == null || !_data.contains(searched)) {
      final searchArr = _data.where((String i) => i.contains(new RegExp(
          r"" + query.split(" ").join("\.*") + "",
          caseSensitive: false)));
      searched = searchArr.isEmpty ? searched : searchArr.first;
    }

    if (searched == null || !_data.contains(searched)) {
      return Column(children: [
        Text(
          '"$searched" Not found',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Theme.of(context).textTheme.caption.color,
          ),
        ),
        FlatButton.icon(
          icon: Icon(Icons.add_location),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return EditPlace(
                suggestionType: 'create',
              );
            }));
          },
          label: Text('Add missing place'),
        ),
      ]);
    }

    return SearchFutureWidget(searchValue: searched);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty
          ? PopupMenuButton(onSelected: (value) {
              if (value == 'add_place')
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return EditPlace(suggestionType: 'create');
                }));
            }, itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.add_location),
                      Text('Add missing place')
                    ],
                  ),
                  value: 'add_place',
                )
              ];
            })
          : IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            )
    ];
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({this.suggestions, this.query, this.onSelected});

  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final String suggestion = suggestions[i];
        return ListTile(
          leading: query.isEmpty ? const Icon(Icons.history) : const Icon(null),
          title: Text(suggestion),
          onTap: () {
            onSelected(suggestion);
          },
        );
      },
    );
  }
}
