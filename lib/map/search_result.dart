import 'dart:typed_data';

import 'package:bmsce/map/building_constants.dart';
import 'package:bmsce/map/college_map.dart';
import 'package:bmsce/map/college_map_widget.dart';
import 'package:bmsce/map/place_cat.dart';
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
    // TODO: implement initState
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
          // WidgetsBinding.instance.scheduleFrameCallback((callback) {
          //   notifier.value = data is Place
          //       ? [data.location]
          //       : data is List<Place>
          //           ? List.generate(data.length, (i) {
          //               return data[i].location;
          //             })
          //           : [];
          //   //if (notifier.value.isNotEmpty) notifier.notifyListeners();
          // });
          selectedPlace = widget.data;
          return getPlaceCard(widget.data);
        } else {
          if (selectedPlace == null) selectedPlace = widget.data[0];
          // WidgetsBinding.instance.scheduleFrameCallback((callback) {
          //   widget.onPlaceChanged(selectedPlace);
          // });

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
    switch (place.runtimeType) {
      case FacultyCabin:
        print('FacultyCabin');
        return FacultyDetailsWidget(
          faculty: place,
          location: locationHR,
        );
      case ClassRoom:
      case Lab:
      case Other:
        return OtherDetailsWidget(
          location: locationHR,
          place: place,
        );
    }
    return Text('${place.runtimeType}');
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

class OtherDetailsWidget extends StatelessWidget {
  final Place place;
  final String location;

  const OtherDetailsWidget(
      {Key key, @required this.place, @required this.location})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Divider(),
          Text(place.name, style: Theme.of(context).textTheme.title),
          // Text('${place.dept != null ? place.dept : ''}'),

          Padding(
              padding: EdgeInsets.all(3.0),
              child: place.dept != null ? Text(place.dept) : null),
          Row(
            children: <Widget>[
              Icon(Icons.location_city),
              Text(location, style: Theme.of(context).textTheme.subhead),
            ],
          ),
        ],
      ),
    );
  }
}

class FacultyDetailsWidget extends StatelessWidget {
  final String location;
  final FacultyCabin faculty;

  const FacultyDetailsWidget(
      {Key key, @required this.location, @required this.faculty})
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
          children: <Widget>[
            ImageLoader(gsPath: faculty.profilePictureLink),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(faculty.name, style: Theme.of(context).textTheme.title),
                Text(
                    '${faculty.designation != null ? faculty.designation + ',' : ''} ${faculty.dept != null ? faculty.dept : ''}'),
              ],
            )
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
        Align(
            alignment: Alignment.centerRight,
            child: FlatButton(
              child: Row(
                children: <Widget>[
                  Text('MORE DETAILS'),
                  Icon(Icons.open_in_new)
                ],
                mainAxisSize: MainAxisSize.min,
              ),
              onPressed: () async {
                if (await canLaunch(faculty.detailsLink)) {
                  launch(faculty.detailsLink);
                }
              },
            )),
      ],
    );
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
                return Text('');
              case ConnectionState.waiting:
              case ConnectionState.active:
                return Icon(
                  Icons.account_circle,
                  size: MediaQuery.of(context).size.width * 0.2,
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
                  return Icon(
                    Icons.account_box,
                    size: MediaQuery.of(context).size.width * 0.2,
                  );
            }
          },
        ));
  }

  getImage() async {
    if (gsPath.startsWith('gs://bmsce-flutter.appspot.com')) {
      if (imageMap.containsKey(gsPath)) return imageMap[gsPath];
      final imageData = await FirebaseStorage.instance
          .ref()
          .child(gsPath.replaceFirst('gs://bmsce-flutter.appspot.com', ''))
          .getData(oneMb);
      imageMap[gsPath] = imageData;
      return imageData;
    } else if (gsPath != null)
      return gsPath;
    else
      return null;
  }
}
