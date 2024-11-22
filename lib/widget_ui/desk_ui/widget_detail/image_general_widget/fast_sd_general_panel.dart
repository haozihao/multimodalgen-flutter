import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:components/toly_ui/ti/circle.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_story_fastsd.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';
import 'package:pieces_ai/components/custom_widget/DropMenuWidget.dart';
import 'package:pieces_ai/widget_ui/desk_ui/category_panel/desk_sytle_grid.dart';
import 'package:utils/utils.dart';

import '../../../../app/api_https/impl/https_ai_config_repository.dart';
import '../../../../app/api_https/impl/https_ai_story_repository.dart';
import '../../../../app/gen/toly_icon_p.dart';
import '../../../../app/model/ai_style_model.dart';
import '../edit_prompt_words_panel.dart';
import '../scene_child_widget/crop_upload_image.dart';

///MultimodalGen模型生图模式
GlobalKey<_FastSdGeneralPanelState> fastSdGeneralPanelKey = GlobalKey();

class FastSdGeneralPanel extends StatefulWidget {
  final Function(double) onGeneralProgress;
  final Function(List<String> images) onGeneralDone;
  final Function(int pegg) onConsumePegg;
  final String draftName;
  final HttpAiStoryRepository httpAiStoryRepository;
  final AiPaintParamsV2 aiPaintParamsV2;

  FastSdGeneralPanel({
    Key? key,
    required this.onGeneralProgress,
    required this.draftName,
    required this.httpAiStoryRepository,
    required this.onGeneralDone,
    required this.aiPaintParamsV2,
    required this.onConsumePegg,
  }) : super(key: key);

  @override
  State<FastSdGeneralPanel> createState() {
    return _FastSdGeneralPanelState();
  }
}

class _FastSdGeneralPanelState extends State<FastSdGeneralPanel>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _textPromptController = TextEditingController();
  late Future<AiStyleModel> _stylefutureFastSd;
  late List<String> mountedModels = [];

  final HttpAiConfigRepository httpAiConfigRepository =
      HttpAiConfigRepository();

  final HttpAiStoryFastSd httpAiStoryFastSd = HttpAiStoryFastSd();

  Child? selectStyle;
  String? imageBase; //图生图的垫图
  int batchSize = 2;
  bool _quality = false;
  bool hd = false;
  String light = "0";
  String camera = "0";
  final List<UserTag> inputTags = [];

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
    _stylefutureFastSd = httpAiConfigRepository.getFastSdStyles();
    _loadMountedModels();
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
    return _buildPpMode();
  }

  Future<void> _loadMountedModels() async {
    try {
      mountedModels = await getMountedModels();
      setState(() {}); // 通知框架重新构建UI
    } catch (error) {
      // 错误处理
    }
  }

  String getUserPrompt() {
    return _textPromptController.text;
  }

  //任务轮询生图模式
  Future<void> generalImage() async {
    //使用任务式生图
    String prompt = _textPromptController.text;
    if (prompt.isEmpty) {
      MotionToast.warning(description: Text("请输入SD提示词！")).show(context);
      widget.onGeneralDone.call([]);
      return;
    }
    if (selectStyle == null) {
      MotionToast.warning(description: Text("请先选择SD模型！")).show(context);
      widget.onGeneralDone.call([]);
      return;
    }
    RegExp chineseRegExp = RegExp(r'[\u4e00-\u9fa5]'); // Unicode范围表示中文字符
    bool hasZh = chineseRegExp.hasMatch(prompt);
    //如果输入了中文，则需要翻译英语。如果输入的是英语，则显示和传递Ai绘画都直接使用
    if (hasZh) {
      //翻译
      if (HttpUtil.baiduTk.isEmpty) {
        MotionToast.warning(description: Text("本地模式需要在首页设置翻译KEY才能支持中文!"))
            .show(context);
        widget.onGeneralDone.call([]);
        return;
      }
      prompt = await widget.httpAiStoryRepository
          .textTrans(text: prompt, langFrom: "zh", langTo: "en");
      print("翻译结果：" + prompt);
    }
    //再加上预置选择的提示词
    inputTags.forEach((tag) {
      prompt += ",";
      prompt += tag.tagEn;
    });

    //给新选的风格的透传数据赋值
    Map<String, dynamic> presetInfo = jsonDecode(selectStyle!.presetInfo);
    AiPaintParamsV2 aiPaintParamsV2 = widget.aiPaintParamsV2.copyWith(
        id: selectStyle!.id,
        styleName: selectStyle!.modelFileName,
        sampling: presetInfo['sampling'],
        steps: presetInfo['steps'],
        lora: presetInfo['lora'],
        negativePrompt: presetInfo['negative_prompt'],
        cfgScale: presetInfo['cfg_scale'].toDouble(),
        modelClass: presetInfo['model_class']);
    //这里还要重新赋值一下
    if (presetInfo.containsKey("hd")) {
      aiPaintParamsV2.hd.modelType = presetInfo['hd']['model_type'];
      aiPaintParamsV2.hd.scale = 2.0;
      aiPaintParamsV2.hd.strength = presetInfo['hd']['strength'];
      // if (quality > 25 && aiPaintParamsV2.hd.modelType == 1) {
      //   aiPaintParamsV2.hd.strength = 0.3 + (quality - 25) / 25 * 0.6;
      //   aiPaintParamsV2.hd.step = 40;
      // }
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

    //如果用户手动输入负向
    // if(_textNegPromptController.text.isNotEmpty){
    //   aiPaintParamsV2.negativePrompt = _textNegPromptController.text;
    // }

    //图生图{controlNet生图}
    if (imageBase != null) {
      List<int> imageBytes = File(imageBase!).readAsBytesSync();
      aiPaintParamsV2.image =
          "data:image/jpeg;base64," + base64Encode(imageBytes);
    }

    debugPrint("最终prompt：" +
        prompt +
        " neg_prompt:" +
        aiPaintParamsV2.negativePrompt.toString());
    aiPaintParamsV2.prompt = prompt;
    aiPaintParamsV2.batchSize = 1;
    // 假设aiImg是一个列表，用来存储每次生成的AiImg对象
    List aiImgList = [];
    var aiImg;
    // 循环调用imgGenerateSenior方法，并将结果添加到列表中
    for (var i = 0; i < batchSize; i++) {
      aiImg = await httpAiStoryFastSd.imgGenerateSenior(
          aiPaintParamsV2: aiPaintParamsV2,
          draftName: widget.draftName,
          hd: hd);
      // 将每次生成的AiImg对象添加到列表中
      aiImgList.add(aiImg);
    }

    if (!mounted) {
      return;
    }
    for (var i = 0; i < aiImgList.length; i++) {
      if (aiImgList[i].images.isNotEmpty) {
        debugPrint("获取本地成功:" + aiImgList[i].images.length.toString());
        //回调结果给左边页面展示
        if (aiImgList[i].images.length > 0) {
          List<String> urls = [];
          aiImgList[i].images.forEach((element) {
            urls.add(element.url);
          });
          widget.onGeneralDone.call(urls);
        } else {
          widget.onGeneralDone.call([]);
        }
      } else {
        MotionToast.warning(description: Text("生成成功但是没获取到结果！")).show(context);
        widget.onGeneralDone.call([]);
      }
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
        debugPrint("获取成功:" + result.scenes[0].imgs.length.toString());
        //回调结果给左边页面展示
        if (result.scenes[0].imgs.length > 0) {
          List<String> urls = [];
          result.scenes[0].imgs.forEach((element) {
            if (element.url != null) urls.add(element.url!);
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

  //显示加载弹窗
  void showLoadingDialog(BuildContext context, String text, bool flag) {
    showDialog(
      context: context,
      barrierDismissible: flag, // 用户不能通过点击背景关闭对话框
      builder: (BuildContext context) {
        return PopScope(
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(), // 加载指示器
                SizedBox(height: 20), // 用于添加空间
                Text(text), // 加载提示文本
              ],
            ),
          ),
        );
      },
    );
  }

  //获取当前挂载模型列表
  Future getMountedModels() async {
    Future<List<String>> mountedModelsFuture =
        httpAiConfigRepository.getFastSdMounted();
    // 等待Future完成，并获取结果
    var mountedModels = await mountedModelsFuture;
    return mountedModels;
  }

  ///FastSd模式
  Widget _buildPpMode() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  width: double.infinity,
                  child: FutureBuilder(
                      future: _stylefutureFastSd,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          // Error handling
                          return Text('Error: ${snapshot.error}');
                        } else {
                          // List<Child> data = [];
                          snapshot.data?.children.forEach((children) {
                            // data.add(children);
                            //默认选中已经挂载的风格
                            if (selectStyle == null &&
                                children.name ==
                                    widget.aiPaintParamsV2.styleName)
                              selectStyle = children;
                          });
                          List<AiStyleModel> aiStyleModels = [];
                          aiStyleModels.add(snapshot.data!);
                          return Row(
                            children: [
                              Padding(
                                child: Text(
                                  "风格",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                padding: EdgeInsets.only(right: 20),
                              ),
                              Expanded(
                                child: Padding(
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
                                          // StarMenuOverlay.displayStarMenu(
                                          //     context,
                                          //     StarMenu(
                                          //       params: StarMenuParameters(
                                          //           shape: MenuShape.grid,
                                          //           // centerOffset: Offset(0, 200),
                                          //           startItemScaleAnimation:
                                          //               1.0,
                                          //           useScreenCenter: true,
                                          //           // openDurationMs: 100,
                                          //           // useTouchAsCenter: true,
                                          //           gridShapeParams:
                                          //               GridShapeParams(
                                          //                   columns: 6,
                                          //                   columnsSpaceH: 0,
                                          //                   columnsSpaceV: 0)),
                                          //       // controller: starMenuController,
                                          //       parentContext: context,
                                          //       items: _buildStyleItem(data),
                                          //       onStateChanged: (state) => print(
                                          //           'Fast SD State changed: $state'),
                                          //       onItemTapped:
                                          //           (index, controller) async {
                                          //         print(
                                          //             'Menu item $index tapped');
                                          //         controller
                                          //             .closeMenu!(); //关闭模型选择
                                          //         showLoadingDialog(context,
                                          //             "模型加载中...", false); //打开加载弹窗
                                          //         //httpAiConfigRepository.getFastSdStyles();
                                          //         var mountedModels =
                                          //             await getMountedModels();
                                          //         print(
                                          //             "查询挂载的模型结果: $mountedModels ");
                                          //         bool mountedFlag = false;
                                          //         //检查是否包含当前模型
                                          //         for (var element
                                          //             in mountedModels) {
                                          //           print("当前挂载模型$element");
                                          //
                                          //           if (element ==
                                          //               data[index].name) {
                                          //             mountedFlag = true;
                                          //           } else {
                                          //             //卸载不需要的模型
                                          //             await httpAiConfigRepository
                                          //                 .FastSdUnMounteModel(
                                          //                     element);
                                          //           }
                                          //         }
                                          //         if (!mountedFlag) {
                                          //           print("挂载列表中没有当前模型,需要挂载");
                                          //           await httpAiConfigRepository
                                          //               .FastSdMounteModel(
                                          //                   data[index].name);
                                          //           print("挂载结束");
                                          //         }
                                          //         setState(() {
                                          //           selectStyle = data[index];
                                          //         });
                                          //         Navigator.of(context).pop();
                                          //       },
                                          //     ));
                                          //使用从底部弹出弹窗加gridview的方式实现上述注释代码的功能
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  padding: EdgeInsets.only(
                                                      top: 20,
                                                      left: 10,
                                                      right: 10),
                                                  height: 300,
                                                  child: StyleGridView(
                                                      aiStyleModels:
                                                          aiStyleModels,
                                                      aiStyleModelChanged:
                                                          (style) {
                                                        setState(() {
                                                          selectStyle = style;
                                                        });
                                                      },
                                                      selectStyleId: this
                                                              .selectStyle
                                                              ?.id ??
                                                          0,
                                                      countPerLine: 5),
                                                );
                                              });
                                        },
                                        child: Text(
                                          "${selectStyle == null ? "点击选择" : selectStyle?.name}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white60),
                                        ),
                                      )),
                                ),
                                flex: 1,
                              )
                            ],
                          );
                        }
                      }),
                ),
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
                      widget.onConsumePegg.call(batchSize);
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
                    style: TextStyle(fontSize: 10, color: Color(0xFF12CDD9))),
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Container(
            child: TextField(
              decoration: InputDecoration(
                hintText: '输入提示词',
                hintStyle: TextStyle(color: Color(0xFF808080), fontSize: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              maxLines: 2,
              maxLength: 400,
              controller: _textPromptController,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const Text(
                "已选提示词：",
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Container(
            padding: EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFF808080), // 设置边框颜色
                // 设置边框宽度
              ),
            ),
            child: Wrap(
              children: List.generate(
                inputTags.length,
                (index) => Chip(
                  // avatar: Image.asset("assets/images/icon_head.webp"),
                  label: Text(
                    inputTags[index].tagZh ?? "",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  // padding: const EdgeInsets.all(5),
                  // labelPadding: const EdgeInsets.all(3),
                  backgroundColor: Color(0xFF787474),
                  // shadowColor: Colors.orangeAccent,
//      deleteIcon: Icon(Icons.close,size: 18),
                  deleteIconColor: Color(0xFF12CDD9),
                  onDeleted: () {
                    setState(() {
                      inputTags.removeAt(index);
                    });
                  },
                  elevation: 3,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Switch(
                value: _quality,
                onChanged: (value) {
                  setState(() {
                    _quality = value;
                  });
                },
              ),
              Text(
                _quality ? '质量更好' : '速度更快',
                style: TextStyle(fontSize: 12, color: Color(0xFF12CDD9)),
              ),
              Switch(
                value: hd,
                onChanged: (value) {
                  setState(() {
                    hd = value;
                  });
                },
              ),
              Text(
                hd ? 'HD-3K' : '1080P',
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
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      padding: EdgeInsets.only(right: 20),
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
                      padding: EdgeInsets.only(right: 20),
                      child: Text(
                        "光线",
                        style: TextStyle(fontWeight: FontWeight.bold),
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
            height: 8,
          ),
          Row(
            children: [
              Circle(
                color: Color(0xFF12CDD9),
                radius: 5,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  "仿图",
                  style: TextStyle(fontSize: 15),
                ),
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
          _buildImage2ImageWidget(),
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
                  child: Image.file(
                      width: 100,
                      height: 100,
                      File(imageBase!),
                      fit: BoxFit.contain),
                  width: 100,
                  height: 100,
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

  _addPpPrompt() {
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              elevation: 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0), // 圆角半径
                ),
                child: Scaffold(
                  backgroundColor: Color(0xFF383838),
                  appBar: AppBar(
                    backgroundColor: Colors.black26,
                    title: Text('提示词宝典'),
                  ),
                  body: Padding(
                    child: EditPromptWordsPanel(
                      initPrompts: [],
                      index: 0,
                      onEditCallback: (inputTags) async {

                      },
                      httpAiStoryRepository: widget.httpAiStoryRepository,
                    ),
                    padding: EdgeInsets.only(left: 25),
                  ),
                ),
                width: 800,
                height: 600,
              ),
            ));
  }

  _selectLocalImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
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
          Directory(ppImagePath).createSync();
        }
        // showDialog(
        //     context: context,
        //     builder: (ctx) => Dialog(
        //           backgroundColor: Theme.of(context).dialogBackgroundColor,
        //           elevation: 5,
        //           child: SizedBox(
        //             child: CropUploadImagePanel(
        //               selectImgPath: file.path!,
        //               onCropped: (cropImgPath) {
        //                 if (cropImgPath.isNotEmpty) {
        //                   setState(() {
        //                     imageBase = cropImgPath;
        //                   });
        //                 }
        //               },
        //               taskSavePath: ppImagePath,
        //               ratio: AiPaintParamsV2.getTrueRatio(
        //                   widget.aiPaintParamsV2.ratio),
        //             ),
        //             width: 600,
        //             height: 600,
        //           ),
        //         ));
        //使用页面跳转方式实现
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CropUploadImagePanel(
                      selectImgPath: file.path!,
                      onCropped: (cropImgPath) {
                        if (cropImgPath.isNotEmpty) {
                          setState(() {
                            imageBase = cropImgPath;
                          });
                        }
                      },
                      taskSavePath: ppImagePath,
                      ratio: AiPaintParamsV2.getTrueRatio(
                          widget.aiPaintParamsV2.ratio),
                    )));
      }
    }
  }

  ///FastSd风格弹窗选择
  List<Widget> _buildStyleItem(List<Child> data) {
    return data.map((children) {
      return Container(
        width: 150,
        color: selectStyle?.name == children.name
            ? Color(0xFF12CDD9)
            : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: CachedNetworkImage(
                imageUrl: children.icon,
                fit: BoxFit.contain,
              ),
              width: 150,
              height: 150,
            ),
            Text(
              children.name,
              style: TextStyle(color: Colors.black),
              maxLines: 1, // 设置最大行数为1
              overflow: TextOverflow.ellipsis, // 超出部分显示省略号
            ),
          ],
        ),
      );
    }).toList();
  }
}
