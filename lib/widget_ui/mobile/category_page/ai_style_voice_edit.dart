import 'dart:convert';

import 'package:app/app.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_config_repository.dart';
import 'package:pieces_ai/app/model/ai_draft.dart';
import 'package:pieces_ai/app/model/ai_style_model.dart';
import 'package:pieces_ai/app/model/config/ai_analyse_role_scene.dart';
import 'package:pieces_ai/app/model/config/ai_tts_style.dart';
import 'package:pieces_ai/app/navigation/mobile/theme/theme.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/widget_ai_chose/ai_input_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utils/utils.dart';
import 'package:uuid/uuid.dart';

import '../../../app/model/TweetScript.dart';
import '../../desk_ui/category_panel/desk_sytle_grid.dart';
import '../../desk_ui/widget_detail/widget_ai_chose/ai_tts_styles_grid.dart';

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

/// blueming.wu
/// 编辑任务前置风格选择，文案输入等编辑页面
class AiStyleEdit extends StatefulWidget {
  final DraftRender draftRender;

  const AiStyleEdit({Key? key, required this.draftRender}) : super(key: key);

  @override
  State<AiStyleEdit> createState() => _AiStyleEditState();
}

class _AiStyleEditState extends State<AiStyleEdit> {
  String videoPath = "";
  String videoName = "";
  String fpsProgressText = "视频解析中...";
  VoidCallback? callbackStopVideo;
  bool isLoading = false;

  ///默认全局配置保存的默认选择
  UserInputConfig userInputConfig = UserInputConfig();

  Child? aiStyleChild;
  AiTtsStyle? aiTtsStyle;
  final AudioPlayer player = AudioPlayer();
  final HttpAiConfigRepository httpAiConfigRepository =
      HttpAiConfigRepository();
  late Future<UserInputConfig> _userConfigFuture;
  late Future<List<AiStyleModel>> _styleFuture;
  late Future<List<AiTtsStyle>> _ttsFuture;

  @override
  void initState() {
    super.initState();
    //加载全局配置文件
    _userConfigFuture = _initializePreferences();
    _styleFuture = httpAiConfigRepository.loadStyleWidgets();
    _ttsFuture = httpAiConfigRepository.loadTtsStyles();
  }

  ///获取用户上次保存的配置
  Future<UserInputConfig> _initializePreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var ratio = prefs.getInt("ratio") ?? 1;
    var voiceId = prefs.getString("voice_id") ?? "Yunjian#5";
    var initStyleId = prefs.getInt("select_style_id") ?? 87;
    var voiceSpeed = prefs.getInt("voice_speed") ?? 76;
    var selectInputType = prefs.getInt("selectInputType") ?? 0;
    userInputConfig = UserInputConfig(
        ratio: ratio,
        voiceId: voiceId,
        initStyleId: initStyleId,
        voiceSpeed: voiceSpeed,
        selectInputType: selectInputType);
    debugPrint('获取配置信息:$userInputConfig');
    return userInputConfig;
  }

  Future<void> _savePreferences() async {
    //保存配置
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("ratio", userInputConfig.ratio);
    await prefs.setString("voice_id", userInputConfig.voiceId);
    await prefs.setInt("select_style_id", userInputConfig.initStyleId);
    await prefs.setInt("voice_speed", userInputConfig.voiceSpeed);
    await prefs.setInt("selectInputType", userInputConfig.selectInputType);
    debugPrint('保存配置信息:$userInputConfig');
  }

  @override
  void dispose() {
    player.dispose();
    _savePreferences();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff2C3036),
        title: _buildTopButton(),
      ),
      body: _buildWidgetList(),
    );
  }

  Widget _buildTopButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "基础设置",
        ),
        const Spacer(), // 添加 Spacer
        ElevatedButton(
          onPressed: () async {
            if (widget.draftRender.type == 3) {
              //追爆款，开始ffmpeg解析
              if (videoPath.isNotEmpty) {
                callbackStopVideo?.call();
              } else {
                MotionToast.info(description: Text("请先点击'获取视频'按钮！"))
                    .show(context);
              }
            } else {
              if (aiStyleChild == null) {
                MotionToast.info(description: Text("请等待风格加载完成！")).show(context);
                return;
              }
              if (aiTtsStyle == null) {
                MotionToast.info(description: Text("请选择配音角色！")).show(context);
                return;
              }
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return const SimpleDialog(
                    backgroundColor: Colors.transparent,
                    children: <Widget>[
                      Center(
                        child: Text('Ai识别人物和场景中...'),
                      ),
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  );
                },
              );
              //如果已经识别过人物和分句，则直接进入下一个页面。
              if (widget.draftRender.rolesAndScenes != null) {
                debugPrint("已经识别过人物了，是否有本地音频地址：" +
                    widget.draftRender.audioPath.toString());
                AiSceneGood aiSceneGood = AiSceneGood(
                    rolesAndScenes: widget.draftRender.rolesAndScenes,
                    srtModelList: [],
                    audioPath: widget.draftRender.audioPath);

                await _nextStepNormal(aiSceneGood);
              } else {
                TaskResult<AiSceneGood?>? taskResult =
                    await inputTextKey.currentState?.getAiSceneGood();
                if (taskResult == null) {
                  MotionToast.error(description: Text("分镜脚本解析出错，请联系客服！"))
                      .show(context);
                  return;
                }
                if (taskResult.success) {
                  await _nextStepNormal(taskResult.data!);
                } else {
                  MotionToast.info(description: Text(taskResult.msg))
                      .show(context);
                  Navigator.of(context).pop();
                }
              }
            }
          },
          child: const Text(
            "下一步",
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  ///根据用户上次保存的配置，初始化页面
  Widget _buildWidgetList() {
    return FutureBuilder<UserInputConfig>(
        future: _userConfigFuture,
        builder: (context, snapdata) {
          if (snapdata.connectionState == ConnectionState.waiting) {
            // Async operation is still in progress
            return Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          } else if (snapdata.hasError) {
            // Error handling
            return Text('Error: ${snapdata.error}');
          } else {
            return Column(
              children: [
                widget.draftRender.type == 3
                    ? Flexible(
                        flex: 3,
                        child: SizedBox.shrink(),
                      )
                    : Flexible(
                        flex: 3,
                        child: StoryTextItem(
                          key: inputTextKey,
                          audioPath: widget.draftRender.audioPath,
                          draftTitle: widget.draftRender.name,
                          httpAiConfigRepository: httpAiConfigRepository,
                          onSelect: (type) {
                            userInputConfig.selectInputType = type;
                            //设置TTS为关闭
                            ttsStyleKey.currentState?.setInputType(type);
                          },
                          originalContent:
                              widget.draftRender.originalContent ?? "",
                          enableInput: widget.draftRender.tweetScript == null,
                          initSelect: userInputConfig.selectInputType,
                        ),
                      ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0x19FFFFFF),
                        // borderRadius: BorderRadius.circular(10), // 设置圆角半径
                      ),
                      padding: const EdgeInsets.only(
                        left: 10,
                        top: 10,
                        right: 10,
                      ),
                      child: FutureBuilder<List<AiStyleModel>>(
                        future: _styleFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Async operation is still in progress
                            return Container(
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            // Error handling
                            return Text('Error: ${snapshot.error}');
                          } else {
                            var selectStyleId = widget.draftRender.tweetScript?.aiPaint.id ??
                                snapdata.data!.initStyleId;
                            if (aiStyleChild == null) {
                              snapshot.data?.forEach((element) {
                                element.children.forEach((children) {
                                  //默认选中本身的风格
                                  if (children.id == selectStyleId) {
                                    aiStyleChild = children;
                                  }
                                });
                              });
                            }
                            // 一共三个区域，左上为 gridView 的风格区域，左下为比例选择，右边为文本区域
                            StyleGridView styleGridView = StyleGridView(
                              aiStyleModels: snapshot.data ?? [],
                              aiStyleModelChanged: (Child aiStyleModel) {
                                logger.d("选中了风格:${aiStyleModel.id}");
                                aiStyleChild = aiStyleModel;
                                userInputConfig.initStyleId = aiStyleModel.id;
                              },
                              selectStyleId:selectStyleId,
                              countPerLine: 5,
                            );
                            return styleGridView;
                          }
                        },
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.only(top: 10, left: 10, right: 10,bottom: 10),
                    child: Row(
                      children: [
                        Flexible(
                          child: _buildVoiceWidget(snapdata.data!),
                          flex: 1,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: _buildOtherSetting(snapdata.data!),
                          flex: 1,
                        )
                      ],
                    )),
              ],
            );
          }
        });
  }

  ///其它设置
  _buildOtherSetting(UserInputConfig snapdata) {
    return Container(
      height: 50,
      padding: EdgeInsets.only(left: 10, right: 10),
      //圆角
      decoration: BoxDecoration(
        color: AppColor.piecesGrey,
        borderRadius: BorderRadius.circular(5), // 设置圆角半径
      ),
      child: InkWell(
        onTap: () {
          //设置底部弹窗高度
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 200,
                child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: VideoRatioWidget(
                      onRatioChanged: (int index) {
                        debugPrint("ratio更改：" + index.toString());
                        userInputConfig.ratio = index;
                      },
                      initRatio: snapdata.ratio,
                    )),
              );
            },
          );
        },
        child: Row(
          children: [
            Icon(
              Icons.settings,
              size: 20,
              color: Colors.white,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              '更多设置',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 10,
            ),
          ],
        ),
      ),
    );
  }

  ///配音角色选择
  _buildVoiceWidget(UserInputConfig snapdata) {
    return Container(
      height: 50,
      padding: EdgeInsets.only(left: 10, right: 10),
      //圆角
      decoration: BoxDecoration(
        color: AppColor.piecesGrey,
        borderRadius: BorderRadius.circular(5), // 设置圆角半径
      ),
      child: FutureBuilder<List<AiTtsStyle>>(
        future: _ttsFuture,
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
            //设置默认选中的音色
            if (aiTtsStyle == null) {
              aiTtsStyle = snapshot.data!
                  .firstWhere((element) => element.type == snapdata.voiceId);
            }
            return InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: EdgeInsets.all(10),
                      child: TtsStylesGridView(
                        key: ttsStyleKey,
                        crossAxisCount: 6,
                        ttsEnable: widget.draftRender.tweetScript?.ttsEnable,
                        aiTtsStyleList: snapshot.data ?? [],
                        aiTtsModelChanged:
                            (AiTtsStyle aiTtsStyle, double speed) {
                          userInputConfig.voiceSpeed = (50 * speed).toInt();
                          // debugPrint("选中了音色:" +
                          //     aiTtsStyle.name +
                          //     " 速度：" +
                          //     userInputConfig.voiceSpeed.toString() +
                          //     "  传过来的速度:" +
                          //     speed.toStringAsFixed(1));
                          setState(() {
                            this.aiTtsStyle = aiTtsStyle;
                          });
                          userInputConfig.voiceId = aiTtsStyle.type;
                        },
                        initSpeed: snapdata.voiceSpeed / 50,
                        onTtsOpen: (select) {

                        },
                        draftType: widget.draftRender.type ?? 1,
                        selectType: widget.draftRender.tweetScript?.tts.type ??
                            snapdata.voiceId,
                        player: player,
                      ),
                    );
                  },
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.record_voice_over,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '配音角色',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    this.aiTtsStyle?.name ?? '请选择',
                    style: TextStyle(fontSize: 12, color: Color(0xFF12CDD9)),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  ///一键成片下一步
  _nextStepNormal(AiSceneGood aiSceneGood) async {
    RolesAndScenes? rolesAndScenes = aiSceneGood.rolesAndScenes;

    //生成空的
    int canVideo = 1;
    int styleId = -1;
    if (aiStyleChild != null) {
      Map<String, dynamic> presetInfo = jsonDecode(aiStyleChild!.presetInfo);
      canVideo = presetInfo['text_to_video'] ?? 2;
      styleId = aiStyleChild!.id;
    }
    TweetScript tweetScript;
    if (widget.draftRender.tweetScript != null) {
      //表示再次制作，再次制作过来的已经是新的对象了，不会影响老的
      tweetScript = widget.draftRender.tweetScript!;
      //把图片地址清空，重新生成
      widget.draftRender.tweetScript!.scenes[0].imgs.forEach((tweetImage) {
        tweetImage.url = "";
        //清空音频
        if (tweetScript.tts.type != aiTtsStyle?.type) {
          tweetImage.tts?.url = "";
          tweetImage.tts?.fileLength = 0;
        }
      });
      //再次制作默认不锁定人物种子
      widget.draftRender.lockedSeed = true;
      //如果风格切换了，则清除固定人物信息
    } else {
      if (rolesAndScenes != null)
        rolesAndScenes.scenes.add(Scene(name: "无", prompt: "")); //增加一个空场景
      tweetScript = TweetScript.generateEmpty(
          aiSceneGood.srtModelList, canVideo == 1, styleId);
    }
    tweetScript.title = widget.draftRender.name;
    tweetScript.icon = aiStyleChild!.icon;
    tweetScript.ttsEnable = ttsStyleKey.currentState?.ttsEnable ?? true;
    int styleType = 0;
    //设置风格
    int shidai = 1;
    if (aiStyleChild != null) {
      Map<String, dynamic> presetInfo = jsonDecode(aiStyleChild!.presetInfo);
      String styleName = presetInfo['style_name'];
      if (styleName.isEmpty) {
        tweetScript.aiPaint.styleName = aiStyleChild!.modelFileName;
      } else {
        tweetScript.aiPaint.styleName = presetInfo['style_name'];
      }
      print("风格透传数据：" + aiStyleChild!.presetInfo);
      shidai = presetInfo['model_file_type'] ?? 1;
      tweetScript.aiPaint.sampling = presetInfo['sampling'];
      tweetScript.aiPaint.steps = presetInfo['steps'];
      tweetScript.aiPaint.lora = presetInfo['lora'];
      tweetScript.aiPaint.negativePrompt = presetInfo['negative_prompt'];
      //这里还要重新赋值一下
      if (presetInfo.containsKey("hd")) {
        // Map<String,dynamic> hdMap = jsonDecode(presetInfo['hd']);
        tweetScript.aiPaint.hd.modelType = presetInfo['hd']['model_type'];
        tweetScript.aiPaint.hd.scale = 2.0;
        tweetScript.aiPaint.hd.strength = presetInfo['hd']['strength'];
        print("下发包含hd参数：" + presetInfo.toString());
      }

      tweetScript.aiPaint.prompt = presetInfo['prompt'];
      tweetScript.aiPaint.cfgScale = presetInfo['cfg_scale'].toDouble();
      tweetScript.aiPaint.modelClass = presetInfo['model_class'];
      //使用本地webUI
      if (aiStyleChild!.id == -123) {
        styleType = 1;
      }
      //使用FastSd
      if (aiStyleChild!.id == -100) {
        styleType = 2;
      }
    }

    //设置尺寸
    tweetScript.aiPaint.ratio = userInputConfig.ratio;
    //设置音色
    if (aiTtsStyle != null) {
      tweetScript.tts.type = aiTtsStyle!.type;
      tweetScript.tts.style = aiTtsStyle?.style;
      tweetScript.tts.speed = userInputConfig.voiceSpeed;
      logger.d("配音角色：${aiTtsStyle!.name} 速度：${userInputConfig.voiceSpeed}");
    }

    DraftRender draft = DraftRender(
        draftVersion: DraftRender.CURRENT_DRAFT_VERSION,
        name: widget.draftRender.name,
        tweetScript: tweetScript,
        rolesAndScenes: rolesAndScenes,
        styleId: aiStyleChild!.id,
        status: 5,
        styleType: styleType,
        type: widget.draftRender.type);
    draft.draftShidai = shidai;
    draft.lockedSeed = widget.draftRender.lockedSeed;
    //把AiScriptDraft的渲染草稿保存到本地，默认taskId
    var uuid = Uuid();
    String uniqueString = uuid.v4();
    //为本地新增一个任务草稿
    // final appBloc = BlocProvider.of<DraftBloc>(context);
    // final id = await appBloc.addOneDraft(Draft(
    //     icon: draft.tweetScript!.icon,
    //     taskId: uniqueString,
    //     name: draft.name,
    //     created: DateTime.now(),
    //     updated: DateTime.now(),
    //     status: 4,
    //     type: draft.type ?? 1));
    draft.tweetScript!.taskId = uniqueString;
    // draft.id = id;
    draft.audioPath = aiSceneGood.audioPath;

    Navigator.pop(context);
    // Navigator.pop(context);
    Navigator.pushNamed(context, UnitRouter.widget_scene_edit,
        arguments: draft);
  }
}

///尺寸选择
class VideoRatioWidget extends StatefulWidget {
  final Function(int) onRatioChanged;
  final int initRatio;

  const VideoRatioWidget(
      {super.key, required this.onRatioChanged, required this.initRatio});

  @override
  _YourWidgetState createState() => _YourWidgetState();
}

class _YourWidgetState extends State<VideoRatioWidget> {
  late int selectedIndex;

  @override
  void initState() {
    selectedIndex = widget.initRatio;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> ratios = ['1:1', '4:3', '16:9', '9:16', '3:4'];
    return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              height: 30,
              child: const Text(
                "画面尺寸",
                style: TextStyle(fontSize: 14),
              ),
            ),
            Flexible(
              flex: 2,
              child: buildRow(ratios),
            )
          ],
        ));
  }

  Widget buildRow(List<String> ratios) {
    List<Widget> ratioWidget = [];
    for (int i = 0; i < ratios.length; i++) {
      Widget widget = Expanded(
        flex: 1,
        child: _buildItem(ratios[i], i),
      );
      ratioWidget.add(widget);
    }
    return Row(children: ratioWidget);
  }

  Widget _buildItem(String title, int index) => Padding(
        padding: EdgeInsets.only(left: 15),
        child: GestureDetector(
          onTap: () {
            widget.onRatioChanged(index);
            setState(() {
              selectedIndex = index;
            });
          },
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: selectedIndex == index
                  ? Color(0x7F17B4BE)
                  : Colors.transparent,
              border: Border.all(
                color: Color(0xFF808080),
                width: 2, // 设置边框宽度
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                color:
                    selectedIndex == index ? Colors.white : Color(0xFFA6A6A6),
                // shadows: [
                //   Shadow(
                //       color: Colors.black,
                //       offset: Offset(.5, .5),
                //       blurRadius: 2),
                // ],
              ),
            ),
          ),
        ),
      );
}

class UserInputConfig {
  int ratio;
  String voiceId;
  int initStyleId;
  int voiceSpeed;
  int selectInputType;

  UserInputConfig(
      {this.ratio = 1,
      this.voiceId = "zhimiao_emo#1",
      this.initStyleId = 90,
      this.voiceSpeed = 76,
      this.selectInputType = 0});

  @override
  String toString() {
    return '保存配置：：ratio:$ratio,voiceId:$voiceId,initStyleId:$initStyleId,voiceSpeed:$voiceSpeed,selectInputType:$selectInputType';
  }
}
