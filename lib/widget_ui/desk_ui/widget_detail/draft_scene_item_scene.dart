import 'package:flutter/material.dart';
import 'package:pieces_ai/app/model/config/ai_analyse_role_scene.dart';

///分句编辑页的场景选择控件
class SceneRadioListTile extends StatefulWidget {
  final List<Scene> scenes;
  final List<int> historySelect;
  final Function(Scene) onSelected;

  const SceneRadioListTile(
      {Key? key,
      required this.scenes,
      required this.onSelected,
      required this.historySelect})
      : super(key: key);

  @override
  _SceneRadioListTileState createState() => _SceneRadioListTileState();
}

class _SceneRadioListTileState extends State<SceneRadioListTile> {
  String selectSceneName = "";

  @override
  void initState() {
    if (widget.historySelect.isNotEmpty) {
      selectSceneName = widget.scenes[widget.historySelect[0]].name;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        children: widget.scenes.map((scene) {
          return GestureDetector(
            onTap: () {
              widget.onSelected.call(scene);
              setState(() {
                selectSceneName = scene.name;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 0.8, // 调整这个值来改变 Radio 的大小
                    child: Radio<String>(
                      value: scene.name,
                      groupValue: selectSceneName,
                      onChanged: (String? value) {
                        widget.onSelected.call(scene);
                        setState(() {
                          selectSceneName = scene.name;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Text(
                      scene.name,
                      style: TextStyle(
                        fontSize: 10,
                        color: selectSceneName == scene.name
                            ? Colors.orangeAccent
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
