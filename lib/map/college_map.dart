import 'package:bmsce/map/add_missing_place.dart';
import 'package:bmsce/map/block_widget.dart';
import 'package:bmsce/map/building_constants.dart';
import 'package:flutter/material.dart';
import 'package:material_search/material_search.dart';

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
    longList = List.generate(1500, (index) {
      return '${_names[index % 9]} $index';
    });
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
              Navigator.of(context)
                  .push(_buildMaterialSearchPage(context))
                  .then((dynamic value) {
                print(value);
                //setState(() => _name = value as String);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.add_location),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return AddPlace();
              })).then((dynamic value) {
                print(value);
                //setState(() => _name = value as String);
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
            height: MediaQuery.of(context).size.height,
            //width: 100.0,
            //color: Colors.yellow,
            child: CustomMultiChildLayout(
              delegate: CollegeMapDelegate(zoom),
              children: <Widget>[
                LayoutId(
                  id: "text",
                  child:
                      Text("IT IS STILL PENDING. YOU CAN'T DO ANYTHING HERE"),
                ),
                LayoutId(
                  child: BlockWidget(
                    block: Block.NB,
                    notifier: notifier,
                    zoom: zoom,
                    angle: 0.11,
                  ),
                  id: Block.NB,
                ),
                LayoutId(
                  child: BlockWidget(
                    angle: 0.11,
                    block: Block.ME,
                    notifier: notifier,
                    zoom: zoom,
                  ),
                  id: Block.ME,
                ),
                LayoutId(
                  child: BlockWidget(
                    block: Block.PG,
                    angle: 0.11,
                    notifier: notifier,
                    zoom: zoom,
                  ),
                  id: Block.PG,
                ),
                LayoutId(
                  child: BlockWidget(
                    block: Block.CS,
                    angle: 0.11,
                    notifier: notifier,
                    zoom: zoom,
                  ),
                  id: Block.CS,
                ),
                LayoutId(
                  child: BlockWidget(
                    block: Block.CR,
                    angle: 0.11,
                    notifier: notifier,
                    zoom: zoom,
                  ),
                  id: Block.CR,
                ),
                LayoutId(
                  child: BlockWidget(
                    block: Block.AS,
                    angle: 0.11,
                    notifier: notifier,
                    zoom: zoom,
                  ),
                  id: Block.AS,
                )
              ],
            )),
      ),
    );
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
              onSelect: (dynamic value) => Navigator.of(context).pop(value),
              onSubmit: (String value) => Navigator.of(context).pop(value),
            ),
          );
        });
  }

  @override
  dispose() {
    notifier.dispose();
    super.dispose();
  }
}

const String PG_101 = "pg101";

class CollegeMapDelegate extends MultiChildLayoutDelegate {
  CollegeMapDelegate(this.zoom);
  final double zoom;
  @override
  void performLayout(Size size) {
    if (hasChild(Block.PG)) {
      layoutChild(Block.PG, new BoxConstraints.loose(size));
      positionChild(Block.PG, new Offset(126.0 * zoom, 120.0 * zoom));
    }
    if (hasChild(Block.CR)) {
      layoutChild(Block.CR, new BoxConstraints.loose(size));
      positionChild(Block.CR, new Offset(220.0 * zoom, 34.0 * zoom));
    }
    if (hasChild(Block.CS)) {
      layoutChild(Block.CS, new BoxConstraints.loose(size));
      positionChild(Block.CS, new Offset(166.0 * zoom, 26.0 * zoom));
    }
    if (hasChild(Block.ME)) {
      layoutChild(Block.ME, new BoxConstraints.loose(size));
      positionChild(Block.ME, new Offset(117.0 * zoom, 35.0 * zoom));
    }
    if (hasChild(Block.AS)) {
      layoutChild(Block.AS, new BoxConstraints.loose(size));
      positionChild(Block.AS, new Offset(218.0 * zoom, 129.0 * zoom));
    }
    if (hasChild(Block.NB)) {
      layoutChild(Block.NB, new BoxConstraints.loose(size));
      positionChild(Block.NB, new Offset(118.0 * zoom, 172.0 * zoom));
    }
    if (hasChild("text")) {
      layoutChild("text", new BoxConstraints.loose(size));
      positionChild("text", new Offset(0.0, 0.0));
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}

//TODO: Map notes
//Any points that comes after a search should be of any one floor. For now no washrooms and all.
