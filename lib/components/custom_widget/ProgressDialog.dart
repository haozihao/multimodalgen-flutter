import 'package:flutter/material.dart';

class ProgressDialog {
  final BuildContext context;
  BuildContext? dialogContext;
  double _progress = 0.0;
  bool _isShowing = false;
  StateSetter? mCustomState;

  ProgressDialog(this.context, this._progress);

  void show(){
    _isShowing = true;
    showDialog<void>(
      useSafeArea: false,
      // 设置点击空白处不会隐藏对话框
      useRootNavigator: false,
      // 确保对话框不会响应根导航器的弹出和关闭
      barrierDismissible: false,
      // 设置点击屏障（对话框外的区域）不会关闭对话框
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (mDialogContext, customState) {
          mCustomState = customState;
          dialogContext = mDialogContext;
          return AlertDialog(
            title: Stack(
              children: [
                Center(
                  child: const Text('生成中...'),
                ),
                Positioned(
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                  right: 0,
                  top: 0,
                )
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                LinearProgressIndicator(value: _progress),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text('${(_progress * 100).toStringAsFixed(0)}%'),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void updateProgress(double progress) {
    if (_isShowing && null != mCustomState) {
      (mCustomState!)(() {
        _progress = progress;
      });
    }
  }

  void hide() {
    if (dialogContext != null && _isShowing) {
      Navigator.of(dialogContext!).pop();
    }
    _isShowing = false;
  }
}
