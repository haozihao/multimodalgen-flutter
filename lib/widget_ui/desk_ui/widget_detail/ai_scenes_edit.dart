import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pieces_ai/app/api_https/ai_story_repository.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_config_repository.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_story_fastsd.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_story_localsd.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_story_repository.dart';
import 'package:pieces_ai/app/api_https/impl/https_video_copy_repository.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';
import 'package:pieces_ai/app/model/ai_draft.dart';
import 'package:pieces_ai/app/model/config/ai_analyse_role_scene.dart';
import 'package:pieces_ai/app/model/user_info_global.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/ai_roles_scenes_select.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/scene_child_widget/ReplaceText.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/scene_child_widget/global_tags_operation.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/scene_child_widget/submit_task_dialog.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/widget_ai_chose/ai_input_content.dart';
import 'package:pieces_ai/widget_ui/mobile/category_page/delete_category_dialog.dart';
import 'package:pieces_ai/widget_ui/mobile/category_page/seek_confim_dialog.dart';
import 'package:storage/storage.dart';
import 'package:utils/utils.dart';
import 'package:widget_module/blocs/category_bloc/draft_bloc.dart';

import '../../../app/navigation/mobile/theme/theme.dart';
import '../../mobile/category_page/edit_draft_panel.dart';
import 'draft_scene_item.dart';

///分句编辑页面。
var logger = Logger(printer: PrettyPrinter(methodCount: 0));

class SliverListSceneEdit extends StatefulWidget {
  final DraftRender draft;

  const SliverListSceneEdit({Key? key, required this.draft}) : super(key: key);

  @override
  State<SliverListSceneEdit> createState() => _SliverListSceneEditState();
}

class _SliverListSceneEditState extends State<SliverListSceneEdit> {
  int count = 0;
  double strength = 0.0;
  double motionStrength = 50;
  final HttpAiConfigRepository aiConfigRepository = HttpAiConfigRepository();
  late AiStoryRepository aiStoryRepository;
  late HttpsVideoCopyRepository httpsVideoCopyRepository;
  final AudioPlayer player = AudioPlayer();
  RolesAndScenes? rolesAndScenes;

  List<GlobalKey<DraftListItemState>> _itemKeys = [];

  @override
  void initState() {
    count = widget.draft.tweetScript!.scenes[0].imgs.length;
    rolesAndScenes = widget.draft.rolesAndScenes;
    aiStoryRepository = widget.draft.styleType == 0
        ? HttpAiStoryRepository()
        : widget.draft.styleType == 1
            ? HttpAiStoryLocalSd()
            : HttpAiStoryFastSd();
    if (widget.draft.type == 3) {
      httpsVideoCopyRepository = HttpsVideoCopyRepository();
    }
    if (rolesAndScenes != null) {
      logger.d('识别的人物和场景' + rolesAndScenes!.roles.length.toString());
    }
    _initializeItemKeys();
    super.initState();
  }

  void _initializeItemKeys() {
    _itemKeys = List.generate(
      widget.draft.tweetScript!.scenes[0].imgs.length,
      (_) => GlobalKey<DraftListItemState>(),
    );
  }

  @override
  void didUpdateWidget(covariant SliverListSceneEdit oldWidget) {
    super.didUpdateWidget(oldWidget);
    logger.d(
        "老的个数：${oldWidget.draft.tweetScript!.scenes[0].imgs.length},新的个数：${widget.draft.tweetScript!.scenes[0].imgs.length}");
    if (widget.draft.tweetScript!.scenes[0].imgs.length !=
        oldWidget.draft.tweetScript!.scenes[0].imgs.length) {
      _initializeItemKeys();
    }
  }

  @override
  void dispose() {
    player.dispose();
    EasyLoading.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          logger.d("是否退出编辑页面：" + didPop.toString());
          if (didPop) return;
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                elevation: 5,
                title: const Text('有未保存修改'),
                content: const Text('点击确定保存草稿并退出？'),
                actions: <Widget>[
                  // TextButton(
                  //   onPressed: () {
                  //     // 回到主页并关闭指定页面
                  //     Navigator.pushNamedAndRemoveUntil(
                  //       context,
                  //       UnitRouter.nav,
                  //       (route) => route == null,
                  //     );
                  //   },
                  //   child: const Text('直接退出！'),
                  // ),
                  TextButton(
                    onPressed: () async {
                      await _saveStatus4Draft(true, widget.draft.status);
                      // 回到主页并关闭指定页面
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        UnitRouter.nav,
                        (route) => route == null,
                      );
                    },
                    child: const Text('确定'),
                  ),
                ],
              );
            },
          );
        },
        child: Scaffold(
          backgroundColor: AppColor.piecesBlackGrey,
          appBar: AppBar(
            title: _buildWindowTopArea(),
            backgroundColor: AppColor.piecesBlackGrey,
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: _buildTopButton(context),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.draft.tweetScript!.scenes[0].imgs.length,
                  //纵向的space
                  itemBuilder: (_, int index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                      child: DraftSceneItem(
                        key: _itemKeys[index],
                        player: player,
                        motionStrength: motionStrength,
                        onDeleteItemClick: (tweetImage, index) {
                          //删除后把删除分句的时间累加到上一句
                          if (widget.draft.tweetScript?.ttsEnable == false) {
                            double duration = tweetImage.tts!.duration!;
                            if (index == 0) {
                              //累加到下一句
                              if (widget.draft.tweetScript!.scenes[0].imgs
                                      .length >
                                  1) {
                                TweetImage next = widget.draft.tweetScript!
                                    .scenes[0].imgs[index + 1];
                                next.tts!.duration ==
                                    (next.tts!.duration! + duration);
                              }
                            } else {
                              TweetImage pre = widget
                                  .draft.tweetScript!.scenes[0].imgs[index - 1];
                              pre.tts!.duration =
                                  (pre.tts!.duration! + duration);
                              print('删除item duration：' +
                                  duration.toString() +
                                  "  上一句总时长:" +
                                  pre.tts!.duration.toString());
                            }
                          }
                          widget.draft.tweetScript!.scenes[0].imgs
                              .removeAt(index);
                          _initializeItemKeys();
                          setState(() {});
                        },
                        onMergeItemClick: (tweetImage, index) {
                          //向上合并
                          if (index > 0 &&
                              index <
                                  widget.draft.tweetScript!.scenes[0].imgs
                                      .length) {
                            TweetImage pre = widget
                                .draft.tweetScript!.scenes[0].imgs[index - 1];
                            double duration =
                                pre.tts!.duration! + tweetImage.tts!.duration!;
                            //置空音频
                            pre.tts?.url = "";
                            pre.tts?.fileLength = 0;
                            tweetImage.tts?.url = "";
                            tweetImage.tts?.fileLength = 0;
                            setState(() {
                              pre.sentence =
                                  pre.sentence + ' ' + tweetImage.sentence;
                              pre.tts!.duration = duration;
                              widget.draft.tweetScript!.scenes[0].imgs
                                  .removeAt(index);
                            });
                            _initializeItemKeys();
                          }
                        },
                        onMergeItemDownClick: (tweetImage, index) {
                          //向下合并
                          print('合并item：' +
                              tweetImage.sentence +
                              " index:" +
                              index.toString());
                          if (index <
                              widget.draft.tweetScript!.scenes[0].imgs.length -
                                  1) {
                            TweetImage next = widget
                                .draft.tweetScript!.scenes[0].imgs[index + 1];
                            String sentence = tweetImage.sentence +
                                ' ' +
                                next.sentence; //前一句的加在前面
                            double duration =
                                tweetImage.tts!.duration! + next.tts!.duration!;
                            //置空音频
                            next.tts?.url = "";
                            next.tts?.fileLength = 0;
                            tweetImage.tts?.url = "";
                            tweetImage.tts?.fileLength = 0;
                            setState(() {
                              next.sentence = sentence;
                              next.tts!.duration = duration;
                              widget.draft.tweetScript!.scenes[0].imgs
                                  .removeAt(index);
                            });
                            _initializeItemKeys();
                          }
                        },
                        onSubItemClick: (tweetImage, cursorPosition) {
                          String sentenceFirst =
                              tweetImage.sentence.substring(0, cursorPosition);
                          String sentenceTwo =
                              tweetImage.sentence.substring(cursorPosition);

                          int index = widget.draft.tweetScript!.scenes[0].imgs
                              .indexOf(tweetImage);
                          //在index+1处增加一个分句，时长为被拆分的句子按字数分为2个时间
                          ImgTts imgTtsTwo = tweetImage.tts!.copyWith();
                          double duration = imgTtsTwo.duration ?? 0;
                          if (duration == 0) {
                            imgTtsTwo.duration = 0;
                          } else {
                            imgTtsTwo.duration = sentenceTwo.length *
                                duration /
                                (sentenceFirst.length + sentenceTwo.length);
                          }
                          debugPrint('拆分item：' +
                              sentenceFirst +
                              " 后半截：" +
                              sentenceTwo +
                              "  之前时长：" +
                              duration.toString() +
                              " 拆分：" +
                              imgTtsTwo.duration.toString());
                          //把当前这句的文案修改，时长修改
                          tweetImage.sentence = sentenceFirst;
                          // tweetImage.ttsText = sentenceFirst;
                          tweetImage.tts!.duration =
                              duration - imgTtsTwo.duration!;
                          //置空音频
                          tweetImage.tts?.url = "";
                          tweetImage.tts?.fileLength = 0;
                          TweetImage newTweetImage = tweetImage.copyWith(
                              sentence: sentenceTwo.isEmpty ? " " : sentenceTwo,
                              userTags: [],
                              tts: imgTtsTwo);
                          widget.draft.tweetScript!.scenes[0].imgs
                              .insert(index + 1, newTweetImage);
                          setState(() {});
                          _initializeItemKeys();
                        },
                        httpAiStoryRepository: aiStoryRepository,
                        localMode: widget.draft.styleType != 0,
                        // httpAiStoryRepository: HttpAiStoryLocalSd(),
                        tweetImage:
                            widget.draft.tweetScript!.scenes[0].imgs[index],
                        index: index,
                        type: widget.draft.type ?? 1,
                        aiPaintParamsV2: widget.draft.tweetScript!.aiPaint,
                        roles:
                            rolesAndScenes == null ? [] : rolesAndScenes!.roles,
                        scenes: rolesAndScenes == null
                            ? []
                            : rolesAndScenes!.scenes,
                        shidai: widget.draft.draftShidai ?? 1,
                        lockedSeed: widget.draft.lockedSeed ?? true,
                        draftName: widget.draft.name,
                        tweetScriptTts: widget.draft.tweetScript?.tts,
                      ),
                    );
                  },
                ),
              ),
              _buildFooter(context)
            ],
          ),
        ));
  }

  _buildFooter(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (ctx) => Dialog(
                        elevation: 5,
                        backgroundColor: Color(0xFF383838),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 2 / 5,
                          child: SubmitTaskDialog(
                              draft: widget.draft,
                              taskType: 0,
                              motionStrength: motionStrength,
                              aiConfigRepository: aiConfigRepository,
                              aiStoryRepository: aiStoryRepository,
                              onSubmit: (success) async {
                                debugPrint("提交成功：" + success.toString());
                                MotionToast.success(description: Text("提交成功！"))
                                    .show(context);
                                await _saveStatus4Draft(true, 0);
                                // 回到主页并关闭指定页面
                                Navigator.of(context).pop();
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    UnitRouter.nav, (route) => false);
                              }),
                        ),
                      ));
            },
            child: Container(
              color: AppColor.piecesBackTwo,
              alignment: Alignment.center,
              height: 55,
              child: Text(
                textAlign: TextAlign.center,
                "提交图片任务",
                style: TextStyle(
                    color: AppColor.piecesBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          flex: 1,
        ),
        //竖线
        Container(
          width: 1,
          height: 55,
          color: AppColor.piecesBlackGrey,
        ),
        Flexible(
          child: GestureDetector(
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (ctx) => Dialog(
                        elevation: 5,
                        backgroundColor: Color(0xFF383838),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 2 / 5,
                          child: SubmitTaskDialog(
                              draft: widget.draft,
                              taskType: 1,
                              motionStrength: motionStrength,
                              aiConfigRepository: aiConfigRepository,
                              aiStoryRepository: aiStoryRepository,
                              onSubmit: (success) async {
                                debugPrint("提交成功：" + success.toString());
                                MotionToast.success(description: Text("提交成功！"))
                                    .show(context);
                                await _saveStatus4Draft(true, 0);
                                // 回到主页并关闭指定页面
                                Navigator.of(context).pop();
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    UnitRouter.nav, (route) => false);
                              }),
                        ),
                      ));
            },
            child: Container(
              color: AppColor.piecesBackTwo,
              alignment: Alignment.center,
              height: 55,
              child: Text(
                textAlign: TextAlign.center,
                "提交视频任务",
                style: TextStyle(
                    color: AppColor.piecesBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          flex: 1,
        )
      ],
    );
  }

  Widget _buildWindowTopArea() {
    return Row(
      children: [
        Text(
          "作品名：",
          style: TextStyle(fontSize: 11),
        ),
        Text(
          widget.draft.name,
          style: TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  ///保存未完成的草稿信息到mysqltaskId
  _saveStatus4Draft(bool refreshMain, int status) async {
    print("更新草稿信息 点击保存 status:" +
        widget.draft.status.toString() +
        "  有没有ID：" +
        widget.draft.id.toString());
    //刷新首页草稿数据
    var scenes = widget.draft.tweetScript!.scenes;
    var firstImg = widget.draft.tweetScript!.icon;

    if (scenes.isNotEmpty) {
      var imgs = scenes[0].imgs;
      if (imgs.length > 0) {
        firstImg = imgs[0].url ?? firstImg;
      }
    }
    if (firstImg.isEmpty || firstImg.endsWith(".mp4"))
      firstImg = widget.draft.tweetScript!.icon;

    if (refreshMain) {
      final appBloc = BlocProvider.of<DraftBloc>(context);
      if (widget.draft.id == null) {
        if (widget.draft.status == 5) widget.draft.status = 4;
        //吧预备役草稿转正
        appBloc.add(EventAddDraft(
            taskId: widget.draft.tweetScript!.taskId!,
            name: widget.draft.name,
            icon: firstImg,
            status: widget.draft.status,
            type: widget.draft.type ?? 1));
      } else {
        appBloc.add(EventUpdateDraft(
            id: widget.draft.id!,
            taskId: widget.draft.tweetScript!.taskId,
            name: widget.draft.name,
            icon: firstImg,
            status: widget.draft.status,
            type: widget.draft.type ?? 1));
      }
    } else {
      //不会到主页，不发出刷新事件
      final draftBloc = BlocProvider.of<DraftBloc>(context);
      if (widget.draft.id == null) {
        if (widget.draft.status == 5) widget.draft.status = 4;
        //吧预备役草稿转正
        await draftBloc.addOneDraft(Draft(
            icon: firstImg,
            taskId: widget.draft.tweetScript!.taskId,
            name: widget.draft.name,
            created: DateTime.now(),
            updated: DateTime.now(),
            status: widget.draft.status,
            type: widget.draft.type ?? 1));
      } else {
        await draftBloc.updateDraft(Draft(
            id: widget.draft.id!,
            icon: firstImg,
            taskId: widget.draft.tweetScript!.taskId,
            name: widget.draft.name,
            updated: DateTime.now(),
            status: widget.draft.status,
            type: widget.draft.type ?? 1));
      }
    }
    // }

    await _saveDraft(widget.draft.tweetScript!.taskId!);
  }

  ///文件写入，当重名时，覆盖文件
  Future<void> _saveDraft(String taskId) async {
    var appDir = await getApplicationDocumentsDirectory();
    String FileSeparate = FileUtil.getFileSeparate();
    String draftCache = "drafts";
    String draftsDir = appDir.path + FileSeparate + draftCache;
    if (!await Directory(draftsDir).exists()) {
      await Directory(draftsDir).create();
    }
    String aiScriptPath = draftsDir + FileSeparate + taskId + '.json';
    File aiScriptFile = File(aiScriptPath);
    await aiScriptFile.writeAsString(jsonEncode(widget.draft));
    print('保存草稿成功');
  }

  Widget _buildTopButton(BuildContext context) {
    return Row(
      children: [
        if (widget.draft.type != 3)
          Flexible(
            child: Container(
              height: 35,
              child: ElevatedButton(
                  //使用线框按钮
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: AppColor.piecesBlue, width: 1),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () async {
                    int styleId = widget.draft.styleId!;
                    if (widget.draft.styleType == 1) {
                      styleId = -1111;
                    } else if (widget.draft.styleType == 2) {
                      styleId = -1112;
                    }
                    //修改为页面跳转
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AiRoleSceneSelectWidget(
                                  rolesAndScenes: rolesAndScenes,
                                  onSave: (bool refresh) {
                                    //看是否有删除和增加角色，有的话需要刷新
                                    if (refresh) {
                                      setState(() {});
                                    }
                                  },
                                  styleId: styleId,
                                  //本地模式暂时固定id为-1111
                                  ratio:
                                      widget.draft.tweetScript!.aiPaint.ratio,
                                  aiPaintParamsV2:
                                      widget.draft.tweetScript!.aiPaint,
                                )));
                  },
                  child: const Text(
                    "固定人物",
                    style: TextStyle(fontSize: 10),
                  )),
            ),
            flex: 1,
          ),
        // Container(
        //   height: 35,
        //   child: ElevatedButton(
        //     onPressed: () async {
        //       int peggPrompt = 0;
        //       for (var tweetImg
        //           in widget.draft.tweetScript!.scenes[0].imgs) {
        //         if ((tweetImg.userTags == null ||
        //             tweetImg.userTags!.isEmpty)) {
        //           peggPrompt += 1;
        //         }
        //       }
        //       //看是否皮蛋足够
        //       if (widget.draft.type == 3 && widget.draft.styleType == 1) {
        //         //本地模式追爆款
        //       } else {
        //         var user = GlobalInfo.instance.user;
        //         if (user.pegg < peggPrompt) {
        //           Toast.error(context, "皮蛋不足！");
        //           MotionToast.warning(
        //                   description: Text(
        //                       "皮蛋不足！\n剩余皮蛋：${user.pegg} 需扣除：${peggPrompt} \n如皮蛋足够请尝试重新登录"))
        //               .show(context);
        //           return;
        //         }
        //       }
        //
        //       showDialog(
        //           context: context,
        //           builder: (ctx) => Dialog(
        //                 elevation: 5,
        //                 child: SizedBox(
        //                   width: 50,
        //                   child: DeleteCategoryDialog(
        //                     title: widget.draft.type == 3
        //                         ? "批量反推提示词"
        //                         : '批量推理提示词',
        //                     content: widget.draft.type == 3
        //                         ? widget.draft.styleType == 0
        //                             ? '反推 -${(peggPrompt)}'
        //                             : "本地反推免费"
        //                         : '推理 -${(peggPrompt)}',
        //                     onSubmit: () async {
        //                       // 开始批量出提示词，并更新进度
        //                       int totalItems = widget
        //                           .draft.tweetScript!.scenes[0].imgs.length;
        //
        //                       for (int i = 0; i < totalItems; i++) {
        //                         EasyLoading.showProgress(i / totalItems,
        //                             status: '批量推理进度：$i/总共$totalItems');
        //                         TweetImage tweetImage = widget
        //                             .draft.tweetScript!.scenes[0].imgs[i];
        //                         if (tweetImage.userTags != null &&
        //                             tweetImage.userTags!.isNotEmpty) {
        //                           continue;
        //                         }
        //
        //                         List<UserTag> userTags = [];
        //                         if (widget.draft.type == 3) {
        //                           List<int> imageBytes =
        //                               File(tweetImage.origin!.image)
        //                                   .readAsBytesSync();
        //                           String imageBase64 =
        //                               base64Encode(imageBytes);
        //                           List<String> prompts =
        //                               widget.draft.styleType == 0
        //                                   ? await httpsVideoCopyRepository
        //                                       .aiPromptByImg(
        //                                           imageBase64: imageBase64)
        //                                   : await httpsVideoCopyRepository
        //                                       .aiPromptByImgLocal(
        //                                           imageBase64: imageBase64);
        //                           String promptConbin = "";
        //                           prompts.forEach((prompt) async {
        //                             var userTagNew;
        //                             userTagNew = new UserTag(
        //                                 tagEn: prompt, tagZh: prompt);
        //                             userTags.add(userTagNew);
        //                             promptConbin += prompt;
        //                             promptConbin += ",";
        //                           });
        //                           if (HttpUtil.baiduTk.isNotEmpty) {
        //                             userTags.clear();
        //                             String zhPromptConbin =
        //                                 await aiStoryRepository.textTrans(
        //                                     text: promptConbin,
        //                                     langFrom: "en",
        //                                     langTo: "zh");
        //                             print("翻译结果：" + zhPromptConbin);
        //                             List<String> promptZhs =
        //                                 zhPromptConbin.split("，");
        //                             List<String> promptEns =
        //                                 promptConbin.split(",");
        //                             for (int i = 0;
        //                                 i < promptEns.length;
        //                                 i++) {
        //                               if (promptEns[i].isEmpty ||
        //                                   i >= promptZhs.length) {
        //                                 continue;
        //                               }
        //                               var userTagNew = new UserTag(
        //                                   tagEn: promptEns[i],
        //                                   tagZh: promptZhs[i]);
        //                               userTags.add(userTagNew);
        //                             }
        //                           }
        //                         } else {
        //                           var userTag;
        //                           String prompt =
        //                               await aiStoryRepository.aiPrompt(
        //                                   sentence: tweetImage.sentence,
        //                                   shidai:
        //                                       widget.draft.draftShidai ??
        //                                           1);
        //                           if (HttpUtil.baiduTk.isNotEmpty) {
        //                             String zhPrompt =
        //                                 await aiStoryRepository.textTrans(
        //                                     text: prompt,
        //                                     langFrom: "en",
        //                                     langTo: "zh");
        //                             print("翻译结果：" + zhPrompt);
        //                             userTag = new UserTag(
        //                                 tagEn: prompt, tagZh: zhPrompt);
        //                           } else {
        //                             userTag = new UserTag(
        //                                 tagEn: prompt, tagZh: prompt);
        //                           }
        //                           userTags.add(userTag);
        //                         }
        //
        //                         setState(() {
        //                           if (tweetImage.userTags == null) {
        //                             tweetImage.userTags = [];
        //                           }
        //                           if (tweetImage.userTags!.isEmpty) {
        //                             tweetImage.userTags!.addAll(userTags);
        //                           } else {
        //                             tweetImage.userTags!
        //                                 .insertAll(0, userTags);
        //                           }
        //                         });
        //                       }
        //                       EasyLoading.showSuccess("批量推理完成！",
        //                           duration: Duration(seconds: 1));
        //                       // EasyLoading.dismiss();
        //                     },
        //                   ),
        //                 ),
        //               ));
        //     },
        //     child: Text(
        //       widget.draft.type == 3 ? "批量反推提示词" : '批量推理提示词',
        //       style: TextStyle(fontSize: 10),
        //     ),
        //   ),
        // ),
        // Container(
        //   height: 35,
        //   child: ElevatedButton(
        //     onPressed: () async {
        //       showDialog(
        //           context: context,
        //           builder: (ctx) => Dialog(
        //                 elevation: 5,
        //                 child: SizedBox(
        //                   width: MediaQuery.of(context).size.width * 1 / 5,
        //                   child: BatchGeneralImageOptionPanel(
        //                     onSubmit: (bool reGeneralImage) async {
        //                       logger.d('是否批量生图：$reGeneralImage');
        //                       await _batchGeneralImg(reGeneralImage);
        //                     },
        //                     title: "批量生图",
        //                     styleType: widget.draft.styleType ?? 0,
        //                     tweetScript: widget.draft.tweetScript!,
        //                   ),
        //                 ),
        //               ));
        //     },
        //     child: const Text(
        //       "批量生图",
        //       style: TextStyle(fontSize: 10),
        //     ),
        //   ),
        // ),
        Flexible(
          child: Container(
            height: 35,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: AppColor.piecesBlue, width: 1),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () async {
                addAllItemTag(EditType.add);
              },
              child: const Text(
                "全局提示词",
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
          flex: 1,
        ),
        // Spacer(),
        Flexible(
          child: Container(
            height: 35,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: AppColor.piecesBlue, width: 1),
              ),
              onPressed: () async {
                replaceOriginalText(EditType.add);
              },
              child: const Text(
                "替换原文",
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
          flex: 1,
        ),
        if (widget.draft.type == 3)
          Flexible(
            child: Container(
              // padding: const EdgeInsets.only(left: 40),
              height: 35,
              child: ElevatedButton(
                onPressed: () async {
                  int peggAsr = (widget.draft.audioSeconds! * 2 / 50).ceil();
                  if (peggAsr <= 10) peggAsr = 10;
                  //看是否皮蛋足够
                  var user = GlobalInfo.instance.user;
                  if (user.pegg < peggAsr) {
                    Toast.error(context, "皮蛋不足！");
                    return;
                  }
                  print("视频长度:" + widget.draft.audioSeconds.toString());
                  showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                            elevation: 5,
                            child: SizedBox(
                              width: 50,
                              child: DeleteCategoryDialog(
                                title: 'AI原文识别',
                                content: '识别 -${(peggAsr)}',
                                onSubmit: () async {
                                  //先上传文件，在访问识别接口
                                  if (widget.draft.audioPath != null) {
                                    //弹窗
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return const SimpleDialog(
                                          children: <Widget>[
                                            Center(
                                              child: Text('Ai识别原视频字幕中...'),
                                            ),
                                            Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    String audioUrl = "";
                                    if (widget.draft.audioPath!
                                        .startsWith("http")) {
                                      audioUrl = widget.draft.audioPath!;
                                    } else {
                                      //上传到云端后
                                      audioUrl =
                                          await aiConfigRepository.fileUpload(
                                              filePath:
                                                  widget.draft.audioPath!);
                                      debugPrint("audioUrl" + audioUrl);
                                      // widget.draft.audioPath = audioUrl;
                                    }

                                    int cursorSentence = 0;
                                    List<SrtModel> sentencesDynamic =
                                        await httpsVideoCopyRepository.aiAsr(
                                            audioUrl: audioUrl, pegg: peggAsr);
                                    if (sentencesDynamic.isEmpty) {
                                      MotionToast.info(
                                              description: Text("识别原文出错!请重试"))
                                          .show(context);
                                      Navigator.pop(context);
                                      return;
                                    }
                                    for (int i = 0;
                                        i <
                                            widget.draft.tweetScript!.scenes[0]
                                                .imgs.length;
                                        i++) {
                                      TweetImage tweetImage = widget
                                          .draft.tweetScript!.scenes[0].imgs[i];
                                      tweetImage.sentence = "";
                                      String localImgName =
                                          tweetImage.origin!.localUrl!;
                                      int index = localImgName.lastIndexOf(
                                          FileUtil.getFileSeparate());
                                      logger.d(
                                          "localImgName:$localImgName    index:$index");
                                      // String numStr = localImgName.substring(
                                      //     index + 7, index + 11);
                                      // int offset = (int.parse(numStr)) * 1000;
                                      // print("numStr:" + offset.toString());
                                      double tmpDuration = 0;
                                      for (int j = cursorSentence;
                                          j < sentencesDynamic.length;
                                          j++) {
                                        SrtModel srtModel = sentencesDynamic[j];
                                        double startTime = srtModel.start;
                                        String str = srtModel.sentence;
                                        //如果是最后一个图片，直接把所有的叠加
                                        if (i ==
                                            widget.draft.tweetScript!.scenes[0]
                                                    .imgs.length -
                                                1) {
                                          tweetImage.sentence += str;
                                          double duration =
                                              srtModel.end - srtModel.start;
                                          tmpDuration += duration;
                                          tweetImage.tts!.duration =
                                              tmpDuration / 1000;
                                        } else {
                                          //时间小于下一个图片的的，句子给上一个
                                          TweetImage tweetImageNext = widget
                                              .draft
                                              .tweetScript!
                                              .scenes[0]
                                              .imgs[i + 1];
                                          //获取文件命带后缀的
                                          String localImgNamNext =
                                              tweetImageNext.origin!.localUrl!
                                                  .substring(index);
                                          //"image-0001.jpg"
                                          var strs = localImgNamNext.split("-");
                                          // debugPrint(
                                          //     "strs:" + strs.toString());
                                          int offsetNext = 1;
                                          try {
                                            String numStrNext =
                                                strs[1].substring(0, 4);
                                            offsetNext =
                                                (int.parse(numStrNext)) * 1000;
                                            // logger.d("numStrNext:${numStrNext}  offsetNext:${offsetNext}");
                                          } catch (e) {
                                            MotionToast.warning(
                                                    description: Text(
                                                        "图片文件序列号出错，请提交截图给客服处理！"))
                                                .show(context);
                                          }
                                          if (srtModel.end <= offsetNext) {
                                            tweetImage.sentence += str;
                                            double duration =
                                                srtModel.end - srtModel.start;
                                            tmpDuration += duration;
                                            tweetImage.tts!.duration =
                                                tmpDuration / 1000;
                                          } else {
                                            tmpDuration = 0;
                                            cursorSentence = j;
                                            break;
                                          }
                                        }
                                        //如果句子的起始时间小于下一个图片的的时间戳，则这个句子给到上一个图片的分句
                                      }
                                    }
                                    //再次遍历，如果当前句子最后不是以标点结尾，需要把下一句中的第一个标点之前的给提到当前句子
                                    //使用皮皮配音，下面这个才生效，不然这个会但乱上面的时间计算
                                    if (widget.draft.tweetScript!.ttsEnable ??
                                        true) {
                                      for (int i = 0;
                                          i <
                                              widget.draft.tweetScript!
                                                      .scenes[0].imgs.length -
                                                  1;
                                          i++) {
                                        TweetImage tweetImage = widget.draft
                                            .tweetScript!.scenes[0].imgs[i];
                                        if (tweetImage.sentence.isEmpty)
                                          continue;
                                        RegExp regExp = RegExp(
                                            r'[\p{P}\p{S}\u0020-\u002F\u003A-\u0040\u005B-\u0060\u007B-\u007E\u3000-\u303F\uFF00-\uFF60\uFFE0-\uFFE6]$');
                                        RegExp regExp02 = RegExp(
                                            r'[\p{P}\p{S}\u0020-\u002F\u003A-\u0040\u005B-\u0060\u007B-\u007E\u3000-\u303F\uFF00-\uFF60\uFFE0-\uFFE6]');

                                        if (regExp
                                            .hasMatch(tweetImage.sentence)) {
                                          // print("字符结尾:" + tweetImage.sentence);
                                        } else {
                                          TweetImage next = widget
                                              .draft
                                              .tweetScript!
                                              .scenes[0]
                                              .imgs[i + 1];
                                          Iterable<Match> matches = regExp02
                                              .allMatches(next.sentence);

                                          if (matches.isNotEmpty) {
                                            // 以标点符号进行切割
                                            List<String> subStrList = [];
                                            int previousMatchEnd = 0;
                                            matches.forEach((match) {
                                              subStrList.add(next.sentence
                                                  .substring(previousMatchEnd,
                                                      match.end));
                                              previousMatchEnd = match.end;
                                            });
                                            subStrList.add(next.sentence
                                                .substring(
                                                    previousMatchEnd)); // 添加剩余部分

                                            if (subStrList.length > 1) {
                                              // 可以给前一句分割第一段
                                              String removeStr =
                                                  subStrList.removeAt(0);
                                              tweetImage.sentence =
                                                  tweetImage.sentence +
                                                      removeStr;

                                              // 重新拼接的 newNextStr 保留标点符号
                                              String newNextStr = "";
                                              subStrList.forEach((element) {
                                                newNextStr += element;
                                              });
                                              next.sentence = newNextStr;
                                            }
                                          }
                                        }
                                      }
                                    }

                                    Navigator.pop(context);
                                    setState(() {});
                                  } else {
                                    Toast.error(context, "音频未解析成功无法识别字幕");
                                  }
                                },
                              ),
                            ),
                          ));
                },
                child: Text(
                  "AI原文识别 -${(widget.draft.audioSeconds! * 2 / 60).ceil()}",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
            flex: 1,
          ),
        if (widget.draft.type == 3)
          Flexible(
            child: Container(
              height: 35,
              child: ElevatedButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                            elevation: 5,
                            child: SizedBox(
                              width: 50,
                              child: ConfirmSeekDialog(
                                onSubmit: (allItem, value) {
                                  print("整体调节相似度：" +
                                      allItem.toString() +
                                      "  value:" +
                                      value.toString());
                                  if (allItem) {
                                    widget.draft.tweetScript!.scenes[0].imgs
                                        .forEach((tweetImage) {
                                      tweetImage.origin!.strength = value;
                                    });
                                  } else {
                                    widget.draft.tweetScript!.scenes[0].imgs
                                        .forEach((tweetImage) {
                                      if (tweetImage.origin!.strength == 0.65)
                                        tweetImage.origin!.strength = value;
                                    });
                                  }
                                  setState(() {});
                                },
                                title: "生图相似度",
                              ),
                            ),
                          ));
                },
                child: const Text(
                  "调节相似度",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
            flex: 1,
          ),
        // if (widget.draft.type == 0 || widget.draft.type == 1)
        //   Container(
        //     padding: const EdgeInsets.only(left: 10),
        //     height: 35,
        //     child: ElevatedButton(
        //       onPressed: () async {
        //         showDialog(
        //             context: context,
        //             builder: (ctx) => Dialog(
        //                   elevation: 5,
        //                   child: SizedBox(
        //                     width: 400,
        //                     child: GlobalOptionPanel(
        //                       onSubmit: (motionStrength) {
        //                         debugPrint('全局配置：$motionStrength');
        //                         setState(() {
        //                           this.motionStrength = motionStrength;
        //                         });
        //                       },
        //                       title: "全局配置",
        //                       motionStrength: motionStrength,
        //                     ),
        //                   ),
        //                 ));
        //       },
        //       child: const Text(
        //         "全局配置",
        //         style: TextStyle(fontSize: 10),
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  ///替换原文弹窗
  void replaceOriginalText(EditType editType) {
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              backgroundColor: AppColor.piecesBackTwo,
              elevation: 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0), // 圆角半径
                ),
                child: ReplaceText(
                  onReplace: (String targetText, String originalText) {
                    widget.draft.tweetScript?.scenes[0].imgs
                        .forEach((tweetImage) {
                      if (tweetImage.sentence.contains(originalText)) {
                        var newText = tweetImage.sentence
                            .replaceAll(originalText, targetText);
                        tweetImage.sentence = newText;
                      }
                    });
                    MotionToast.success(description: Text('替换成功'))
                        .show(context);
                    setState(() {});
                  },
                ),
                width: MediaQuery.of(context).size.width * 4 / 5,
                height: MediaQuery.of(context).size.height * 2 / 5,
              ),
            ));
  }

  ///跳转到词输入弹框
  void addAllItemTag(EditType editType) {
    //使用底部弹窗实现上述注释代码
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return GlobalTagsOperation(
            httpAiStoryRepository: aiStoryRepository,
            onEditCallback: (inputTags) async {
              if (EditType.add == editType) {
                widget.draft.tweetScript?.scenes[0].imgs.forEach((tweetImage) {
                  setState(() {
                    tweetImage.userTags!.add(inputTags);
                  });
                });
                //全局添加
              }
            },
            onReplace: (String targetText, String originalText) async {
              debugPrint(
                  "replace originalText:$originalText  targetText:$targetText");
              showLoadingDialog(context, originalText, targetText);
            },
          );
        });
  }

  ///批量替换关键词并将替换的英文重新翻译
  Future<void> showLoadingDialog(
    BuildContext context,
    String originalText,
    String targetText,
  ) async {
    final completer = Completer<void>(); // 使用Completer来控制弹窗的关闭时机

    // 显示弹窗
    showDialog<bool>(
      context: context,
      barrierDismissible: false, // 用户不能通过点击外部区域来关闭弹窗
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: <Widget>[
              CircularProgressIndicator(), // 加载动画
              SizedBox(width: 20), // 间距
              Text('全局替换中...'), // 加载提示文本
            ],
          ),
        );
      },
    );

    // 遍历所有的分镜的关键词，把其中的文字替换为target
    final futures = <Future<void>>[];

    widget.draft.tweetScript?.scenes[0].imgs.forEach((tweetImage) {
      // 为每个tweetImage创建一个Future，并将它们添加到futures列表中
      futures.add(_processUserTags(tweetImage, originalText, targetText));
    });

    // 等待所有异步操作完成
    await Future.wait(futures);

    // 异步操作完成后关闭弹窗
    if (!completer.isCompleted) {
      completer.complete();
      Navigator.of(context).pop();
      MotionToast.success(description: Text('替换成功')).show(context);
    }
  }

  Future<void> _processUserTags(
    TweetImage tweetImage,
    String originalText,
    String targetText,
  ) async {
    // 如果存在userTags，则创建一个新的列表以避免在遍历中修改原始列表
    List<UserTag>? newTags = tweetImage.userTags?.toList();
    if (newTags != null) {
      for (var userTag in newTags) {
        debugPrint("userTag: ${userTag.tagZh}");
        if (userTag.tagZh == originalText && targetText.isEmpty) {
          tweetImage.userTags?.remove(userTag);
        } else if (userTag.tagZh!.contains(originalText)) {
          var newText = userTag.tagZh?.replaceAll(originalText, targetText);
          userTag.tagZh = newText;
          var enWords = await aiStoryRepository.textTrans(
            text: newText ?? '',
            langFrom: "zh",
            langTo: "en",
          );
          debugPrint("翻译: $enWords");
          userTag.tagEn = enWords;
        }
      }
      // 使用setState更新UI，因为可能在_processUserTags中修改了tweetImage.userTags
      setState(() {});
    }
  }

}
