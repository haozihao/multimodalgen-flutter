import 'package:flutter/material.dart';

class NumChangeWidget extends StatefulWidget {
  final double height;
  final ValueChanged<double> onValueChanged;
  final bool disabled;

  NumChangeWidget(
      {Key? key,
      this.height = 36.0,
      this.disabled = false,
      required this.onValueChanged})
      : super(key: key);

  @override
  _NumChangeWidgetState createState() {
    return _NumChangeWidgetState();
  }
}

class _NumChangeWidgetState extends State<NumChangeWidget> {
  TextEditingController _numcontroller = TextEditingController();
  double num = 0.6;

  @override
  void initState() {
    super.initState();
    _numcontroller.addListener(_onNumChange);
  }

  void _onNumChange() {
    String text = _numcontroller.text;
    if (text.isNotEmpty) {
      String result = text.replaceAll(RegExp(r'^[0]+'), ''); // 去掉首位0的正则替换
      if (result != '') {
        num = double.parse(result);
        widget.onValueChanged(num);
      }
      if (result != text) {
        _numcontroller.selection =
            TextSelection.fromPosition(TextPosition(offset: result.length));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _numcontroller.text = num.toStringAsFixed(1);

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
          color: Color(0x1FFFFFFF)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: _minusNum,
            child: Container(
              width: 32.0,
              alignment: Alignment.center,
              child: Icon(Icons.horizontal_rule_outlined,
                  color: num == 0 || widget.disabled
                      ? Color.fromRGBO(255, 255, 255, .4)
                      : Colors.white),
            ),
          ),
          Container(
            width: 0.5,
            color: Colors.black54,
          ),
          Container(
            width: 62.0,
            alignment: Alignment.center,
            child: TextField(
              controller: _numcontroller,
              // TextEditingController, used to get the text value
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              // Set keyboard to accept decimal numbers
              textAlign: TextAlign.center,
              // Center align content
              maxLines: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 10),
              ),
              // inputFormatters: [
              //   FilteringTextInputFormatter.allow(
              //       RegExp(r'^0(\.\d{0,2})?$|^1(\.0{0,2})?$')),
              //   // Allow only numbers between 0 and 1 with up to 2 decimal places
              // ],
              style: TextStyle(fontSize: 16, color: Colors.white),
              readOnly: widget.disabled,
            ),
          ),
          Container(
            width: 0.5,
            color: Colors.black54,
          ),
          GestureDetector(
            onTap: _addNum,
            child: Container(
              width: 32.0,
              alignment: Alignment.center,
              child: Icon(
                Icons.add_outlined,
                color: widget.disabled
                    ? const Color.fromRGBO(255, 255, 255, .4)
                    : Colors.white,
              ), // 设计图
            ),
          ),
        ],
      ),
    );
  }

  void _minusNum() {
    if (num == 0.1 || widget.disabled) {
      return;
    }

    setState(() {
      num -= 0.1;

      widget.onValueChanged(num);
    });
  }

  void _addNum() {
    if (num >= 1 || widget.disabled) {
      return;
    }
    setState(() {
      num += 0.1;

      widget.onValueChanged(num);
    });
  }
}
