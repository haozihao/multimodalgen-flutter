import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:pieces_ai/app/api_https/ai_config_repository.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_config_repository.dart';
import 'package:pieces_ai/app/api_https/impl/https_video_copy_repository.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';
import 'package:pieces_ai/app/model/config/ai_analyse_role_scene.dart';
import 'package:pieces_ai/app/navigation/mobile/theme/theme.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/scene_child_widget/crop_upload_image.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/scene_child_widget/image_tools_item.dart';
import 'package:pieces_ai/widget_ui/mobile/category_page/delete_category_dialog.dart';
import 'package:utils/utils.dart';

import '../../../app/api_https/ai_story_repository.dart';
import 'draft_scene_item_scene.dart';
import 'edit_prompt_words_panel.dart';
import 'edit_words_panel.dart';
import 'general_advanced_panel.dart';

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

/// 单项编辑分句Item
class DraftSceneItem extends StatefulWidget {
  final TweetImage tweetImage;
  final AiPaintParamsV2 aiPaintParamsV2;
  final TweetScriptTts? tweetScriptTts;
  final AudioPlayer player;
  final String draftName;
  final int index;
  final double motionStrength;
  final int type;
  final int shidai;
  final bool lockedSeed;
  final Function(TweetImage, int)? onDeleteItemClick;
  final Function(TweetImage, int)? onMergeItemClick;
  final Function(TweetImage, int)? onMergeItemDownClick;
  final Function(TweetImage, int)? onSubItemClick;
  final AiStoryRepository httpAiStoryRepository;
  final List<Role> roles;
  final List<Scene> scenes;
  final bool localMode;

  const DraftSceneItem(
      {Key? key,
      this.onDeleteItemClick,
      this.onMergeItemClick,
      this.onSubItemClick,
      required this.httpAiStoryRepository,
      required this.tweetImage,
      required this.index,
      required this.aiPaintParamsV2,
      required this.roles,
      required this.localMode,
      required this.scenes,
      required this.type,
      required this.shidai,
      this.onMergeItemDownClick,
      required this.lockedSeed,
      required this.draftName,
      this.tweetScriptTts,
      required this.player,
      required this.motionStrength})
      : super(key: key);

  @override
  State<DraftSceneItem> createState() => DraftListItemState();
}

class DraftListItemState extends State<DraftSceneItem> {
  final AiConfigRepository aiConfigRepository = HttpAiConfigRepository();
  final HttpsVideoCopyRepository httpsVideoCopyRepository =
      HttpsVideoCopyRepository();
  bool isGeneral = false;
  bool isGeneralPrompt = false;
  bool isTransPrompt = false;
  Scene? _scene;
  int selectRoleIndex = -1; //文生动画时使用，单选人物
  final List<String> urls = [];
  final List<String> videoUrls = [];
  final TextEditingController _textEditingController = TextEditingController();
  GlobalKey<ImageToolItemState> imageToolItemKey = GlobalKey();

  @override
  void initState() {
    widget.tweetImage.userTags ??= [];
    widget.aiPaintParamsV2.strength = widget.aiPaintParamsV2.strength ?? 0.55;
    if (widget.type == 3) {
      widget.tweetImage.origin?.strength =
          widget.tweetImage.origin?.strength ?? 0.55;
    }
    //看是否有系统提示词
    if (widget.tweetImage.prompt.isNotEmpty) {
      logger.d("有传入的提示词：" + widget.tweetImage.prompt);
      UserTag userTag = new UserTag(
          tagEn: widget.tweetImage.enPrompt, tagZh: widget.tweetImage.prompt);
      if (widget.tweetImage.userTags?.isNotEmpty == true) {
        widget.tweetImage.userTags![0] = userTag;
      } else {
        widget.tweetImage.userTags!.add(userTag);
      }
    }
    _textEditingController.text = widget.tweetImage.sentence;
    if (widget.tweetImage.url?.isNotEmpty ?? false) {
      urls.add(widget.tweetImage.url!);
    }
    if (widget.tweetImage.videoUrl?.isNotEmpty ?? false) {
      videoUrls.add(widget.tweetImage.videoUrl!);
      debugPrint("初始化视频item:" + videoUrls.toString());
    }
    _autoSelectRole();
    super.initState();
  }

  ///自动根据分句里文字名字匹配人物和场景
  _autoSelectRole() {
    //看当前分句是否包含某个角色名字或者场景名字，包含则默认选中
    if (widget.tweetImage.rolesId?.isNotEmpty == true) {
      //已经选择过
    } else {
      //没选择过，自动匹配，看原文里是否有角色名字
      if (widget.roles.isNotEmpty) {
        widget.tweetImage.rolesId = [];
        for (int i = 0; i < widget.roles.length; i++) {
          Role role = widget.roles[i];
          if (widget.tweetImage.sentence.contains(role.name)) {
            widget.tweetImage.rolesId!.add(i);
          }
        }
      }
    }

    if (widget.tweetImage.sceneId?.isNotEmpty == true) {
      _scene = widget.scenes[widget.tweetImage.sceneId![0]];
    } else {
      if (widget.scenes.isNotEmpty) {
        widget.tweetImage.sceneId = [];
        for (int i = 0; i < widget.scenes.length; i++) {
          Scene element = widget.scenes[i];
          if (widget.tweetImage.sentence.contains(element.name)) {
            _scene = element;
            widget.tweetImage.sceneId!.add(i);
            break;
          }
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant DraftSceneItem oldWidget) {
    debugPrint("DraftSceneItem didUpdateWidget：" + widget.tweetImage.prompt);
    widget.tweetImage.userTags ??= [];
    if (widget.tweetImage.sentence.isNotEmpty) {
      // Check if the current sentence contains a character name or scene name,
      // and select it by default if it does.
      if (widget.tweetImage.rolesId?.isNotEmpty == true) {
        // Already selected, remove any indices that are out of bounds
        for (int i = widget.tweetImage.rolesId!.length - 1; i >= 0; i--) {
          final int roleId = widget.tweetImage.rolesId![i];
          if (roleId < 0 || roleId >= widget.roles.length) {
            widget.tweetImage.rolesId?.removeAt(i);
          }
        }
      }

      setState(() {
        _textEditingController.text = widget.tweetImage.sentence;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //线框圆角
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColor.piecesBackTwo,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Column(
            // mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: Container(
                      alignment: Alignment.center,
                      height: 120,
                      child: Column(
                        // direction: Axis.vertical,
                        mainAxisAlignment: MainAxisAlignment.center,
                        // runAlignment: WrapAlignment.center,
                        children: [
                          Container(
                              alignment: Alignment.center,
                              width: 30,
                              height: 30,
                              child: Text(
                                widget.index.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              color: Color(0xFF808080)),
                          GestureDetector(
                            child: Container(
                              padding: EdgeInsets.only(top: 3),
                              child: const Text(
                                "删除",
                                style: TextStyle(
                                    fontSize: 10, color: Color(0xFFFFC300)),
                              ),
                            ),
                            onTap: () {
                              _deleteSentence(context);
                            },
                          ),
                          if (widget.index != 0)
                            GestureDetector(
                              child: Container(
                                padding: EdgeInsets.only(top: 3),
                                child: const Text(
                                  "向上合并",
                                  style: TextStyle(
                                      fontSize: 10, color: Color(0xFFFFC300)),
                                ),
                              ),
                              onTap: () {
                                widget.onMergeItemClick
                                    ?.call(widget.tweetImage, widget.index);
                              },
                            ),
                          GestureDetector(
                            child: Container(
                              padding: EdgeInsets.only(top: 3),
                              child: const Text(
                                "向下合并",
                                style: TextStyle(
                                    fontSize: 10, color: Color(0xFFFFC300)),
                              ),
                            ),
                            onTap: () {
                              widget.onMergeItemDownClick
                                  ?.call(widget.tweetImage, widget.index);
                            },
                          ),
                        ],
                      ),
                    ),
                    flex: 1,
                  ),

                  ///一键追爆款原图显示组件，一键追爆款模式下才出现
                  if (widget.type == 3)
                    Flexible(
                      child: Stack(
                        alignment: AlignmentDirectional.topEnd,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              child: Image.file(
                                  File(widget.tweetImage.origin!.localUrl ==
                                          null
                                      ? widget.tweetImage.origin!.image
                                      : widget.tweetImage.origin!.localUrl!),
                                  fit: BoxFit.cover),
                              onTap: () {},
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.image,
                                // allowedExtensions: [
                                //   'jpg',
                                //   'png',
                                // ],
                              );
                              if (result != null) {
                                PlatformFile file = result.files.single;
                                if (file.path?.isNotEmpty == true) {
                                  // 使用 path.dirname() 函数获取父目录
                                  if (widget.tweetImage.origin!.localUrl !=
                                      null) {
                                    //使用页面跳转方式实现
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CropUploadImagePanel(
                                                  selectImgPath: file.path!,
                                                  onCropped: (cropImgPath) {
                                                    if (cropImgPath
                                                        .isNotEmpty) {
                                                      setState(() {
                                                        // 立即重新设置回原来的值
                                                        widget
                                                                .tweetImage
                                                                .origin!
                                                                .localUrl =
                                                            cropImgPath;
                                                        widget.tweetImage
                                                                .origin!.image =
                                                            cropImgPath;
                                                      });
                                                    }
                                                  },
                                                  taskSavePath: Directory(widget
                                                          .tweetImage
                                                          .origin!
                                                          .localUrl!)
                                                      .parent
                                                      .path,
                                                  baseSaveName:
                                                      FileUtil.getFileName(
                                                          widget
                                                              .tweetImage
                                                              .origin!
                                                              .localUrl!),
                                                  ratio: AiPaintParamsV2
                                                      .getTrueRatio(widget
                                                          .aiPaintParamsV2
                                                          .ratio),
                                                )));
                                  }
                                }
                              }
                            },
                            icon: const Icon(Icons.change_circle),
                            iconSize: 35,
                            color: Color(0xFF12CDD9),
                          ),
                        ],
                      ),
                      flex: 3,
                    ),
                  Flexible(
                    child: Container(
                      alignment: Alignment.center,
                      height: 120,
                      child: Padding(
                        child: TextField(
                          // enabled: widget.tweetImage.mediaType != 1,
                          controller: _textEditingController,
                          style: const TextStyle(
                              color: Color(0xFFE5E5E5), fontSize: 10),
                          textAlign: TextAlign.left,
                          maxLines: null,
                          // 设置为null或不指定即可自动包裹内容
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            // 处理文本改变事件
                            debugPrint("onChanged：" + value);
                            if (value.isNotEmpty) {
                              widget.tweetImage.tts?.url = "";
                              widget.tweetImage.tts?.fileLength = 0;
                            }
                            widget.tweetImage.sentence = value;
                            widget.tweetImage.ttsText = value;
                          },
                          onSubmitted: (value) {
                            // 处理按下Enter键事件
                            // 获取当前光标的位置
                            // FocusScope.of(context).requestFocus(_focusNode);
                            final cursorPosition =
                                _textEditingController.selection.base.offset;
                            // 其他逻辑处理代码...
                            widget.onSubItemClick
                                ?.call(widget.tweetImage, cursorPosition);
                          },
                        ),
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                    flex: 2,
                  ),
                  if (widget.type != 3)
                    Flexible(
                      child: Container(
                        alignment: Alignment.center,
                        height: 120,
                        child: SingleChildScrollView(
                          child: widget.roles.isEmpty
                              ? const Text('未识别角色',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10))
                              : Wrap(
                                  children: List<Widget>.generate(
                                      widget.roles.length, (index) {
                                    return ChoiceChip(
                                      avatar: widget.localMode
                                          ? (widget.roles[index].icon == null ||
                                                  widget.roles[index].icon!
                                                      .isEmpty)
                                              ? null
                                              : Image.file(File(widget
                                                  .roles[index].icon!
                                                  .split(
                                                      "imgs.pencil-stub.com")[1]))
                                          : CachedNetworkImage(
                                              imageUrl:
                                                  widget.roles[index].icon ??
                                                      "",
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                              fadeInDuration:
                                                  Duration(milliseconds: 100),
                                            ),
                                      // avatarBorder: CircleBorder(),
                                      label: Text(widget.roles[index].name),
                                      selected:
                                          widget.tweetImage.rolesId != null &&
                                              widget.tweetImage.rolesId!
                                                  .contains(index),
                                      selectedColor: Color(0xFF12CDD9),
                                      surfaceTintColor: Colors.white,
                                      padding: const EdgeInsets.all(2),
                                      labelPadding: const EdgeInsets.all(2),
                                      // visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                                      //降低上下边距
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      onSelected: (bool selected) {
                                        widget.tweetImage.rolesId ??= [];
                                        logger.d("选中了哪个人物：" +
                                            index.toString() +
                                            selected.toString());
                                        setState(() {
                                          if (widget.tweetImage.rolesId!
                                              .contains(index)) {
                                            widget.tweetImage.rolesId!
                                                .remove(index);
                                          } else {
                                            widget.tweetImage.rolesId!
                                                .add(index);
                                          }
                                        });
                                      },
                                    );
                                  }),
                                ),
                        ),
                      ),
                      flex: 1,
                    ),
                  if (widget.type != 3)
                    Flexible(
                      child: Container(
                        alignment: Alignment.center,
                        height: 120,
                        child: widget.scenes.isEmpty
                            ? const Text('未识别场景',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10))
                            : SceneRadioListTile(
                                scenes: widget.scenes,
                                onSelected: (Scene) {
                                  _scene = Scene;
                                  //翻译场景内容
                                  widget.tweetImage.sceneId ??= [];
                                  widget.tweetImage.sceneId!.clear();
                                  widget.tweetImage.sceneId!
                                      .add(widget.scenes.indexOf(_scene!));
                                  debugPrint("选中的sceneId：" +
                                      widget.tweetImage.sceneId.toString());
                                },
                                historySelect: widget.tweetImage.sceneId!,
                              ),
                      ),
                      flex: 1,
                    ),
                ],
              ),
              const Divider(
                height: 1,
                color: AppColor.piecesBackTwo,
              ),
              ImageToolItem(
                key: imageToolItemKey,
                tweetImage: widget.tweetImage,
                type: widget.type,
                shidai: widget.shidai,
                localMode: widget.localMode,
                aiConfigRepository: aiConfigRepository,
                httpAiStoryRepository: widget.httpAiStoryRepository,
                onShowImageGeneral: () => showImgScaleDialog(context),
                aiPaintParamsV2: widget.aiPaintParamsV2,
                roles: widget.roles,
                urls: urls,
                videoUrls: videoUrls,
                lockedSeed: widget.lockedSeed,
                selectMediaType: (int mediaType) {
                  setState(() {
                    widget.tweetImage.mediaType = mediaType;
                  });
                },
                draftName: widget.draftName,
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///生图调用
  generalImg() async {
    await imageToolItemKey.currentState?.loadImage();
  }

  ///刷新图片显示
  notifyImg() {
    imageToolItemKey.currentState?.setState(() {});
  }

  ///刷新各种状态显示
  notifyImageDisplayState(int mediaType) {
    imageToolItemKey.currentState?.refreshState(mediaType);
  }

  ///跳转到词输入弹框
  _doEdit(EditType editType, String? words, int index) {
    print("编辑的words：" + words.toString() + "  editType:" + editType.toString());
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              elevation: 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0), // 圆角半径
                ),
                child: editType == EditType.add
                    ? Scaffold(
                        backgroundColor: Color(0xFF383838),
                        appBar: AppBar(
                          backgroundColor: Colors.black26,
                          title: Text('描述词生成器'),
                        ),
                        body: Padding(
                          child: EditPromptWordsPanel(
                            initPrompts: [],
                            index: index,
                            onEditCallback: (inputTags) async {
                              if (EditType.add == editType) {
                                setState(() {
                                  widget.tweetImage.userTags!.add(inputTags);
                                });
                              }
                            },
                            httpAiStoryRepository: widget.httpAiStoryRepository,
                          ),
                          padding: EdgeInsets.only(left: 25),
                        ),
                      )
                    : EditKeyWordsPanel(
                        words: words,
                        onEditCallback: (index, words, type, modify) async {
                          RegExp chineseRegExp =
                              RegExp(r'[\u4e00-\u9fa5]'); // Unicode范围表示中文字符
                          bool hasZh = chineseRegExp.hasMatch(words);
                          String enWords = words;
                          //如果输入了中文，则需要翻译英语。如果输入的是英语，则显示和传递Ai绘画都直接使用
                          if (hasZh) {
                            //翻译
                            if (HttpUtil.baiduTk.isEmpty) {
                              Toast.error(context, "本地模式需要在首页设置翻译KEY才能支持中文!");
                              return;
                            }
                            enWords = await widget.httpAiStoryRepository
                                .textTrans(
                                    text: words, langFrom: "zh", langTo: "en");
                            print("翻译结果：" + enWords);
                          }
                          var userTag =
                              new UserTag(tagEn: enWords, tagZh: words);
                          if (EditType.add == editType) {
                            setState(() {
                              widget.tweetImage.userTags!.add(userTag);
                            });
                          } else {
                            setState(() {
                              widget.tweetImage.userTags![index] = userTag;
                            });
                          }
                        },
                        index: index,
                      ),
                width: editType == EditType.add ? 800 : 400,
                height: editType == EditType.add ? 600 : 80,
              ),
            ));
  }

  ///历史生成的大图记录
  void showImgScaleDialog(BuildContext context) {
    if (widget.tweetImage.url != null) {
      //以页面方式打开AdvanceGeneralPage
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return AdvanceGeneralPage(
          imageUrl: widget.tweetImage.url,
          videoUrl: widget.tweetImage.videoUrl,
          inputTags: widget.tweetImage.userTags ?? [],
          urls: urls,
          onImageSelected: (url, videoUrl, mediaType) {
            logger.d("选择的设置的图片：$url，$videoUrl，$mediaType");
            setState(() {
              widget.tweetImage.mediaType = mediaType;
              widget.tweetImage.url = url;
              widget.tweetImage.videoUrl = videoUrl;
            });
            notifyImageDisplayState(mediaType);
          },
          localMode: widget.localMode,
          draftName: widget.draftName,
          aiPaintParamsV2: widget.aiPaintParamsV2,
          mediaType: widget.tweetImage.mediaType ?? 0,
          videoUrls: videoUrls,
          motionStrength: widget.motionStrength,
          tweetImage: widget.tweetImage,
          type: widget.type,
          tweetScriptTts: widget.tweetScriptTts,
          index: widget.index,
        );
      }));
    }
  }

  void _deleteSentence(BuildContext context) async {
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              elevation: 5,
              // shape: rRectBorder,
              child: SizedBox(
                width: 50,
                child: DeleteCategoryDialog(
                  title: '确认删除？',
                  content: '    删除分句后，图片也会一起删除!',
                  onSubmit: () {
                    isGeneral = false;
                    isGeneralPrompt = false;
                    widget.onDeleteItemClick
                        ?.call(widget.tweetImage, widget.index);
                    // Navigator.of(context).pop();
                  },
                ),
              ),
            ));
  }
}

class DeleteOfChip extends StatelessWidget {
  final String text;
  final int index;
  final Function(int) onDelete;
  final Function(int) onTap;

  const DeleteOfChip(
      {Key? key,
      required this.text,
      required this.onDelete,
      required this.index,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Chip(
          // avatar: Image.asset("assets/images/icon_head.webp"),
          label: Text(
            text,
          ),
          // clipBehavior: Clip.hardEdge,
          labelStyle: TextStyle(color: Colors.white, fontSize: 8),
          padding: const EdgeInsets.all(0),
          labelPadding: const EdgeInsets.all(0),
          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
          //降低上下边距
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: Color(0xFF787474),
          // shadowColor: Colors.orangeAccent,
//      deleteIcon: Icon(Icons.close,size: 18),
          deleteIconColor: AppColor.piecesBlue,
          onDeleted: () => {onDelete.call(index)},
          elevation: 3,
        ),
        onTap: () {
          onTap.call(index);
        });
  }
}
