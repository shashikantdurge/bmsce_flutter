import 'package:bmsce/map/building_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BlockPainter extends CustomPainter {
  BlockPainter(this.block, this.zoom);
  final double zoom;
  final Block block;
  @override
  void paint(Canvas canvas, Size size) {
    final buildingPaint = new Paint()..color = Colors.grey[300];
    switch (block) {
      case Block.AS:
        drawAsBlock(canvas, buildingPaint);
        break;
      case Block.CR:
        drawCrBlock(canvas, buildingPaint);
        break;
      case Block.ME:
        drawMeBlock(canvas, buildingPaint);
        break;
      case Block.CS:
        drawCsBlock(canvas, buildingPaint);
        break;
      case Block.NB:
        drawNbBlock(canvas, buildingPaint);
        break;
      case Block.PG:
        drawPgBlock(canvas, buildingPaint);
        break;
    }
  }

  drawCrBlock(Canvas canvas, Paint buildingPaint) {
    canvas.drawRect(
        Rect.fromLTRB(0 * zoom, 42 * zoom, 1 * zoom, 48 * zoom), buildingPaint);
    canvas.drawRect(
        Rect.fromLTRB(1 * zoom, 0 * zoom, 12 * zoom, 68 * zoom), buildingPaint);
  }

  drawNbBlock(Canvas canvas, Paint buildingPaint) {
    canvas.drawRect(
        Rect.fromLTRB(0 * zoom, 0 * zoom, 46 * zoom, 46 * zoom), buildingPaint);
    canvas.drawRect(Rect.fromLTRB(4 * zoom, 40 * zoom, 46 * zoom, 62 * zoom),
        buildingPaint);
    canvas.drawRect(Rect.fromLTRB(0 * zoom, 62 * zoom, 46 * zoom, 86 * zoom),
        buildingPaint);

    final path = Path()
      ..moveTo(46.0 * zoom, 0.0)
      ..arcToPoint(Offset(50 * zoom, 40 * zoom),
          radius: Radius.elliptical(9 * zoom, 19 * zoom))
      ..arcToPoint(Offset(50 * zoom, 44 * zoom),
          clockwise: false, radius: Radius.elliptical(9 * zoom, 5 * zoom))
      ..arcToPoint(Offset(56 * zoom, 86 * zoom),
          radius: Radius.elliptical(11 * zoom, 23 * zoom))
      ..lineTo(46 * zoom, 86 * zoom);
    canvas.drawPath(path, buildingPaint);
  }

  drawAsBlock(Canvas canvas, Paint buildingPaint) {
    canvas.drawRect(
        Rect.fromLTRB(0 * zoom, 0 * zoom, 12 * zoom, 18 * zoom), buildingPaint);
    canvas.drawRect(
        Rect.fromLTRB(12 * zoom, 0 * zoom, 27 * zoom, 9 * zoom), buildingPaint);
    canvas.drawRect(Rect.fromLTRB(16 * zoom, 9 * zoom, 27 * zoom, 18 * zoom),
        buildingPaint);
    canvas.drawRect(Rect.fromLTRB(6 * zoom, 18 * zoom, 27 * zoom, 42 * zoom),
        buildingPaint);
  }

  drawMeBlock(Canvas canvas, Paint buildingPaint) {
    canvas.drawRect(
        Rect.fromLTRB(0 * zoom, 0 * zoom, 32 * zoom, 12 * zoom), buildingPaint);
    canvas.drawRect(Rect.fromLTRB(0 * zoom, 18 * zoom, 32 * zoom, 40 * zoom),
        buildingPaint);
    canvas.drawRect(Rect.fromLTRB(0 * zoom, 46 * zoom, 32 * zoom, 68 * zoom),
        buildingPaint);
    canvas.drawRect(Rect.fromLTRB(22 * zoom, 12 * zoom, 32 * zoom, 18 * zoom),
        buildingPaint);
    canvas.drawRect(Rect.fromLTRB(22 * zoom, 40 * zoom, 32 * zoom, 46 * zoom),
        buildingPaint);
    final path1 = Path()
      ..moveTo(22 * zoom, 12 * zoom)
      ..lineTo(18 * zoom, 14.5 * zoom)
      ..lineTo(20 * zoom, 18 * zoom)
      ..lineTo(22 * zoom, 16.5 * zoom);
    final path2 = Path()
      ..moveTo(22 * zoom, 40 * zoom)
      ..lineTo(18 * zoom, 42.5 * zoom)
      ..lineTo(20 * zoom, 46 * zoom)
      ..lineTo(22 * zoom, 44.5 * zoom);
    canvas.drawPath(path1, buildingPaint);
    canvas.drawPath(path2, buildingPaint);
  }

  drawCsBlock(Canvas canvas, Paint buildingPaint) {
    canvas.drawRect(Rect.fromLTRB(0 * zoom, 24 * zoom, 14 * zoom, 59 * zoom),
        buildingPaint);
    canvas.drawRect(Rect.fromLTRB(4 * zoom, 18 * zoom, 36 * zoom, 34 * zoom),
        buildingPaint);
    canvas.drawRect(Rect.fromLTRB(4 * zoom, 34 * zoom, 14 * zoom, 43 * zoom),
        buildingPaint);
    canvas.drawRect(Rect.fromLTRB(4 * zoom, 43 * zoom, 36 * zoom, 59 * zoom),
        buildingPaint);
    canvas.drawRect(Rect.fromLTRB(28 * zoom, 34 * zoom, 36 * zoom, 43 * zoom),
        buildingPaint);
    canvas.drawRect(Rect.fromLTRB(30 * zoom, 12 * zoom, 32 * zoom, 18 * zoom),
        buildingPaint);
    canvas.drawRect(
        Rect.fromLTRB(8 * zoom, 0 * zoom, 50 * zoom, 12 * zoom), buildingPaint);
    //canvas.drawCircle(Offset(0.0 * zoom, 0.0 * zoom), 1.0, Paint());
    //print('Original Point in Block Paint ${28.0}, ${28.0}');
  }

  drawPgBlock(Canvas canvas, Paint buildingPaint) {
    canvas.drawRect(
        Rect.fromLTRB(0.0 * zoom, 0.0 * zoom, 25.0 * zoom, 21.0 * zoom),
        buildingPaint);

    canvas.drawRect(
        Rect.fromLTRB(8.0 * zoom, 30.0 * zoom, 74.0 * zoom, 42.0 * zoom),
        buildingPaint);
    canvas.drawRect(
        Rect.fromLTRB(25.0 * zoom, 6.0 * zoom, 32.0 * zoom, 30.0 * zoom),
        buildingPaint);
    canvas.drawRect(
        Rect.fromLTRB(32.0 * zoom, 0.0 * zoom, 68.0 * zoom, 21.0 * zoom),
        buildingPaint);
    canvas.drawRect(
        Rect.fromLTRB(74.0 * zoom, 0.0 * zoom, 88.0 * zoom, 30.0 * zoom),
        buildingPaint);
    canvas.drawRect(
        Rect.fromLTRB(68.0 * zoom, 6.0 * zoom, 74 * zoom, 30.0 * zoom),
        buildingPaint);
    var path = Path()
      ..moveTo(8.0 * zoom, 42.0 * zoom)
      ..lineTo(74.0 * zoom, 42.0 * zoom)
      ..lineTo(74.0 * zoom, 42.1 * zoom)
      ..lineTo(8.0 * zoom, 42.1 * zoom)
      ..moveTo(74.0 * zoom, 42.0 * zoom)
      ..lineTo(74.0 * zoom, 30.0 * zoom)
      ..lineTo(74.1 * zoom, 30.0 * zoom)
      ..lineTo(74.1 * zoom, 42.0 * zoom)
      ..lineTo(74.0 * zoom, 42.0 * zoom)
      ..moveTo(74.0 * zoom, 30.0 * zoom)
      ..lineTo(88.0 * zoom, 30.0 * zoom)
      ..lineTo(88.0 * zoom, 30.1 * zoom)
      ..lineTo(74.0 * zoom, 30.1 * zoom)
      ..moveTo(88.0 * zoom, 30.0 * zoom)
      ..lineTo(88.0 * zoom, 0.0 * zoom)
      ..lineTo(88.1 * zoom, 0.0 * zoom)
      ..lineTo(88.1 * zoom, 30.0 * zoom)
      ..moveTo(68 * zoom, 0 * zoom)
      ..lineTo(68.1 * zoom, 0 * zoom)
      ..lineTo(68.1 * zoom, 6 * zoom)
      ..lineTo(68 * zoom, 6 * zoom)
      ..moveTo(32 * zoom, 21 * zoom)
      ..lineTo(32 * zoom, 21.1 * zoom)
      ..lineTo(68 * zoom, 21.1 * zoom)
      ..lineTo(68 * zoom, 21 * zoom)
      ..moveTo(32 * zoom, 21 * zoom)
      ..lineTo(32.1 * zoom, 21 * zoom)
      ..lineTo(32.1 * zoom, 30 * zoom)
      ..lineTo(32 * zoom, 30 * zoom)
      ..moveTo(25 * zoom, 0 * zoom)
      ..lineTo(25.1 * zoom, 0 * zoom)
      ..lineTo(25.1 * zoom, 6 * zoom)
      ..lineTo(25 * zoom, 6 * zoom)
      ..moveTo(0 * zoom, 21 * zoom)
      ..lineTo(0 * zoom, 21.1 * zoom)
      ..lineTo(25 * zoom, 21.1 * zoom)
      ..lineTo(25 * zoom, 21 * zoom);
    canvas.drawShadow(path, Colors.red, 1.0, false);
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      // Annotate a rectangle containing the picture of the sun
      // with the label "Sun". When text to speech feature is enabled on the
      // device, a user will be able to locate the sun on this picture by
      // touch.
      var rect = Offset.zero & size;
      var width = size.shortestSide * 0.4;
      rect = const Alignment(0.8, -0.9).inscribe(new Size(width, width), rect);
      return [
        new CustomPainterSemantics(
          rect: rect,
          properties: new SemanticsProperties(
            label: 'Sun',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
  }

  // Since this Sky painter has no fields, it always paints
  // the same thing and semantics information is the same.
  // Therefore we return false here. If we had fields (set
  // from the constructor) then we would return true if any
  // of them differed from the same fields on the oldDelegate.
  @override
  bool shouldRepaint(BlockPainter oldDelegate) => false;
  @override
  bool shouldRebuildSemantics(BlockPainter oldDelegate) => false;
}
