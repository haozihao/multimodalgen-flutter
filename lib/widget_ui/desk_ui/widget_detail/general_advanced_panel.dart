import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/scene_child_widget/scene_anime_item.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/scene_child_widget/scene_tts_item.dart';

import '../../../app/model/TweetScript.dart';
import '../../../app/model/ai_image2_video.dart';
import '../../../app/navigation/mobile/theme/theme.dart';
import '../category_panel/video/video_general_widget.dart';
import 'image_general_widget/image_general_panel.dart';

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

///高级编辑模式
class AdvanceGeneralPage extends StatefulWidget {
  final TweetImage tweetImage;
  final TweetScriptTts? tweetScriptTts;
  final String? imageUrl;
  final String? videoUrl;
  final String draftName;
  final int mediaType;
  final int type;
  final int index;
  final double motionStrength;
  final List<String> urls;
  final List<String> videoUrls;

  ///外部分镜填写的关键词
  final List<UserTag> inputTags;
  final Function(String url, String videoUrl, int mediaType) onImageSelected;
  final bool localMode;
  final AiPaintParamsV2 aiPaintParamsV2;

  AdvanceGeneralPage({
    required this.imageUrl,
    required this.urls,
    required this.onImageSelected,
    required this.localMode,
    required this.draftName,
    required this.aiPaintParamsV2,
    required this.mediaType,
    this.videoUrl,
    required this.videoUrls,
    required this.motionStrength,
    required this.inputTags,
    required this.tweetImage,
    this.tweetScriptTts,
    required this.type,
    required this.index,
  });

  @override
  State<AdvanceGeneralPage> createState() {
    return _AdvanceGeneralPageState();
  }
}

class _AdvanceGeneralPageState extends State<AdvanceGeneralPage>
    with SingleTickerProviderStateMixin {
  int initialIndex = 0;

  @override
  void initState() {
    initialIndex = widget.mediaType == 0 ? 0 : 1;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.piecesBackTwo,
      appBar: AppBar(
        title: Text("高级编辑"),
      ),
      body: _buildGeneralTabBar(),
    );
  }

  List<String> titles = ["生图", "生视频", "配音", "画面运动"];

  ///3种生图模式
  Widget _buildGeneralTabBar() {
    //如果origin的image2VideoParam为空，则初始化一个。并设置给origin
    if (widget.tweetImage.origin == null) {
      widget.tweetImage.origin =
          Origin(image: "", strength: widget.motionStrength);
    }
    if (widget.tweetImage.origin?.image2VideoParam == null) {
      widget.tweetImage.origin?.image2VideoParam =
          Image2VideoParam(image: '', prompt: '');
    }
    return DefaultTabController(
        length: titles.length,
        initialIndex: initialIndex,
        child: Column(
          children: [
            ButtonsTabBar(
              // controller: _tabController,
              backgroundColor: AppColor.piecesBlue,
              unselectedBackgroundColor: AppColor.piecesBackTwo,
              labelStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                color: AppColor.piecesBackTwo,
                fontWeight: FontWeight.bold,
              ),
              contentCenter: true,
              borderWidth: 1,
              unselectedBorderColor: AppColor.piecesBackTwo,
              // radius: 100,
              // Add your tabs here
              tabs: titles
                  .map((e) => Tab(
                        child: Text(
                          e,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ))
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                // controller: _tabController,
                children: <Widget>[
                  ImgGeneralPanel(
                    imageUrl: widget.imageUrl,
                    urls: widget.urls,
                    inputTags: widget.inputTags,
                    onImageSelected: widget.onImageSelected,
                    localMode: widget.localMode,
                    draftName: widget.draftName,
                    aiPaintParamsV2: widget.aiPaintParamsV2,
                  ),
                  VideoGeneralPanel(
                    key: videoGeneralPanelKey,
                    imageUrl: widget.imageUrl,
                    videoUrl: widget.videoUrl,
                    urls: widget.urls,
                    image2videoParam:
                        widget.tweetImage.origin?.image2VideoParam,
                    onImageSelected: widget.onImageSelected,
                    localMode: widget.localMode,
                    draftName: widget.draftName,
                    aiPaintParamsV2: widget.aiPaintParamsV2,
                    videoUrls: widget.videoUrls,
                    motionStrength: widget.motionStrength,
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 100,
                    color: Color(0xFF3B3B3C),
                    child: SceneTtsItem(
                      tweetImage: widget.tweetImage,
                      type: widget.type,
                      localMode: widget.localMode,
                      selectMediaType: (int mediaType) {},
                      ratio: widget.aiPaintParamsV2.ratio,
                      tweetScriptTts: widget.tweetScriptTts,
                      draftName: widget.draftName,
                    ),
                  ),

                  ///画面运动
                  Container(
                    height: 100,
                    alignment: Alignment.center,
                    color: Color(0xFF3B3B3C),
                    child: SceneAnimeItem(
                      tweetImage: widget.tweetImage,
                      type: widget.type,
                      localMode: widget.localMode,
                      selectMediaType: (int mediaType) {},
                      ratio: widget.aiPaintParamsV2.ratio,
                      index: widget.index,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
