import 'package:components/toly_ui/toly_ui.dart';
import 'package:flutter/material.dart';

/// create by blueming.wu
///可以调节一键原创各种全局数值的调节板
class GlobalOptionPanel extends StatefulWidget {
  final String title;
  final String content;
  final double motionStrength;
  final Function(double motionStrength)? onSubmit;

  const GlobalOptionPanel({
    Key? key,
    this.title = '',
    this.content = '',
    this.onSubmit, required this.motionStrength,
  }) : super(key: key);

  @override
  State<GlobalOptionPanel> createState() => _GlobalOptionPanelState();
}

class _GlobalOptionPanelState extends State<GlobalOptionPanel> {
  double motionStrength = 50;
  bool allItem = true;

  @override
  void initState() {
    motionStrength = widget.motionStrength;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildBar(context),
        _buildTitle(context),
        _buildContent(),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Circle(
                color: Color(0xFF12CDD9),
                radius: 7,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  "生视频调节",
                  style: TextStyle(fontSize: 15),
                ),
              )
            ],
          ),
          Row(
            children: [
              Text(
                "运动系数：",
                style: TextStyle(fontSize: 15),
              ),
              Slider(
                value: motionStrength,
                min: 1,
                max: 255,
                // divisions: 20,
                label: motionStrength.toStringAsFixed(0),
                activeColor: Color(0xFF12CDD9),
                inactiveColor: Colors.green.withAlpha(99),
                onChanged: (value) {
                  setState(() {
                    motionStrength = value;
                  });
                },
                onChangeEnd: (value) {
                  debugPrint("滑动结束:" + motionStrength.toStringAsFixed(1));
                },
              ),
              Text(
                motionStrength.toStringAsFixed(0),
                style: TextStyle(color: Color(0xFF12CDD9)),
              ),
            ],
          ),
          // Row(
          //   children: [
          //     Checkbox(
          //       value: allItem,
          //       onChanged: (bool? value) {
          //         setState(() {
          //           allItem = value!;
          //         });
          //       },
          //     ),
          //     Text("应用至所有配图"),
          //   ],
          // ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              widget.content,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.justify,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFooter(context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 15.0, top: 10, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          InkWell(
            onTap: () async {
              widget.onSubmit?.call(motionStrength);
              Navigator.of(context).pop();
            },
            child: Container(
              alignment: Alignment.center,
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  color: Theme.of(context).primaryColor),
              child: const Text('确 定',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              alignment: Alignment.center,
              height: 40,
              width: 100,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  color: Colors.orangeAccent),
              child: const Text('取 消',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  _buildBar(context) => Row(
        children: <Widget>[
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 30,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 10, top: 5),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      );
}
