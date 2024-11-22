import 'package:flutter/material.dart';

class NumberInputWidget extends StatefulWidget {
  final int initValue;
  final Function(int value) onValueChanged;

  const NumberInputWidget(
      {super.key, required this.initValue, required this.onValueChanged});

  @override
  _NumberInputWidgetState createState() => _NumberInputWidgetState();
}

class _NumberInputWidgetState extends State<NumberInputWidget> {
  final TextEditingController _controller = TextEditingController();
  int _currentValue = 1;
  int maxValue = 30;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initValue;
    _controller.text = _currentValue.toString();
  }

  ///加大
  void _increment() {
    setState(() {
      if (_currentValue < maxValue) {
        _currentValue++;
        _controller.text = _currentValue.toString();
        widget.onValueChanged.call(_currentValue);
      }
    });
  }

  void _decrement() {
    setState(() {
      if (_currentValue > 1) {
        _currentValue--;
        _controller.text = _currentValue.toString();
        widget.onValueChanged.call(_currentValue);
      }
    });
  }

  void _onChanged(String value) {
    int? newValue = int.tryParse(value);
    if (newValue != null && newValue >= 1 && newValue <= maxValue) {
      setState(() {
        _currentValue = newValue;
      });
      widget.onValueChanged.call(_currentValue);
    } else {
      // 如果输入无效或超出范围，恢复当前值
      _controller.text = _currentValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 50,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: _onChanged,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(
          width: 10,),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _increment,
              child: const Icon(Icons.arrow_drop_up),
            ),
            InkWell(
              onTap: _decrement,
              child: const Icon(Icons.arrow_drop_down),
            ),
          ],
        ),
      ],
    );
  }
}
