import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

class ReplaceText extends StatelessWidget {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _targetTextEditingController =
      TextEditingController();
  final Function(String targetText, String originalText) onReplace;

  ReplaceText({super.key, required this.onReplace});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        // Flexible(
        //   child: Text(
        //     "替换原文",
        //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        //   ),
        //   flex: 1,
        // ),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              // mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "查找 |   ",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: TextField(
                    controller: _textEditingController,
                    maxLines: 1, // 设置为null，表示自适应行数
                    // focusNode: _focusNode, // 将创建的焦点传递给TextField
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      hintText: '请输入要替换的关键词',
                      hintStyle: TextStyle(fontSize: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  flex: 4,
                )
              ],
            ),
          ),
          flex: 3,
        ),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "替换为 |",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: TextField(
                    controller: _targetTextEditingController,
                    maxLines: 1, // 设置为null，表示自适应行数
                    // focusNode: _focusNode, // 将创建的焦点传递给TextField
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      hintText: '请输入目标关键词（不输入则表示替换为空）',
                      hintStyle: TextStyle(fontSize: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  flex: 4,
                )
              ],
            ),
          ),
          flex: 2,
        ),
        Spacer(),
        Flexible(
          child: SizedBox(
            child: ElevatedButton(
              onPressed: () {
                String originalText = _textEditingController.text;
                if (originalText.isEmpty) {
                  MotionToast.info(description: Text("请输入要替换的关键词"))
                      .show(context);
                  return;
                }
                String targetText = _targetTextEditingController.text;
                Navigator.of(context).pop();
                onReplace.call(targetText, originalText);
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFF12CDD9)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // 设置圆角
                  ),
                ),
              ),
              child: Text(
                "确定",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            width: 140,
            height: 45,
          ),
          flex: 1,
        )
      ],
    );
  }
}
