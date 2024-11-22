import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:utils/utils.dart';

import '../../../../app/api_https/ai_config_repository.dart';
import '../../../../app/api_https/ai_story_repository.dart';
import '../../../../app/model/TweetScript.dart';
import '../../../../app/model/config/ai_analyse_role_scene.dart';
import '../../../../app/model/user_info_global.dart';
import '../../../../app/navigation/mobile/theme/theme.dart';
import 'crop_upload_image.dart';

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

///分镜组件的图片显示和操作区域
class ImageToolItem extends StatefulWidget {
  final Function() onShowImageGeneral;
  final Function(int mediaType) selectMediaType;
  final bool lockedSeed;
  final TweetImage tweetImage;
  final String draftName;
  final List<Role> roles;
  final Scene? scene;
  final int type;
  final int shidai;
  final bool localMode;
  final List<String> urls;
  final List<String> videoUrls;
  final AiConfigRepository aiConfigRepository;
  final AiStoryRepository httpAiStoryRepository;
  final AiPaintParamsV2 aiPaintParamsV2;

  ImageToolItem(
      {Key? key,
      required this.tweetImage,
      required this.type,
      required this.localMode,
      required this.aiConfigRepository,
      required this.httpAiStoryRepository,
      required this.onShowImageGeneral,
      required this.aiPaintParamsV2,
      required this.roles,
      this.scene,
      required this.urls,
      required this.videoUrls,
      required this.lockedSeed,
      required this.selectMediaType,
      required this.draftName,
      required this.shidai})
      : super(key: key);

  @override
  State<ImageToolItem> createState() => ImageToolItemState();
}

class ImageToolItemState extends State<ImageToolItem> {
  bool isGeneral = false;
  bool _LockedSeed = true;
  bool isImage = true;

  @override
  void initState() {
    _LockedSeed = widget.lockedSeed;
    isImage = widget.tweetImage.mediaType == 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          alignment: Alignment.center,
          child: GestureDetector(
            child: SizedBox(
              height: 200,
              child: (widget.tweetImage.url?.isEmpty ?? true)
                  ? SizedBox.shrink()
                  : widget.tweetImage.url!.startsWith("http")
                      ? CachedNetworkImage(
                          imageUrl: widget.tweetImage.url!,
                          // progressIndicatorBuilder:
                          //     (context, url, downloadProgress) =>
                          //         CircularProgressIndicator(
                          //             value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : Image.file(File(widget.tweetImage.url!),
                          fit: BoxFit.cover),
            ),
            onTap: () => widget.onShowImageGeneral.call(),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.type == 3)
                SizedBox(
                  child: Column(
                    children: [
                      Text(
                        widget.tweetImage.origin!.strength.toStringAsFixed(2),
                        style: TextStyle(color: Color(0xFF12CDD9)),
                      ),
                      Slider(
                        value: widget.tweetImage.origin!.strength,
                        min: 0.1,
                        max: 1.0,
                        label: widget.tweetImage.origin!.strength
                            .toStringAsFixed(1),
                        activeColor: Color(0xFF12CDD9),
                        onChanged: (value) {
                          print("value:" + value.toStringAsFixed(1));
                          setState(() {
                            widget.tweetImage.origin!.strength = value;
                          });
                        },
                        // onChangeEnd: (value) {
                        //   print(
                        //       "滑动结束:" + _speed.toStringAsFixed(1));
                        // },
                      )
                    ],
                  ),
                  width: 150,
                ),
              if (widget.type != 3)
                Wrap(
                  runAlignment: WrapAlignment.start,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Switch(
                      value: _LockedSeed,
                      onChanged: (value) {
                        setState(() {
                          _LockedSeed = value;
                        });
                      },
                    ),
                    Text(
                      _LockedSeed ? '锁定种子' : '随机种子',
                      style: TextStyle(fontSize: 12, color: Color(0xFF12CDD9)),
                    ),
                  ],
                ),
              ElevatedButton(
                onPressed: () async {
                  //看是否皮蛋足够
                  var user = GlobalInfo.instance.user;
                  if (!widget.localMode && user.pegg < 1) {
                    MotionToast.error(description: Text("皮蛋不足!")).show(context);
                    return;
                  }
                  if (isGeneral) {
                    return;
                  }
                  setState(() {
                    isGeneral = true;
                  });

                  String url = await loadImage();
                  if (url.isNotEmpty) widget.urls.add(url);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // 设置圆角半径
                  ),
                  backgroundColor: Color(0xFF12CDD9),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size(75, 30),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                ),
                child: isGeneral
                    ? const SizedBox(
                        child: const CircularProgressIndicator(
                          color: Colors.black,
                        ),
                        width: 20,
                        height: 20,
                      )
                    : Text(
                        widget.localMode ? "免费生图" : "生图|-1皮蛋",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
        Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.image,
                      );
                      if (result != null) {
                        PlatformFile file = result.files.single;
                        if (file.path?.isNotEmpty == true) {
                          // 保存到当前草稿目录
                          String draftPath =
                              await FileUtil.getPieceAiDraftFolderByTaskId(
                                  widget.draftName);
                          String ppImagePath = draftPath +
                              FileUtil.getFileSeparate() +
                              "local_image" +
                              FileUtil.getFileSeparate();
                          if (!Directory(ppImagePath).existsSync()) {
                            Directory(ppImagePath).createSync(recursive: true);
                          }
                          //使用页面方式打开
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => CropUploadImagePanel(
                                    selectImgPath: file.path!,
                                    onCropped: (cropImgPath) {
                                      if (cropImgPath.isNotEmpty) {
                                        setState(() {
                                          // 立即重新设置回原来的值
                                          widget.tweetImage.url = cropImgPath;
                                          widget.urls.add(cropImgPath);
                                        });
                                      }
                                    },
                                    taskSavePath: ppImagePath,
                                    baseSaveName:
                                        FileUtil.getFileName(file.name),
                                    ratio: AiPaintParamsV2.getTrueRatio(
                                        widget.aiPaintParamsV2.ratio),
                                  )));
                        }
                      }
                    },
                    icon: const Icon(Icons.upload_outlined),
                    iconSize: 35,
                    color: Color(0xFF12CDD9),
                  ),
                  Switch(
                    value: isImage,
                    onChanged: (value) {
                      setState(() {
                        isImage = value;
                        if (isImage) {
                          widget.selectMediaType.call(0);
                        } else {
                          widget.selectMediaType.call(1);
                        }
                      });
                    },
                  ),
                  Text(
                    isImage
                        ? '图片'
                        : widget.videoUrls.isEmpty
                            ? '视频'
                            : '视频',
                    style: TextStyle(fontSize: 12, color: AppColor.piecesBlue),
                  ),
                  Text(
                    isImage
                        ? widget.urls.isEmpty
                            ? '（未生成）'
                            : '（已生成）'
                        : widget.videoUrls.isEmpty
                            ? '（未生成）'
                            : '（已生成）',
                    style: TextStyle(
                        fontSize: 12,
                        color: isImage
                            ? widget.urls.isEmpty
                                ? Colors.red
                                : AppColor.piecesBlue
                            : widget.videoUrls.isEmpty
                                ? Colors.red
                                : AppColor.piecesBlue),
                  ),
                  ElevatedButton(
                    onPressed: () => widget.onShowImageGeneral.call(),
                    style: ElevatedButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size(75, 30),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
                        side: BorderSide(color: Color(0xFF12CDD9), width: 1),
                      ),
                      backgroundColor: Colors.black,
                    ),
                    child: Text(
                      "高级编辑",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                ],
              ),
            )),
        if (widget.tweetImage.mediaType == 1)
          GestureDetector(
            onTap: () => widget.onShowImageGeneral.call(),
            child: Center(
                child: Image(
              image: AssetImage("assets/images/text_video.png"),
            )),
          ),
      ],
    );
  }


  ///刷新状态显示
  void refreshState(int mediaType) {
    setState(() {
      isImage = mediaType == 0;
    });
  }

  ///单张生图
  Future<String> loadImage() async {
    //组装推理提示词和角色场景提示词
    AiPaintParamsV2 aiPaintParamsV2 = widget.httpAiStoryRepository
        .composePrompt(
            tweetImage: widget.tweetImage,
            aiPaintParamsV2original: widget.aiPaintParamsV2,
            roles: widget.roles,
            lockedSeed: _LockedSeed,
            scene: widget.scene,
            type: widget.type);
    if (widget.type == 3) {
      //追爆款，图生图
    }

    var aiImg = await widget.httpAiStoryRepository
        .imgGenerate(aiPaintParamsV2: aiPaintParamsV2, context: context);
    if (aiImg.images.isNotEmpty) {
      var length = aiImg.images.length;
      var urlLast = aiImg.images[length - 1].url;
      logger.d("网络图片地址：$urlLast");
      //先下载图片到本地草稿文件夹，然后再重新赋值
      String draftPath =
          await FileUtil.getPieceAiDraftFolderByTaskId(widget.draftName);
      String ppImagePath = draftPath +
          FileUtil.getFileSeparate() +
          "pp_image" +
          FileUtil.getFileSeparate();
      FileUtil.createDirectoryIfNotExists(ppImagePath);
      String imageName = FileUtil.getHttpNameWithExtension(urlLast);
      String imageFilePath = ppImagePath + imageName;
      logger.d("获取到ppImagePath：$ppImagePath, imageFilePath: $imageFilePath");
      await _downloadResource(urlLast, imageFilePath);
      if (mounted) {
        setState(() {
          isGeneral = false;
          widget.tweetImage.url = imageFilePath;
        });
      } else {
        isGeneral = false;
        widget.tweetImage.url = imageFilePath;
      }
      return imageFilePath;
    } else {
      setState(() {
        isGeneral = false;
      });
      return "";
    }
    // }
  }

  _downloadResource(String url, String path) async {
    logger.d("下载资源：$url");
    await HttpUtil.instance.client.download(url, path,
        onReceiveProgress: (int get, int total) {
      String progress = ((get / total) * 100).toStringAsFixed(2);
    });
  }
}
