import 'dart:typed_data';

import 'package:bmsce/course/course_dept_sem.dart';
import 'package:bmsce/map/building_constants.dart';
import 'package:bmsce/map/college_map.dart';
import 'package:bmsce/map/college_map_widget.dart';
import 'package:bmsce/map/edit_place.dart';
import 'package:bmsce/map/place.dart';
import 'package:bmsce/map/suggest_an_edit.dart';
import 'package:bmsce/user_profile/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

var imageMap = {};

class SearchFutureWidget extends StatefulWidget {
  final String searchValue;
  SearchFutureWidget(
      {Key key, @required this.searchValue}) //, @required this.notifier})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SearchFutureWidgetState();
  }
}

class SearchFutureWidgetState extends State<SearchFutureWidget> {
  ValueNotifier notifier = ValueNotifier<List<String>>([]);

  @override
  void dispose() {
    // TODO: implement dispose
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.searchValue),
      ),
      body: CollegeMapWidget(
        notifier: notifier,
      ),
      bottomSheet: FutureBuilder(
        future: getSearchResult(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('Not Found');
            case ConnectionState.waiting:
            case ConnectionState.active:
              return Container(
                  height: 50.0,
                  width: double.infinity,
                  child: Center(child: CircularProgressIndicator()));
            case ConnectionState.done:
              dynamic data = snapshot.data;
              if (snapshot.hasData) {
                return PlaceBottomSheet(
                  data: data,
                  onPlaceChanged: (place) {
                    notifier.value = [place.location];
                  },
                );
              } else
                return Text('Not Found');
          }
        },
      ),
    );
  }

  getSearchResult() async {
    final docsSnap = await Firestore.instance
        .collection('college_map')
        .where('searchName', isEqualTo: widget.searchValue)
        .getDocuments();
    if (docsSnap.documents.length == 1) {
      return Place.fromMap(docsSnap.documents.first.data);
    }
    if (docsSnap.documents.length > 1) {
      return List.generate(docsSnap.documents.length, (index) {
        return Place.fromMap(docsSnap.documents[index].data);
      });
    }
    CollegeMapState.getSearchNames();
    return null;
  }
}

class PlaceBottomSheet extends StatefulWidget {
  final dynamic data;
  final ValueChanged<Place> onPlaceChanged;

  const PlaceBottomSheet(
      {Key key, @required this.data, @required this.onPlaceChanged})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PlaceBottomSheetState();
  }
}

class PlaceBottomSheetState extends State<PlaceBottomSheet>
    with SingleTickerProviderStateMixin {
  AnimationController animController;
  Place selectedPlace;

  @override
  void initState() {
    super.initState();
    animController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.scheduleFrameCallback((callback) {
      widget.onPlaceChanged(selectedPlace);
    });
    return BottomSheet(
      builder: (BuildContext context) {
        if (widget.data is Place) {
          selectedPlace = widget.data;
          return getPlaceCard(widget.data);
        } else {
          if (selectedPlace == null) selectedPlace = widget.data[0];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              getPlaceCard(selectedPlace),
              Divider(color: Colors.black),
              FlatButton(
                  child: Text('SHOW LIST'),
                  onPressed: () {
                    showPlacesList();
                  })
            ],
          );
        }
      },
      onClosing: () {},
      animationController: animController,
    );
  }

  getPlaceCard(Place place) {
    String locationHR = "";
    try {
      final blockPrefix = place.location.split('_D_').first;
      final block = BlockIdPrefixMap.entries.firstWhere((entry) {
        return entry.value == blockPrefix;
      }).key;
      locationHR =
          '${BlockNameMap[block]}, ${FloorNameMap[place.location.split('_D_')[1]]}';
    } catch (err) {}
    return PlaceDetailsWidget(
      place: place,
      location: locationHR,
    );
  }

  showPlacesList() {
    showModalBottomSheet(
            builder: (BuildContext context) {
              return getPlacesListView(widget.data);
            },
            context: context)
        .then((onValue) {
      if (onValue is Place) {
        setState(() {
          selectedPlace = onValue;
        });
        //widget.onPlaceChanged(onValue);
      }
    });
  }

  getPlacesListView(List<Place> places) {
    return ListView(
      children: List.generate(places.length, (i) {
        Place place = places[i];
        String locationHR = "";
        try {
          final blockPrefix = place.location.split('_D_').first;
          final block = BlockIdPrefixMap.entries.firstWhere((entry) {
            return entry.value == blockPrefix;
          }).key;
          locationHR =
              '${BlockNameMap[block]}, ${FloorNameMap[place.location.split('_D_')[1]]}';
        } catch (err) {}
        return ListTile(
          title: Text(place.name),
          subtitle:
              Text('${place.dept != null ? place.dept + '\n' : ''}$locationHR'),
          onTap: () {
            Navigator.pop(context, place);
          },
        );
      }),
    );
  }
}

class PlaceDetailsWidget extends StatelessWidget {
  final String location;
  final Place place;

  const PlaceDetailsWidget(
      {Key key, @required this.location, @required this.place})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Divider(),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ImageLoader(gsPath: place.photoUrl),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton(
                      onSelected: (value) async {
                        processSuggestion(context);
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            child: Text('Suggest an edit'),
                            value: 'suggest_an_edit',
                          )
                        ];
                      },
                    ),
                  ),
                  Text(place.name, style: Theme.of(context).textTheme.title),
                  Text(
                      '${place.designation != null ? place.designation + ',' : ''} ${place.dept != null ? deptNameFromPrefix(place.dept).item2 : ''}'),
                ],
              ),
            ),
          ],
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.location_city),
              Text(location, style: Theme.of(context).textTheme.subhead),
            ],
          ),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.phone),
              onPressed: place.phoneNumber != null ? () {} : null,
            ),
            IconButton(
              icon: Icon(Icons.email),
              onPressed: place.email != null ? () {} : null,
            ),
            FlatButton(
              child: Row(
                children: <Widget>[
                  Text('MORE DETAILS'),
                  Icon(Icons.open_in_new)
                ],
                mainAxisSize: MainAxisSize.min,
              ),
              onPressed: place.website != null
                  ? () async {
                      if (await canLaunch(place.website)) {
                        launch(place.website);
                      }
                    }
                  : null,
            )
          ],
        ),
      ],
    );
  }

  processSuggestion(BuildContext context) async {
    final suggestionType = await showDialog(
        context: context,
        builder: (context) {
          return SuggestAnEditDialog(
            name: place.searchName,
            place: place,
            user: User.instance,
          );
        });
    if (suggestionType == 'edit') {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return EditPlace(
          suggestionType: suggestionType,
          place: place,
        );
      }));
    } else if (suggestionType == "close") {}
  }
}

class ImageLoader extends StatelessWidget {
  final String gsPath;
  final oneMb = 1024 * 1024;

  const ImageLoader({Key key, @required this.gsPath}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.width * 0.25,
        width: MediaQuery.of(context).size.width * 0.25,
        child: FutureBuilder(
          future: getImage(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return Placeholder(
                  fallbackHeight: MediaQuery.of(context).size.width * 0.2,
                  fallbackWidth: MediaQuery.of(context).size.width * 0.2,
                  strokeWidth: 0.2,
                );
              case ConnectionState.done:
                dynamic data = snapshot.data;
                if (snapshot.hasData && snapshot.data is Uint8List)
                  return Image.memory(data);
                else if (snapshot.hasData && snapshot.data is String)
                  return Image.network(
                    snapshot.data,
                  );
                else
                  return Placeholder(
                    fallbackHeight: MediaQuery.of(context).size.width * 0.2,
                    fallbackWidth: MediaQuery.of(context).size.width * 0.2,
                    strokeWidth: 0.2,
                  );
            }
          },
        ));
  }

  getImage() async {
    if (gsPath is String &&
        gsPath.startsWith('gs://bmsce-flutter.appspot.com')) {
      if (imageMap.containsKey(gsPath)) return imageMap[gsPath];
      try {
        final imageData = await FirebaseStorage.instance
            .ref()
            .child(gsPath.replaceFirst('gs://bmsce-flutter.appspot.com', ''))
            .getData(oneMb);
        imageMap[gsPath] = imageData;
        return imageData;
      } catch (err) {
        return null;
      }
    } else if (gsPath != null && await canLaunch(gsPath))
      return gsPath;
    else
      return null;
  }
}
