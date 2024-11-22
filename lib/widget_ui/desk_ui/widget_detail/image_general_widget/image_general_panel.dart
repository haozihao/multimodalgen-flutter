import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:horizontal_list_view/horizontal_list_view.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:logger/logger.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path/path.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_story_repository.dart';
import 'package:pieces_ai/app/navigation/mobile/theme/theme.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/image_general_widget/fast_sd_general_panel.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/image_general_widget/pp_general_panel.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/image_general_widget/sd_webui_general_panel.dart';
import 'package:utils/utils.dart';

import '../../../../app/model/TweetScript.dart';
import '../../../../app/model/user_info_global.dart';

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

///点击查看历史图片
class ImgGeneralPanel extends StatefulWidget {
  final String? imageUrl;
  final String draftName;
  final List<String> urls;

  ///外部分镜填写的关键词
  final List<UserTag> inputTags;
  final Function(String url, String videoUrl, int mediaType) onImageSelected;
  final bool localMode;
  final bool? isFromTool;
  final AiPaintParamsV2 aiPaintParamsV2;

  ImgGeneralPanel({
    required this.imageUrl,
    required this.urls,
    required this.onImageSelected,
    required this.localMode,
    required this.draftName,
    required this.aiPaintParamsV2,
    required this.inputTags,
    this.isFromTool = false,
  });

  @override
  State<ImgGeneralPanel> createState() {
    return _ImgScaleDialogState();
  }
}

class _ImgScaleDialogState extends State<ImgGeneralPanel>
    with SingleTickerProviderStateMixin {
  late String imageUrl;
  int initialIndex = 0;
  CarouselSliderController _carouselController = CarouselSliderController();
  // late List<String> urls;
  late TabController _tabController;
  final HttpAiStoryRepository httpAiStoryRepository = HttpAiStoryRepository();

  final HorizontalListViewController _controller =
      HorizontalListViewController();
  bool isGeneral = false;
  int pegg = 2;

  ///生图的进度，SD本地的可能无法获取进度
  // double generalProgress = 0;

  ///生图模式，0为MultimodalGen模型，1为sd-webui，2为mj,3为Fast-SD
  int generalType = 0;
  final List<String> uButtons = ["左上", "右上", "左下", "右下"];

  @override
  void initState() {
    imageUrl = widget.imageUrl ?? "";
    //判断imageUrl再urls中的位置
    initialIndex = widget.urls.indexOf(imageUrl);
    _tabController =
        TabController(length: 3, vsync: this, animationDuration: Duration.zero);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.piecesBlackGrey,
      body: Column(
        children: [
          _buildLeftImages(context),
          Expanded(
            child: Padding(
                padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                child: _buildGeneralTabBar()),
          ),
          _buildGeneralButton(context)
        ],
      ),
    );
  }

  ///生土按钮
  _buildGeneralButton(BuildContext context) {
    return Container(
      color: AppColor.piecesGrey,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: ElevatedButton(
              onPressed: () => _pressGeneral(context),
              child: isGeneral
                  ? SizedBox(
                      child: const CircularProgressIndicator(
                        color: Colors.black,
                      ),
                      height: 30,
                      width: 30,
                    )
                  : Text(
                      "立即生成 | -$pegg皮蛋",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          if (!widget.isFromTool!) Spacer(),
          if (!widget.isFromTool!)
            Container(
              child: ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (!imageUrl.startsWith("clip"))
                    widget.onImageSelected(imageUrl, '', 0);
                  Navigator.of(context).pop();
                },
                child: Text(
                  "设置为配图",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  _pressGeneral(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (isGeneral) return;
    //根据类型调用不同的生土
    setState(() {
      isGeneral = true;
    });
    switch (generalType) {
      case 0:
        await ppGeneralPanelKey.currentState!.generalImage(pegg);
        break;
      case 1:
        await fastSdGeneralPanelKey.currentState!.generalImage();
        break;
      case 2:
        await sdWebuiGeneralPanelKey.currentState!.generalImage();
        break;
      case 3:
        //判断是否为年卡
        var user = GlobalInfo.instance.user;
        if (user.vipLevel! <= 3) {
          MotionToast.warning(description: Text("MJ生图暂只对年卡会员开放!"))
              .show(context);
          setState(() {
            isGeneral = false;
          });
          return;
        }
        break;
      case 4:
        break;
    }
  }

  ///右边图片操作区域
  Widget _buildLeftImages(BuildContext context) {
    bool canClip = false;
    String disPlayUrl = imageUrl;
    if (imageUrl.startsWith("clip")) {
      canClip = true;
      disPlayUrl = imageUrl.split("||")[1];
    }
    return Stack(
      // alignment: Alignment.bottomCenter,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.piecesBackTwo,
                // 边框颜色
                width: 1.0, // 边框宽度
              ),
            ),
            child: disPlayUrl.isNotEmpty
                ? CarouselSlider(
                    carouselController: _carouselController,
                    items: widget.urls.map((url) {
                      return _buildHistoryImage(url, context);
                    }).toList(),
                    options: CarouselOptions(
                      // disableCenter: true,
                      aspectRatio: 16 / 9,
                      viewportFraction: 1,
                      initialPage: initialIndex,
                      //禁止轮播
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          imageUrl = widget.urls[index];
                        });
                      },
                      scrollDirection: Axis.horizontal,
                    ))
                : SizedBox.shrink(),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          right: 0,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.urls.map((url) {
                return Container(
                  width: 12.0,
                  height: 12.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(imageUrl == url ? 0.9 : 0.4)),
                );
              }).toList()),
        ),
        if (isGeneral)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: AppColor.piecesBackTwo.withAlpha(200),
              child: Column(
                // mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: Text(
                      "图片生成中...",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  if (generalType == 2)
                    Text(
                      "高峰时段快速生图约等待1分钟，普通生图约等待\n5~10分钟。闲时速度稍快。请耐心等待。\n\n生图过程中请勿退出，最近平均等待时间为3分16秒",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  SizedBox(
                    child: CircularProgressIndicator(),
                    width: 40,
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          child: _buildDownloadButton(context),
          right: 10,
          top: 10,
        ),
        if (canClip) _buildMjClipButton(disPlayUrl, context),
      ],
    );
  }

  ///单张图片下载按钮
  _buildDownloadButton(BuildContext context) {
    return IconButton(
        onPressed: () async {
          if (imageUrl.isEmpty) {
            MotionToast.info(description: Text("图片为空！")).show(context);
            return;
          }
          // await ImagePickers.saveImageToGallery(imageUrl);
          await ImageGallerySaverPlus.saveFile(imageUrl);
          MotionToast.success(description: Text("下载成功。已保存到相册")).show(context);
        },
        icon: Icon(Icons.download_outlined, color: AppColor.piecesBlue));
  }

  ///MJ模式生图，需要切割按钮
  Widget _buildMjClipButton(String disPlayUrl, BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: uButtons
            .map((e) => Tooltip(
                  message: "获取图片$e",
                  child: TextButton(
                      onPressed: () async {
                        String imageLocalPath =
                            await getCacheImagePath(disPlayUrl);
                        debugPrint("获取到原始图片本地地址为:" + imageLocalPath);
                        if (imageLocalPath.isNotEmpty) {
                          setState(() {
                            isGeneral = true;
                          });
                          String cropImagePath = await cropMjImage(
                              imageLocalPath, widget.draftName, e);
                          setState(() {
                            isGeneral = false;
                            imageUrl = cropImagePath;
                            widget.urls.add(cropImagePath);
                          });
                          //切割成功后往后滚动一格
                          // _controller.animateToPage(
                          //   _controller.pageLenght,
                          //   duration: const Duration(milliseconds: 500),
                          //   curve: Curves.linearToEaseOut,
                          // );
                          debugPrint("切割后图片地址:" + cropImagePath);
                        } else {
                          MotionToast.warning(description: Text("原始图片地址没找到！"))
                              .show(context);
                        }
                      },
                      child: Text(e)),
                ))
            .toList(),
      ),
    );
  }

  // List<String> titles = ["MultimodalGen", "Fast-SD", "SD-WebUi", "MJ模式"];
  List<String> titles = ["MultimodalGen", "Fast-SD", "SD-WebUi"];

  ///4种生图模式
  Widget _buildGeneralTabBar() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          //降低tabbar的间距
          // labelPadding: EdgeInsets.zero,
          // indicatorSize: TabBarIndicatorSize.label,
          // indicatorColor: Color(0xFF12CDD9),
          // indicatorWeight: 2,
          // isScrollable: true,
          // dragStartBehavior: DragStartBehavior.start,
          onTap: (index) {
            debugPrint("选中模式...$index");
            generalType = index;
            setState(() {
              if (generalType == 0) {
                pegg = 2;
              } else if (generalType == 1 || generalType == 2) {
                pegg = 0;
              } else if (generalType == 3) {
                pegg = 8;
              } else if (generalType == 4) {
                pegg = 8;
              }
            });
          },
          tabs: titles
              .map((e) => Tab(
                  height: 30,
                  child: Text(
                    e,
                    style: TextStyle(fontSize: 12),
                  )))
              .toList(),
        ),
        SizedBox(
          height: 8,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              PPGeneralPanel(
                key: ppGeneralPanelKey,
                draftName: widget.draftName,
                inputTags: widget.inputTags,
                httpAiStoryRepository: httpAiStoryRepository,
                onGeneralProgress: (progress) {
                  logger.d("生成进度：$progress");
                  // setState(() {
                  //   generalProgress = progress;
                  // });
                },
                onGeneralDone: (List<String> images) {
                  if (images.isNotEmpty) {
                    String firstUrl = images[0];
                    setState(() {
                      isGeneral = false;
                      imageUrl = firstUrl;
                      widget.urls.addAll(images);
                      //设置initialIndex为新增图片的位置
                      initialIndex = widget.urls.length;
                      _carouselController.jumpToPage(initialIndex);
                    });
                  } else {
                    setState(() {
                      isGeneral = false;
                    });
                  }
                },
                aiPaintParamsV2: widget.aiPaintParamsV2,
                onConsumePegg: (int pegg) {
                  setState(() {
                    this.pegg = pegg;
                  });
                },
              ),
              FastSdGeneralPanel(
                key: fastSdGeneralPanelKey,
                draftName: widget.draftName,
                httpAiStoryRepository: httpAiStoryRepository,
                onGeneralProgress: (progress) {
                  debugPrint("FAST-SD生成进度：$progress");
                  // setState(() {
                  //   generalProgress = progress;
                  // });
                },
                onGeneralDone: (List<String> images) {
                  if (images.isNotEmpty) {
                    String firstUrl = images[0];
                    setState(() {
                      isGeneral = false;
                      imageUrl = firstUrl;
                      widget.urls.addAll(images);
                    });
                  } else {
                    setState(() {
                      isGeneral = false;
                    });
                  }
                },
                aiPaintParamsV2: widget.aiPaintParamsV2,
                onConsumePegg: (int pegg) {
                  setState(() {
                    this.pegg = pegg;
                  });
                },
              ),
              SdWebuiGeneralPanel(
                key: sdWebuiGeneralPanelKey,
                draftName: widget.draftName,
                onGeneralProgress: (double) {},
                httpAiStoryRepository: httpAiStoryRepository,
                onGeneralDone: (List<String> images) {
                  if (images.isNotEmpty) {
                    String firstUrl = images[0];
                    setState(() {
                      isGeneral = false;
                      imageUrl = firstUrl;
                      widget.urls.addAll(images);
                    });
                  } else {
                    setState(() {
                      isGeneral = false;
                    });
                  }
                },
                aiPaintParamsV2: widget.aiPaintParamsV2,
              ),
              // MjGeneralPanel(
              //   key: mjGeneralPanelKey,
              //   draftName: widget.draftName,
              //   httpAiStoryRepository: httpAiStoryRepository,
              //   onGeneralProgress: (progress) {
              //     debugPrint("MJ生成进度：$progress");
              //   },
              //   onGeneralDone: (List<String> images) {
              //     if (images.isNotEmpty) {
              //       String firstUrl = images[0];
              //       setState(() {
              //         isGeneral = false;
              //         imageUrl = firstUrl;
              //         widget.urls.addAll(images);
              //       });
              //     } else {
              //       setState(() {
              //         isGeneral = false;
              //       });
              //     }
              //   },
              //   onConsumePegg: (int pegg) {
              //     setState(() {
              //       this.pegg = pegg;
              //     });
              //   },
              //   aiPaintParamsV2: widget.aiPaintParamsV2,
              // ),

              // TencentGeneralPanel(
              //   key: tencentGeneralPanelKey,
              //   draftName: widget.draftName,
              //   httpAiStoryRepository: httpAiStoryRepository,
              //   onGeneralProgress: (progress) {
              //     debugPrint("混元生图生成进度：$progress");
              //     // setState(() {
              //     //   generalProgress = progress;
              //     // });
              //   },
              //   onGeneralDone: (List<String> images) {
              //     if (images.isNotEmpty) {
              //       String firstUrl = images[0];
              //       setState(() {
              //         isGeneral = false;
              //         imageUrl = firstUrl;
              //         urls.addAll(images);
              //       });
              //     } else {
              //       setState(() {
              //         isGeneral = false;
              //       });
              //     }
              //   },
              //   aiPaintParamsV2: widget.aiPaintParamsV2,
              //   onConsumePegg: (int pegg) {
              //     setState(() {
              //       this.pegg = pegg;
              //     });
              //   },
              // )
            ],
          ),
        ),
      ],
    );
  }

  ///显示所有历史记录的图片
  Widget _buildHistoryImage(String url, BuildContext context) {
    String disPlayUrl = url;
    bool canClip = false;
    if (url.startsWith("clip")) {
      canClip = true;
      disPlayUrl = url.split("||")[1];
    }
    return Container(
      child: disPlayUrl.startsWith("http")
          ? CachedNetworkImage(
              imageUrl: disPlayUrl,
              fit: BoxFit.contain,
            )
          : Image.file(File(disPlayUrl), fit: BoxFit.contain),
    );
  }

  void _scrollToItem(int index, BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width / 4;
    double offset = index * itemWidth;
    _controller.animateTo(
      offset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // 获取缓存图片文件的本地路径
  Future<String> getCacheImagePath(String imageUrl) async {
    File cachedImageFile = await DefaultCacheManager().getSingleFile(imageUrl);
    return cachedImageFile.path;
  }

  ///4张图截图
  Future<String> cropMjImage(
      String originalImagePath, String draftName, String uv) async {
    String originalImageName = basenameWithoutExtension(originalImagePath);
    // 加载PNG图片
    final Uint8List? list = await FileUtil.readFileAsBytes(originalImagePath);
    final ui.Codec codec = await ui.instantiateImageCodec(list!);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    // 图片的宽高
    final int width = image.width;
    final int height = image.height;

    // 切割成四个小图片
    final int halfWidth = width ~/ 2;
    final int halfHeight = height ~/ 2;

    final Rect targetRect =
        Rect.fromLTWH(0, 0, halfWidth.toDouble(), halfHeight.toDouble());
    Rect srcRect =
        Rect.fromLTWH(0, 0, halfWidth.toDouble(), halfHeight.toDouble());
    switch (uv) {
      case "右上":
        srcRect = Rect.fromLTWH(halfWidth.toDouble(), 0, halfWidth.toDouble(),
            halfHeight.toDouble());
        break;
      case "左下":
        srcRect = Rect.fromLTWH(0, halfHeight.toDouble(), halfWidth.toDouble(),
            halfHeight.toDouble());
        break;
      case "右下":
        srcRect = Rect.fromLTWH(halfWidth.toDouble(), halfHeight.toDouble(),
            halfWidth.toDouble(), halfHeight.toDouble());
        break;
    }

    final cropImage = await _cropImage(image, srcRect, targetRect);

    // 保存成JPG格式
    String draftPath = await FileUtil.getPieceAiDraftFolderByTaskId(draftName);
    String mjImagePath = draftPath +
        FileUtil.getFileSeparate() +
        "mj_image" +
        FileUtil.getFileSeparate();
    if (!Directory(mjImagePath).existsSync()) {
      Directory(mjImagePath).createSync(recursive: true);
    }
    String filePath = mjImagePath + originalImageName + "_" + uv + ".jpg";
    await _saveImage(cropImage, filePath);
    return filePath;
  }

  Future<ui.Image> _cropImage(
      ui.Image image, Rect cropRect, Rect targetRect) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, targetRect); //这里canvas的画布设置需要固定
    canvas.drawImageRect(image, cropRect, targetRect, Paint());
    final croppedImage = await recorder
        .endRecording()
        .toImage(cropRect.width.toInt(), cropRect.height.toInt());
    return croppedImage;
  }

  Future<void> _saveImage(ui.Image image, String fileName) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    img.Image? image2 = img.decodeImage(buffer);
    if (image2 == null) return;
    // 将图片编码为 JPG 格式的字节数据，并设置压缩质量
    List<int> jpgBytes = img.encodeJpg(image2, quality: 95);
    final file = File(fileName);
    await file.writeAsBytes(jpgBytes);
    print('Saved $fileName   size:${jpgBytes.length}');
  }
}
