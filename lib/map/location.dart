import 'dart:typed_data';

import 'package:bmsce/map/block_widget.dart';
import 'package:bmsce/map/building_constants.dart';
import 'package:bmsce/my_widgets/floor_radio_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:tuple/tuple.dart';

class LocationMarker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LocationMarkerState();
  }
}

class LocationMarkerState extends State<LocationMarker> {
  GlobalKey previewContainer = new GlobalKey();
  final blocks = BlockNameMap.keys.toList();
  Block selectedBlock;
  String selectedFloor;
  String placeMarkerId;
  ValueNotifier<double> zoomNotifier;
  final stateKey = GlobalKey<ScaffoldState>();

  double zoom;

  @override
  void initState() {
    super.initState();
    selectedBlock = meghanablock != null ? meghanablock : Block.CS;
    zoom = meghanaZoom != null ? meghanaZoom : 5.0;
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
              if (placeMarkerId == null) {
                stateKey.currentState.showSnackBar(SnackBar(
                  content: Text('Please Mark the Location'),
                ));
                return;
              }
              meghanablock = selectedBlock;
              meghanaFloor = selectedFloor;
              meghanaZoom = zoom;
              final boundary = previewContainer.currentContext
                  .findRenderObject() as RenderRepaintBoundary;
              ui.Image image = await boundary.toImage();
              ByteData byteData =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              Uint8List pngBytes = byteData.buffer.asUint8List();
              Navigator.pop(
                  context, Tuple3(pngBytes, placeMarkerId, selectedBlock));
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
                        onMarkerChanged: (markerStr) {
                          placeMarkerId = markerStr.replaceFirst(
                              "somefloor", selectedFloor);
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
                      zoomNotifier.notifyListeners();
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
                      zoomNotifier.notifyListeners();
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
                placeMarkerId = null;
              },
            ),
          ),
          Positioned(
            bottom: 5.0,
            left: 5.0,
            child: FloorsRadio(
              floorsList: BlockFloors[selectedBlock],
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
  final ValueChanged<String> onFloorChange;

  const FloorsRadio(
      {Key key, this.floorsList = const ["G"], @required this.onFloorChange})
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
    groupValue = meghanaFloor != null ? meghanaFloor : widget.floorsList[0];
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
  final ValueChanged<String> onMarkerChanged;

  const BlockMarker(
      {Key key,
      @required this.block,
      @required this.zoomNotifier,
      @required this.onMarkerChanged})
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
    currentBlock = widget.block;
  }

  @override
  Widget build(BuildContext context) {
    double zoom = widget.zoomNotifier.value;
    if (currentBlock != widget.block) {
      markerNotifier.value = [];
      markerNotifier.notifyListeners();
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

        markerNotifier.notifyListeners();
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
