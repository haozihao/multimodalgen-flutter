import 'package:flutter/material.dart';

/// create by bluemingwu
/// 添加关键词

enum EditType { add, update }

class EditKeyWordsPanel extends StatefulWidget {
  final EditType type;
  final int index;
  final String? hint;
  final String? words;
  final Function(int, String, EditType, bool) onEditCallback;

  const EditKeyWordsPanel(
      {Key? key,
        this.type = EditType.add,
        required this.onEditCallback,
        required this.index,
        this.hint,
        this.words})
      : super(key: key);

  @override
  _EditCategoryPanelState createState() => _EditCategoryPanelState();
}

class _EditCategoryPanelState extends State<EditKeyWordsPanel> {
  String name = '';
  bool modify = false;
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showClearButton = false;

  @override
  void initState() {
    name = widget.words ?? "";
    _textEditingController.text = name;
    _textEditingController.addListener(() {
      setState(() {
        _showClearButton = _textEditingController.text.isNotEmpty;
      });
    });
    // 焦点设置在文本框上
    _focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: TextField(
            controller: _textEditingController,
            focusNode: _focusNode, // 将创建的焦点传递给TextField
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              hintText: widget.hint ?? '中文需主页左下角设置翻译KEY',
              border: OutlineInputBorder(),
              suffixIcon: _showClearButton
                  ? IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  _doEdit(_textEditingController.text);
                },
              )
                  : null,
            ),
            onSubmitted: _doEdit,

          ),
        ),
      ],
    );
  }

  void _doEdit(String str) {
    name = _textEditingController.text;
    if (name.isNotEmpty) {
      if (widget.type == EditType.add) {
        widget.onEditCallback.call(widget.index, str, widget.type, modify);
      } else if (widget.type == EditType.update) {
        widget.onEditCallback.call(widget.index, str, widget.type, modify);
      }
    }
    Navigator.of(context).pop();
  }
}
