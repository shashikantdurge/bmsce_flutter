import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const double _kOuterRadius = 16.0;
const double _kInnerRadius = 15.0;

class ColorRadioButton extends StatefulWidget {
  const ColorRadioButton(
      {Key key,
      @required this.color,
      @required this.groupColor,
      @required this.onChanged,
      this.activeColor})
      : super(key: key);

  /// The value represented by this radio button.
  final Color color;

  /// The currently selected value for this group of radio buttons.
  ///
  /// This radio button is considered selected if its [color] matches the
  /// [groupColor].
  final Color groupColor;

  /// Called when the user selects this radio button.
  ///
  /// The radio button passes [color] as a parameter to this callback. The radio
  /// button does not actually change state until the parent widget rebuilds the
  /// radio button with the new [groupColor].
  ///
  /// If null, the radio button will be displayed as disabled.
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt; for example:
  ///
  /// ```dart
  /// new Radio<SingingCharacter>(
  ///   value: SingingCharacter.lafayette,
  ///   groupValue: _character,
  ///   onChanged: (SingingCharacter newValue) {
  ///     setState(() {
  ///       _character = newValue;
  ///     });
  ///   },
  /// )
  /// ```
  final ValueChanged<Color> onChanged;

  /// The color to use when this radio button is selected.
  ///
  /// Defaults to [ThemeData.toggleableActiveColor].
  final Color activeColor;

  @override
  _RadioState<Color> createState() =>
      new _RadioState<Color>(myRadioColor: color);
}

class _RadioState<T> extends State<ColorRadioButton>
    with TickerProviderStateMixin {
  _RadioState({this.myRadioColor});

  bool get _enabled => widget.onChanged != null;
  final Color myRadioColor;
  Color _getInactiveColor(ThemeData themeData) {
    return _enabled ? themeData.unselectedWidgetColor : themeData.disabledColor;
  }

  void _handleChanged(bool selected) {
    if (selected) widget.onChanged(widget.color);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData themeData = Theme.of(context);
    return new _RadioRenderObjectWidget(
      selected: widget.color == widget.groupColor,
      activeColor: myRadioColor,
      inactiveColor: _getInactiveColor(themeData),
      onChanged: _enabled ? _handleChanged : null,
      vsync: this,
    );
  }
}

class _RadioRenderObjectWidget extends LeafRenderObjectWidget {
  const _RadioRenderObjectWidget({
    Key key,
    @required this.selected,
    @required this.activeColor,
    @required this.inactiveColor,
    this.myRadioColor,
    this.onChanged,
    @required this.vsync,
  })  : assert(selected != null),
        assert(activeColor != null),
        assert(inactiveColor != null),
        assert(vsync != null),
        super(key: key);

  final bool selected;
  final Color inactiveColor;
  final Color activeColor;
  final ValueChanged<bool> onChanged;
  final TickerProvider vsync;
  final Color myRadioColor;

  @override
  _RenderRadio createRenderObject(BuildContext context) => new _RenderRadio(
        value: selected,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        onChanged: onChanged,
        vsync: vsync,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderRadio renderObject) {
    renderObject
      ..value = selected
      ..activeColor = activeColor
      ..inactiveColor = inactiveColor
      ..onChanged = onChanged
      ..vsync = vsync;
  }
}

class _RenderRadio extends RenderToggleable {
  _RenderRadio({
    bool value,
    Color activeColor,
    Color inactiveColor,
    ValueChanged<bool> onChanged,
    Color myRadioColor,
    @required TickerProvider vsync,
  }) : super(
          value: value,
          tristate: false,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          onChanged: onChanged,
          additionalConstraints: BoxConstraints.tight(const Size(
              1.4 * kRadialReactionRadius, 1.4 * kRadialReactionRadius)),
          vsync: vsync,
        );

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    paintRadialReaction(canvas, offset,
        const Offset(kRadialReactionRadius, kRadialReactionRadius));

    final Offset center = (offset & size).center;
    final Color radioColor = onChanged != null ? activeColor : inactiveColor;

    // Outer circle
    final Paint paint = new Paint()
      ..color = Color.lerp(radioColor, radioColor, position.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, _kOuterRadius, paint);

    // Inner circle
    if (!position.isDismissed) {
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(center, _kInnerRadius * position.value, paint);
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isInMutuallyExclusiveGroup = true;
  }
}
