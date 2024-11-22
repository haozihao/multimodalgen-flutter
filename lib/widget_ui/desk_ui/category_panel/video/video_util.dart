import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:utils/utils.dart';

class VideoUtil {
  static final VideoUtil _instance = VideoUtil._internal();

  static VideoUtil get instance => _instance;

  ///通用全局单例，第一次使用时初始化
  VideoUtil._internal();


  static Future<String> hdGeneral(
      String imageInputFrame, String imageOutputFrame) async {
    final ffmpegDirectory = Directory.current;
    String exePath = ffmpegDirectory.path + "\\realesrgan-ncnn-vulkan.exe";
    List<String> arguments = [
      "-i",
      imageInputFrame,
      "-s",
      "2",
      "-t",
      "256",
      "-m",
      "Real-ESRGAN-models",
      "-n",
      "realesrgan-x4plus",
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
    print('DONE 完成HD高清:');

    //清理内容，原始输入内容
    FileUtil.deleteFolderContent(imageInputFrame);
    return imageOutputFrame;
  }
}
