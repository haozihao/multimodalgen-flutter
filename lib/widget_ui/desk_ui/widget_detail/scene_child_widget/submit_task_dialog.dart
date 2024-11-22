import 'dart:io';

import 'package:components/toly_ui/ti/circle.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pieces_ai/app/model/ai_draft.dart';
import 'package:utils/utils.dart';

import '../../../../app/api_https/ai_story_repository.dart';
import '../../../../app/api_https/impl/https_ai_config_repository.dart';
import '../../../../app/model/TweetScript.dart';
import '../../../../app/model/ai_image2_video.dart';
import '../../../../app/model/config/ai_analyse_role_scene.dart';
import '../../../../app/model/config/ai_tts_style.dart';
import '../../../../app/model/user_info_global.dart';
import '../../../../app/navigation/mobile/theme/theme.dart';
import '../widget_ai_chose/ai_tts_styles_grid.dart';

var logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

///提交任务选项组件
class SubmitTaskDialog extends StatefulWidget {
  final DraftRender draft;
  final RolesAndScenes? rolesAndScenes;
  final HttpAiConfigRepository aiConfigRepository;
  final AiStoryRepository aiStoryRepository;
  final Function(bool) onSubmit;
  final double motionStrength;

  ///0表示图片任务，1表示视频任务
  final int taskType;

  SubmitTaskDialog({Key? key,
    required this.draft,
    this.rolesAndScenes,
    required this.aiConfigRepository,
    required this.aiStoryRepository,
    required this.onSubmit,
    required this.motionStrength,
    required this.taskType})
      : super(key: key);

  @override
  State<SubmitTaskDialog> createState() => _SubmitTaskDialogState();
}

class _SubmitTaskDialogState extends State<SubmitTaskDialog> {
  double progress = 0.0;
  late final player = AudioPlayer();
  late String ttsType;
  late int speed;
  List<bool> _isChecked = [false, false, false];
  late int peggImg;
  late int peggTts;
  double _diversity = 0;
  late Future<List<AiTtsStyle>> _aiTtsStyleListFuture;
  int videoModelVersion = 2;
  bool allVideo = true;

  //30为低质量模式，50为高质量模式
  int step = 30;

  @override
  void initState() {
    ttsType = widget.draft.tweetScript!.tts.type;
    speed = widget.draft.tweetScript!.tts.speed!;
    _aiTtsStyleListFuture = widget.aiConfigRepository.loadTtsStyles();
    //如果是提交视频任务，则默认选中动态视频
    if (widget.taskType == 1) {
      _isChecked[0] = true;
    }
    _calculatePegg();
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBar(context),
        _buildTitle(context),
        _buildContent(),
        // Expanded(child: _buildContent()),
        _buildFooter(context),
        if (isSubmitting)
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withAlpha(33),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF12CDD9)),
          )
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Center(child: Text(
      '提交任务',
      style: const TextStyle(
          color: AppColor.piecesBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold),
    ) ,);
  }

  String _getLabel(double value) {
    switch (value.round()) {
      case 0:
        return '普通(HD)';
      case 1:
        return '高清(FHD)';
      case 2:
        return '超清(QHD)';
      default:
        return '';
    }
  }

  Widget _buildContent() {
    return Container(
      // color: Colors.grey.withAlpha(33),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.taskType == 0)
            Padding(
              padding: EdgeInsets.only(left: 15, top: 15),
              child: Row(
                children: [
                  Circle(
                    color: Color(0xFF12CDD9),
                    radius: 7,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Tooltip(
                      message: "默认为HD普通高清。FHD扣除皮蛋4倍，QHD扣除皮蛋6倍。质量越高，图片细节越丰富",
                      child: Text(
                        "图片质量：",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Text(
                      "${_getLabel(_diversity)}",
                      style: TextStyle(fontSize: 15, color: Color(0xFF12CDD9)),
                    ),
                  )
                ],
              ),
            ),
          if (widget.taskType == 0)
            Padding(
              padding: EdgeInsets.only(left: 15, top: 5),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "默认为HD普通高清。FHD扣除皮蛋4倍，QHD扣除皮蛋6倍。质量越高，图片细节越丰富",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  )),
            ),
          if (widget.taskType == 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        valueIndicatorTextStyle: TextStyle(
                          color: Colors.white,
                        ),
                        valueIndicatorColor: Color(0xFF12CDD9),
                        showValueIndicator: ShowValueIndicator.always,
                      ),
                      child: Slider(
                        value: _diversity,
                        min: 0,
                        max: 2,
                        divisions: 2,
                        activeColor: Color(0xFF12CDD9),
                        label: _getLabel(_diversity),
                        inactiveColor: Colors.green.withAlpha(99),
                        onChanged: (value) {
                          setState(() {
                            _diversity = value;
                            _calculatePegg();
                          });
                        },
                        onChangeEnd: (value) {
                          print("滑动结束:" + _diversity.toStringAsFixed(1));
                        },
                      ),
                    )),
              ],
            ),
          if (_isChecked[0]) _buildVideoModelSelect(),
          if (widget.taskType == 1)
            CheckboxListTile(
              title: Text('动态视频'),
              subtitle: Text(
                '勾选后每个分镜将生成动态视频',
                style: TextStyle(fontSize: 12),
              ),
              value: _isChecked[0],
              activeColor: Color(0xFF12CDD9),
              onChanged: (value) {
                bool checked = value ?? false;
                setState(() {
                  peggImg;
                  peggTts;
                  _isChecked[0] = checked;
                  _calculatePegg();
                });
              },
            ),
          if (widget.taskType == 0)
            CheckboxListTile(
              title: Text('Ai提示词'),
              subtitle:
              Text('勾选后将在原提示词基础上增加Ai推理提示词',
                  style: TextStyle(fontSize: 12)),
              value: _isChecked[1],
              activeColor: Color(0xFF12CDD9),
              onChanged: (value) {
                bool checked = value ?? false;
                setState(() {
                  peggImg;
                  peggTts;
                  _isChecked[1] = checked;
                  _calculatePegg();
                });
              },
            ),
          CheckboxListTile(
            title: Text('重新配音'),
            subtitle: Text(
                '勾选后将重新生成TTS配音', style: TextStyle(fontSize: 12)),
            value: _isChecked[2],
            activeColor: Color(0xFF12CDD9),
            onChanged: (value) {
              bool checked = value ?? false;
              setState(() {
                peggImg;
                peggTts;
                _isChecked[2] = checked;
                _calculatePegg();
              });
            },
          ),
          if (_isChecked[2])
            SizedBox(
              height: 200,
              child: _buildTtsSelectWidget(),
            ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              widget.taskType == 0
                  ? "生图 -${peggImg}  语音 -${peggTts}"
                  : "生视频 -${peggImg}  语音 -${peggTts}",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.justify,
            ),
          )
        ],
      ),
    );
  }

  _buildVideoModelSelect() {
    return Column(
      children: [
        // Row(
        //   children: [
        //     //模型单选，可以选择2个型号，一个选择1.0版本，一个选择2.0版本
        //     SizedBox(width: 15,),
        //     Text("模型型号："),
        //     Text('1.0', style: TextStyle(fontSize: 12)),
        //     Radio(
        //       value: 1,
        //       groupValue: videoModelVersion,
        //       onChanged: (value) {
        //         setState(() {
        //           videoModelVersion = value as int;
        //           _calculatePegg();
        //         });
        //       },
        //     ),
        //     Tooltip(
        //       message: "XL视频模型支持提示词引导运动。可生成更加个性化的视频",
        //       child: Text('2.0', style: TextStyle(fontSize: 12)),
        //     ),
        //     //2.0模型只支持6秒视频
        //     Radio(
        //       value: 2,
        //       groupValue: videoModelVersion,
        //       onChanged: (value) {
        //         setState(() {
        //           videoModelVersion = value as int;
        //           _calculatePegg();
        //         });
        //       },
        //     ),
        //   ],
        // ),
        // Divider(
        //   height: 1,
        //   color: Colors.grey,
        // ),
        Row(
          children: [
            //模型单选，可以选择2个型号，一个选择1.0版本，一个选择2.0版本
            SizedBox(width: 15,),
            Text("范围："),
            Text('所有分句', style: TextStyle(fontSize: 12)),
            Radio(
              value: true,
              groupValue: allVideo,
              onChanged: (value) {
                setState(() {
                  allVideo = value as bool;
                  _calculatePegg();
                });
              },
            ),
            Tooltip(
              message: "只针对视频模式分句生成视频",
              child: Text('视频分句', style: TextStyle(fontSize: 12)),
            ),
            //2.0模型只支持6秒视频
            Radio(
              value: false,
              groupValue: allVideo,
              onChanged: (value) {
                setState(() {
                  allVideo = value as bool;
                  _calculatePegg();
                });
              },
            ),
          ],
        ),
        Divider(
          height: 1,
          color: Colors.grey,
        ),
        Row(
          children: [
            SizedBox(
              width: 15,
            ),
            Text('高质量模式', style: TextStyle(fontSize: 12)),
            //使用checkbox选择是否启动高质量模型
            Checkbox(
              value: step == 50,
              onChanged: (value) {
                setState(() {
                  step = value! ? 50 : 30;
                  _calculatePegg();
                });
              },
            ),
            SizedBox(
              width: 15,
            ),
          ],
        ),

      ],
    );
  }

  ///重新计算皮蛋数
  _calculatePegg() {
    peggImg = 0;
    int sentenceLen = 0;
    for (int i = 0; i < widget.draft.tweetScript!.scenes[0].imgs.length; i++) {
      var tweetImg = widget.draft.tweetScript!.scenes[0].imgs[i];

      //如果勾选了全部生视频，则直接计算为视频
      if(widget.taskType == 0){
        if (tweetImg.url?.isEmpty ?? true) {
          if (widget.draft.styleType == 0) {
            //本地模式，图片不扣
            peggImg += 1;
          }
        }
      }else{
        if (allVideo) {
          if (widget.draft.styleType != 1) {
            //本地模式，图片不扣
            if (videoModelVersion == 1) {
              peggImg += 20;
            } else {
              peggImg += 80;
            }
          }
        } else {
          if (tweetImg.mediaType == 1) {
            //生动画每个分镜扣10皮蛋
            if (tweetImg.videoUrl?.isEmpty ?? true) {
              if (widget.draft.styleType != 1) {
                if (videoModelVersion == 1) {
                  peggImg += 20;
                } else {
                  peggImg += 80;
                }
              }
            }
          } else {
            if (tweetImg.url?.isEmpty ?? true) {
              if (widget.draft.styleType != 1) {
                //本地模式，图片不扣
                peggImg += 1;
              }
            }
          }
        }
      }
      //看当前分句是否已经有配音，没有的话则需要计算
      //如果是强制配音，则直接计算
      if (_isChecked[2]) {
        //重新配音
        sentenceLen += tweetImg.sentence.length;
      } else {
        if (tweetImg.tts?.url?.isEmpty ?? true) {
          sentenceLen += tweetImg.sentence.length;
        }
      }
    }

    peggTts = 0;
    if (widget.draft.tweetScript?.ttsEnable == true) {
      peggTts = (sentenceLen / 100).ceil();
    }
    //看选择的_diversity值，如果是0则扣除皮蛋为1倍，1为4倍，2为6倍
    if (_diversity == 0) {
      peggImg = peggImg;
    } else if (_diversity == 1) {
      peggImg *= 4;
    } else if (_diversity == 2) {
      peggImg *= 6;
    }

    //如果是高质量模式，则扣除皮蛋增加一倍
    if (step == 50) {
      peggImg *= 2;
    }
    logger.d("图片皮蛋：${peggImg}，TTS皮蛋：${peggTts}");
  }

  Widget _buildFooter(context) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 15.0, top: 10, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          InkWell(
            onTap: () {
              //查看当前是否有进行的任务
              var nowRunTask = GlobalConfiguration().get("now_run");
              if (nowRunTask >= 3) {
                MotionToast.info(description: Text("当前已达并发任务上限：3个"))
                    .show(context);
                return;
              }
              //看皮蛋是否充足
              var user = GlobalInfo.instance.user;
              if (user.pegg < (peggImg + peggTts)) {
                MotionToast.info(description: Text("当前皮蛋不足！")).show(
                    context);
              } else {
                //如果是追爆款，需要检查原文
                if (widget.draft.type == 3 &&
                    widget.draft.tweetScript!.scenes[0].imgs[0].sentence
                        .isEmpty) {
                  MotionToast.info(description: Text("请先获取原文！")).show(
                      context);
                  return;
                }
                _submitTask(peggImg + peggTts);
              }
            },
            child: Container(
              alignment: Alignment.center,
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  color: Color(0xFF12CDD9)),
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

  ///TTS选择的widget
  _buildTtsSelectWidget() {
    var initSpeed = speed / 50;
    return FutureBuilder<List<AiTtsStyle>>(
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
            player: player,
            aiTtsStyleList: snapshot.data ?? [],
            aiTtsModelChanged: (AiTtsStyle aiTtsStyle, double speed) {
              logger.d("选中了音色:" +
                  aiTtsStyle.name +
                  " 速度：" +
                  speed.toStringAsFixed(1));
              ttsType = aiTtsStyle.type;
              this.speed = (50 * speed).toInt();
            },
            initSpeed: initSpeed,
            onTtsOpen: (select) {},
            draftType: 1,
            selectType: ttsType,
          );
        }
      },
    );
  }

  _buildBar(context) =>
      Row(
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
                color: Theme
                    .of(context)
                    .primaryColor,
              ),
            ),
          ),
        ],
      );

  bool isSubmitting = false;

  void _submitTask(int pegg) async {
    if (isSubmitting) {
      MotionToast.warning(description: Text("请不要重复提交！")).show(context);
      return;
    }
    setState(() {
      isSubmitting = true;
    });
    for (int i = 0; i < widget.draft.tweetScript!.scenes[0].imgs.length; i++) {
      TweetImage tweetImage = widget.draft.tweetScript!.scenes[0].imgs[i];
      if (_isChecked[0] || tweetImage.mediaType == 1) {
        if (tweetImage.url == null || tweetImage.url!.isEmpty) {
          MotionToast.info(description: Text("视频模式需要先生成所有图片！"))
              .show(context);
          isSubmitting = false;
          return;
        }
      }
      if (widget.draft.styleType != 0) {
        //如果是本地模式，先看是否图片都已经生成完整，不完整则不让提交
        if (tweetImage.url == null || tweetImage.url!.isEmpty) {
          MotionToast.info(description: Text("本地模式需要生成所有图片！")).show(
              context);
          isSubmitting = false;
          return;
        }
      } else {
        //非本地模式，但是是追爆款，把所有原图上传再提交任务
        if (widget.draft.type == 3) {
          if (tweetImage.origin?.localUrl?.isNotEmpty ?? true) {
            //如果已经生过图了则不需要提交
            if (tweetImage.url?.isEmpty ?? true) {
              String httpUrl = await widget.aiConfigRepository.fileUpload(
                  filePath: tweetImage.origin!.localUrl!,
                  specFolder: "windows_hot",
                  format: "jpg");
              logger.d("追爆款模式提交任务上传本地图片:" + httpUrl);
              //替换本地路径为线上路径
              tweetImage.origin?.image = httpUrl;
            }
          }
          widget.draft.tweetScript?.useOrigin = true;
        }
      }
      setState(() {
        progress = i * 0.95 / widget.draft.tweetScript!.scenes[0].imgs.length;
        logger.d("=提交任务 progress:" + progress.toString());
      });
    }

    for (int i = 0; i < widget.draft.tweetScript!.scenes[0].imgs.length; i++) {
      TweetImage tweetImage = widget.draft.tweetScript!.scenes[0].imgs[i];
      //云端或者fast-sd，并且短剧
      if (widget.draft.styleType == 0 || widget.draft.styleType == 2) {
        if (widget.draft.type == 1 || widget.draft.type == 3) {
          if (tweetImage.sentence.isEmpty && tweetImage.mediaType == 0) {
            logger.d("删除没有原文的分镜:" + i.toString());
            widget.draft.tweetScript!.scenes[0].imgs.removeAt(i);
          }
          //如果选择了每个分镜生成视频，则修改每个分句的类型
          if(widget.taskType==1){
            if (allVideo) {
              tweetImage.mediaType = 1;
              File? cachedImageFile =
              await FileUtil.getImageFile(tweetImage.url!);
              if (cachedImageFile != null) {
                String imageUrl = await widget.aiConfigRepository.fileUpload(
                    filePath: cachedImageFile.path,
                    specFolder: "windows_i2v",
                    format: "jpg");
                logger.d(
                    "选择了Ai动画视频模式:${_isChecked.toString()},图片上传成功Url：$imageUrl，原图大小：${cachedImageFile.length()}");
                if (widget.draft.type == 3) {
                  //追爆款模式有origin
                } else {
                  tweetImage.origin = Origin(
                      image2VideoParam: null,
                      image: '',
                      strength: widget.motionStrength);
                }
                //取得原来的image2VideoParam,如果没有则新建一个。有则修改某些值
                if (tweetImage.origin!.image2VideoParam == null) {
                  Image2VideoParam image2videoParam = Image2VideoParam(
                      image: imageUrl,
                      seed: -1,
                      //macos平台fps传24，其他传6
                      fps: 24,
                      // fps: Platform.isMacOS ? 24 : 6,
                      modelVersion: videoModelVersion,
                      steps: step,
                      //使用图片的提示词暂时
                      prompt: tweetImage.prompt,
                      ratio: widget.draft.tweetScript!.aiPaint.ratio,
                      motionStrength: widget.motionStrength.toInt(),
                      duration: 4);
                  tweetImage.origin!.image2VideoParam = image2videoParam;
                } else {
                  Image2VideoParam image2videoParam = tweetImage.origin!.image2VideoParam!;
                  image2videoParam.image = imageUrl;
                  image2videoParam.modelVersion = videoModelVersion;
                  image2videoParam.steps = step;
                  image2videoParam.fps = 24;
                  image2videoParam.ratio = widget.draft.tweetScript!.aiPaint.ratio;
                  image2videoParam.motionStrength = widget.motionStrength.toInt();
                  image2videoParam.duration = 4;
                }
              }
            } else {
              //没有选择每个分镜则只提交单个分镜打开的
              if (tweetImage.mediaType == 1) {
                if (tweetImage.videoUrl == null || tweetImage.videoUrl!.isEmpty) {
                  File? cachedImageFile =
                  await FileUtil.getImageFile(tweetImage.url!);
                  if (cachedImageFile != null) {
                    String imageUrl = await widget.aiConfigRepository.fileUpload(
                        filePath: cachedImageFile.path,
                        specFolder: "windows_i2v",
                        format: "jpg");
                    logger.d(
                        "有个单个分镜生视频:${_isChecked.toString()},图片上传成功Url：$imageUrl，原图大小：${cachedImageFile.length()}");
                    if (widget.draft.type == 3) {
                      //追爆款模式有origin
                    } else {
                      if(tweetImage.origin==null){
                        tweetImage.origin = Origin(
                            image2VideoParam: null,
                            image: '',
                            strength: widget.motionStrength);
                      }
                    }
                    //取得原来的image2VideoParam,如果没有则新建一个。有则修改某些值
                    if (tweetImage.origin!.image2VideoParam == null) {
                      Image2VideoParam image2videoParam = Image2VideoParam(
                          image: imageUrl,
                          seed: -1,
                          //macos平台fps传24，其他传6
                          fps: 24,
                          // fps: Platform.isMacOS ? 24 : 6,
                          modelVersion: videoModelVersion,
                          steps: step,
                          //使用图片的提示词暂时
                          prompt: tweetImage.prompt,
                          ratio: widget.draft.tweetScript!.aiPaint.ratio,
                          motionStrength: widget.motionStrength.toInt(),
                          duration: 4);
                      tweetImage.origin!.image2VideoParam = image2videoParam;
                    } else {
                      Image2VideoParam image2videoParam = tweetImage.origin!.image2VideoParam!;
                      image2videoParam.image = imageUrl;
                      image2videoParam.modelVersion = videoModelVersion;
                      image2videoParam.steps = step;
                      image2videoParam.fps = 24;
                      image2videoParam.ratio = widget.draft.tweetScript!.aiPaint.ratio;
                      image2videoParam.motionStrength = widget.motionStrength.toInt();
                      image2videoParam.duration = 4;
                    }
                  }
                } else {
                  if (widget.draft.type == 3) {
                    logger.d("追爆款模式不清除图片:" + i.toString());
                  } else {
                    logger.d("已经生成过了，清除图片base64:" + i.toString());
                    tweetImage.origin =
                        Origin(image: "", strength: widget.motionStrength);
                  }
                }
              }
            }
          }

          //如果需要重新配音，则把配音信息修改，并且，把之前的配音清空
          if (_isChecked[2]) {
            logger.d("重新配音：$ttsType,语速：$speed");
            tweetImage.tts?.url = "";
            widget.draft.tweetScript!.tts.type = ttsType;
            widget.draft.tweetScript!.tts.speed = speed;
          }
        }
      }
    }

    //把识别待选的人物列表放入提交任务的信息
    if (widget.rolesAndScenes != null) {
      // Extract roles from rolesAndScenes
      List<TweetRole> tweetRoles = widget.rolesAndScenes!.roles
          .map((role) => TweetRole.fromRole(role))
          .toList();
      widget.draft.tweetScript!.roles = tweetRoles;
    }

    //如果是一键原创的,本地传音频的模式，吧本地音频上传到服务器，构建透传的bgm字段
    if (widget.draft.type == 1 && !widget.draft.tweetScript!.ttsEnable!) {
      if (widget.draft.audioPath?.isNotEmpty ?? true) {
        //上传到云端后
        // 检查文件是否存在
        File audioFile = File(widget.draft.audioPath!);
        if (await audioFile.exists()) {
          // 文件存在，执行上传操作
          String audioUrl = await widget.aiConfigRepository
              .fileUpload(filePath: widget.draft.audioPath!);
          logger.d("本地上传音频:" + audioUrl);
          widget.draft.tweetScript!.bgm = Bgm(bgmUrl: audioUrl, duratuion: 0);
        } else {
          // 文件不存在
          MotionToast.error(description: Text("提交任务报错了。本地音频不存在："))
              .show(context);
          // 在这里可以添加相应的处理逻辑，比如给用户提示文件不存在等
        }
      }
    }

    //根据_diversity的值，设置图片质量
    if (_diversity == 0) {
      // widget.draft.tweetScript!.aiPaint.hd.scale = 0;
    } else if (_diversity == 1) {
      widget.draft.tweetScript!.aiPaint.hd.scale = 3.5;
    } else if (_diversity == 2) {
      widget.draft.tweetScript!.aiPaint.hd.scale = 4.0;
    }

    //是否强制增加Ai推理提示词
    if (_isChecked[1]) {
      widget.draft.tweetScript!.aiPrompt = true;
      logger.d("强制推理提示词:");
    }

    // 异步访问网络获得String的list
    TaskResult<String> taskResult = await widget.aiStoryRepository.addTask(
        tweetScript: widget.draft.tweetScript!,
        pegg: pegg,
        type: widget.draft.type ?? 1);
    setState(() {
      progress = 1.0;
    });
    if (!taskResult.success) {
      MotionToast.error(
          description: Text(
              "提交任务报错了。请联系客服!具体信息为：${taskResult.msg}"))
          .show(context);
      isSubmitting = false;
      return;
    }
    String taskId = taskResult.data!;

    //把AiScriptDraft的渲染草稿保存到本地
    widget.draft.tweetScript!.taskId = taskId;
    //提交任务后草稿状态更改为进行中
    widget.draft.status = 0;
    isSubmitting = false;
    widget.onSubmit(true);
  }
}
