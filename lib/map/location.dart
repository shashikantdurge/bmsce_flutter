import 'package:bmsce/map/block_widget.dart';
import 'package:bmsce/map/building_constants.dart';
import 'package:bmsce/my_widgets/floor_radio_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tuple/tuple.dart';

class LocationMarker extends StatefulWidget {
  final String initLocationId;

  const LocationMarker({Key key, this.initLocationId}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    Block selectedBlock;
    String selectedFloor;
    String rawLocationId;

    if (initLocationId != null) {
      final blockFloor = getBlockFloorFrmLocationId(initLocationId);
      selectedBlock = blockFloor.item1;
      selectedFloor = blockFloor.item2;
      rawLocationId = initLocationId.replaceFirst(
          '_D_${selectedFloor}_D_', '_D_somefloor_D_');
    } else {
      selectedBlock = Block.CS;
      selectedFloor = "G";
    }

    return LocationMarkerState(selectedBlock, selectedFloor, rawLocationId);
  }

  static Tuple2<Block, String> getBlockFloorFrmLocationId(String locationId) {
    Block block;
    String floor;
    try {
      final blockPrefix = locationId.split('_D_').first;
      floor = locationId.split('_D_')[1];
      block = BlockIdPrefixMap.entries.firstWhere((entry) {
        return entry.value == blockPrefix;
      }).key;
    } catch (err) {}
    return Tuple2(block, floor);
  }

  static String getLocationHrFrmId(String locationId) {
    if (locationId is String) {
      final locTuple = getBlockFloorFrmLocationId(locationId);
      return '${BlockNameMap[locTuple.item1]}, ${FloorNameMap[locTuple.item2]}';
    } else {
      return null;
    }
  }
}

class LocationMarkerState extends State<LocationMarker> {
  GlobalKey previewContainer = new GlobalKey();
  final blocks = BlockNameMap.keys.toList();
  Block selectedBlock;
  String selectedFloor;
  String rawSelLocationId;

  ValueNotifier<double> zoomNotifier;
  final stateKey = GlobalKey<ScaffoldState>();
  double zoom;
  LocationMarkerState(
      this.selectedBlock, this.selectedFloor, this.rawSelLocationId);

  @override
  void initState() {
    super.initState();

    zoom = 5.0;
    zoomNotifier = ValueNotifier(zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: stateKey,
      appBar: AppBar(
        title: Text('Touch the screen on the correct location'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              if (rawSelLocationId == null) {
                stateKey.currentState.showSnackBar(SnackBar(
                  content: Text('Please Mark the Location'),
                ));
                return;
              }
              String selectedLocationId =
                  rawSelLocationId.replaceFirst('somefloor', selectedFloor);

              Navigator.pop(context, selectedLocationId);
            },
          )
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            left: 0.0,
            top: 0.0,
            bottom: 0.0,
            right: 0.0,
            child: Scrollbar(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      key: previewContainer,
                      child: BlockMarker(
                        block: selectedBlock,
                        zoomNotifier: zoomNotifier,
                        initMarkedValues: [rawSelLocationId],
                        onMarkerChanged: (markerStr) {
                          rawSelLocationId = markerStr;
                        },
                      ),
                    ),
                  )),
            ),
          ),
          Positioned(
            right: -40.0,
            top: 5.0,
            bottom: 5.0,
            child: Center(
                child: Transform.rotate(
                    angle: -1.5708,
                    child: Text(
                      'Bull temple Road',
                      style: TextStyle(color: Colors.grey),
                    ))),
          ),
          Positioned(
            right: 10.0,
            bottom: 10.0,
            child: Container(
              child: ButtonBar(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.zoom_out,
                      size: 40.0,
                      color: Colors.grey[700],
                    ),
                    onPressed: () {
                      if (zoomNotifier.value == 1) return;
                      zoomNotifier.value = zoomNotifier.value - 1;
                      // zoomNotifier.notifyListeners();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.zoom_in,
                      size: 40.0,
                      color: Colors.grey[700],
                    ),
                    onPressed: () {
                      if (zoomNotifier.value == 10) return;
                      zoomNotifier.value = zoomNotifier.value + 1;
                      // zoomNotifier.notifyListeners();
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10.0,
            right: 10.0,
            child: DropdownButton(
              value: selectedBlock,
              items: List.generate(blocks.length, (index) {
                return DropdownMenuItem(
                  child: Text(BlockNameMap[blocks[index]]),
                  value: blocks[index],
                );
              }),
              onChanged: (value) {
                setState(() {
                  selectedBlock = value;
                });
                rawSelLocationId = null;
              },
            ),
          ),
          Positioned(
            bottom: 5.0,
            left: 5.0,
            child: FloorsRadio(
              floorsList: BlockFloors[selectedBlock],
              initFloor: selectedFloor,
              onFloorChange: (floor) {
                selectedFloor = floor;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FloorsRadio extends StatefulWidget {
  final List<String> floorsList;
  final String initFloor;
  final ValueChanged<String> onFloorChange;

  const FloorsRadio(
      {Key key,
      this.floorsList = const ["G"],
      this.initFloor = "G",
      @required this.onFloorChange})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FloorsRadioState();
  }
}

class FloorsRadioState extends State<FloorsRadio> {
  String groupValue;

  @override
  void initState() {
    super.initState();
    groupValue = widget.initFloor;
    widget.onFloorChange(groupValue);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.floorsList.contains(groupValue)) {
      groupValue = widget.floorsList[0];
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.floorsList.length, (index) {
        return FloorRadioButton<String>(
          value: widget.floorsList[index],
          groupValue: groupValue,
          onChanged: (String value) {
            setState(() {
              groupValue = value;
            });
            widget.onFloorChange(groupValue);
          },
        );
      }),
    );
  }
}

class BlockMarker extends StatefulWidget {
  final ValueNotifier<double> zoomNotifier;
  final Block block;
  final List<String> initMarkedValues;
  final ValueChanged<String> onMarkerChanged;

  const BlockMarker(
      {Key key,
      @required this.block,
      @required this.zoomNotifier,
      @required this.onMarkerChanged,
      this.initMarkedValues = const []})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return BlockMarkerState();
  }
}

class BlockMarkerState extends State<BlockMarker> {
  final padding = 50.0;
  final ValueNotifier<List<String>> markerNotifier = ValueNotifier([]);
  Block currentBlock;

  @override
  void initState() {
    super.initState();
    widget.zoomNotifier.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.scheduleFrameCallback((c) {
      markerNotifier.value = widget.initMarkedValues;
    });
    currentBlock = widget.block;
  }

  @override
  Widget build(BuildContext context) {
    double zoom = widget.zoomNotifier.value;
    if (currentBlock != widget.block) {
      markerNotifier.value = widget.initMarkedValues;
      // markerNotifier.notifyListeners();
      currentBlock = widget.block;
    }
    return GestureDetector(
      onTapDown: (tapDetails) {
        RenderBox box = context.findRenderObject();
        final offset = box.globalToLocal(tapDetails.globalPosition);
        double x = (offset.dx - padding) / zoom;
        double y = (offset.dy - padding) / zoom;
        print('Renderbox offset ${offset.dx / zoom}, ${offset.dy / zoom}');
        final xystr =
            "${BlockIdPrefixMap[widget.block]}_D_somefloor_D_${x.toStringAsFixed(4).replaceAll(".", "X")}_D_${y.toStringAsFixed(4).replaceAll(".", "Y")}";
        markerNotifier.value = [xystr];

        // markerNotifier.notifyListeners();
        widget.onMarkerChanged(xystr);
        //print('pointing at $x , $y');
      },
      child: Container(
        padding: EdgeInsets.all(padding),
        color: Colors.grey[50],
        child: BlockWidget.draw(
          block: widget.block,
          zoom: zoom,
          notifier: markerNotifier,
        ),
      ),
    );
  }
}
