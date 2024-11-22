import 'dart:convert';

import 'package:components/components.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pieces_ai/app/model/config/ai_analyse_role_scene.dart';
import 'package:utils/utils.dart';

import '../../../../app/api_https/impl/https_ai_story_repository.dart';
import 'ai_input_content.dart';

GlobalKey<_AiWriteArticlePanelState> AiWriteKey = GlobalKey();
const String AiWriteArticle =
    "帮我写一个短电影分镜脚本，总共---个分镜，每个画面精细生动，且引人入胜。主题是根据+++来展开的一个剧情。每个分镜给出电影画面的详细的描述词和简短的中文旁白，"
    "画面的描述词分别提供中文和英文。严格按如下json格式返回：[{\"zh\":\"中文的画面描述\",\"en\":\"英文的画面描述\",\"narration\":\"旁白内容\"},{\"zh\":\"中文的画面描述\",\"en\":\"英文的画面描述\",\"narration\":\"旁白内容\"},...]";

var logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

///Ai帮我写剧本脚本
class AiWriteArticlePanel extends StatefulWidget {
  final String draftName;

  AiWriteArticlePanel({
    Key? key,
    required this.draftName,
  }) : super(key: key);

  @override
  State<AiWriteArticlePanel> createState() {
    return _AiWriteArticlePanelState();
  }
}

class _AiWriteArticlePanelState extends State<AiWriteArticlePanel>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _textPromptController = TextEditingController();
  final HttpAiStoryRepository httpAiStoryRepository = HttpAiStoryRepository();
  int sceneNum = 4;
  int pegg = 8;

  ///每个分镜扣除多少个皮蛋
  int oneScenePegg = 2;

  @override
  void initState() {
    pegg = sceneNum * oneScenePegg;
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _textPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: EdgeInsets.all(10),
      child: _buildContent(),
    );
  }

  ///MultimodalGen生图模式
  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            child: TextField(
              decoration: InputDecoration(
                hintText: '输入主题如：六一儿童节',
                hintStyle: TextStyle(color: Color(0xFF808080), fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              maxLines: 10,
              maxLength: 1000,
              controller: _textPromptController,
            ),
          ),flex: 3,
        ),
        Flexible(
          child: Row(
            children: [
              Circle(
                color: Color(0xFF12CDD9),
                radius: 5,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "分镜数",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              NumberInputWidget(
                initValue: sceneNum,
                onValueChanged: (int value) {
                  logger.d("NumberInputWidget change:${value}");
                  sceneNum = value;
                  setState(() {
                    pegg = sceneNum * oneScenePegg;
                  });
                },
              ),
            ],
          ),
          flex: 2,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "说明：Ai自动生成文案和画面提示词，每个分镜-$oneScenePegg皮蛋",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "当前扣除皮蛋：-${pegg}",
                  style: TextStyle(color: Color(0xFF12CDD9),fontSize: 12),
                ),
              ),
            ],
          ),
          flex: 2,
        )
      ],
    );
  }

  ///获取Ai自动写的内容
  Future<TaskResult<AiSceneGood?>> aiWriteArticle() async {
    String title = _textPromptController.text;
    if (title.isEmpty) {
      // MotionToast.info(description: Text("请输入一个主题")).show(context);
      return TaskResult(data: null, success: false, msg: "请输入一个主题！");
    }
    String prompt = AiWriteArticle.replaceFirst("---", sceneNum.toString())
        .replaceFirst("+++", title);
    String article = await httpAiStoryRepository.aiPrompt(
        sentence: prompt, shidai: 4, pegg: pegg, gptType: 3);
    List<dynamic> sentenceList = [];
    try {
      if (article.contains("json\n"))
        article = article.replaceAll("json\n", "");
      if (article.contains("```")) {
        article = article.replaceAll("```", "");
      }
      sentenceList = jsonDecode(article);
    } catch (e) {
      debugPrint("解析Ai返回json出错！");
      return TaskResult(data: null, success: false, msg: "Ai文章出错请重试！");
    }
    List<SrtModel> srtModelList = [];
    sentenceList.forEach((element) {
      String sentence = element['narration'];
      var enPrompt = element['en'];
      var zhPrompt = element['zh'];
      debugPrint("sentence:${sentence},prompt:${prompt}");
      SrtModel srtModel = SrtModel(
          start: 0,
          end: 0,
          sentence: sentence,
          prompt: zhPrompt,
          enPrompt: enPrompt);
      srtModelList.add(srtModel);
    });
    AiSceneGood aiSceneGood = AiSceneGood(
        srtModelList: srtModelList,
        rolesAndScenes: RolesAndScenes(roles: [], scenes: []),
        audioPath: "");
    return TaskResult(data: aiSceneGood, success: true, msg: "获取成功");
  }
}
