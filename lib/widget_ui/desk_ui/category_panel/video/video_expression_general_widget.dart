import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pieces_ai/app/navigation/mobile/theme/theme.dart';

var logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

///生视频组件
class VideoExpressionGeneralPanel extends StatefulWidget {
  final String sourceUrl;
  final Function(String expressionName, bool image2Video) onExpressionSelected;

  VideoExpressionGeneralPanel({
    required this.sourceUrl,
    required this.onExpressionSelected,
  });

  @override
  State<VideoExpressionGeneralPanel> createState() {
    return _VideoExpressionGeneralPanelState();
  }
}

class _VideoExpressionGeneralPanelState
    extends State<VideoExpressionGeneralPanel>
    with AutomaticKeepAliveClientMixin {
  late String imageUrl;
  bool audio = false;
  int currentSelect = 0;

  ///是图片生成表情视频还是视频生成表情视频
  bool image2Video = true;
  final List<Expression> expressionList = [
    Expression(name: "Ai匹配", enName: "ai"),
    Expression(name: "笑", enName: "laugh"),
    Expression(name: "标准笑", enName: "laugh_normal"),
    Expression(name: "哭", enName: "cry"),
    Expression(name: "悲伤", enName: "sad"),
    Expression(name: "悲伤2", enName: "sad_02"),
    Expression(name: "惊吓", enName: "scared"),
    Expression(name: "惊喜", enName: "amazing"),
    Expression(name: "神曲忐忑", enName: "tante"),
  ];

  @override
  void initState() {
    imageUrl = widget.sourceUrl;
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildExpressionVideo();
  }

  /**
   * 普通生视频
   */
  Widget _buildExpressionVideo() {
    return Column(
      children: [
        _buildSelectImageOrVideo(),
        _buildSelectHaveAudio(),
        SizedBox(
          height: 5,
        ),
        Expanded(child: _buildExpressionPanel()),
      ],
    );
  }

  ///是否生成表情视频的同时也生成对应的音频
  Widget _buildSelectHaveAudio() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          '没有音频',
          style: TextStyle(fontSize: 10, color: AppColor.piecesBlue),
        ),
        Switch(
          value: audio,
          onChanged: (value) {
            setState(() {
              audio = value;
              _callBack(expressionList[currentSelect].enName, image2Video);
            });
          },
        ),
        Text(
          '生成音频',
          style: TextStyle(fontSize: 10, color: AppColor.piecesBlue),
        ),
      ],
    );
  }

  ///图片生成表情视频还是视频生成表情视频
  Widget _buildSelectImageOrVideo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text('选中图片生成', style: TextStyle(fontSize: 12)),
        Radio(
          value: true,
          groupValue: image2Video,
          onChanged: (value) {
            setState(() {
              image2Video = value ?? true;
              _callBack(expressionList[currentSelect].enName, image2Video);
            });
          },
        ),
        SizedBox(
          width: 25,
        ),
        Text('选中的视频生成', style: TextStyle(fontSize: 12)),
        Radio(
          value: false,
          groupValue: image2Video,
          onChanged: (value) {
            setState(() {
              image2Video = value ?? false;
              _callBack(expressionList[currentSelect].enName, image2Video);
            });
          },
        ),
      ],
    );
  }

  ///回调
  _callBack(String expressionName, bool image2Video) {
    expressionName = audio ? expressionName + ".mp4" : expressionName + ".pkl";
    widget.onExpressionSelected(expressionName, image2Video);
  }

  SliverGridDelegate gridDelegate =
      const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 5,
    crossAxisSpacing: 5,
    mainAxisSpacing: 5,
  );

  ///入场动画选择
  _buildExpressionPanel() {
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        // scrollDirection: Axis.horizontal,
        itemCount: expressionList.length,
        gridDelegate: gridDelegate,
        itemBuilder: (_, int index) =>
            _buildAnimSelectItem(index, expressionList[index]));
  }

  ///单个的item
  Widget _buildAnimSelectItem(int index, Expression expression) =>
      GestureDetector(
        onTap: () {
          setState(() {
            currentSelect = index;
          });
          _callBack(expressionList[currentSelect].enName, image2Video);
        },
        child: Padding(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: currentSelect == index
                        ? Color(0xFF12CDD9)
                        : Colors.grey,
                    width: 2, // 设置边框宽度
                  ),
                  // image: DecorationImage(
                  //   image: CachedNetworkImageProvider(icons[index]),
                  //   fit: BoxFit.fitWidth,
                  // ),
                ),
              ),
              Text(
                expression.name,
                maxLines: 1,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          padding: const EdgeInsets.only(left: 2, top: 2, right: 2),
        ),
      );
}

class Expression {
  final String name;
  final String enName;

  Expression({required this.name, required this.enName});
}
