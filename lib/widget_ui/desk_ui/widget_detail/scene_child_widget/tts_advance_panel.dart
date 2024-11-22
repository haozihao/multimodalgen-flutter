import 'package:authentication/models/user.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_audio.dart';
import 'package:pieces_ai/app/model/config/ai_tts_style.dart';
import 'package:pieces_ai/app/navigation/mobile/theme/theme.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/widget_ai_chose/ai_tts_styles_grid.dart';
import 'package:utils/utils.dart';
import 'package:path/path.dart' as path;

import '../../../../app/api_https/impl/https_ai_config_repository.dart';
import '../../../../app/model/TweetScript.dart';
import '../../../../app/model/user_info_global.dart';
import '../../../../app/utils/draft_util.dart';

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

///TTS高级配音
class TtsAdvancePanel extends StatefulWidget {
  const TtsAdvancePanel(
      {Key? key,
      required this.initSpeed,
      required this.draftType,
      required this.selectType,
      this.ttsEnable,
      required this.sentence,
      this.imgTts,
      required this.onSave,
      required this.draftName})
      : super(key: key);

  final int draftType;
  final Function(String sentence, ImgTts? imgTts) onSave;
  final double initSpeed;
  final String selectType;
  final bool? ttsEnable;
  final String sentence;
  final ImgTts? imgTts;
  final String draftName;

  @override
  State<TtsAdvancePanel> createState() => _TtsAdvancePanelState();
}

class _TtsAdvancePanelState extends State<TtsAdvancePanel> {
  late final player = AudioPlayer();
  late String ttsType;
  late String text;
  late ImgTts? imgTts;
  double _speed = 1.5;
  double initSpeed = 1.5;
  bool isGeneral = false;
  final HttpAiConfigRepository httpAiConfigRepository =
      HttpAiConfigRepository();
  final TextEditingController _textEditingController = TextEditingController();
  final HttpsAiAudio httpsAiAudio = HttpsAiAudio();
  late Future<List<AiTtsStyle>> _aiTtsStyleListFuture;

  @override
  void initState() {
    super.initState();
    imgTts = widget.imgTts;
    text = widget.sentence;
    _textEditingController.text = text;
    _speed = widget.initSpeed;
    initSpeed = widget.initSpeed;
    ttsType = widget.selectType;
    _aiTtsStyleListFuture = httpAiConfigRepository.loadTtsStyles();
  }

  @override
  void dispose() {
    player.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List<Widget> widgets = [];
    // widgets.add();

    return Padding(
      padding: const EdgeInsets.all(10), // 整体页面增加 padding
      child: Column(
        children: [
          Flexible(
            child: FutureBuilder<List<AiTtsStyle>>(
              future: _aiTtsStyleListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Async operation is still in progress
                  return Container(
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  // Error handling
                  return Text('Error: ${snapshot.error}');
                } else {
                  return TtsStylesGridView(
                    ttsEnable: true,
                    openSwitch: false,
                    crossAxisCount: 6,
                    player: player,
                    aiTtsStyleList: snapshot.data ?? [],
                    aiTtsModelChanged: (AiTtsStyle aiTtsStyle, double speed) {
                      debugPrint("选中了音色:" +
                          aiTtsStyle.name +
                          " 速度：" +
                          speed.toStringAsFixed(1));
                      ttsType = aiTtsStyle.type;
                      _speed = speed;
                      loadingButtonKey.currentState
                          ?.modifyData(text, ttsType, speed);
                    },
                    initSpeed: _speed,
                    onTtsOpen: (select) {},
                    draftType: 1,
                    selectType: ttsType,
                  );
                }
              },
            ),
            flex: 4,
          ),
          _buildTextField(),
          // SizedBox(height: 10), // 增加间距
          Row(children: [
            TextButton(
              onPressed: () => _playAudio(context),
              child: const Row(
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 28,
                    color: AppColor.piecesBlue,
                  ),
                  SizedBox(width: 5,),
                  Text(
                    "试听",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Spacer(),
            LoadingButton(
              key: loadingButtonKey,
              sentence: text,
              draftName: widget.draftName,
              httpsAiAudio: httpsAiAudio,
              onSuccess: (ImgTts? imgTts) {
                if (imgTts == null) {
                  MotionToast.warning(description: Text("配音失败！")).show(context);
                } else {
                  this.imgTts = imgTts;
                }
              },
              ttsType: ttsType,
              speed: _speed,
            ),
            // Text("00:00")
          ]),

          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0), // 增加内部 padding
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    // minimumSize: Size(180, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0), // 设置圆角半径
                    ),
                    backgroundColor: Colors.grey,
                  ),
                  child: Text(
                    "取消",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0), // 增加内部 padding
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave.call(_textEditingController.text, imgTts);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    // minimumSize: Size(180, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0), // 设置圆角半径
                    ),
                    backgroundColor: Color(0xFF12CDD9),
                  ),
                  child: Text(
                    "保存",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///播放配音
  _playAudio(BuildContext context) {
    if (imgTts?.url?.isEmpty ?? true) {
      MotionToast.info(description: Text("此分镜还没有配音！")).show(context);
    } else {
      player.setUrl(imgTts!.url!);
      player.setSpeed(1.0);
      player.play();
    }
  }

  Widget _buildTextField() {
    User userLocal = GlobalInfo.instance.user;
    int maxLength =
        (userLocal.vipLevel == 4 || userLocal.vipLevel == 5) ? 300 : 200;
    return Container(
      width: double.infinity,
      // height: MediaQuery.of(context).size.height * 1 / 5,
      child: TextField(
        controller: _textEditingController,
        // 绑定 TextEditingController
        style: const TextStyle(color: Colors.white, fontSize: 12),
        maxLines: 4,
        maxLength: maxLength,
        cursorColor: Colors.green,
        cursorRadius: const Radius.circular(3),
        cursorWidth: 5,
        showCursor: true,
        onChanged: (String value) {
          debugPrint("输入文字变化：$value");
          text = value;
          loadingButtonKey.currentState?.modifyData(text, ttsType, _speed);
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(5),
          hintText: "请输入配音内容...",
          border: OutlineInputBorder(),
        ),
        // onChanged: (v) {},
      ),
    );
  }
}

GlobalKey<_LoadingButtonState> loadingButtonKey = GlobalKey();

class LoadingButton extends StatefulWidget {
  final String sentence;
  final String ttsType;
  final double speed;
  final String draftName;
  final HttpsAiAudio httpsAiAudio;
  final Function(ImgTts? imgTts) onSuccess;

  const LoadingButton({
    Key? key,
    required this.sentence,
    required this.httpsAiAudio,
    required this.onSuccess,
    required this.ttsType,
    required this.speed,
    required this.draftName,
  }) : super(key: key);

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool isGeneral = false;
  late String text;
  late String ttsType;
  late double _speed;

  @override
  void initState() {
    super.initState();
    text = widget.sentence;
    ttsType = widget.ttsType;
    _speed = widget.speed;
  }

  modifyData(String sentence, String ttsType, double speed) {
    debugPrint("选中了音色:$ttsType  文案：$sentence"
            " 速度：" +
        speed.toStringAsFixed(1));
    this.text = sentence;
    this.ttsType = ttsType;
    this._speed = speed;
  }

  ///根据草稿文件类型，下载资源
  Future<String> _downLoadResourceByType(
      String draftPath, String url, DraftFileType draftFileType) async {
    //使用join方法实现上述注释代码
    String ppImagePath =
        path.join(draftPath, DraftUtil.getDraftTypeFolderName(draftFileType));
    await FileUtil.createDirectoryIfNotExists(ppImagePath);
    String imageName = FileUtil.getHttpNameWithExtension(url);
    String saveFilePath = path.join(ppImagePath, imageName);
    logger.d("下载资源saveFilePath：" + saveFilePath);
    await _downloadResource(url, saveFilePath);
    return saveFilePath;
  }

  _downloadResource(String url, String path) async {
    logger.d("下载资源：$url");
    await HttpUtil.instance.client.download(url, path,
        onReceiveProgress: (int get, int total) {
      String progress = ((get / total) * 100).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (text.isEmpty) {
          MotionToast.warning(description: Text("文本不能为空！")).show(context);
          return;
        }
        setState(() {
          isGeneral = true;
        });
        ImgTts? imgTts = await widget.httpsAiAudio.tts(
            sentence: text,
            pegg: 2,
            type: ttsType,
            speed: (50 * _speed).toInt(),
            volume: 100);
        //下载
        if (imgTts != null) {
          String draftPath =
              await FileUtil.getPieceAiDraftFolderByTaskId(widget.draftName);
          String saveFilePath = await _downLoadResourceByType(
              draftPath, imgTts.url!, DraftFileType.AUDIO);
          imgTts.url = saveFilePath;
        }
        setState(() {
          isGeneral = false;
        });
        widget.onSuccess.call(imgTts);
      },
      style: ElevatedButton.styleFrom(
        // minimumSize: Size(140, 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // 设置圆角半径
        ),
        padding: EdgeInsets.all(5),
        backgroundColor: AppColor.piecesBlue,
      ),
      child: isGeneral
          ? CircularProgressIndicator()
          : Text(
              "开始配音 | -2",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
    );
  }
}
