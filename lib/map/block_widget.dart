import 'package:bmsce/map/block_painter.dart';
import 'package:bmsce/map/building_constants.dart';
import 'package:flutter/material.dart';

class BlockWidget extends StatefulWidget {
  final double zoom;
  final double angle;
  final Block block;
  final String prefixInId;
  final ValueNotifier<List<String>> notifier;

  const BlockWidget(
      {Key key,
      this.zoom,
      this.angle,
      this.block,
      this.prefixInId,
      this.notifier})
      : super(key: key);

  factory BlockWidget.draw({
    key,
    block,
    zoom = 1.0,
    notifier,
    angle = 0.0,
  }) {
    return BlockWidget(
      angle: angle,
      block: block,
      key: key,
      notifier: notifier,
      prefixInId: BlockIdPrefixMap[block],
      zoom: zoom,
    );
  }
  BlockState createState() => BlockState();
}

class BlockState extends State<BlockWidget> {
  BlockState();

  bool isSomethingMarked = false;
  @override
  void initState() {
    super.initState();
    if (widget.notifier != null) {
      widget.notifier.addListener(() {
        List<String> pgMarkers = [];
        markers.clear();
        widget.notifier.value.forEach((point) {
          if (point.startsWith(widget.prefixInId)) {
            pgMarkers.add(point);
          }
        });
        if (pgMarkers.isNotEmpty) {
          setState(() {
            markers = pgMarkers;
          });
          isSomethingMarked = true;
        }
        if (pgMarkers.isEmpty && isSomethingMarked) {
          setState(() {
            markers = pgMarkers;
          });
          isSomethingMarked = false;
        }
      });
    }
  }

  List<String> markers = [];

  final ScrollController controller = ScrollController();

  final stateKey = GlobalKey<ScaffoldState>();
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
        child:
            Stack(overflow: Overflow.visible, fit: StackFit.expand, children: [
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
                          Icons.adjust,
                        ),
                      ),
                    ),
                  );
                })),
          ),
        ]),
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
      final offset =
          new Offset(x * zoom - (2.5 * zoom), y * zoom - (2.5 * zoom));
      positionChild(point, offset);
      print("ZOOM $zoom , $offset");
    });
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}
