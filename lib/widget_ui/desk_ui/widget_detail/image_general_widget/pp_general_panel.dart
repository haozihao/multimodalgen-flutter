import 'dart:convert';
import 'dart:io';

import 'package:components/toly_ui/ti/circle.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';
import 'package:pieces_ai/components/custom_widget/DropMenuWidget.dart';
import 'package:pieces_ai/widget_ui/desk_ui/category_panel/desk_sytle_grid.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:utils/utils.dart';

import '../../../../app/api_https/impl/https_ai_config_repository.dart';
import '../../../../app/api_https/impl/https_ai_story_repository.dart';
import '../../../../app/gen/toly_icon_p.dart';
import '../../../../app/model/ai_style_model.dart';
import '../../../../app/navigation/mobile/theme/theme.dart';
import '../edit_prompt_words_panel.dart';
import '../scene_child_widget/crop_upload_image.dart';

var logger = Logger(printer: PrettyPrinter(methodCount: 1));

//MultimodalGen模型生图模式
GlobalKey<_PPGeneralPanelState> ppGeneralPanelKey = GlobalKey();

class PPGeneralPanel extends StatefulWidget {
  final Function(double) onGeneralProgress;
  final Function(List<String> images) onGeneralDone;

  ///外部分镜填写的关键词
  final List<UserTag> inputTags;
  final Function(int pegg) onConsumePegg;
  final String draftName;
  final HttpAiStoryRepository httpAiStoryRepository;
  final AiPaintParamsV2 aiPaintParamsV2;

  PPGeneralPanel({
    Key? key,
    required this.onGeneralProgress,
    required this.draftName,
    required this.httpAiStoryRepository,
    required this.onGeneralDone,
    required this.aiPaintParamsV2,
    required this.onConsumePegg,
    required this.inputTags,
  }) : super(key: key);

  @override
  State<PPGeneralPanel> createState() {
    return _PPGeneralPanelState();
  }
}

class _PPGeneralPanelState extends State<PPGeneralPanel>
    with AutomaticKeepAliveClientMixin {
  late Future<List<AiStyleModel>> _stylefuturePp;
  final HttpAiConfigRepository httpAiConfigRepository =
      HttpAiConfigRepository();
  Child? selectStyle;
  String? imageBase; //图生图的垫图
  int batchSize = 2;
  bool _quality = false;
  String light = "0";
  String camera = "0";
  late final List<DynamicTagData<UserTag>> inputTags;
  late DynamicTagController<DynamicTagData<UserTag>> _dynamicTagController;

  final lightList = const [
    {'label': '无', 'value': '0', 'prompt': ''},
    {'label': '电影氛围光照', 'value': '1', 'prompt': 'cinematic lighting'},
    {'label': '柔和光线', 'value': '2', 'prompt': 'Soft light'},
    {'label': '明亮光线', 'value': '3', 'prompt': 'Bright light'},
  ];

  final cameraPromptList = const [
    {'label': '无', 'value': '0', 'prompt': ''},
    {'label': '特写', 'value': '1', 'prompt': '(close up:1.5)'},
    {'label': '俯视图', 'value': '2', 'prompt': '(Top-View:1.3)'},
    {'label': '侧视图', 'value': '3', 'prompt': '(super side angle:1.3)'},
    {'label': '背视图', 'value': '4', 'prompt': '(Back view:1.6)'},
  ];

  @override
  void initState() {
    _stylefuturePp = httpAiConfigRepository.loadStylePp();
    inputTags = widget.inputTags
        .map((e) => DynamicTagData<UserTag>(e.tagZh ?? "", e))
        .toList();
    _dynamicTagController = DynamicTagController<DynamicTagData<UserTag>>();
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _dynamicTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildPpMode();
  }

  ///计算消耗皮蛋
  _calculatePegg() {
    int consumePegg = batchSize * (_quality ? 5 : 1);
    widget.onConsumePegg.call(consumePegg);
  }

  ///任务轮询生图模式
  Future<void> generalImage(int pegg) async {
    //使用任务式生图
    if (inputTags.isEmpty) {
      MotionToast.warning(description: Text("请输入提示词！")).show(context);
      widget.onGeneralDone.call([]);
      return;
    }
    if (selectStyle == null) {
      MotionToast.warning(description: Text("请选择风格！")).show(context);
      widget.onGeneralDone.call([]);
      return;
    }
    String prompt = "";
    //遍历inputTags，拼接成一个字符串
    inputTags.forEach((element) {
      prompt += element.data.tagEn + ",";
    });
    RegExp chineseRegExp = RegExp(r'[\u4e00-\u9fa5]'); // Unicode范围表示中文字符
    bool hasZh = chineseRegExp.hasMatch(prompt);
    //如果输入了中文，则需要翻译英语。如果输入的是英语，则显示和传递Ai绘画都直接使用
    if (hasZh) {
      logger.e("组装提示词时，发现里面输入了中文，需要翻译成英文");
    }

    //给新选的风格的透传数据赋值
    Map<String, dynamic> presetInfo = jsonDecode(selectStyle!.presetInfo);
    var cfgScale = presetInfo['cfg_scale'];
    AiPaintParamsV2 aiPaintParamsV2 = widget.aiPaintParamsV2.copyWith(
        id: selectStyle!.id,
        styleName: selectStyle!.modelFileName,
        sampling: presetInfo['sampling'],
        steps: presetInfo['steps'],
        lora: presetInfo['lora'],
        prompt: '',
        negativePrompt: presetInfo['negative_prompt'],
        cfgScale: cfgScale.toDouble(),
        modelClass: presetInfo['model_class']);
    //这里还要重新赋值一下
    if (presetInfo.containsKey("hd")) {
      aiPaintParamsV2.hd.modelType = presetInfo['hd']['model_type'];
      aiPaintParamsV2.hd.scale = 2.0;
      aiPaintParamsV2.hd.strength = presetInfo['hd']['strength'];
      if (_quality) {
        // aiPaintParamsV2.hd.strength = 0.3;
        // aiPaintParamsV2.hd.step = 30;
        aiPaintParamsV2.hd.scale = 3.5;
      }
      debugPrint("重绘参数：" + aiPaintParamsV2.hd.strength.toString());
    }
    RegExp regex = RegExp("%s");
    String newPrompt =
        presetInfo['prompt'].replaceFirstMapped(regex, (match) => prompt);
    prompt = newPrompt != presetInfo['prompt']
        ? newPrompt
        : presetInfo['prompt'] + prompt;

    //组装光照和视角
    prompt += ",";
    prompt += lightList[int.parse(light)]['prompt'] ?? "";
    prompt += ",";
    prompt += cameraPromptList[int.parse(camera)]['prompt'] ?? "";

    debugPrint("最终prompt：" +
        prompt +
        " neg_prompt:" +
        aiPaintParamsV2.negativePrompt.toString());

    if (imageBase != null) {
      List<int> imageBytes = File(imageBase!).readAsBytesSync();
      aiPaintParamsV2.image =
          "data:image/jpeg;base64," + base64Encode(imageBytes);
      // aiPaintParamsV2.strength = 0.4;
      debugPrint("图生图strength：" + aiPaintParamsV2.strength.toString());
    }

    // aiPaintParamsV2.detection = false;
    TweetScript tweetScript =
        TweetScript.generateEmptyImgData(prompt, aiPaintParamsV2, batchSize);
    // tweetScript.detection = false;
    var result = await widget.httpAiStoryRepository
        .addTask(tweetScript: tweetScript, pegg: pegg, type: 2);
    if (result.success) {
      String taskId = result.data.toString();
      debugPrint("提交PP生图任务成功：" + taskId);
      await _getPpResultDelay(taskId);
    } else {
      MotionToast.error(description: Text("提交任务出错！${result.msg}"))
          .show(context);
    }
  }

  ///递归获取生图结果
  Future<void> _getPpResultDelay(String taskId) async {
    if (!mounted) {
      return;
    }
    var progressResult =
        await widget.httpAiStoryRepository.getTaskProgress(taskId: taskId);
    if (progressResult >= 1.0) {
      var result =
          await widget.httpAiStoryRepository.getTaskResult(taskId: taskId);
      if (result != null) {
        logger.d("获取图片任务成功:" + result.scenes[0].imgs.length.toString());
        //回调结果给左边页面展示
        if (result.scenes[0].imgs.length > 0) {
          List<String> urls = [];
          //先下载图片到本地草稿文件夹，然后再重新赋值
          String draftPath =
              await FileUtil.getPieceAiDraftFolderByTaskId(widget.draftName);
          String ppImagePath = draftPath +
              FileUtil.getFileSeparate() +
              "pp_image" +
              FileUtil.getFileSeparate();
          await Future.forEach(result.scenes[0].imgs, (element) async {
            if (element.url != null) {
              FileUtil.createDirectoryIfNotExists(ppImagePath);
              String imageName =
                  FileUtil.getHttpNameWithExtension(element.url!);
              logger.d("获取到ppImagePath：" + ppImagePath);
              String imageFilePath = ppImagePath + imageName;
              await _downloadResource(element.url!, imageFilePath);
              urls.add(imageFilePath);
            }
          });
          widget.onGeneralDone.call(urls);
        } else {
          widget.onGeneralDone.call([]);
        }
      } else {
        MotionToast.warning(description: Text("生成成功但是没获取到结果！")).show(context);
        widget.onGeneralDone.call([]);
      }
    } else {
      widget.onGeneralProgress.call(progressResult);
      Future.delayed(Duration(seconds: 2), () {
        _getPpResultDelay(taskId);
      });
    }
  }

  _downloadResource(String url, String path) async {
    logger.d("下载资源：$url");
    await HttpUtil.instance.client.download(url, path,
        onReceiveProgress: (int get, int total) {
      String progress = ((get / total) * 100).toStringAsFixed(2);
    });
  }

  ///MultimodalGen生图模式
  Widget _buildPpMode() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FutureBuilder<List<AiStyleModel>>(
                    future: _stylefuturePp,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        // Error handling
                        return Text('Error: ${snapshot.error}');
                      } else {
                        snapshot.data?.forEach((element) {
                          element.children.forEach((children) {
                            //默认选中本身的风格
                            if (selectStyle == null &&
                                children.id == widget.aiPaintParamsV2.id)
                              selectStyle = children;
                          });
                        });
                        return Row(
                          children: [
                            Padding(
                              child: Text(
                                "风格",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              padding: EdgeInsets.only(right: 20),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 4, bottom: 4),
                              child: Container(
                                  height: 25,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      // 边框颜色
                                      width: 1.0, // 边框宽度
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(5.0), // 圆角半径
                                  ),
                                  child: ElevatedButton(
                                    //圆角线框灰色风格
                                    style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.transparent),
                                    ),
                                    onPressed: () {
                                      //从底部弹出一个选择风格的弹窗
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                              padding: EdgeInsets.only(
                                                  top: 20, left: 10, right: 10),
                                              height: 300,
                                              child: StyleGridView(
                                                  aiStyleModels: snapshot.data!,
                                                  aiStyleModelChanged: (style) {
                                                    logger.d("选择风格：" +
                                                        style.name +
                                                        " id:" +
                                                        style.id.toString());
                                                    setState(() {
                                                      selectStyle = style;
                                                    });
                                                  },
                                                  selectStyleId:
                                                      this.selectStyle?.id ?? 0,
                                                  countPerLine: 5),
                                            );
                                          });
                                    },
                                    child: Text(
                                      "${selectStyle == null ? "点击选择" : selectStyle?.name}",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white60),
                                    ),
                                  )),
                            )
                          ],
                        );
                      }
                    }),
                flex: 1,
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: DropMenuWidget(
                    leading: Padding(
                      child: Text(
                        "数量",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      padding: EdgeInsets.only(right: 20),
                    ),
                    data: const [
                      {'label': '1张', 'value': '1'},
                      {'label': '2张', 'value': '2'},
                      {'label': '3张', 'value': '3'},
                      {'label': '4张', 'value': '4'},
                    ],
                    selectCallBack: (value) {
                      print('选中的value是：$value');
                      batchSize = int.parse(value);
                      _calculatePegg();
                    },
                    offset: const Offset(-40, 40),
                    selectedValue: '2', //默认选中2张
                  ),
                ),
                flex: 1,
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const Text(
                "支持中英文输入",
                style: TextStyle(fontSize: 10),
              ),
              const Tooltip(
                message: '专业生成模式完整教程',
                child: Icon(
                  Icons.help,
                  color: Colors.white,
                  size: 15,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => _addPpPrompt(),
                child: Text("提示词宝典",
                    style: TextStyle(fontSize: 14, color: AppColor.piecesBlue)),
              )
            ],
          ),
          _buildInputTags(),
          Row(
            children: [
              Text(
                '普通高清',
                style: TextStyle(fontSize: 12, color: Color(0xFF12CDD9)),
              ),
              Switch(
                value: _quality,
                onChanged: (value) {
                  setState(() {
                    _quality = value;
                    _calculatePegg();
                  });
                },
              ),
              Text(
                '3K超清(HD)',
                style: TextStyle(fontSize: 12, color: Color(0xFF12CDD9)),
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  alignment: Alignment.center,
                  child: DropMenuWidget(
                    leading: Padding(
                      child: Text(
                        "视角",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      padding: EdgeInsets.only(right: 10),
                    ),
                    data: cameraPromptList,
                    selectCallBack: (value) {
                      print('选中的value是：$value');
                      camera = value;
                    },
                    offset: const Offset(-20, 40),
                    selectedValue: '0', //默认选中第0个
                  ),
                ),
                flex: 1,
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.center,
                  child: DropMenuWidget(
                    leading: const Padding(
                      padding: EdgeInsets.only(right: 10, left: 10),
                      child: Text(
                        "光线",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    data: lightList,
                    selectCallBack: (value) {
                      print('选中的value是：$value');
                      light = value;
                    },
                    offset: const Offset(-20, 40),
                    selectedValue: '0', //默认选中第三个
                  ),
                ),
                flex: 1,
              )
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Circle(
                color: Color(0xFF12CDD9),
                radius: 5,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "仿图",
                  style: TextStyle(fontSize: 14),
                ),
              )
            ],
          ),
          SizedBox(
            height: 5,
          ),
          _buildImage2ImageWidget(),
        ],
      ),
    );
  }

  ///提示词输入组件
  _buildInputTags() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          TextFieldTags<DynamicTagData<UserTag>>(
            textfieldTagsController: _dynamicTagController,
            initialTags: inputTags,
            textSeparators: const [','],
            letterCase: LetterCase.normal,
            validator: (DynamicTagData<UserTag> tag) {
              if (_dynamicTagController.getTags!
                  .any((element) => element.tag == tag.tag)) {
                return '已存在';
              }
              return null;
            },
            inputFieldBuilder: (context, inputFieldValues) {
              return TextField(
                onTap: () {
                  _dynamicTagController.getFocusNode?.requestFocus();
                },
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
                controller: inputFieldValues.textEditingController,
                focusNode: inputFieldValues.focusNode,
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 74, 137, 92),
                      width: 3.0,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColor.piecesBlue,
                      width: 1.0,
                    ),
                  ),
                  // helperText: 'Zootopia club...',
                  // helperStyle: const TextStyle(
                  //   color: Color.fromARGB(255, 74, 137, 92),
                  // ),
                  hintText: inputFieldValues.tags.isNotEmpty ? '' : "输入提示词...",
                  errorText: inputFieldValues.error,
                  prefixIconConstraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9),
                  prefixIcon: inputFieldValues.tags.isNotEmpty
                      ? SingleChildScrollView(
                          controller: inputFieldValues.tagScrollController,
                          scrollDirection: Axis.vertical,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 8,
                              left: 5,
                            ),
                            child: Wrap(
                                runSpacing: 2.0,
                                spacing: 2.0,
                                children: inputFieldValues.tags
                                    .map((DynamicTagData<UserTag> tag) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                      color: Color.fromARGB(255, 74, 137, 92),
                                    ),
                                    // margin: const EdgeInsets.symmetric(
                                    //     horizontal: 5.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0, vertical: 2.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: InkWell(
                                            child: Text(
                                              '${tag.tag}',
                                              //超出部分省略号
                                              // overflow: TextOverflow.fade,
                                              style: const TextStyle(
                                                  //超出部分省略号
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 10,
                                                  color: Colors.white),
                                            ),
                                            onTap: () {
                                              //print("$tag selected");
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 4.0),
                                        InkWell(
                                          child: const Icon(
                                            Icons.cancel,
                                            size: 14.0,
                                            color: Color.fromARGB(
                                                255, 233, 233, 233),
                                          ),
                                          onTap: () {
                                            logger.d("onTagRemoved:" + tag.tag);
                                            inputFieldValues.onTagRemoved(tag);
                                            inputTags.remove(tag.data);
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                }).toList()),
                          ),
                        )
                      : null,
                ),
                onChanged: (value) {
                  logger.d("onChanged:" + value);
                  final UserTag userTag = UserTag(tagZh: value, tagEn: value);
                  final tagData = DynamicTagData(value, userTag);
                  inputFieldValues.onTagChanged(tagData);
                },
                onSubmitted: (value) async {
                  logger.d("onSubmitted:" + value);
                  //看是否包含中文，如果包含中文，则需要翻译
                  RegExp chineseRegExp = RegExp(r'[\u4e00-\u9fa5]');
                  var enValue = value;
                  bool hasZh = chineseRegExp.hasMatch(enValue);
                  if (hasZh) {
                    //如果有百度翻译key
                    if (HttpUtil.baiduTk.isNotEmpty) {
                      enValue = await widget.httpAiStoryRepository
                          .textTrans(text: value, langFrom: "zh", langTo: "en");
                      logger.d("使用百度翻译结果：" + enValue);
                    } else {
                      enValue = await httpAiConfigRepository.translate(
                          content: value, lanTo: "en");
                      logger.d("使用pieces翻译结果：" + enValue);
                    }
                  }
                  final tagData = DynamicTagData(
                      value, UserTag(tagZh: value, tagEn: enValue));
                  inputFieldValues.onTagSubmitted(tagData);
                  inputTags.add(tagData);
                },
              );
            },
          ),
          //把上述注释的删除按钮放到Colum的最右边底部
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                style: ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                  minimumSize: WidgetStateProperty.all(Size(0, 0)),
                ),
                onPressed: () {
                  _dynamicTagController.clearTags();
                },
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                  size: 20,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  ///图生图垫图操作
  _buildImage2ImageWidget() {
    return Row(
      children: [
        if (imageBase != null)
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      // 边框颜色
                      width: 1.0, // 边框宽度
                    ),
                    borderRadius: BorderRadius.circular(12.0), // 圆角半径
                  ),
                  child: Image.file(File(imageBase!), fit: BoxFit.contain),
                  width: 70,
                  height: 70,
                ),
                IconButton(
                    onPressed: () => setState(() {
                          imageBase = null;
                        }),
                    icon: Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ))
              ],
            ),
          ),
        InkWell(
          onTap: () => _selectLocalImage(),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                // 边框颜色
                width: 1.0, // 边框宽度
              ),
              borderRadius: BorderRadius.circular(12.0), // 圆角半径
            ),
            child: Icon(
              TolyIconP.add,
              color: Colors.white,
              size: 35,
            ),
            width: 70,
            height: 70,
          ),
        )
      ],
    );
  }

  ///调出提示词宝典
  _addPpPrompt() {
    //使用底部弹窗实现上述注释代码
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.only(top: 20, left: 10, right: 10),
            // height: 300,
            child: EditPromptWordsPanel(
              initPrompts: [],
              index: 0,
              onEditCallback: (UserTag inputTags) async {
                logger.d("提示词宝典提示词返回:" + inputTags.tagEn);
                DynamicTagData<UserTag> tagData =
                    DynamicTagData(inputTags.tagZh ?? "", inputTags);
                this._dynamicTagController.onTagSubmitted(tagData);
                this.inputTags.add(tagData);
              },
              httpAiStoryRepository: widget.httpAiStoryRepository,
            ),
          );
        });
  }

  _selectLocalImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      // allowedExtensions: ['jpg', 'png', 'webp', 'jpeg'],
    );
    if (result != null) {
      PlatformFile file = result.files.single;
      if (file.path?.isNotEmpty == true) {
        // 保存到当前草稿目录
        String draftPath =
            await FileUtil.getPieceAiDraftFolderByTaskId(widget.draftName);
        String ppImagePath = draftPath +
            FileUtil.getFileSeparate() +
            "pp_image" +
            FileUtil.getFileSeparate();
        if (!Directory(ppImagePath).existsSync()) {
          Directory(ppImagePath).createSync(recursive: true);
        }
        //使用页面跳转方式实现
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return CropUploadImagePanel(
            selectImgPath: file.path!,
            onCropped: (cropImgPath) {
              if (cropImgPath.isNotEmpty) {
                setState(() {
                  imageBase = cropImgPath;
                });
              }
            },
            taskSavePath: ppImagePath,
            ratio: AiPaintParamsV2.getTrueRatio(widget.aiPaintParamsV2.ratio),
          );
        }));
      }
    }
  }
}
