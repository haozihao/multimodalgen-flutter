import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowButtons extends StatefulWidget {
  final List<Widget>? actions;
  final Function()? onSaveDraft;
  const WindowButtons({Key? key,  this.actions, this.onSaveDraft}) : super(key: key);

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    return  Align(
      alignment:Alignment.topRight,child:  Wrap(
        spacing: 5,
        children: [
          if(widget.actions!=null)
            ...widget.actions!,
          SizedBox(
            width: 30,
            height: 30,
            child: WindowCaptionButton.minimize(
              brightness:brightness,
              onPressed: () async {
                bool isMinimized = await windowManager.isMinimized();
                if (isMinimized) {
                  windowManager.restore();
                } else {
                  windowManager.minimize();
                }
              },
            ),
          ),
          SizedBox(
            width: 30,
            height: 30,
            child: FutureBuilder<bool>(
              future: windowManager.isMaximized(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.data == true) {
                  return WindowCaptionButton.unmaximize(
                    brightness: brightness,
                    onPressed: () async{
                      await windowManager.unmaximize();
                      setState(() {

                      });
                    },
                  );
                }
                return WindowCaptionButton.maximize(
                  brightness: brightness,
                  onPressed: () async{
                    await windowManager.maximize();
                    setState(() {

                    });
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: 30,
            width: 30,
            child: WindowCaptionButton.close(
              brightness: brightness,
              onPressed: () {
                if (widget.onSaveDraft != null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('是否保存草稿？'),
                        content: const Text('点击确定保存草稿并退出'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () async {
                              widget.onSaveDraft!.call();
                            },
                            child: const Text('确认'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  windowManager.close();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
