import 'dart:convert';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/log.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/session.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/statistics.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:logger/logger.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';
import 'package:pieces_ai/app/model/ai_draft.dart';
import 'package:pieces_ai/ffmpeg/util.dart';
import 'package:pieces_ai/ffmpeg/video_util.dart';
import 'package:progress_border/progress_border.dart';
import 'package:storage/storage.dart';
import 'package:utils/utils.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../navigation/mobile/theme/theme.dart';

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

///实现一个导出页面，用户可以选择导出视频的格式和质量。有个居中方形的导出进度条，下方有一个导出按钮，点击后会导出视频。
class ExportVideo extends StatefulWidget {
  final Draft draft;

  const ExportVideo({Key? key, required this.draft}) : super(key: key);

  @override
  _ExportVideoState createState() => _ExportVideoState();
}

class _ExportVideoState extends State<ExportVideo>
    with SingleTickerProviderStateMixin {
  double borderWidth = 8;
  Statistics? _statistics;
  double progress = 0.0;
  double totalVideoDuration = 0;
  late int? _sessionId;
  String stateText = "";

  //是否合成字幕
  bool videoSubtitles = true;

  //是否正在导出
  bool isExporting = false;
  late String fullVideoPath;
  var videoPlayerController;
  late final chewieController = ChewieController(
    videoPlayerController: videoPlayerController,
    autoPlay: true,
    looping: false,
  );

  @override
  void initState() {
    super.initState();
    FFmpegKitConfig.init().then((_) {
      VideoUtil.prepareAssets();
      VideoUtil.registerApplicationFonts();
    });
    _statistics = null;
    _sessionId = null;
    // FFmpegKitConfig.enableLogCallback(logCallback);
    fullVideoPath = "";
    FFmpegKitConfig.enableStatisticsCallback(statisticsCallback);
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    super.dispose();
    FFmpegKit.cancel();
    if (videoPlayerController != null) videoPlayerController.dispose();
    chewieController.dispose();
    WakelockPlus.disable();
  }

  void statisticsCallback(Statistics statistics) {
    this._statistics = statistics;
    this.updateProgressDialog();
  }

  ///更新导出进度
  void updateProgressDialog() {
    var statistics = this._statistics;
    if (statistics == null || statistics.getTime() < 0) {
      return;
    }

    double timeInMilliseconds = this._statistics!.getTime();
    int completePercentage =
        (timeInMilliseconds * 100) ~/ (totalVideoDuration * 1000);
    logger.d("Creating video % $completePercentage");
    setState(() {
      progress = completePercentage / 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text('视频导出'),
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          // _buildExportFormat(),
          // _buildExportQuality(),
          _buildExportSubtitle(),
          Spacer(),
          Flexible(
            child: Stack(
              children: [
                isExporting ? _buildExportProgress() : SizedBox.shrink(),
                if (fullVideoPath.isNotEmpty)
                  Container(
                    child: (videoPlayerController != null &&
                            videoPlayerController.value.isInitialized)
                        ? AspectRatio(
                            aspectRatio:
                                videoPlayerController.value.aspectRatio,
                            child: Chewie(
                              controller: chewieController,
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
              ],
            ),
            flex: 2,
          ),
          Spacer(),
          if (!isExporting && fullVideoPath.isEmpty) _buildExportButton(),
        ],
      ),
    );
  }

  ///合成字幕控件
  _buildExportSubtitle() {
    return CheckboxListTile(
      title: Text("合成字幕", style: TextStyle(fontSize: 16, color: Colors.white)),
      value: videoSubtitles,
      onChanged: (value) {
        setState(() {
          videoSubtitles = value!;
        });
      },
      subtitle: Text("取消后合成的视频不显示字幕",
          style: TextStyle(fontSize: 12, color: Colors.white)),
    );
  }

  _buildExportFormat() {
    return Container(
      child: Text("导出格式"),
    );
  }

  _buildExportQuality() {
    return Container(
      child: Text("导出质量"),
    );
  }

  ///实现一个矩形的进度框，用于显示导出进度。
  _buildExportProgress() {
    //矩形的进度框
    return Center(
      child: Container(
        //宽度为屏幕一半
        width: MediaQuery.of(context).size.width / 2,
        height: MediaQuery.of(context).size.width / 2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blue.withAlpha(100),
          border: ProgressBorder.all(
            color: Colors.blue,
            width: borderWidth,
            progress: progress,
          ),
        ),
        child: Text(stateText),
      ),
    );
  }

  _buildExportButton() {
    //居中导出按钮
    return Center(
      child: ElevatedButton(
        //设置背景色
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(AppColor.piecesBlue),
          //设置触摸时的背景色
          overlayColor: WidgetStateProperty.all(Colors.grey),
        ),
        onPressed: () {
          _exportVideo();
        },
        child: Text(
          "导出视频",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  _exportVideo() {
    if (isExporting) {
      Toast.error(context, "正在导出中，请稍后");
      return;
    }
    //导出视频
    createVideo();
  }

  ///创建视频
  void createVideo() async {
    DraftRender? draftRender = await getDraftJson();
    if (draftRender == null) {
      logger.d("draftRender is null");
      return;
    }
    setState(() {
      isExporting = true;
      stateText = "视频合成中...";
    });

    double tmpTotalVideoDuration = 0;
    TweetScript tweetScript = draftRender.tweetScript!;
    String originalAudioPath = draftRender.audioPath ?? "";
    List<TweetImage> localImageList = [];
    List<String> localAudioPaths = [];
    bool allVideo = true;
    int jpgIndex = 0;
    for (int i = 0; i < tweetScript.scenes[0].imgs.length; i++) {
      TweetImage tweetImage = tweetScript.scenes[0].imgs[i];
      //做一下容错机制
      if (tweetImage.mediaType == 0) {
        if (tweetImage.url == null) {
          logger.e("图片url为null");
          continue;
        }
        if (tweetImage.url!.isEmpty) {
          logger.e("图片url为空");
          continue;
        }
        if (tweetImage.url!.startsWith("http")) {
          logger.e("图片url为网络地址");
          continue;
        } else {
          File file = File(tweetImage.url!);
          if (!file.existsSync()) {
            logger.e("图片文件不存在");
            continue;
          }
        }
      }
      if (tweetImage.mediaType == 1) {
        if (tweetImage.videoUrl == null) {
          continue;
        }
        if (tweetImage.videoUrl!.isEmpty) {
          continue;
        }
        if (tweetImage.videoUrl!.startsWith("http")) {
          continue;
        } else {
          File file = File(tweetImage.videoUrl!);
          if (!file.existsSync()) {
            continue;
          }
        }
      }

      //如果originalAudioPath不为空
      if(tweetScript.ttsEnable ?? true){
        //这时候如果tts为空或者tts.url为空，则不添加到localImageList中
        if(tweetImage.tts == null || tweetImage.tts!.url == null || tweetImage.tts!.url!.isEmpty){
          logger.d("音频为空，不添加到localImageList中");
          continue;
        }
      }

      //将图片或视频添加到localImageList中
      localImageList.add(tweetImage);
      //如果音频为null或者空，则不添加到音频列表中
      if (tweetImage.tts!.url != null && tweetImage.tts!.url!.isNotEmpty) {
        localAudioPaths.add(tweetImage.tts!.url!);
      }
      double duration = tweetImage.tts!.duration ?? 0;
      tmpTotalVideoDuration += duration;
      logger.d("音频时长：$duration，总时长：$tmpTotalVideoDuration");
    }

    //生成SRT字幕
    String srtPath = await getTmpSrtFile().then((value) => value.path);
    await VideoUtil.generateSrt(srtPath, localImageList);

    // 如果localImageList大于10个，则将localImageList分割成多个list，每个list最多10个元素
    List<List<TweetImage>> splitList = [];
    if (localImageList.length > 10) {
      for (int i = 0; i < localImageList.length; i += 10) {
        int end = i + 10;
        if (end > localImageList.length) {
          end = localImageList.length;
        }
        splitList.add(localImageList.sublist(i, end));
      }
    } else {
      splitList.add(localImageList);
    }

    // 遍历splitList，将其中的每个list生成一个视频，然后将这些视频合并成一个视频
    List<String> videoPaths = [];
    //使用一个while循环从splitList中取出每个list，生成一个视频,保证前一个视频生成完成后再生成下一个视频
    int index = 0;
    while (index < splitList.length) {
      List<TweetImage> localImageList = splitList[index];
      //计算当次的视频总时长
      double totalDuration = 0;
      // localImageList.forEach((element) {
      //   totalDuration += element.tts!.duration ?? 0;
      // });
      //使用for(int i=0;i<localImageList.length;i++)的方式，因为需要获取到每个元素的索引
      for (int i = 0; i < localImageList.length; i++) {
        TweetImage tweetImage = localImageList[i];
        double duration = tweetImage.tts!.duration ?? 0;
        totalDuration += duration;
        if (tweetImage.mediaType != 1) {
          allVideo = false;
          jpgIndex = i;
        }
      }
      totalVideoDuration = totalDuration;
      setState(() {
        stateText = "视频合成中...\n第${index + 1}/${splitList.length}个分镜";
      });
      String videoTmpPath =
          await getTmpVideoFile(index).then((value) => value.path);
      double upScale = 1.0;
      if (draftRender.tweetScript!.aiPaint.hd.scale != null) {
        if (draftRender.tweetScript!.aiPaint.hd.scale! > 2.0)
          upScale = draftRender.tweetScript!.aiPaint.hd.scale! - 2.0;
      }
      final ffmpegCommand = VideoUtil.generateMovingVideoScriptList(
          localImageList,
          draftRender.tweetScript!.aiPaint.ratio,
          upScale,
          videoTmpPath,
          allVideo,
          jpgIndex);
      ffprint(
          "FFmpeg process started 开始给视频创建动效 with arguments: \'${ffmpegCommand}\'.");
      //将上述executeAsync方法改为execute
      final session = await FFmpegKit.execute(ffmpegCommand);
      final state =
          FFmpegKitConfig.sessionStateToString(await session.getState());
      final returnCode = await session.getReturnCode();
      final failStackTrace = await session.getFailStackTrace();
      List<Log> logs = await session.getLogs();

      logger.d(
          "FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");
      if (ReturnCode.isSuccess(returnCode)) {
        logger.d("创建视频动效完成 completed successfully;当前是第几伦的10个.$index");
      } else {
        //遍历打印
        logger.e("创建动效失败，下面是具体日志.");
        logs.forEach((element) {
          ffprint(element.getMessage());
        });
      }
      videoPaths.add(videoTmpPath);
      index++;
    }

    this.totalVideoDuration = tmpTotalVideoDuration;
    if (videoPaths.length == 1) {
      concatAudio(videoPaths[0], localAudioPaths,originalAudioPath, srtPath);
    } else {
      String videoTmpPath =
          await getTmpVideoFile(-1).then((value) => value.path);
      final ffmpegCommand =
          VideoUtil.generateConcatVideoScriptList(videoPaths, videoTmpPath);
      ffprint(
          "FFmpeg process started 开始合并多个视频 with arguments: \'${ffmpegCommand}\'.");
      FFmpegKit.executeAsync(ffmpegCommand, (FFmpegSession session) async {
        final state =
            FFmpegKitConfig.sessionStateToString(await session.getState());
        final returnCode = await session.getReturnCode();
        final failStackTrace = await session.getFailStackTrace();
        logger.d(
            "FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");
        if (ReturnCode.isSuccess(returnCode)) {
          logger.d("合并多个视频 completed successfully; playing video.");

          ///删除临时视频文件
          videoPaths.forEach((element) {
            File(element).delete();
          });
          concatAudio(videoTmpPath, localAudioPaths,originalAudioPath, srtPath);
        } else {
          logger.d("Create failed. Please check log for the details.");
        }
      }, (log) {
        ffprint(log.getMessage());
      });
    }
  }

  ///合并音频
  concatAudio(String videoTmpPath, List<String> localAudioPaths,
      String originalAudioPath, String subtitlePath) async {
    if (localAudioPaths.isEmpty) {
      logger.d("音频列表为空，使用原音频:$originalAudioPath");
      muxVideoAudio(videoTmpPath, originalAudioPath ?? "", subtitlePath);
    } else {
      String audioPath = await getTmpAudioFile().then((value) => value.path);
      final ffmpegCommandAudio = await VideoUtil.generateConcatAudioScriptList(
          localAudioPaths, audioPath);
      ffprint(
          "FFmpeg process 开始音频链接 with arguments: \'${ffmpegCommandAudio}\'.");
      FFmpegKit.executeAsync(
        ffmpegCommandAudio,
        (FFmpegSession session) async {
          final state =
              FFmpegKitConfig.sessionStateToString(await session.getState());
          final returnCode = await session.getReturnCode();
          final failStackTrace = await session.getFailStackTrace();
          logger.d(
              "FFmpeg 音频 process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");
          if (ReturnCode.isSuccess(returnCode)) {
            logger.d("Create completed successfully; playing video.");
            muxVideoAudio(videoTmpPath, audioPath, subtitlePath);
          } else {
            logger.d("音频链接失败Create failed. Please check log for the details.");
          }
        },
        (log) {
          ffprint(log.getMessage());
        },
      );
    }
  }

  ///合并音频和视频
  muxVideoAudio(
      String videoTmpPath, String audioPath, String subtitlePath) async {
    String videoPath = await getVideoFile().then((value) => value.path);
    final ffmpegCommandAudio = VideoUtil.generateMuxVideoAudioScript(
        videoTmpPath, audioPath, videoPath);
    ffprint(
        "FFmpeg process started 合并视频和音轨 with arguments: \'${ffmpegCommandAudio}\'.");
    FFmpegKit.executeAsync(
      ffmpegCommandAudio,
      (FFmpegSession session) async {
        final state =
            FFmpegKitConfig.sessionStateToString(await session.getState());
        final returnCode = await session.getReturnCode();
        final failStackTrace = await session.getFailStackTrace();
        logger.d(
            "FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");
        if (ReturnCode.isSuccess(returnCode)) {
          ffprint("Create completed successfully; playing video.");
          if (videoSubtitles) {
            setState(() {
              stateText = "合入字幕中...";
            });
            var fontPath = await VideoUtil.assetPath(VideoUtil.FONT_ASSET_1);
            muxSubtitle(videoPath, fontPath, subtitlePath);
          } else {
            _onConcatVideoSuccess(videoPath);
          }
        } else {
          logger.d("Create failed. Please check log for the details.");
        }
      },
    );
  }

  muxSubtitle(String videoPath, String fontPath, String subtitlePath) async {
    String videoPathAndSubtitle =
        await getTmpVideoFile(99).then((value) => value.path);
    // final burnSubtitlesCommand = await VideoUtil.generateTextOverlayScript(
    //     "皮皮动画", 48, videoPath, videoPathAndSubtitle, fontPath, 0.0, 5.0);
    String subtitleStr =
        "\"subtitles=$subtitlePath:force_style='Alignment=2,Fontname=HanYiDaHei'\"";
    String burnSubtitlesCommand =
        "-hide_banner -y -i ${videoPath} -lavfi $subtitleStr -c:v libx264 ${videoPathAndSubtitle}";
    ffprint(
        "FFmpeg process 开始合入字幕 with arguments: \'${burnSubtitlesCommand}\'.");
    FFmpegKit.executeAsync(
      burnSubtitlesCommand,
      (FFmpegSession session) async {
        final state =
            FFmpegKitConfig.sessionStateToString(await session.getState());
        final returnCode = await session.getReturnCode();
        final failStackTrace = await session.getFailStackTrace();
        logger.d(
            "FFmpeg 合入字幕 process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");
        if (ReturnCode.isSuccess(returnCode)) {
          listAllStatistics(session as FFmpegSession);
          _onConcatVideoSuccess(videoPathAndSubtitle);
        } else {
          logger.d("音频链接失败Create failed. Please check log for the details.");
        }
      },
      (log) {
        ffprint(log.getMessage());
      },
    );
  }

  ///合并视频成功后的操作
  _onConcatVideoSuccess(String videoPath) {
    saveVideoToGallery(videoPath);
    MotionToast.success(description: Text("导出成功，已保存到相册")).show(context);
    isExporting = false;
    videoPlayerController = VideoPlayerController.file(File(videoPath))
      ..initialize().then((_) {
        setState(() {
          fullVideoPath = videoPath;
        });
      });
  }

  Future<File> getVideoFile() async {
    final String video = "video.mp4";
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/$video");
  }

  ///获取临时视频文件
  Future<File> getTmpVideoFile(int index) async {
    // final String video = "videoTmp.mp4"
    final String video = "videoTmp$index.mp4";
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/$video");
  }

  ///获取临时音频文件
  Future<File> getTmpAudioFile() async {
    final String audio = "audioTmp.wav";
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/$audio");
  }

  ///获取临时字幕文件
  Future<File> getTmpSrtFile() async {
    final String srt = "subtitle.srt";
    Directory documentsDirectory = await VideoUtil.documentsDirectory;
    return new File("${documentsDirectory.path}/$srt");
  }

  ///获取草稿文件
  Future<DraftRender?> getDraftJson() async {
    String draftsDir = await FileUtil.getDraftFolder();
    String aiScriptPath =
        draftsDir + FileUtil.getFileSeparate() + widget.draft.taskId! + '.json';
    File aiScriptFile = File(aiScriptPath);
    DraftRender? draftRender;
    if (aiScriptFile.existsSync()) {
      logger.d('本地有提交任务时保存的草稿地址喂：' + aiScriptPath);
      String aiScriptStr = await aiScriptFile.readAsString();
      draftRender = DraftRender.fromJson(jsonDecode(aiScriptStr));
    }
    return draftRender;
  }

  saveVideoToGallery(String videoPath) async {
    final result = await ImageGallerySaverPlus.saveFile(videoPath);
    //使用默认播放器打开视频
    logger.d(result);
    // Uint8List data = await File(videoPath).readAsBytes();
    // await ImagePickers.saveByteDataImageToGallery(data);
  }

  void burnSubtitles(List<String> localImgPaths) {
    VideoUtil.assetPath(VideoUtil.FONT_ASSET_1).then((subtitlePath) {
      getTmpVideoFile(0).then((videoFile) {
        getTmpVideoFile(99).then((videoWithSubtitlesFile) {
          ffprint("开始测试字幕功能");

          // final ffmpegCommand = VideoUtil.generateEncodeVideoScript(
          //     localImgPaths[0],
          //     localImgPaths[1],
          //     localImgPaths[2],
          //     videoFile.path,
          //     "libx264",
          //     "");

          // FFmpegKit.executeAsync(ffmpegCommand, (session) async {
          //   final state =
          //       FFmpegKitConfig.sessionStateToString(await session.getState());
          //   final returnCode = await session.getReturnCode();
          //   final failStackTrace = await session.getFailStackTrace();
          //
          //   ffprint(
          //       "FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}");

          // if (ReturnCode.isSuccess(returnCode)) {
          ffprint("Create completed successfully; burning subtitles.");

          String burnSubtitlesCommand =
              "-y -i ${videoFile.path} -vf subtitles=$subtitlePath:force_style='Fontname=Trueno' -c:v libx264 ${videoWithSubtitlesFile.path}";

          ffprint(
              "FFmpeg process started with arguments: \'$burnSubtitlesCommand\'.");

          FFmpegKit.executeAsync(burnSubtitlesCommand,
              (Session secondSession) async {
            final secondState = FFmpegKitConfig.sessionStateToString(
                await secondSession.getState());
            final secondReturnCode = await secondSession.getReturnCode();
            final secondFailStackTrace =
                await secondSession.getFailStackTrace();

            if (ReturnCode.isSuccess(secondReturnCode)) {
              saveVideoToGallery(videoWithSubtitlesFile.path);
              ffprint("Burn subtitles completed successfully; playing video.");
            } else if (ReturnCode.isCancel(secondReturnCode)) {
              ffprint("Burn subtitles operation cancelled");
            } else {
              ffprint(
                  "Burn subtitles failed with state ${secondState} and rc ${secondReturnCode}.${notNull(secondFailStackTrace, "\\n")}");
            }
          }).then((session) => _sessionId = session.getSessionId());
          // }
          // }).then((session) {
          //   _sessionId = session.getSessionId();
          //   ffprint(
          //       "Async FFmpeg process started with sessionId ${session.getSessionId()}.");
          // });
        });
      });
    });
  }
}
