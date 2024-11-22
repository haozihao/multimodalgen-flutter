import 'package:app/app.dart';
import 'package:flutter/material.dart';
import 'package:pieces_ai/app/model/ai_draft.dart';
import 'package:utils/utils.dart';

/// 说明:新建草稿弹框
class NewDraftDialog extends StatelessWidget {
  final int type;
  final String? originalContent;

  const NewDraftDialog({Key? key, required this.type, this.originalContent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildSimpleDialog(context),
      ],
    );
  }

  SimpleDialog _buildSimpleDialog(BuildContext context) {
    return SimpleDialog(
      title: _buildTitle(),
      titlePadding: const EdgeInsets.only(top: 15, left: 10, bottom: 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
      children: [_buildChild(context, type, originalContent)],
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      elevation: 4,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
    );
  }

  CustomTextField _buildChild(
      BuildContext context, int type, String? originalContent) {
    return CustomTextField(
      type: type,
      originalContent: originalContent ?? "",
    );
  }

  Widget _buildTitle() {
    return Row(
      //标题
      children: <Widget>[
        Image.asset(
          "assets/images/ic_launcher.png",
          width: 30,
          height: 30,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          type == 3 ? "追爆款模式：" : "一键原创模式",
          style: TextStyle(color: Color(0xff999999), fontSize: 16),
        ),
      ],
    );
  }
}

class CustomTextField extends StatefulWidget {
  final int type;
  final String originalContent;

  const CustomTextField(
      {Key? key, required this.type, required this.originalContent})
      : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    // 焦点设置在文本框上
    _focusNode.requestFocus();
  }

  String getTextFieldValue() {
    return _controller.text;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.blue),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '作品名',
              ),
              // onEditingComplete: () {
              //   print('onEditingComplete');
              // },
              onSubmitted: (v) {
                // 获取TextField中的内容
                String textFieldContent = _controller.text;
                Navigator.of(context).pop();
                // 获取 CustomTextField 的文本值
                print("onSubmitted 跳转到编辑页" + textFieldContent.toString());
                _toSecondPage(widget.type, textFieldContent);
                _controller.clear();
              },
            ),
            flex: 1),
        const SizedBox(height: 12),
        Flexible(
          child: SizedBox(
            child: ElevatedButton(
                onPressed: () {
                  // 获取TextField中的内容
                  String textFieldContent = _controller.text;
                  if (textFieldContent.isEmpty) {
                    Toast.warning(context, '输入作品名!');
                  } else {
                    Navigator.of(context).pop();
                    // 获取 CustomTextField 的文本值
                    print("_toDetail 跳转到编辑页" + textFieldContent.toString());
                    _toSecondPage(widget.type, textFieldContent);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF12CDD9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // 设置圆角半径为5像素
                  ),
                ),
                child: const Text(
                  textAlign: TextAlign.center,
                  "提交",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                )),
            width: 120,
            height: 40,
          ),
          flex: 1,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  _toSecondPage(int type, String textFieldContent) {
    DraftRender draft = DraftRender(
        draftVersion: DraftRender.CURRENT_DRAFT_VERSION,
        name: textFieldContent,
        status: -1,
        type: widget.type);
    draft.originalContent = widget.originalContent;
    Navigator.pushNamed(context, UnitRouter.ai_style_edit, arguments: draft);
  }
}
