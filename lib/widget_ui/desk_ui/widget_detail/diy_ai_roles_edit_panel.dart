import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pieces_ai/app/api_https/ai_story_repository.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_story_fastsd.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_story_localsd.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_story_repository.dart';
import 'package:pieces_ai/app/api_https/impl/https_diy_roles_repository.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';
import 'package:pieces_ai/app/model/diy/diy_roles.dart' as diy;
import 'package:utils/utils.dart';

import '../../../app/api_https/impl/https_ai_config_repository.dart';
import '../../../app/model/ai_style_model.dart';
import '../category_panel/desk_sytle_grid.dart';
import 'edit_prompt_words_panel.dart';

/// create by blueming.wu
/// Ai推文自定义形象新增+编辑页面
class DiyAiRolesEditPanel extends StatefulWidget {
  const DiyAiRolesEditPanel({
    Key? key,
    required this.onSave,
    this.aiPaintParamsV2,
    this.customRolePicture,
    required this.styleId,
  }) : super(key: key);

  final Function(bool refresh) onSave;
  final AiPaintParamsV2? aiPaintParamsV2;
  final diy.CustomRolePicture? customRolePicture;
  final int styleId;

  @override
  _StyleGridViewState createState() => _StyleGridViewState();
}

class _StyleGridViewState extends State<DiyAiRolesEditPanel> {
  int selectRoleIndex = 0;
  int selectGender = 1;
  bool refresh = false;
  bool isGeneral = false;
  late String imgUrl;
  List<diy.Tag> userTags = [];
  double seed = -1;
  late PageController _pageControllerGender;
  TextEditingController textNameController = TextEditingController();
  late AiStoryRepository httpAiStoryRepository;
  HttpsDiyRolesRepository httpsDiyRolesRepository = HttpsDiyRolesRepository();
  final HttpAiConfigRepository httpAiConfigRepository =
      HttpAiConfigRepository();
  late AiPaintParamsV2? aiPaintParamsV2;
  late Future<List<AiStyleModel>> _future;
  late int styleId;

  @override
  void initState() {
    styleId = widget.styleId;
    _future = httpAiConfigRepository.loadStyleWidgets();
    aiPaintParamsV2 = widget.aiPaintParamsV2 ?? null;
    if (widget.customRolePicture == null) {
      imgUrl = "";
    } else {
      if (styleId == -1111 || styleId == -1112) {
        imgUrl = widget.customRolePicture!.icon.split("https://+")[1];
      } else {
        imgUrl = widget.customRolePicture!.icon;
      }
      // seed = widget.customRolePicture!.rolePromptInfo!.imgs[widget.aiPaintParamsV2.ratio].seed;
      ///这里正确的应该改成下面的
      // imgUrl = widget.customRolePicture!.rolePromptInfo!
      //     .imgs[widget.aiPaintParamsV2.ratio].path;
      selectGender = widget.customRolePicture!.sex;
    }
    textNameController.text = widget.customRolePicture?.name ?? "";
    if (styleId == -1111) {
      httpAiStoryRepository = HttpAiStoryLocalSd();
    } else if (styleId == -1112) {
      httpAiStoryRepository = HttpAiStoryFastSd();
    } else {
      httpAiStoryRepository = HttpAiStoryRepository();
    }
    super.initState();
    _pageControllerGender = PageController();
  }

  @override
  void dispose() {
    _pageControllerGender.dispose();
    textNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("自定义形象", style: TextStyle(fontSize: 18))),
      body: Padding(
        padding: EdgeInsets.only(left: 5, right: 5, top: 5),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFA6A6A6), width: 1),
                        // borderRadius: BorderRadius.circular(10),
                      ),
                      child: styleId == -1111 || styleId == -1112
                          ? imgUrl.isNotEmpty
                              ? imgUrl.contains("imgs.pencil-stub.com")
                                  ? Image.file(
                                      File(imgUrl
                                          .split("imgs.pencil-stub.com")[1]),
                                      fit: BoxFit.cover)
                                  : Image.file(File(imgUrl), fit: BoxFit.cover)
                              : SizedBox(
                                  width: 400,
                                  height: 300,
                                )
                          : CachedNetworkImage(
                              fit: BoxFit.contain,
                              imageUrl: imgUrl,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) =>
                                  const Center(
                                child: Text("角色预览区"),
                              ),
                            ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 10), child: _buildName()),
                  if (widget.aiPaintParamsV2 == null)
                    SizedBox(
                      child: FutureBuilder<List<AiStyleModel>>(
                        future: _future,
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
                            // 一共三个区域，左上为 gridView 的风格区域，左下为比例选择，右边为文本区域
                            StyleGridView styleGridView = StyleGridView(
                              aiStyleModels: snapshot.data ?? [],
                              aiStyleModelChanged: (Child aiStyleModel) {
                                print(
                                    "选中了风格:${aiStyleModel.name}，id:${aiStyleModel.id}");
                                this.styleId = aiStyleModel.id;
                                Map<String, dynamic> presetInfo =
                                    jsonDecode(aiStyleModel.presetInfo);
                                String styleName = presetInfo['style_name'];
                                if (styleName.isEmpty) {
                                  styleName = aiStyleModel.modelFileName;
                                }
                                print("风格透传数据：" + aiStyleModel.presetInfo);
                                var sampling = presetInfo['sampling'];
                                var steps = presetInfo['steps'];
                                var lora = presetInfo['lora'];
                                var negativePrompt =
                                    presetInfo['negative_prompt'];
                                var prompt = presetInfo['prompt'];
                                var modelClass = presetInfo['model_class'];
                                var cfg_scale = presetInfo['cfg_scale'];
                                var hd = Hd();
                                this.aiPaintParamsV2 = AiPaintParamsV2(
                                    batchSize: 1,
                                    cfgScale: cfg_scale.toDouble(),
                                    detection: true,
                                    hd: hd,
                                    height: 600,
                                    sampling: sampling,
                                    lora: lora,
                                    negativePrompt: negativePrompt,
                                    modelClass: modelClass,
                                    prompt: prompt,
                                    ratio: 1,
                                    seed: -1,
                                    steps: steps,
                                    styleName: presetInfo['style_name'],
                                    width: 450);
                                //这里还要重新赋值一下
                                if (presetInfo.containsKey("hd")) {
                                  hd.modelType = presetInfo['hd']['model_type'];
                                  hd.scale = 2.0;
                                  hd.strength = presetInfo['hd']['strength'];
                                }
                              },
                              selectStyleId: styleId,
                              countPerLine: 6,
                            );
                            return styleGridView;
                          }
                        },
                      ),
                      height: 220,
                    ),
                  Container(
                    height: 700,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          child: Text('描述词：  ', style: TextStyle(fontSize: 14)),
                          padding: EdgeInsets.only(top: 15),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: _buildInputTags(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(child: _buildBtn(), bottom: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildName() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "角色名称：",
              style: TextStyle(fontSize: 14),
            ),
            Flexible(
                child: Container(
                  // width: 180,
                  height: 30,
                  child: TextField(
                    //设置输入文字的大小
                    style: TextStyle(fontSize: 12),
                    //设置输入文字居中
                    // textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    //缩小输入框的高度，文字上下的边距
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: '请输入角色名',
                      contentPadding:
                          EdgeInsets.only(left: 10, top: 2, bottom: 2),
                      hintStyle:
                          TextStyle(color: Color(0xFF808080), fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    controller: textNameController,
                  ),
                ),
                flex: 2),
          ],
        ),
        _buildSex()
      ],
    );
  }

  Widget _buildSex() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text('角色性别：', style: TextStyle(fontSize: 14)),
        Text('男', style: TextStyle(fontSize: 12)),
        Radio(
          value: 1,
          groupValue: selectGender,
          onChanged: (value) {
            setState(() {
              selectGender = value!;
            });
          },
        ),
        SizedBox(
          width: 25,
        ),
        Text('女', style: TextStyle(fontSize: 14)),
        Radio(
          value: 2,
          groupValue: selectGender,
          onChanged: (value) {
            setState(() {
              selectGender = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildInputTags() {
    List<UserTag> initPrompts = [];
    widget.customRolePicture?.rolePromptInfo?.tags?.forEach((tag) {
      UserTag userTag = UserTag(tagEn: tag.en, tagZh: tag.zh);
      initPrompts.add(userTag);
    });
    print("初始化的tags：" + initPrompts.toString());
    return Container(
      child: EditPromptWordsPanel(
        initPrompts: initPrompts,
        promptType: 1,
        index: 0,
        onUserTagModify: (inputTags) {
          //选择的提示词保存起来。
          if (inputTags.isNotEmpty) {
            userTags.clear();
            inputTags.forEach((key, value) {
              userTags.add(diy.Tag(en: value.enName, type: 1, zh: value.name));
            });
          }
        },
        httpAiStoryRepository: httpAiStoryRepository,
      ),
    );
  }

  Widget _buildBtn() {
    return ButtonBar(
      children: [
        SizedBox(
          child: ElevatedButton(
            onPressed: () => _generalDiyRole(),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0), // 设置圆角半径
              ),
              backgroundColor: Color(0xFF12CDD9),
            ),
            child: isGeneral
                ? const CircularProgressIndicator(
                    color: Colors.black,
                  )
                : Text(
                    "立即生成 | -1",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
          ),
          width: 150,
          height: 40,
        ),
        Padding(
          padding: EdgeInsets.only(left: 20),
          child: _buildSaveBtn(),
        )
      ],
    );
  }

  ///人物选择整个widget
  Widget _buildSaveBtn() => SizedBox(
        child: ElevatedButton(
          onPressed: () => _saveAndExit(),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // 设置圆角半径
            ),
            backgroundColor: Color(0xFF12CDD9),
          ),
          child: isGeneral
              ? const CircularProgressIndicator(
                  color: Colors.black,
                )
              : Text(
                  "保存并退出",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
        ),
        width: 130,
        height: 40,
      );

  ///访问访问生成一个DIY角色
  _generalDiyRole() async {
    if (userTags.isEmpty) {
      MotionToast.info(description: Text("没有提示词!")).show(context);
      return;
    }
    if (this.aiPaintParamsV2 == null) {
      MotionToast.info(description: Text("等待风格加载完成!")).show(context);
      return;
    }
    setState(() {
      isGeneral = true;
    });
    String prompt = "";
    userTags.forEach((element) {
      prompt += element.en;
      prompt += ",";
    });
    debugPrint("人物提示词:$prompt");
    RegExp regex = RegExp("%s");
    String newPrompt = this
        .aiPaintParamsV2!
        .prompt
        .replaceFirstMapped(regex, (match) => prompt);
    prompt = newPrompt != this.aiPaintParamsV2!.prompt
        ? newPrompt
        : this.aiPaintParamsV2!.prompt + prompt;
    AiPaintParamsV2 aiPaintParamsV2 =
        this.aiPaintParamsV2!.copyWith(prompt: prompt);
    //2.2模型的一致性角色
    if (aiPaintParamsV2.modelClass == 3) {
      String name = textNameController.text;
      debugPrint('2.2模型支持一致性角色:$name');
      var tweetRole = TweetRole(
          name: name,
          negativePrompt: aiPaintParamsV2.negativePrompt ?? "",
          prompt: prompt,
          seed: -1);
      aiPaintParamsV2.roles = [tweetRole];
      aiPaintParamsV2.prompt = '[${tweetRole.name}]';
    }
    var aiImg = await httpAiStoryRepository.imgGenerate(
        context: context, aiPaintParamsV2: aiPaintParamsV2);

    if (aiImg.images.isNotEmpty) {
      setState(() {
        refresh = true;
        isGeneral = false;
        seed = aiImg.allSeeds[0];
        imgUrl = aiImg.images[0].url;
      });
    } else {
      MotionToast.error(description: Text("生成失败，请重试")).show(context);
      setState(() {
        isGeneral = false;
      });
    }
  }

  ///执行保存并且推出
  _saveAndExit() async {
    if (textNameController.text.isEmpty) {
      MotionToast.info(description: Text("请输入角色名!")).show(context);
      return;
    }
    if (userTags.isEmpty) {
      MotionToast.info(description: Text("没有人物提示词!")).show(context);
      return;
    }
    //用户进来没生成图，点击保存直接退出
    if (!refresh) {
      Navigator.of(context).pop();
      return;
    }
    String prompt = "";
    userTags.forEach((element) {
      prompt += element.en;
      prompt += ",";
    });
    setState(() {
      isGeneral = true;
    });
    //访问网络进行提交
    diy.CustomRolePicture customRolePicture;
    if (widget.customRolePicture == null) {
      diy.RolePromptInfo rolePromptInfo;
      DateTime now = DateTime.now();
      int milliseconds = now.millisecondsSinceEpoch;
      List<diy.Img> imgs =
          List.generate(7, (index) => diy.Img(path: "", seed: -1));
      for (int i = 0; i < 7; i++) {
        if (i == this.aiPaintParamsV2!.ratio) {
          diy.Img img = diy.Img(path: imgUrl, seed: seed);
          imgs[i] = img;
        }
      }
      //如果是本地模式，则自动加一个http头防止服务器增加头
      if (styleId == -1111 || styleId == -1112) {
        imgUrl = "https://+" + imgUrl;
      }
      //把当次用户输入和选择tag的中英文同时保存起来
      rolePromptInfo = diy.RolePromptInfo(
          imgs: imgs, negativePrompt: "", prompt: prompt, tags: userTags);
      customRolePicture = diy.CustomRolePicture(
          icon: imgUrl,
          id: null,
          name: textNameController.text,
          rolePromptInfo: rolePromptInfo,
          sex: selectGender,
          status: 1,
          style: styleId,
          updateTime: milliseconds.toDouble());
    } else {
      ///icon显示什么
      customRolePicture = widget.customRolePicture!;
      diy.RolePromptInfo rolePromptInfo =
          customRolePicture.rolePromptInfo!.copyWith();
      diy.Img img = diy.Img(path: imgUrl, seed: seed);
      //兼容之前的角色错误
      if (rolePromptInfo.imgs.length - 1 < this.aiPaintParamsV2!.ratio) {
        print("老的有问题的自定义角色:" + rolePromptInfo.imgs.length.toString());
        if (rolePromptInfo.imgs.length < this.aiPaintParamsV2!.ratio) {}
        rolePromptInfo.imgs.insert(this.aiPaintParamsV2!.ratio, img);
      } else {
        rolePromptInfo.imgs[this.aiPaintParamsV2!.ratio] = img;
      }
      rolePromptInfo.prompt = prompt;
      rolePromptInfo.tags = userTags;
      customRolePicture.icon = imgUrl;
      customRolePicture.style = styleId;
      customRolePicture.rolePromptInfo = rolePromptInfo;
    }

    int code = await httpsDiyRolesRepository.updateDiyRole(customRolePicture);
    print("更新角色返回code" + code.toString());
    setState(() {
      isGeneral = false;
    });
    if (code == 200) {
      Navigator.of(context).pop();
      widget.onSave.call(refresh);
    } else {
      Toast.error(context, "保存失败，联系客服！");
    }
  }
}
