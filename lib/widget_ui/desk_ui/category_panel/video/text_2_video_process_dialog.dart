import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path/path.dart' as path;
import 'package:pieces_ai/app/api_https/impl/https_ai_config_repository.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_story_repository.dart';
import 'package:utils/utils.dart';

import '../../../../app/model/TweetScript.dart';
import '../../../../app/model/ai_image2_video.dart';

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

///Ai图生视频处理流程得弹窗
class Text2VideoProcessDialog {
  final Function(String, int?) onComplete;
  ///进度回调
  final Function(String, int) onProgress;
  final String imagePath;
  final String draftName;
  final int type;
  final String? expressionName;
  final int seed;
  final int fpsTotal;
  final int newFps;
  final int motionStrength;
  final int ratio;
  final int duration;
  final int videoModelVersion ;
  final String? prompt;
  final int pegg;
  final int steps;
  final bool hd;

  Text2VideoProcessDialog({
    required this.onComplete,
    required this.imagePath,
    required this.fpsTotal,
    required this.newFps,
    required this.seed,
    required this.type,
    required this.videoModelVersion,
    this.expressionName,
    this.prompt,
    required this.motionStrength,
    required this.ratio,
    required this.draftName,
    required this.duration,
    required this.pegg,
    required this.hd,
    required this.onProgress,
    required this.steps,
  });

  double totalProgress = 0.0;
  String fpsProgressText = "Ai视频生成中，预计需要60S...";
  String videoName = "";
  int count = 0;
  bool stop = false;
  final HttpAiStoryRepository httpAiStoryRepository = HttpAiStoryRepository();
  final HttpAiConfigRepository httpAiConfigRepository =
      HttpAiConfigRepository();

  ///开始生成Ai视频
  Future<void> startVideo(BuildContext context) async {
    videoName = path.basenameWithoutExtension(imagePath) +
        "_" +
        FileUtil.generateRandomString(8);
    String sourceUrl = imagePath;
    //如果imagePath以.mp4结尾，则先先将本地mp4传到云端
    if (imagePath.endsWith(".mp4")) {
      String imageUrl = await httpAiConfigRepository.fileUpload(
          filePath: imagePath, specFolder: "windows_i2v", format: "mp4");
      if (imageUrl.isNotEmpty) {
        sourceUrl = imageUrl;
      } else {
        MotionToast.error(description: Text("上传视频失败")).show(context);
        return;
      }
    }
    Image2VideoParam image2videoParam = Image2VideoParam(
        image: sourceUrl,
        seed: seed,
        ratio: ratio,
        motionStrength: motionStrength,
        fps: 24,
        prompt: prompt,
        modelVersion: videoModelVersion,
        duration: duration,
        steps: steps);

    TweetScript tweetScript = TweetScript.generateImage2VideoData(
        ratio, 1, image2videoParam, type, expressionName);
    var result = await httpAiStoryRepository.addTask(
        tweetScript: tweetScript, pegg: pegg, type: 2);
    if (result.success) {
      String taskId = result.data.toString();
      debugPrint("提交PPAi视频任务成功：" + taskId);
      await _getPpResultDelay(taskId, type, context);
    } else {
      MotionToast.error(description: Text("提交任务出错！${result.msg}"))
          .show(context);
    }
  }

  stopTask() {
    this.stop = true;
  }

  ///递归获取生图结果
  Future<void> _getPpResultDelay(
      String taskId, int type, BuildContext context) async {
    if (stop) {
      return;
    }
    //3分钟超时，3分钟等于90次
    if (count > 300) {
      MotionToast.error(description: Text("生成视频超时！")).show(context);
      return;
    }
    var progressResult =
        await httpAiStoryRepository.getTaskProgress(taskId: taskId);
    if (progressResult >= 1.0) {
      var result = await httpAiStoryRepository.getTaskResult(taskId: taskId);
      if (result != null) {
        //回调结果给左边页面展示
        if (result.scenes[0].imgs.length > 0) {
          List<String> urls = [];
          List<int?> seeds = [];
          result.scenes[0].imgs.forEach((element) {
            if (element.videoUrl != null) {
              urls.add(element.videoUrl!);
              seeds.add(element.seed);
            }
          });
          String videoUrl = urls.first;
          int? seed = seeds.first;
          var moreFpsVideoPath;
          if (videoUrl.isEmpty) {
            MotionToast.info(description: Text("生成视频失败！")).show(context);
            moreFpsVideoPath = "";
          } else {
            //videoUrl是否以http开发，如果不是则直接讲videoUrl内容作为错误提示信息
            if (!videoUrl.startsWith("http")) {
              onComplete.call(videoUrl, -1);
              return;
            }
            //下载视频到本地,下载到图片同级目录
            // 保存到当前草稿目录
            String draftPath =
                await FileUtil.getPieceAiDraftFolderByTaskId(draftName);
            String ppVideoPath = draftPath +
                FileUtil.getFileSeparate() +
                "pp_video" +
                FileUtil.getFileSeparate();
            if (!Directory(ppVideoPath).existsSync()) {
              Directory(ppVideoPath).createSync(recursive: true);
            }
            String videoFilePath = ppVideoPath + videoName + ".mp4";
            await HttpUtil.instance.client.download(videoUrl, videoFilePath,
                onReceiveProgress: (int get, int total) {
              String progress = ((get / total) * 100).toStringAsFixed(2);
            });
            if (type == 1) {
              moreFpsVideoPath = videoFilePath;
            } else {
              //Ai视频补帧
              if (Platform.isWindows) {
                moreFpsVideoPath = await _nextStepVideoFps(
                    videoFilePath, videoName + ".mp4", hd);
                await File(videoFilePath).delete();
              } else {
                moreFpsVideoPath = videoFilePath;
              }
            }
          }
          onComplete.call(moreFpsVideoPath, seed);
        } else {
          onComplete.call('', -1);
        }
      } else {
        MotionToast.warning(description: Text("生成成功但是没获取到结果！")).show(context);
        onComplete.call('', -1);
      }
    } else {
      logger.d("获取PPAi视频任务进度：$count");
      onProgress.call(fpsProgressText, count);
      Future.delayed(Duration(seconds: 2), () {
        _getPpResultDelay(taskId, type, context);
      });
    }
    count++;
  }

  ///Ai视频补帧
  Future<String> _nextStepVideoFps(
      String originalVideoPath, String videoName, bool hd) async {
    String rootDirectory = path.dirname(path.absolute(originalVideoPath));
    String aiFpsRootPath = await FileUtil.getVideoAiFolder(rootDirectory);
    // 解析后的Frame图片
    String imageInputFrame =
        aiFpsRootPath + FileUtil.getFileSeparate() + "inputFrame";
    if (!await Directory(imageInputFrame).exists()) {
      await Directory(imageInputFrame).create(recursive: true);
    }
    String imageOutputFrame =
        aiFpsRootPath + FileUtil.getFileSeparate() + "outputFrame";
    if (!await Directory(imageOutputFrame).exists()) {
      await Directory(imageOutputFrame).create(recursive: true);
    }

    final ffmpegDirectory = Directory.current;

    //视频图片高清处理
    if (hd) {

    }

    // await VideoUtil.hdGeneral(imageInputFrame, hdImageOutPutFrame);
    // imageInputFrame = hdImageOutPutFrame;

    // 指定exe文件路径和命令参数
    String exePath = ffmpegDirectory.path + "\\rife-ncnn-vulkan";
    List<String> arguments = [
      "-i",
      imageInputFrame,
      "-n",
      fpsTotal.toString(),
      "-m",
      "rife-v4.6",
      "-o",
      imageOutputFrame
    ];
    // 启动进程
    Process processMoreFps = await Process.start(exePath, arguments);
    // 获取进程的标准输出流
    processMoreFps.stdout.transform(utf8.decoder).listen((data) {
      print('stdout: $data');
    });

    // 获取进程的标准错误流
    processMoreFps.stderr.transform(utf8.decoder).listen((data) {
      print('stderr: $data');
    });
    await processMoreFps.exitCode;
    print('DONE more FPS:');

    // setState(() {
    //   fpsProgressText = "重新生成视频...";
    // });

    String ffmpegPath = ffmpegDirectory.path + "\\ffmpeg.exe";
    String newVideoPath =
        aiFpsRootPath + FileUtil.getFileSeparate() + "fps_24_" + videoName;
    List<String> argumentsMergerVideo = [
      "-y",
      "-framerate", newFps.toString(),
      "-i", imageOutputFrame + FileUtil.getFileSeparate() + "%08d.png",
      "-c:a", "copy",
      "-crf", "15",
      "-c:v", "libx264",
      "-pix_fmt", "yuv420p",
      // "-b:v", "8M", // 设置视频比特率为5Mbps（可以根据需求调整）
      newVideoPath
    ];
    // 启动进程
    Process processMergerVideo =
        await Process.start(ffmpegPath, argumentsMergerVideo);
    // 获取进程的标准输出流
    processMergerVideo.stdout.transform(utf8.decoder).listen((data) {
      print('stdout: $data');
    });

    // 获取进程的标准错误流
    processMergerVideo.stderr.transform(utf8.decoder).listen((data) {
      print('stderr: $data');
    });
    await processMergerVideo.exitCode;
    print('DONE 重新合成视频:');

    //清理内容
    FileUtil.deleteFolderContent(imageInputFrame);
    FileUtil.deleteFolderContent(imageOutputFrame);
    return newVideoPath;
  }
}
