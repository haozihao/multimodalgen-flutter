import 'dart:async';
import 'dart:io';

import 'package:authentication/models/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pieces_ai/app/model/user_info_global.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/widget_ai_chose/ai_write_article.dart';
import 'package:utils/utils.dart';

import '../../../../app/api_https/impl/https_ai_config_repository.dart';
import '../../../../app/api_https/impl/https_video_copy_repository.dart';
import '../../../../app/gen/toly_icon_p.dart';
import '../../../../app/model/config/ai_analyse_role_scene.dart';

GlobalKey<_StoryTextItemState> inputTextKey = GlobalKey();

///小说文本输入区域+音频SRT
class StoryTextItem extends StatefulWidget {
  final String draftTitle;
  final String originalContent;
  final String? audioPath;
  final String? srtPath;
  final int initSelect;
  final HttpAiConfigRepository httpAiConfigRepository;
  final Function(int) onSelect;
  final bool enableInput;

  StoryTextItem(
      {Key? key,
      required this.draftTitle,
      required this.httpAiConfigRepository,
      required this.onSelect,
      required this.originalContent,
      required this.enableInput,
      this.audioPath,
      this.srtPath,
      required this.initSelect})
      : super(key: key);

  @override
  State<StoryTextItem> createState() => _StoryTextItemState();
}

class _StoryTextItemState extends State<StoryTextItem>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  late TabController _tabController;
  late AudioPlayer player;
  final List<String> titles = [
    "Ai帮我写",
    "上传音频",
    "输入文案",
  ];
  String audioPath = "";
  int pegg = 0;
  String audioDuration = "";
  String audioName = "";
  String srtPath = "";
  String srtName = "";
  int inputType = 0;

  @override
  void dispose() {
    _focusNode.dispose();
    _textEditingController.dispose(); // 释放 TextEditingController
    _tabController.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StoryTextItem oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    audioPath = widget.audioPath ?? "";
    srtPath = widget.srtPath ?? "";
    _textEditingController.text = widget.originalContent;
    inputType = widget.initSelect;
    _tabController = TabController(
        length: 3,
        vsync: this,
        animationDuration: Duration.zero,
        initialIndex: inputType);
    player = AudioPlayer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0x19FFFFFF),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10),
            //父类的宽度的比例
            child: FractionallySizedBox(
              widthFactor: 3 / 4,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                controller: _tabController,
                onTap: (index) {
                  inputType = index;
                  widget.onSelect.call(inputType);
                },
                // labelPadding: EdgeInsets.symmetric(horizontal: 10.0),
                tabs: titles
                    .map((e) =>
                        Tab(child: Text(e, style: TextStyle(fontSize: 14))))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: titles.map((e) => _buildContent(e)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String title) {
    if (titles[0] == title) {
      return AiWriteArticlePanel(key: AiWriteKey, draftName: "draftName");
    } else if (titles[1] == title) {
      return _buildAudioAndSrt(title);
    } else {
      return _buildTextField(title);
    }
  }

  Widget _buildTextField(String title) {
    User userLocal = GlobalInfo.instance.user;
    int maxLength =
        (userLocal.vipLevel == 4 || userLocal.vipLevel == 5) ? 6000 : 3000;
    return Padding(
      padding: EdgeInsets.all(15),
      child: Container(
        width: double.infinity,
        child: TextField(
          controller: _textEditingController,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          maxLines: 50,
          enabled: widget.enableInput,
          maxLength: maxLength,
          cursorColor: Colors.green,
          cursorRadius: const Radius.circular(3),
          cursorWidth: 5,
          showCursor: true,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10),
            hintText: widget.enableInput ? "请输入文本内容..." : "再次制作无需操作",
            border: OutlineInputBorder(),
          ),
          // onChanged: (v) {},
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String hours = duration.inHours.toString().padLeft(0, '2');
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  Widget _buildAudioAndSrt(String title) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Color(0xFF808080))),
            child: InkWell(
              onTap: () {
                if (widget.enableInput) _selectLocalAudio();
              },
              child: Center(
                child: Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Icon(
                        TolyIconP.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    Text(
                      audioName.isEmpty
                          ? "请上传音频(支持mp3和wav音频、支持视频提取)"
                          : "你已选择：${audioName},(时长${audioDuration})",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    if (!widget.enableInput)
                      Text(
                        "再次制作无需选择",
                        style: TextStyle(color: Color(0xFF12CDD9)),
                      )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Color(0xFF808080))),
            child: InkWell(
                onTap: () async {
                  if (!widget.enableInput) return;
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: [
                      'srt',
                    ],
                  );
                  if (result != null) {
                    PlatformFile file = result.files.single;
                    if (file.path?.isNotEmpty == true) {
                      setState(() {
                        srtName = file.name;
                        pegg = 0;
                      });
                      srtPath = file.path!;
                    }
                  } else {
                    // User canceled the picker
                  }
                },
                child: Center(
                  child: Wrap(
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "添加字幕(可选)",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                            srtName.isEmpty ? "仅支持SRT格式" : "你已选择：${srtName}",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      )
                    ],
                  ),
                )),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text("说明：若不添加SRT文件，则需扣除一定皮蛋数，1分钟音频对应-2皮蛋",
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "当前扣除皮蛋：-${pegg}",
              style: TextStyle(color: Color(0xFF12CDD9)),
            ),
          ),
        ],
      ),
    );
  }

  _selectLocalAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      // allowedExtensions: ['mp3', 'wav', 'avi', 'wmv', 'mp4', 'mov'],
    );
    if (result != null) {
      PlatformFile file = result.files.single;
      if (file.path?.isNotEmpty == true) {
        audioPath = file.path!;
        //如果是视频，则提取
        if (!audioPath.endsWith(".mp3") && !audioPath.endsWith(".wav")) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF12CDD9)), // 设置CircularProgressIndicator颜色
                    ),
                    SizedBox(height: 20),
                    Text(
                      '音频提取中...', // 添加文字
                      style: TextStyle(
                        color: Color(0xFF12CDD9), // 设置文字颜色
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
          String extractFolder = await FileUtil.getDraftFolder() +
              FileUtil.getFileSeparate() +
              "extractAudio";
          String extractAudioPath =
              extractFolder + FileUtil.getFileSeparate() + file.name;
          if (!await Directory(extractFolder).exists()) {
            await Directory(extractFolder).create(recursive: true);
          }
          // final cliCommandAudio = FfmpegCommand.simple(
          //   ffmpegPath: Directory.current.path + "\\ffmpeg.exe",
          //   inputs: [
          //     FfmpegInput.asset(audioPath),
          //   ],
          //   args: [
          //     CliArg.logLevel(LogLevel.info),
          //     const CliArg(name: 'vn'),
          //     const CliArg(name: 'y'),
          //     const CliArg(name: 'c:a', value: "mp3"),
          //   ],
          //   outputFilepath: extractAudioPath,
          // );
          // final processAudio = await Ffmpeg().run(cliCommandAudio);
          // processAudio.stderr.transform(utf8.decoder).listen((data) {
          //   // debugPrint(data);
          // });
          // await processAudio.exitCode;
          Navigator.of(context).pop();
          if (await File(extractAudioPath).exists()) {
            // debugPrint('提取成功mp3:' + extractAudioPath);
            audioPath = extractAudioPath;
          } else {
            MotionToast.error(description: Text("提取音频出错，请检查视频文件是否包含音频！"))
                .show(context);
            return;
          }
        }
        Duration duration = await player.setUrl(audioPath) ?? Duration.zero;
        await player.play();
        debugPrint("监听：" + duration.toString());
        setState(() {
          audioName = file.name;
          pegg = (duration.inMinutes + 1) * 2;
          audioDuration = formatDuration(duration);
        });
      }
    } else {
      // User canceled the picker
    }
  }

  ///获取组装剧本的数据
  Future<TaskResult<AiSceneGood?>> getAiSceneGood() async {
    String content;
    if (inputType == 0) {
      ///AI自动写分镜文字内容
      return await AiWriteKey.currentState?.aiWriteArticle() ??
          TaskResult(data: null, success: false, msg: "出错了！");
    } else if (inputType == 1) {
      _textEditingController.text = "";
      return await getSrtSentences();
    } else {
      content = _textEditingController.text;
      if (content.isEmpty) {
        return TaskResult(data: null, success: false, msg: "请输入文案内容！");
      }
      //分句+获取角色列表
      List<SrtModel> srtModelList =
          await widget.httpAiConfigRepository.loadSentence(content);
      RolesAndScenes? rolesAndScenes = await HttpAiConfigRepository()
          .aiAnalyseRolesAndScenes(prompt: content);
      audioPath = "";
      srtPath = "";
      return TaskResult(
        data: AiSceneGood(
            srtModelList: srtModelList,
            rolesAndScenes: rolesAndScenes,
            audioPath: audioPath),
        success: true,
      );
    }
  }

  ///走上传音频和srt逻辑
  Future<TaskResult<AiSceneGood?>> getSrtSentences() async {
    if (audioPath.isEmpty) {
      return TaskResult(data: null, success: false, msg: "请先上传音频文件");
    }
    List<SrtModel> srtModelList;
    if (srtPath.isEmpty) {
      //通过ART识别接口
      srtModelList = await transAudioToSentence();
    } else {
      srtModelList = transSrtToSentence();
    }
    String content = "";
    List<SrtModel> newSrtModels = [];
    for (int i = 0; i < srtModelList.length; i++) {
      SrtModel srtModel = srtModelList[i];
      content += srtModel.sentence;
      //25个字到45个之间
      if (srtModel.sentence.length >= 25) {
        newSrtModels.add(srtModel);
        // debugPrint("不用合并分句：" + srtModel.toString());
      } else {
        while ((i + 1) < srtModelList.length &&
            (srtModel.sentence.length + srtModelList[i + 1].sentence.length) <=
                40) {
          RegExp regExp = RegExp(
              r'[\p{P}\p{S}\u0020-\u002F\u003A-\u0040\u005B-\u0060\u007B-\u007E\u3000-\u303F\uFF00-\uFF60\uFFE0-\uFFE6]$');
          bool endsWithPunctuation = regExp.hasMatch(srtModel.sentence);
          // 标点结尾以及如果是ASR识别都不主动加标点而直接合并
          if (endsWithPunctuation || srtPath.isEmpty) {
            // debugPrint("是标点结尾:" + srtModel.toString());
            srtModel.sentence += srtModelList[i + 1].sentence;
          } else {
            srtModel.sentence += "，";
            srtModel.sentence += srtModelList[i + 1].sentence;
          }
          i++;
        }
        //这里再指定这个新的分句的时间为下一个的起始时间
        if (i == srtModelList.length - 1)
          srtModel.end = srtModelList[i].end;
        else
          srtModel.end = srtModelList[i + 1].start;
        // debugPrint("最终合并后的分句：" + srtModel.toString());
        newSrtModels.add(srtModel);
      }
    }
    RolesAndScenes? rolesAndScenes =
        await HttpAiConfigRepository().aiAnalyseRolesAndScenes(prompt: content);
    AiSceneGood aiSceneGood = AiSceneGood(
        srtModelList: newSrtModels,
        rolesAndScenes: rolesAndScenes,
        audioPath: audioPath);
    return TaskResult(data: aiSceneGood, success: true);
  }

  ///把Audio通ASR识别并返回数据
  Future<List<SrtModel>> transAudioToSentence() async {
    //上传到云端后
    String audioUrl =
        await widget.httpAiConfigRepository.fileUpload(filePath: audioPath);
    // print("audioUrl" + audioUrl);
    return HttpsVideoCopyRepository().aiAsr(audioUrl: audioUrl, pegg: pegg);
  }

  ///把SRT转换成分句信息，包括起始时间和时长
  List<SrtModel> transSrtToSentence() {
    List<SrtModel> srtList = [];
    // 读取文件内容
    final file = File(srtPath);
    final lines = file.readAsLinesSync();

    double startTime = 0.0;
    double endTime = 0.0;
    String sentence = '';

    for (var line in lines) {
      // 如果是数字，则表示一个新的SRT项开始
      if (int.tryParse(line) != null) {
        if (endTime != 0.0 && sentence.isNotEmpty) {
          srtList.add(
              SrtModel(start: startTime, end: endTime, sentence: sentence));
        }
        startTime = 0.0;
        endTime = 0.0;
        sentence = '';
      }
      // 解析时间段
      else if (line.contains('-->')) {
        final times = line.split('-->');
        startTime = parseTime(times[0].trim());
        endTime = parseTime(times[1].trim());
      }
      // 解析字幕内容
      else if (line.isNotEmpty) {
        sentence += line.trim();
      }
    }

    // 添加最后一项
    if (startTime != 0.0 && endTime != 0.0 && sentence.isNotEmpty) {
      srtList.add(SrtModel(start: startTime, end: endTime, sentence: sentence));
    }

    return srtList;
  }

  // 解析时间字符串，返回毫秒数
  double parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final secondsParts = parts[2].split(',');
    final seconds = int.parse(secondsParts[0]);
    final milliseconds = int.parse(secondsParts[1]);
    return (hours * 3600 + minutes * 60 + seconds + milliseconds / 1000) * 1000;
  }
}

class SrtModel {
  final double start;
  double end;
  String sentence;
  final String? prompt;
  final String? enPrompt;

  // 构造函数
  SrtModel(
      {required this.start,
      required this.end,
      required this.sentence,
      this.prompt,
      this.enPrompt});

  @override
  String toString() {
    return 'SrtModel(start: $start, end: $end, sentence: $sentence)';
  }
}

class AiSceneGood {
  final List<SrtModel> srtModelList;
  final RolesAndScenes? rolesAndScenes;
  final String? audioPath;

  AiSceneGood({
    required this.srtModelList,
    required this.rolesAndScenes,
    required this.audioPath,
  });
}
