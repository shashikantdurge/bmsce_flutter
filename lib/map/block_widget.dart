import 'package:bmsce/map/block_painter.dart';
import 'package:bmsce/map/building_constants.dart';
import 'package:flutter/material.dart';

class BlockWidget extends StatefulWidget {
  final double zoom;
  final double angle;
  final Block block;
  final String prefixInId;
  final ValueNotifier<List<String>> notifier;
  final VoidCallback onMarked;

  const BlockWidget(
      {Key key,
      this.zoom,
      this.angle,
      this.block,
      this.prefixInId,
      this.notifier,
      this.onMarked})
      : super(key: key);

  factory BlockWidget.draw(
      {key, block, zoom = 1.0, notifier, angle = 0.0, VoidCallback onMarked}) {
    return BlockWidget(
      angle: angle,
      block: block,
      key: key,
      notifier: notifier,
      prefixInId: BlockIdPrefixMap[block],
      zoom: zoom,
      onMarked: onMarked,
    );
  }
  BlockState createState() => BlockState();
}

class BlockState extends State<BlockWidget> {
  List<String> markers = [];
  bool isSomethingMarked = false;

  @override
  void initState() {
    super.initState();
    if (widget.notifier != null) {
      widget.notifier.addListener(() {
        List<String> newMarkers = [];
        markers.clear();

        widget.notifier.value.forEach((point) {
          if (point is String) if (point.startsWith(widget.prefixInId)) {
            newMarkers.add(point);
          }
        });
        if (newMarkers.isNotEmpty) {
          setState(() {
            markers = newMarkers;
          });
          isSomethingMarked = true;
          if (widget.onMarked != null) widget.onMarked();
        }
        if (newMarkers.isEmpty && isSomethingMarked) {
          setState(() {
            markers = newMarkers;
          });
          isSomethingMarked = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double zoom = widget.zoom;
    double angle = widget.angle; //0.11;
    return Transform.rotate(
      angle: angle,
      child: SizedBox(
        height: BlockHeightMap[widget.block] * zoom,
        width: BlockAspectRatioMap[widget.block] *
            BlockHeightMap[widget.block] *
            zoom,
        child: Stack(
          overflow: Overflow.visible,
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 0.0,
              top: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: CustomPaint(
                painter: BlockPainter(widget.block, zoom),
              ),
            ),
            Positioned(
              left: 0.0,
              top: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: CustomMultiChildLayout(
                  delegate: BlockDelegate(zoom, markers),
                  children: List.generate(markers.length, (index) {
                    return LayoutId(
                      id: markers[index],
                      child: Transform.rotate(
                        angle: -angle,
                        child: SizedBox(
                          height: zoom,
                          width: zoom,
                          child: IconButton(
                            padding: EdgeInsets.all(0.0),
                            iconSize: 5 * zoom,
                            onPressed: () {
                              // showModalBottomSheet(
                              //     context: context,
                              //     builder: (context) {
                              //       Text('markers');
                              //     });
                            },
                            icon: Icon(
                              Icons.location_on,
                            ),
                          ),
                        ),
                      ),
                    );
                  })
                    ..add(LayoutId(
                      child: Transform.rotate(
                        angle: -angle,
                        child: Center(
                          widthFactor: 2.0,
                          heightFactor: 2.0,
                          child: Text(
                            BlockNameMap[widget.block],
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(fontSize: 13.0, color: Colors.grey),
                          ),
                        ),
                      ),
                      id: 'blockName',
                    ))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //widget.notifier.dispose();
  }
}

class BlockDelegate extends MultiChildLayoutDelegate {
  BlockDelegate(this.zoom, this.points);
  final double zoom;
  final List<String> points;
  @override
  void performLayout(Size size) {
    points.forEach((point) {
      double x = double.parse(point.split("_D_")[2].replaceFirst("X", "."));
      double y = double.parse(point.split("_D_")[3].replaceFirst("Y", "."));
      layoutChild(point, new BoxConstraints.tight(Size.zero));
      final offset = new Offset(x * zoom - (2.5 * zoom), y * zoom - (5 * zoom));
      positionChild(point, offset);
      print("ZOOM $zoom , $offset");
    });
    if (hasChild('blockName')) {
      layoutChild(
          'blockName',
          new BoxConstraints.tightForFinite(
              width: size.width + zoom * 5, height: size.height));
      positionChild('blockName', Offset(0.0, 0.0));
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}
