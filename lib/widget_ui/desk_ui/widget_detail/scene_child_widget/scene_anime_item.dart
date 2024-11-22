import 'package:flutter/material.dart';
import 'package:pieces_ai/components/custom_widget/DropMenuWidget.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/scene_child_widget/anime_preview_panel.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/scene_child_widget/jy_anime_panel.dart';

import '../../../../app/model/TweetScript.dart';
import '../../../../app/model/config/ai_analyse_role_scene.dart';

///分镜组件的画面动画运动调整
class SceneAnimeItem extends StatefulWidget {
  final Function(int mediaType) selectMediaType;
  final TweetImage tweetImage;
  final Scene? scene;
  final int type;
  final int ratio;
  final int index;
  final bool localMode;

  SceneAnimeItem(
      {Key? key,
      required this.tweetImage,
      required this.type,
      required this.localMode,
      this.scene,
      required this.selectMediaType,
      required this.ratio,
      required this.index})
      : super(key: key);

  @override
  State<SceneAnimeItem> createState() => _SceneAnimeItemState();
}

class _SceneAnimeItemState extends State<SceneAnimeItem> {
  bool isGeneral = false;
  bool isImage = true;
  String direction = "0";
  late Anime? anime;
  final directionList = const [
    {'label': '向上', 'value': '0', 'prompt': ''},
    {'label': '向下', 'value': '1', 'prompt': ''},
    {'label': '向左', 'value': '2', 'prompt': ''},
    {'label': '向右', 'value': '3', 'prompt': ''},
  ];

  @override
  void initState() {
    anime = widget.tweetImage.anime;
    isImage = widget.tweetImage.mediaType == 0;
    if (widget.tweetImage.imgEffectType != null &&
        widget.tweetImage.imgEffectType != -1) {
      direction = widget.tweetImage.imgEffectType!.toString();
    } else {
      widget.tweetImage.imgEffectType = widget.index % 2;
      debugPrint('选中的value是：${widget.tweetImage.imgEffectType}');
      direction = widget.tweetImage.imgEffectType.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ElevatedButton(
        //   onPressed: () => _showJyAnimeDialog(context),
        //   style: ElevatedButton.styleFrom(
        //     // backgroundColor: (anime == null || anime?.animeIn == "无")
        //     //     ? Colors.grey
        //     //     : Color(0xFF12CDD9),
        //     padding: EdgeInsets.all(5),
        //     minimumSize: Size(0, 35),
        //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //   ),
        //   child:  Text(
        //     "出入场动画",
        //     style: const TextStyle(color: Colors.white, fontSize: 10),
        //   ),
        // ),
        //只在mediaType=0时显示，只对图片生效
        if (widget.tweetImage.mediaType == 0)
          Container(
            alignment: Alignment.center,
            width: 60,
            child: DropMenuWidget(
              leading: const Padding(
                padding: EdgeInsets.all(0),
              ),
              data: directionList,
              selectCallBack: (value) {
                debugPrint('选中的value是：$value');
                direction = value;
                widget.tweetImage.imgEffectType = int.parse(direction);
              },
              offset: const Offset(0, 40),
              selectedValue: direction, //默认选中第三个
            ),
          ),
        if (widget.tweetImage.mediaType == 0)
          ElevatedButton(
            onPressed: () => _showImgScaleDialog(context),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(5),
              minimumSize: Size(50, 35),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "预览",
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
      ],
    );
  }

  ///关键帧预览
  _showImgScaleDialog(BuildContext context) {
    if (widget.tweetImage.url != null) {
      double width = MediaQuery.of(context).size.width * 4 / 5;
      showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            // alignment: Alignment.center,
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            // elevation: 4,
            child: SizedBox(
              width: width,
              height: width,
              child: AnimePreviewPanel(
                tweetImage: widget.tweetImage,
                ratio: widget.ratio,
                direction: direction,
              ),
            ),
          );
        },
      );
    }
  }

  ///剪映入场动画设置
  _showJyAnimeDialog(BuildContext context) {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          alignment: Alignment.center,
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          elevation: 4,
          child: SizedBox(
            child: JyAnimePanel(
              anime: anime,
              onSave: (Anime anime) {
                debugPrint("选择的入场动画：${anime.toJson().toString()}");
                setState(() {
                  this.anime = anime;
                });
                widget.tweetImage.anime = anime;
              },
            ),
            width: MediaQuery.of(context).size.width * 3 / 5,
            height: MediaQuery.of(context).size.height * 3 / 5,
          ),
        );
        ;
      },
    );
  }
}
