import 'dart:async';

import 'package:flutter/material.dart';

class NumberPicker<T extends num> extends StatefulWidget {
  final ShapeBorder? shape;
  final TextStyle? valueTextStyle;
  final void Function(T value) onValue;
  final Widget? customAddButton;
  final Widget? customMinusButton;
  // final AnimationController? animController;
  // final Animation<double>? animation;
  final T maxValue;
  final T minValue;
  final T initialValue;
  final T Function(T value) stepper;

  // final

  ///default vale true
  final bool enable;
  // final bool hideWhenDisabled;
  // final bool animateShowHide;

  NumberPicker({
    Key? key,
    this.shape,
    this.valueTextStyle,
    required this.onValue,
    required this.initialValue,
    required this.maxValue,
    required this.minValue,
    required this.stepper,
    this.customAddButton,
    this.customMinusButton,
    this.enable = true,
    // this.hideWhenDisabled = true,
    // this.animateShowHide = true,
    // this.animController,
    // this.animation
  })  : assert(initialValue.runtimeType != String),
        assert(maxValue.runtimeType == initialValue.runtimeType),
        assert(minValue.runtimeType == initialValue.runtimeType),
        super(key: key);

  NumberPicker.consistent({
    Key? key,
    ShapeBorder? shape,
    TextStyle? valueTextStyle,
    required void Function(T value) onValue,
    required T initialValue,
    required T maxValue,
    required T minValue,
    required T step,
    Widget? customAddButton,
    Widget? customMinusButton,
    bool enable = true,
    // bool hideWhenDisabled = true,
    // bool animateShowHide = true,
    // AnimationController? animController,
    // Animation<double>? animation
  }) : this(
            key: key,
            shape: shape,
            valueTextStyle: valueTextStyle,
            onValue: onValue,
            initialValue: initialValue,
            maxValue: maxValue,
            minValue: minValue,
            customAddButton: customAddButton,
            customMinusButton: customMinusButton,
            enable: enable,
            // hideWhenDisabled: hideWhenDisabled,
            // animateShowHide: animateShowHide,
            // animController: animController,
            // animation: animation,
            stepper: (_) => step);

  @override
  State<StatefulWidget> createState() {
    return NumberPickerState<T>();
  }
}

class NumberPickerState<T extends num> extends State<NumberPicker<T>> with TickerProviderStateMixin {
  late T _initialValue = widget.initialValue;
  late T _maxValue = widget.maxValue;
  late T _minValue = widget.minValue;
  late T Function(T value) _stepper = widget.stepper;
  Timer? _timer;
  /*late final AnimationController? _controller = widget.animController ??
      (widget.animateShowHide
          ? AnimationController(
              duration: const Duration(seconds: 3),
              vsync: this,
            )
          : null);
  late final Animation<double>? _animation = widget.animation ??
      (widget.animateShowHide
          ? CurvedAnimation(parent: _controller!, curve: Curves.fastOutSlowIn, reverseCurve: Curves.fastOutSlowIn)
          : null);*/

  @override
  void initState() {
    super.initState();
    // _initialValue = widget.initialValue;
    // _maxValue = widget.maxValue;
    // _minValue = widget.minValue;
    // _stepper = widget.step;
  }

  @override
  void dispose() {
    // _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        ignoring: !widget.enable,
        child: /*widget.animateShowHide
            ? SizeTransition(
                sizeFactor: _animation!,
                axis: Axis.horizontal,
                axisAlignment: -1.0,
                child: _mainLayout(context),
              )
            : */
            _mainLayout(context));
  }

  Widget _mainLayout(BuildContext context) => Card(
        shadowColor: Colors.transparent,
        elevation: 0.0,
        semanticContainer: true,
        color: Colors.transparent,
        shape: widget.shape ??
            RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0.0)),
                side: BorderSide(width: 1.0, color: Color(0xffF0F0F0))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: minus,
              /*onTapDown: (details) {
                onLongPress(DoAction.MINUS);
              },
              onTapCancel: () {
                _timer?.cancel();
              },*/
              child: widget.customMinusButton ??
                  Padding(
                    padding: EdgeInsets.only(left: 6, right: 6, bottom: 6, top: 6),
                    child: Icon(
                      Icons.remove,
                      size: 15,
                    ),
                  ),
            ),
            Container(
              width: _textSize(widget.valueTextStyle ?? TextStyle(fontSize: 14)).width,
              child: Text(
                "$_initialValue",
                style: widget.valueTextStyle ?? TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            InkWell(
              onTap: add,
              /*onTapDown: (details) {
                onLongPress(DoAction.ADD);
              },
              onTapCancel: () {
                _timer?.cancel();
              },*/
              child: widget.customAddButton ??
                  Padding(
                    padding: EdgeInsets.only(left: 6, right: 6, bottom: 6, top: 6),
                    child: Icon(Icons.add, size: 15),
                  ),
            )
          ],
        ),
      );

  Size _textSize(TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: _maxValue.toString(), style: style), maxLines: 1, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: _maxValue.toString().length * style.fontSize!);
    return textPainter.size;
  }

  void minus() {
    _timer?.cancel();
    if (canDoAction(DoAction.MINUS)) {
      setState(() {
        _initialValue = (_initialValue - _stepper(_initialValue)) as T;
      });
    }
    widget.onValue(_initialValue);
  }

  void add() {
    _timer?.cancel();
    if (canDoAction(DoAction.ADD)) {
      setState(() {
        _initialValue = (_initialValue + _stepper(_initialValue)) as T;
      });
    }
    widget.onValue(_initialValue);
  }

  void onLongPress(DoAction action) {
    var timer = Timer.periodic(Duration(milliseconds: 300), (t) {
      action == DoAction.MINUS ? minus() : add();
    });
    setState(() {
      _timer = timer;
    });
  }

  bool canDoAction(DoAction action) {
    if (action == DoAction.MINUS) {
      return _initialValue - _stepper(_initialValue) >= _minValue;
    }
    if (action == DoAction.ADD) {
      return _initialValue + _stepper(_initialValue) <= _maxValue;
    }
    return false;
  }
}

enum DoAction { MINUS, ADD }
