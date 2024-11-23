import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:components/components.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:horizontal_list_view/horizontal_list_view.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:logger/logger.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pieces_ai/app/navigation/mobile/theme/theme.dart';
import 'package:pieces_ai/widget_ui/desk_ui/category_panel/video/text_2_video_process_dialog.dart';
import 'package:pieces_ai/widget_ui/desk_ui/category_panel/video/video_expression_general_widget.dart';
import 'package:video_player/video_player.dart';

import '../../../../app/api_https/impl/https_ai_config_repository.dart';
import '../../../../app/api_https/impl/https_ai_story_repository.dart';
import '../../../../app/model/TweetScript.dart';
import '../../../../app/model/ai_image2_video.dart';
import '../../../../app/model/user_info_global.dart';

var logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

GlobalKey<_VideoGeneralPanelState> videoGeneralPanelKey = GlobalKey();

///生视频组件
class VideoGeneralPanel extends StatefulWidget {
  final String? imageUrl;
  final String? videoUrl;
  final String draftName;
  final Image2VideoParam? image2videoParam;
  final double motionStrength;
  final List<String> urls;
  final List<String> videoUrls;
  final Function(String url, String videoUrl, int mediaType) onImageSelected;
  final bool localMode;
  final AiPaintParamsV2 aiPaintParamsV2;

  VideoGeneralPanel({
    key,
    required this.imageUrl,
    required this.urls,
    required this.onImageSelected,
    required this.localMode,
    required this.draftName,
    required this.aiPaintParamsV2,
    this.videoUrl,
    required this.videoUrls,
    required this.motionStrength,
    this.image2videoParam,
  });

  @override
  State<VideoGeneralPanel> createState() {
    return _VideoGeneralPanelState();
  }
}

class _VideoGeneralPanelState extends State<VideoGeneralPanel>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late String imageUrl;
  late String videoUrl;
  late List<String> urls = [];
  late List<String> videoUrls;
  final HttpAiConfigRepository httpAiConfigRepository =
      HttpAiConfigRepository();
  final HttpAiStoryRepository httpsAiStoryRepository = HttpAiStoryRepository();
  final TextEditingController _textEditingController = TextEditingController();
  var videoPlayerController;
  var chewieController;
  late Chewie chewie;

  final HorizontalListViewController _controller =
      HorizontalListViewController();
  final HorizontalListViewController _controllerVideo =
      HorizontalListViewController();
  late TabController _tabController;
  late final TextEditingController _textPromptController;
  int generalType = 0;
  List<String> titles = [
    "生视频",
    "生表情",
  ];
  String? expressionName;

  ///是图片生成表情视频还是视频生成表情视频
  bool image2Video = true;
  bool isGeneral = false;
  int pegg = 20;
  int videoModelVersion = 2;

  ///生图的进度，SD本地的可能无法获取进度
  // double generalProgress = 0;
  Text2VideoProcessDialog? text2videoProcessDialog;

  double motionStrength = 50;
  double duration = 4;
  bool _LockedSeed = false;
  bool _hd = false;
  int seed = 123456;
  int count = 0;
  int steps = 30;

  @override
  void initState() {
    imageUrl = widget.imageUrl ?? "";
    videoUrl = widget.videoUrl ?? "";
    expressionName = "ai";
    _textPromptController =
        TextEditingController(text: widget.image2videoParam?.prompt ?? "");
    motionStrength = widget.motionStrength;
    videoModelVersion = widget.image2videoParam?.modelVersion ?? 2;
    steps = widget.image2videoParam?.steps ?? 30;
    widget.urls.forEach((element) {
      if (!element.startsWith("clip")) {
        urls.add(element);
      }
    });
    logger.d("_VideoGeneralPanelState init urls:$urls");
    _tabController = TabController(
        length: 2,
        vsync: this,
        animationDuration: Duration.zero,
        initialIndex: 0);
    videoUrls = widget.videoUrls;
    if (videoUrl.isNotEmpty) {
      videoPlayerController = VideoPlayerController.file(File(videoUrl))
        ..initialize().then((_) {
          chewieController = ChewieController(
            videoPlayerController: videoPlayerController,
            autoPlay: true,
            looping: false,
          );
          chewie = Chewie(controller: chewieController);
          setState(() {});
        });
    }
    _calculatePegg();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VideoGeneralPanel oldWidget) {
    widget.urls.forEach((element) {
      if (!element.startsWith("clip")) {
        urls.add(element);
      }
    });
    logger.d("_VideoGeneralPanelState didUpdateWidget urls:$urls");
    super.didUpdateWidget(oldWidget);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    _textEditingController.dispose();
    if (videoPlayerController != null) videoPlayerController.dispose();
    chewieController.dispose();
    if (text2videoProcessDialog != null) text2videoProcessDialog!.stopTask();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: AppColor.piecesBlackGrey,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 300,
                      child: (videoPlayerController != null &&
                              videoPlayerController.value.isInitialized)
                          ? AspectRatio(
                              aspectRatio:
                                  videoPlayerController.value.aspectRatio,
                              child: chewie,
                            )
                          : SizedBox.shrink(),
                    ),
                    if (isGeneral)
                      Container(
                        alignment: Alignment.center,
                        height: 300,
                        color: Color(0xaa000000),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 15),
                              child: Text(
                                "Ai视频生成中已耗时${count * 2}秒...",
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            Text(
                              "高峰时段快速生视频约等待2分钟，普通出视频约等待\n2~5分钟。闲时速度稍快。请耐心等待\n\n生成中请勿退出，最近平均等待时间为4分16秒",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            SizedBox(
                              child: CircularProgressIndicator(),
                              width: 50,
                              height: 50,
                            ),
                          ],
                        ),
                      ),
                    Positioned(
                      child: _buildDownloadButton(context),
                      left: 10,
                      top: 10,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Circle(
                        color: AppColor.piecesBlue,
                        radius: 5,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(
                          "选择下面图片生成视频",
                          style: TextStyle(fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Listener(
                  onPointerSignal: (PointerSignalEvent event) {
                    if (event is PointerScrollEvent) {
                      // 检查是否是鼠标滚轮事件
                      // event.scrollDelta.dy 代表垂直方向的滚动值，正值代表向下滚动，负值代表向上滚动
                      print('Mouse wheel scrolled: ${event.scrollDelta.dy}');
                      if (event.scrollDelta.dy > 50) {
                        _controller.animateToPage(
                          _controller.currentPage + 1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.linearToEaseOut,
                        );
                      } else if (event.scrollDelta.dy < -50) {
                        _controller.animateToPage(
                          _controller.currentPage - 1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.linearToEaseOut,
                        );
                      }
                    }
                  },
                  child: HorizontalListView.builder(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    alignment: CrossAxisAlignment.center,
                    controller: _controller,
                    itemCount: urls.length,
                    itemBuilder: (_, index) =>
                        _buildHistoryImage(urls[index], context),
                  ),
                ),
                SizedBox(
                  child: TabBar(
                    controller: _tabController,
                    indicatorWeight: 3,
                    onTap: (index) {
                      logger.d("选中的生视频的模式...$index");
                      generalType = index;
                    },
                    tabs: titles
                        .map((e) => Tab(
                                child: Text(
                              e,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            )))
                        .toList(),
                  ),
                  width: 300,
                ),
                // _buildNormalVideo(),
                SizedBox(
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: _buildNormalVideo()),
                      VideoExpressionGeneralPanel(
                        sourceUrl: imageUrl,
                        onExpressionSelected:
                            (String expressionName, bool isImage) {
                          logger.d("选中的表情...$expressionName,选中的模式：$isImage");
                          this.expressionName = expressionName;
                          this.image2Video = isImage;
                        },
                      ),
                    ],
                  ),
                  height: 400,
                ),
              ],
            ),
          ),
          //位于底部
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildGeneralButton(context),
          ),
        ],
      ),
    );
  }

  ///重新计算皮蛋数，每2秒/5皮蛋
  _calculatePegg() {
    logger.d("_hd:$_hd,duration:$duration,steps:$steps");
    var pegg = videoModelVersion == 1 ? 20 : 20;
    if (_hd) {
      pegg *= 2;
    }
    if (steps > 30) {
      pegg *= 2;
    }
    this.pegg = pegg.toInt();
    //如果modelVersion为2，则皮蛋数翻5倍
    if (videoModelVersion == 2) {
      this.pegg *= 4;
    }
  }

  ///Ai服务器强化提示词
  Future<String> _pressGeneralPrompt(String imagePrompt) async {
    String prompt = _textPromptController.text;
    if (imagePrompt.isEmpty) {
      prompt = await httpsAiStoryRepository.aiPrompt(
          sentence: prompt,
          shidai: 4,
          template: 't2v',
          imageUrl: imagePrompt,
          pegg: 5);
    } else {
      prompt = await httpsAiStoryRepository.aiPrompt(
          sentence: prompt,
          shidai: 4,
          template: 'i2v',
          imageUrl: imagePrompt,
          pegg: 5);
    }
    return prompt;
  }

  ///生图按钮
  _buildGeneralButton(BuildContext context) {
    return Container(
      color: AppColor.piecesGrey,
      height: 50,
      child: Row(
        children: [
          Container(
            height: 50,
            alignment: Alignment.center,
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
          Spacer(),
          Container(
            height: 50,
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                //保存生成参数
                widget.image2videoParam?.modelVersion = videoModelVersion;
                widget.image2videoParam?.prompt = _textPromptController.text;
                widget.image2videoParam?.steps = steps;
                widget.onImageSelected(imageUrl, videoUrl, 1);
                Navigator.of(context).pop();
              },
              child: Text(
                "设置为分镜视频",
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

  ///开始生视频
  _pressGeneral(BuildContext context) async {
    //判断是否为年卡
    var user = GlobalInfo.instance.user;
    if (user.vipLevel! <= 3) {
      MotionToast.warning(description: Text("Ai动画暂只对年卡会员开放!")).show(context);
      setState(() {
        isGeneral = false;
      });
      return;
    }
    if (isGeneral) return;
    String httpUrl = imageUrl;
    //根据类型调用不同的生土
    setState(() {
      isGeneral = true;
    });
    if (image2Video) {
      //选中图片生成表情视频
      //修改成再生成时将图片上传到服务器
      if (!httpUrl.startsWith("http")) {
        httpUrl = await httpAiConfigRepository.fileUpload(
            filePath: imageUrl, specFolder: "windows_i2v", format: "jpg");
        if (httpUrl.isEmpty) {
          MotionToast.error(description: Text("上传本地图片到服务器失败")).show(context);
          return;
        }
      }
    } else {
      if (videoUrl.isEmpty) {
        isGeneral = false;
        MotionToast.warning(description: Text("没有选择生成表情的视频！")).show(context);
        return;
      }
    }

    // String localImagePath = imageUrl;
    // if (imageUrl.startsWith("http"))
    //   localImagePath = await getCacheImagePath(imageUrl);
    if (imageUrl.isNotEmpty) {
      if (_textEditingController.text.isEmpty)
        seed = -1;
      else
        seed = int.parse(_textEditingController.text);

      String prompt = _textPromptController.text;
      //保存提示词
      widget.image2videoParam?.prompt = prompt;
      widget.image2videoParam?.modelVersion = videoModelVersion;
      widget.image2videoParam?.steps = steps;
      // if (videoModelVersion == 2) {
      //   prompt = await _pressGeneralPrompt(imageUrl);
      //   logger.d("强化后的提示词:$prompt，模型版本:$videoModelVersion");
      // }
      text2videoProcessDialog = Text2VideoProcessDialog(
        onComplete: (newVideoPath, seed) async {
          setState(() {
            isGeneral = false;
          });
          if (newVideoPath.isNotEmpty && newVideoPath.endsWith("mp4")) {
            videoUrl = newVideoPath;
            videoUrls.add(videoUrl);
            if (videoPlayerController != null) {
              await videoPlayerController.dispose();
            }
            if (chewieController != null) {
              await chewieController.dispose();
            }

            videoPlayerController = VideoPlayerController.file(File(videoUrl))
              ..initialize().then((_) {
                chewieController = ChewieController(
                  videoPlayerController: videoPlayerController,
                  autoPlay: true,
                  looping: false,
                );
                chewie = Chewie(
                  controller: chewieController,
                );
                setState(() {});
              });
          } else {
            MotionToast.warning(description: Text(newVideoPath)).show(context);
          }
        },
        onProgress: (info, count) {
          logger.d("生视频进度:$count");
          //count每计数一次为2秒
          setState(() {
            this.count = count;
          });
        },
        imagePath: image2Video ? httpUrl : videoUrl,
        seed: _LockedSeed ? seed : -1,
        hd: _hd,
        type: generalType,
        expressionName: expressionName,
        fpsTotal: 24 * (duration.toInt()),
        newFps: 24,
        videoModelVersion: videoModelVersion,
        prompt: prompt,
        motionStrength: motionStrength.toInt(),
        ratio: widget.aiPaintParamsV2.ratio,
        draftName: widget.draftName,
        duration: duration.toInt(),
        pegg: pegg,
        steps: steps,
      );
      await text2videoProcessDialog?.startVideo(context);
    } else {
      MotionToast.info(description: Text("图片文件不存在！")).show(context);
    }
  }

  ///单张图片下载按钮
  _buildDownloadButton(BuildContext context) {
    return IconButton(
        onPressed: () async {
          if (videoUrl.isEmpty) {
            MotionToast.info(description: Text("视频为空！")).show(context);
            return;
          }
          await ImageGallerySaverPlus.saveFile(videoUrl);
          MotionToast.success(description: Text("下载成功。已保存到相册")).show(context);
        },
        icon: Icon(
          Icons.download_outlined,
          color: AppColor.piecesBlue,
        ));
  }

  /**
   * 普通生视频
   */
  Widget _buildNormalVideo() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          child: TextField(
            decoration: InputDecoration(
              hintText: videoModelVersion == 1
                  ? "1.0模型不支持提示词引导"
                  : "请输入生成视频运动引导提示词，不填则自动生成",
              hintStyle: TextStyle(color: Color(0xFF808080), fontSize: 12),
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
            maxLength: 800,
            //文字大小
            style: TextStyle(fontSize: 12),
            enabled: videoModelVersion == 2,
            controller: _textPromptController,
          ),
        ),
        if (videoModelVersion == 1)
          Row(
            children: [
              Circle(
                color: AppColor.piecesBlue,
                radius: 5,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  "运动幅度",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Text(
                "(数值越大，运动越强烈)",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        if (videoModelVersion == 1)
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  child: Slider(
                value: motionStrength,
                min: 1,
                max: 255,
                // divisions: 20,
                label: motionStrength.toStringAsFixed(0),
                activeColor: AppColor.piecesBlue,
                inactiveColor: Colors.green.withAlpha(99),
                onChanged: (value) {
                  setState(() {
                    motionStrength = value;
                  });
                },
                onChangeEnd: (value) {
                  debugPrint("滑动结束:" + motionStrength.toStringAsFixed(1));
                },
              )),
              Text(
                "${motionStrength.toStringAsFixed(0)}",
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
        // Row(
        //   children: [
        //     Circle(
        //       color: Color(0xFF12CDD9),
        //       radius: 7,
        //     ),
        //     Padding(
        //       padding: EdgeInsets.only(left: 15),
        //       child: Text(
        //         "时长",
        //         style: TextStyle(fontSize: 15),
        //       ),
        //     ),
        //     Text(
        //       "(生成时长越长，计算时间越久，连贯性更差)",
        //       style: TextStyle(fontSize: 14, color: Colors.grey),
        //     ),
        //   ],
        // ),
        // Row(
        //   mainAxisSize: MainAxisSize.max,
        //   children: [
        //     Expanded(
        //         child: Slider(
        //       value: duration,
        //       min: 4,
        //       max: 6,
        //       divisions: 1,
        //       label: duration.toStringAsFixed(0),
        //       activeColor: Color(0xFF12CDD9),
        //       inactiveColor: Colors.green.withAlpha(99),
        //       onChanged: (value) {
        //         setState(() {
        //           duration = value;
        //           _calculatePegg();
        //         });
        //       },
        //       onChangeEnd: (value) {
        //         debugPrint("滑动结束:" + duration.toStringAsFixed(0));
        //       },
        //     )),
        //     Text(
        //       "${duration.toStringAsFixed(0)}秒",
        //       style: TextStyle(fontSize: 18),
        //     )
        //   ],
        // ),
        Row(
          children: [
            Circle(
              color: AppColor.piecesBlue,
              radius: 5,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                "其他设置",
                style: TextStyle(fontSize: 12),
              ),
            ),
            Text(
              // "(超清2K生成耗时多一倍，高质量模式耗时多一倍，请耐心等待)",
              "(高质量模式耗时多一倍，请耐心等待)",
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        Row(
          children: [
            // Switch(
            //   value: _hd,
            //   onChanged: (value) {
            //     setState(() {
            //       _hd = value;
            //       _calculatePegg();
            //     });
            //   },
            // ),
            // Text(
            //   _hd ? '2K超清' : '1080P',
            //   style: TextStyle(fontSize: 12, color: Color(0xFF12CDD9)),
            // ),
            Switch(
              value: steps > 30,
              onChanged: (value) {
                setState(() {
                  if (value) {
                    steps = 50;
                  } else {
                    steps = 30;
                  }
                  _calculatePegg();
                });
              },
            ),
            Text(
              steps > 30 ? '质量更好' : '速度更快',
              style: TextStyle(fontSize: 12, color: AppColor.piecesBlue),
            ),
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
              style: TextStyle(fontSize: 12, color: AppColor.piecesBlue),
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        if (_LockedSeed)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '设置固定种子数值',
                  border: OutlineInputBorder(),
                ),
              )
            ],
          ),
      ],
    );
  }

  ///显示所有生视频的图片
  Widget _buildHistoryImage(String url, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: url == imageUrl ? Color(0xFF12CDD9) : Colors.transparent,
          // 边框颜色
          width: 2.0, // 边框宽度
        ),
        // borderRadius: BorderRadius.circular(12.0), // 圆角半径
      ),
      // padding: EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          if (isGeneral) return;
          setState(() {
            imageUrl = url;
          });
        },
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            child: url.startsWith("http")
                ? CachedNetworkImage(
                    // width: 150,
                    // height: 100,
                    imageUrl: url,
                    fit: BoxFit.contain,
                  )
                : Image.file(File(url), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  ///显示历史生成的视频记录
  Widget _buildHistoryVideo(String url, int index, BuildContext context) {
    debugPrint("视频url:" + url);
    return GestureDetector(
      onTap: () {
        if (isGeneral) return;
        setState(() {
          videoUrl = url;
          //同时显示该视频得seed号
          // _LockedSeed = true;
          // _textEditingController.text = seed.toString();
        });
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(
            color: url == videoUrl ? Color(0xFF12CDD9) : Colors.grey,
            // 边框颜色
            width: 2.0, // 边框宽度
          ),
          borderRadius: BorderRadius.circular(12.0), // 圆角半径
        ),
        // padding: EdgeInsets.all(5),
        child: Stack(
          children: [
            Positioned(
              left: 5,
              top: 5,
              child: Text("视频${index + 1}"),
            ),
            Center(
              child: Image(
                image: AssetImage("assets/images/text_video.png"),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 获取缓存图片文件的本地路径
  Future<String> getCacheImagePath(String imageUrl) async {
    File cachedImageFile = await DefaultCacheManager().getSingleFile(imageUrl);
    return cachedImageFile.path;
  }
}
