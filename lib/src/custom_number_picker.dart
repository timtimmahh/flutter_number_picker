import 'dart:async';

import 'package:flutter/material.dart';

class NumberPicker<T extends num> extends StatefulWidget {
  final ShapeBorder? shape;
  final TextStyle? valueTextStyle;
  final void Function(T value) onValue;
  final Widget? customAddButton;
  final Widget? customMinusButton;
  final T maxValue;
  final T minValue;
  final T initialValue;
  final T step;

  ///default vale true
  final bool enable;

  NumberPicker(
      {Key? key,
      this.shape,
      this.valueTextStyle,
      required this.onValue,
      required this.initialValue,
      required this.maxValue,
      required this.minValue,
      required this.step,
      this.customAddButton,
      this.customMinusButton,
      this.enable = true})
      : assert(initialValue.runtimeType != String),
        assert(maxValue.runtimeType == initialValue.runtimeType),
        assert(minValue.runtimeType == initialValue.runtimeType),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NumberPickerState<T>();
  }
}

class NumberPickerState<T extends num> extends State<NumberPicker<T>> {
  late T _initialValue = widget.initialValue;
  late T _maxValue = widget.maxValue;
  late T _minValue = widget.minValue;
  late T _step = widget.step;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // _initialValue = widget.initialValue;
    // _maxValue = widget.maxValue;
    // _minValue = widget.minValue;
    // _step = widget.step;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.enable,
      child: Card(
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
                    padding:
                        EdgeInsets.only(left: 6, right: 6, bottom: 6, top: 6),
                    child: Icon(
                      Icons.remove,
                      size: 15,
                    ),
                  ),
            ),
            Container(
              width: _textSize(widget.valueTextStyle ?? TextStyle(fontSize: 14))
                  .width,
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
                    padding:
                        EdgeInsets.only(left: 6, right: 6, bottom: 6, top: 6),
                    child: Icon(Icons.add, size: 15),
                  ),
            )
          ],
        ),
      ),
    );
  }

  Size _textSize(TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: _maxValue.toString(), style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(
          minWidth: 0, maxWidth: _maxValue.toString().length * style.fontSize!);
    return textPainter.size;
  }

  void minus() {
    _timer?.cancel();
    if (canDoAction(DoAction.MINUS)) {
      setState(() {
        _initialValue = (_initialValue - _step) as T;
      });
    }
    widget.onValue(_initialValue);
  }

  void add() {
    _timer?.cancel();
    if (canDoAction(DoAction.ADD)) {
      setState(() {
        _initialValue = (_initialValue + _step) as T;
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
      return _initialValue - _step >= _minValue;
    }
    if (action == DoAction.ADD) {
      return _initialValue + _step <= _maxValue;
    }
    return false;
  }
}

enum DoAction { MINUS, ADD }
