import 'package:cached_network_image/cached_network_image.dart';
import 'package:components/toly_ui/ti/circle.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:pieces_ai/app/model/config/ai_tts_style.dart';

var logger = Logger(printer: PrettyPrinter());

/// create by blueming.wu
/// Ai推文音色选择专用widget
GlobalKey<_StyleGridViewState> ttsStyleKey = GlobalKey();

class TtsStylesGridView extends StatefulWidget {
  const TtsStylesGridView(
      {Key? key,
      required this.aiTtsStyleList,
      required this.aiTtsModelChanged,
      required this.initSpeed,
      required this.onTtsOpen,
      required this.draftType,
      required this.selectType,
      this.ttsEnable,
      this.openSwitch,
      required this.player,
      this.crossAxisCount = 5})
      : super(key: key);

  final List<AiTtsStyle> aiTtsStyleList;
  final Function(AiTtsStyle, double) aiTtsModelChanged;
  final Function(bool) onTtsOpen;
  final AudioPlayer player;
  final int draftType;
  final double initSpeed;
  final String selectType;
  final bool? ttsEnable;
  final bool? openSwitch;
  final int crossAxisCount;

  @override
  _StyleGridViewState createState() => _StyleGridViewState();
}

class _StyleGridViewState extends State<TtsStylesGridView> {
  int selectedIndex = 0; //默认选中第一个风格
  late final AudioPlayer player;

  //语速调节时使用的初始值
  double _speed = 1.5;
  bool ttsEnable = true;

  //试听时是否开启语速调节
  bool openSwitch = true;

  @override
  void initState() {
    super.initState();
    ttsEnable = widget.ttsEnable ?? true;
    openSwitch = widget.openSwitch ?? true;
    for (int i = 0; i < widget.aiTtsStyleList.length; i++) {
      if (widget.aiTtsStyleList[i].type == widget.selectType) {
        selectedIndex = i;
        break;
      }
    }
    _speed = widget.initSpeed;
    // widget.aiTtsModelChanged(widget.aiTtsStyleList[selectedIndex], _speed);
    player = widget.player;
    player.setSpeed(_speed);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List<Widget> widgets = [];
    // widgets.add();

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildTitle(widget.aiTtsStyleList),
        const SizedBox(height: 16),
        if (ttsEnable)
          Expanded(
            child: _buildGridView(widget.aiTtsStyleList),
          ),
        // Spacer(),
        Row(
          children: [
            Circle(
              color: Color(0xFF12CDD9),
              radius: 5,
            ),
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: Text(
                "语速选择",
                style: TextStyle(fontSize: 12),
              ),
            )
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                child: Slider(
              value: _speed,
              min: 0.8,
              max: 2.0,
              // divisions: 20,
              label: _speed.toStringAsFixed(2),
              activeColor: Color(0xFF12CDD9),
              inactiveColor: Colors.green.withAlpha(99),
              onChanged: (value) {
                setState(() {
                  _speed = value;
                });
              },
              onChangeEnd: (value) {
                print("滑动结束:" + _speed.toStringAsFixed(1));
                widget.aiTtsModelChanged(
                    widget.aiTtsStyleList[selectedIndex], _speed);
                player.setSpeed(_speed);
                player.play();
              },
            )),
            Text(
              "x ${_speed.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      ],
    );
  }

  void setInputType(int type) {
    setState(() {
      ttsEnable = (type == 0 || type == 2);
    });
  }

  void setTtsEnable(bool enable) {
    setState(() {
      ttsEnable = enable;
    });
  }

  Widget _buildTitle(List<AiTtsStyle> aiTtsStyleList) {
    return Row(
      children: [
        Circle(
          color: Color(0xFF12CDD9),
          radius: 5,
        ),
        Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            "配音设置",
            style: TextStyle(fontSize: 12),
          ),
        ),
        if (openSwitch)
          Switch(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: ttsEnable,
              onChanged: (select) {
                setState(() {
                  ttsEnable = select;
                });
                widget.onTtsOpen.call(ttsEnable);
              }),
        if (openSwitch)
          Text(
            widget.draftType == 3 ? "(关闭后该作品使用原视频音频)" : "(关闭后该作品将使用上传音频配音)",
            style: TextStyle(fontSize: 10),
          )
      ],
    );
  }

  Widget _buildGridView(List<AiTtsStyle> aiTtsStyleList) => GridView.count(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: 3 / 4,
        children: List.generate(
          aiTtsStyleList.length,
          (index) => _buildItem(aiTtsStyleList[index].name,
              aiTtsStyleList[index].icon, index, aiTtsStyleList[index]),
        ),
      );

  Container _buildItem(
          String title, String imageUrl, int index, AiTtsStyle aiTtsStyle) =>
      Container(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () async {
            widget.aiTtsModelChanged(aiTtsStyle, _speed);
            logger.d("选中音色的url地址:" + aiTtsStyle.toJson().toString());
            setState(() {
              selectedIndex = index;
            });
            await player.setUrl(aiTtsStyle.url);
            await player.play();
          },
          child: Column(
            children: [
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedIndex == index
                          ? Color(0xFF12CDD9)
                          : Colors.transparent,
                      width: 2, // 设置边框宽度
                    ),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(imageUrl),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                flex: 4,
              ),
              const SizedBox(height: 5),
              Text(
                title,
                maxLines: 1,
                style: const TextStyle(color: Color(0xFFA6A6A6), fontSize: 10),
              ),
            ],
          ),
        ),
      );
}
