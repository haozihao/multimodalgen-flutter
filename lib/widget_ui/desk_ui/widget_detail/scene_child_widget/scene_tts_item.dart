import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/scene_child_widget/tts_advance_panel.dart';

import '../../../../app/model/TweetScript.dart';
import '../../../../app/model/config/ai_analyse_role_scene.dart';
import '../../../../app/navigation/mobile/theme/theme.dart';

///分镜组件的画面动画运动调整
class SceneTtsItem extends StatefulWidget {
  final Function(int mediaType) selectMediaType;
  final TweetImage tweetImage;
  final String draftName;
  final TweetScriptTts? tweetScriptTts;
  final Scene? scene;
  final int type;
  final int ratio;
  final bool localMode;

  SceneTtsItem({
    Key? key,
    required this.tweetImage,
    required this.type,
    required this.localMode,
    this.scene,
    required this.selectMediaType,
    required this.ratio,
    this.tweetScriptTts,
    required this.draftName,
  }) : super(key: key);

  @override
  State<SceneTtsItem> createState() => _SceneTtsItemState();
}

class _SceneTtsItemState extends State<SceneTtsItem> {
  bool isGeneral = false;
  bool isImage = true;
  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    isImage = widget.tweetImage.mediaType == 0;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.piecesBlackGrey,
      child: TtsAdvancePanel(
        ttsEnable: true,
        initSpeed: widget.tweetScriptTts!.speed! / 50,
        draftType: widget.type,
        selectType: widget.tweetScriptTts!.type,
        sentence: widget.tweetImage.sentence,
        imgTts: widget.tweetImage.tts,
        onSave: (String sentence, ImgTts? imgTts) {
          debugPrint("配音返回：$imgTts");
          widget.tweetImage.sentence = sentence;
          widget.tweetImage.tts = imgTts;
        },
        draftName: widget.draftName,
      ),
    );
  }

  ///播放配音
  _playAudio(BuildContext context) {
    if (widget.tweetImage.tts?.url?.isEmpty ?? true) {
      MotionToast.info(description: Text("此分镜还没有配音！")).show(context);
    } else {
      player.setUrl(widget.tweetImage.tts!.url!);
      player.play();
    }
  }
}
