import 'package:bmsce/map/block_widget.dart';
import 'package:bmsce/map/building_constants.dart';
import 'package:flutter/material.dart';

class CollegeMapWidget extends StatelessWidget {
  final double zoom;
  final ValueNotifier<List<String>> notifier;
  final ScrollController horScrollContr = ScrollController();
  final ScrollController vertScrollContr = ScrollController();

  CollegeMapWidget({Key key, this.zoom = 3.0, @required this.notifier})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    horScrollContr.addListener(() {
      print('HOR SCROLL OFFSET ${horScrollContr.offset}');
    });
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        controller: horScrollContr,
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          controller: vertScrollContr,
          child: Container(
              height: 1500.0, //MAP HEIGHT
              width: 1000.0, //MAP WIDTH
              //color: Colors.yellow,
              child: CustomMultiChildLayout(
                delegate: CollegeMapDelegate(zoom),
                children: <Widget>[
                  LayoutId(
                    child: BlockWidget.draw(
                      block: Block.NB,
                      notifier: notifier,
                      zoom: zoom,
                      angle: 0.11,
                      onMarked: () {
                        animateHorScroll(118.0, Block.NB);
                        animateVerScroll(172.0, Block.NB);
                      },
                    ),
                    id: Block.NB,
                  ),
                  LayoutId(
                    child: BlockWidget.draw(
                      angle: 0.11,
                      block: Block.ME,
                      notifier: notifier,
                      zoom: zoom,
                      onMarked: () {
                        animateHorScroll(117.0, Block.ME);
                        animateVerScroll(35.0, Block.ME);
                      },
                    ),
                    id: Block.ME,
                  ),
                  LayoutId(
                    child: BlockWidget.draw(
                      block: Block.PG,
                      angle: 0.11,
                      notifier: notifier,
                      zoom: zoom,
                      onMarked: () {
                        animateHorScroll(126.0, Block.PG);
                        animateVerScroll(120.0, Block.PG);
                      },
                    ),
                    id: Block.PG,
                  ),
                  LayoutId(
                    child: BlockWidget.draw(
                      block: Block.CS,
                      angle: 0.11,
                      notifier: notifier,
                      zoom: zoom,
                      onMarked: () {
                        animateHorScroll(166.0, Block.CS);
                        animateVerScroll(26.0, Block.CS);
                      },
                    ),
                    id: Block.CS,
                  ),
                  LayoutId(
                    child: BlockWidget.draw(
                      block: Block.CR,
                      angle: 0.11,
                      notifier: notifier,
                      zoom: zoom,
                      onMarked: () {
                        animateHorScroll(220.0, Block.CR);
                        animateVerScroll(34.0, Block.CR);
                      },
                    ),
                    id: Block.CR,
                  ),
                  LayoutId(
                    child: BlockWidget.draw(
                      block: Block.AS,
                      angle: 0.11,
                      notifier: notifier,
                      zoom: zoom,
                      onMarked: () {
                        animateHorScroll(218.0, Block.AS);
                        animateVerScroll(129.0, Block.AS);
                      },
                    ),
                    id: Block.AS,
                  ),
                  LayoutId(
                    child: BlockWidget.draw(
                      block: Block.SCIENCE,
                      angle: 0.11,
                      notifier: notifier,
                      zoom: zoom,
                      onMarked: () {
                        animateHorScroll(86.0, Block.SCIENCE); //
                        animateVerScroll(214.0, Block.SCIENCE); //
                      },
                    ),
                    id: Block.SCIENCE,
                  ),
                  LayoutId(
                    child: BlockWidget.draw(
                      block: Block.LIB,
                      angle: 0.11,
                      notifier: notifier,
                      zoom: zoom,
                      onMarked: () {
                        animateHorScroll(255.0, Block.LIB); //
                        animateVerScroll(40.0, Block.LIB); //
                      },
                    ),
                    id: Block.LIB,
                  ),
                  LayoutId(
                    child: BlockWidget.draw(
                      block: Block.INDOOR,
                      angle: 0.11,
                      notifier: notifier,
                      zoom: zoom,
                      onMarked: () {
                        animateHorScroll(186.0, Block.INDOOR);
                        animateVerScroll(212.0, Block.INDOOR);
                      },
                    ),
                    id: Block.INDOOR,
                  )
                ],
              )),
        ),
      ),
    );
  }

  animateHorScroll(double offsetX, Block block) {
    double hor = 0.5 * horScrollContr.position.viewportDimension +
        (offsetX * zoom - horScrollContr.position.viewportDimension) +
        (BlockHeightMap[block] * BlockAspectRatioMap[block] * zoom / 2);
    horScrollContr.animateTo(hor,
        duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  animateVerScroll(double offsetY, Block block) {
    double ver = 0.7 * vertScrollContr.position.viewportDimension +
        (offsetY * zoom - vertScrollContr.position.viewportDimension) +
        (BlockHeightMap[block] * zoom / 2);
    vertScrollContr.animateTo(ver,
        duration: Duration(milliseconds: 500), curve: Curves.ease);
  }
}

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
    if (hasChild(Block.SCIENCE)) {
      layoutChild(Block.SCIENCE, new BoxConstraints.loose(size));
      positionChild(Block.SCIENCE, new Offset(86.0 * zoom, 214.0 * zoom));
    }
    if (hasChild(Block.LIB)) {
      layoutChild(Block.LIB, new BoxConstraints.loose(size));
      positionChild(Block.LIB, new Offset(255.0 * zoom, 40.0 * zoom));
    }
    if (hasChild(Block.INDOOR)) {
      layoutChild(Block.INDOOR, new BoxConstraints.loose(size));
      positionChild(Block.INDOOR, new Offset(186.0 * zoom, 212.0 * zoom));
    }
    if (hasChild("text")) {
      layoutChild("text", new BoxConstraints.loose(size));
      positionChild("text", new Offset(0.0, 0.0));
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}
