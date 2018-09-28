// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const double _kOuterRadius = 20.0;
const double _kInnerRadius = 4.5;

class FloorRadioButton<T> extends StatefulWidget {
  const FloorRadioButton({
    Key key,
    @required this.value,
    @required this.groupValue,
    @required this.onChanged,
    this.activeColor,
    this.materialTapTargetSize,
  }) : super(key: key);
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final Color activeColor;
  final MaterialTapTargetSize materialTapTargetSize;

  @override
  _RadioState<T> createState() => new _RadioState<T>();
}

class _RadioState<T> extends State<FloorRadioButton<T>>
    with TickerProviderStateMixin {
  bool get _enabled => widget.onChanged != null;

  Color _getInactiveColor(ThemeData themeData) {
    return _enabled ? themeData.unselectedWidgetColor : themeData.disabledColor;
  }

  void _handleChanged(bool selected) {
    if (selected) widget.onChanged(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData themeData = Theme.of(context);
    Size size;
    switch (widget.materialTapTargetSize ?? themeData.materialTapTargetSize) {
      case MaterialTapTargetSize.padded:
        size = const Size(
            2 * kRadialReactionRadius + 8.0, 2 * kRadialReactionRadius + 8.0);
        break;
      case MaterialTapTargetSize.shrinkWrap:
        size = const Size(2 * kRadialReactionRadius, 2 * kRadialReactionRadius);
        break;
    }
    final BoxConstraints additionalConstraints = new BoxConstraints.tight(size);
    return new _RadioRenderObjectWidget(
      selected: widget.value == widget.groupValue,
      activeColor: widget.activeColor ?? themeData.toggleableActiveColor,
      inactiveColor: _getInactiveColor(themeData),
      onChanged: _enabled ? _handleChanged : null,
      additionalConstraints: additionalConstraints,
      vsync: this,
      displayValue: widget.value,
    );
  }
}

class _RadioRenderObjectWidget<T> extends LeafRenderObjectWidget {
  const _RadioRenderObjectWidget(
      {Key key,
      @required this.selected,
      @required this.activeColor,
      @required this.inactiveColor,
      @required this.additionalConstraints,
      this.onChanged,
      @required this.vsync,
      @required this.displayValue})
      : assert(selected != null),
        assert(activeColor != null),
        assert(inactiveColor != null),
        assert(vsync != null),
        super(key: key);

  final T displayValue;
  final bool selected;
  final Color inactiveColor;
  final Color activeColor;
  final ValueChanged<bool> onChanged;
  final TickerProvider vsync;
  final BoxConstraints additionalConstraints;

  @override
  _RenderRadio createRenderObject(BuildContext context) => new _RenderRadio(
      value: selected,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      onChanged: onChanged,
      vsync: vsync,
      additionalConstraints: additionalConstraints,
      displayValue: displayValue);

  @override
  void updateRenderObject(BuildContext context, _RenderRadio renderObject) {
    renderObject
      ..value = selected
      ..activeColor = activeColor
      ..inactiveColor = inactiveColor
      ..onChanged = onChanged
      ..additionalConstraints = additionalConstraints
      ..vsync = vsync
      ..displayValue = displayValue;
  }
}

class _RenderRadio<T> extends RenderToggleable {
  _RenderRadio(
      {bool value,
      Color activeColor,
      Color inactiveColor,
      ValueChanged<bool> onChanged,
      BoxConstraints additionalConstraints,
      @required TickerProvider vsync,
      this.displayValue})
      : super(
          value: value,
          tristate: false,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          onChanged: onChanged,
          additionalConstraints: additionalConstraints,
          vsync: vsync,
        );
  T displayValue;

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    paintRadialReaction(canvas, offset,
        const Offset(kRadialReactionRadius, kRadialReactionRadius));

    final Offset center = (offset & size).center;
    final Color radioColor = onChanged != null ? activeColor : inactiveColor;

    // Outer circle
    final Paint paint = new Paint()
      ..color = Color.lerp(inactiveColor, radioColor, position.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(
        Rect.fromCircle(center: center, radius: _kOuterRadius), paint);
    if (displayValue is String) {
      final val = displayValue as String;
      TextPainter textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(text: val, style: TextStyle(color: Colors.black)));
      textPainter
        ..layout(maxWidth: _kOuterRadius)
        ..paint(canvas, center);
    }

    // Inner circle
    if (!position.isDismissed) {
      paint.style = PaintingStyle.fill;
      canvas.drawRect(
          Rect.fromCircle(center: center, radius: _kOuterRadius), paint);
      if (displayValue is String) {
        final val = displayValue as String;
        TextPainter textPainter = TextPainter(
            textDirection: TextDirection.ltr,
            text: TextSpan(text: val, style: TextStyle(color: Colors.white)));
        textPainter
          ..layout(maxWidth: _kOuterRadius)
          ..paint(canvas, center);
      }
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..isInMutuallyExclusiveGroup = true
      ..isChecked = value == true;
  }
}
