import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:components/toly_ui/ti/circle.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_story_localsd.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';
import 'package:pieces_ai/components/custom_widget/DropMenuWidget.dart';
import 'package:utils/utils.dart';

import '../../../../app/api_https/impl/https_ai_config_repository.dart';
import '../../../../app/api_https/impl/https_ai_story_repository.dart';
import '../../../../app/gen/toly_icon_p.dart';
import '../../../../app/model/ai_style_model.dart';
import '../scene_child_widget/crop_upload_image.dart';

//MultimodalGen模型生图模式
GlobalKey<_SdWebuiGeneralPanelState> sdWebuiGeneralPanelKey = GlobalKey();

class SdWebuiGeneralPanel extends StatefulWidget {
  final Function(double) onGeneralProgress;
  final Function(List<String> images) onGeneralDone;
  final String draftName;
  final HttpAiStoryRepository httpAiStoryRepository;
  final AiPaintParamsV2 aiPaintParamsV2;

  SdWebuiGeneralPanel({
    Key? key,
    required this.onGeneralProgress,
    required this.draftName,
    required this.httpAiStoryRepository,
    required this.onGeneralDone,
    required this.aiPaintParamsV2,
  }) : super(key: key);

  @override
  State<SdWebuiGeneralPanel> createState() {
    return _SdWebuiGeneralPanelState();
  }
}

class _SdWebuiGeneralPanelState extends State<SdWebuiGeneralPanel>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _textPromptController = TextEditingController();
  final TextEditingController _textNegPromptController =
      TextEditingController();
  late Future<AiStyleModel> _styleFutureSdLocal;
  final HttpAiConfigRepository httpAiConfigRepository =
      HttpAiConfigRepository();
  final HttpAiStoryLocalSd httpAiStoryLocalSd = HttpAiStoryLocalSd();
  Child? selectStyle;
  String? imageBase; //图生图的垫图
  int batchSize = 2;
  double quality = 25;
  String light = "0";
  String camera = "";

  final lightList = const [
    {'label': '无', 'value': '0', 'prompt': ''},
    {'label': '电影氛围光照', 'value': '1', 'prompt': 'cinematic lighting'},
    {'label': '柔和光线', 'value': '2', 'prompt': 'Soft light'},
    {'label': '明亮光线', 'value': '3', 'prompt': 'Bright light'},
  ];

  @override
  void initState() {
    _styleFutureSdLocal = httpAiConfigRepository.getLocalStyles();
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _textPromptController.dispose();
    _textNegPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildPpMode();
  }

  String getUserPrompt() {
    return _textPromptController.text;
  }

  ///任务轮询生图模式
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
      if (quality > 25 && aiPaintParamsV2.hd.modelType == 1) {
        aiPaintParamsV2.hd.strength = 0.3 + (quality - 25) / 25 * 0.6;
        aiPaintParamsV2.hd.step = 40;
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

    //如果用户手动输入负向
    if (_textNegPromptController.text.isNotEmpty) {
      aiPaintParamsV2.negativePrompt = _textNegPromptController.text;
    }

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
    aiPaintParamsV2.batchSize = batchSize;
    var aiImg = await httpAiStoryLocalSd.imgGenerateSenior(
        aiPaintParamsV2: aiPaintParamsV2, draftName: widget.draftName);
    if (!mounted) {
      return;
    }
    if (aiImg.images.isNotEmpty) {
      debugPrint("获取本地成功:" + aiImg.images.length.toString());
      //回调结果给左边页面展示
      if (aiImg.images.length > 0) {
        List<String> urls = [];
        aiImg.images.forEach((element) {
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
                child: Container(
                  width: double.infinity,
                  child: FutureBuilder(
                      future: _styleFutureSdLocal,
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
                          List<Child> data = [];
                          snapshot.data?.children.forEach((children) {
                            data.add(children);
                            //默认选中本身的风格
                            if (selectStyle == null &&
                                children.id == widget.aiPaintParamsV2.id)
                              selectStyle = children;
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
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  height: 300,
                                                  child: GridView.count(
                                                    crossAxisCount: 4,
                                                    children:
                                                        _buildStyleItem(data),
                                                  ),
                                                );
                                              }).then((value) {
                                            if (value != null) {
                                              setState(() {
                                                selectStyle = value;
                                              });
                                            }
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
                    },
                    offset: const Offset(-40, 40),
                    selectedValue: '2', //默认选中2张
                  ),
                ),
                flex: 1,
              )
            ],
          ),
          Container(
            child: TextField(
              decoration: InputDecoration(
                hintText: '输入提示词',
                hintStyle: TextStyle(color: Color(0xFF808080), fontSize: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              maxLines: 3,
              maxLength: 400,
              controller: _textPromptController,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            child: TextField(
              decoration: InputDecoration(
                hintText: '负向提示词',
                hintStyle: TextStyle(color: Color(0xFF808080), fontSize: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              maxLines: 3,
              maxLength: 400,
              controller: _textNegPromptController,
            ),
          ),
          Row(
            children: [
              Circle(
                color: Color(0xFF12CDD9),
                radius: 7,
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
            height: 10,
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
            width: 100,
            height: 100,
          ),
        )
      ],
    );
  }

  _selectLocalImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowedExtensions: [
        'jpg',
        'png',
      ],
    );
    if (result != null) {
      PlatformFile file = result.files.single;
      if (file.path?.isNotEmpty == true) {
        // 保存到当前草稿目录
        String draftPath =
            await FileUtil.getPieceAiDraftFolderByTaskId(widget.draftName);
        String ppImagePath = draftPath +
            FileUtil.getFileSeparate() +
            "sd_image" +
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
        //使用页面跳转实现上面注释的弹窗
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

  List<Widget> _buildStyleItem(List<Child> data) {
    return data.map((children) {
      return Container(
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
            ),
          ],
        ),
      );
    }).toList();
  }
}
