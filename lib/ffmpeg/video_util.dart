/*
 * Copyright (c) 2018-2022 Taner Sener
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';

import 'util.dart';

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

class VideoUtil {
  static const String FONT_ASSET_1 = "hanyi.ttf";
  static const String FONT_ASSET_2 = "truenorg.otf";

  static const String shaderCode = """
uniform float u_time;
varying vec2 TextureCoordsVarying;
uniform sampler2D texture;

vec2 uv;

float rnd(float x) {
    return fract(sin(dot(vec2(x+47.49,38.2467/(x+2.3)), vec2(12.9898, 78.233)))* (43758.5453));
}

float drawCircle(vec2 center, float radius) {
    return 1.0 - smoothstep(0.0, radius, length(uv - center));
}

void main() {
    const int _SnowflakeAmount = 200; // Number of snowflakes
    const float _BlizardFactor = 0.2; // _BlizardFactor Fury of the storm!

    gl_FragColor = texture2D(texture, TextureCoordsVarying);
    uv = vec2(TextureCoordsVarying.x, 1.0 - TextureCoordsVarying.y);
    float j;

    for (int i = 0; i < _SnowflakeAmount; i++) {
        j = float(i);
        float speed = 0.3 + rnd(cos(j)) * (0.7 + 0.5 * cos(j / (float(_SnowflakeAmount) * 0.25)));
        vec2 center = vec2((0.25 - uv.y) * _BlizardFactor + rnd(j) + 0.1 * cos(u_time + sin(j)), mod(sin(j) - speed * (u_time * 1.5 * (0.1 + _BlizardFactor)), 0.9));
        gl_FragColor += vec4(0.2 * drawCircle(center, 0.001 + speed * 0.012));
    }
}
""";

  static void registerApplicationFonts() {
    var fontNameMapping = Map<String, String>();
    fontNameMapping["MyFontName"] = "Doppio One";
    VideoUtil.tempDirectory.then((tempDirectory) {
      FFmpegKitConfig.setFontDirectoryList(
          [tempDirectory.path, "/system/fonts", "/System/Library/Fonts"],
          fontNameMapping);
      FFmpegKitConfig.setEnvironmentVariable(
          "FFREPORT",
          "file=" +
              new File(tempDirectory.path + "/" + today() + "-ffreport.txt")
                  .path);
    });
  }

  static void prepareAssets() async {
    await VideoUtil.assetToFile(FONT_ASSET_1);
    // await VideoUtil.assetToFile(FONT_ASSET_2);
  }

  static Future<File> assetToFile(String assetName) async {
    final ByteData assetByteData =
        await rootBundle.load('assets/fonts/$assetName');

    final List<int> byteList = assetByteData.buffer
        .asUint8List(assetByteData.offsetInBytes, assetByteData.lengthInBytes);

    final String fullTemporaryPath =
        join((await tempDirectory).path, assetName);
    logger.d('Saving asset $assetName to file at $fullTemporaryPath.');

    Future<File> fileFuture = new File(fullTemporaryPath)
        .writeAsBytes(byteList, mode: FileMode.writeOnly, flush: true);

    ffprint('assets/$assetName saved to file at $fullTemporaryPath.');

    return fileFuture;
  }

  static Future<String> assetPath(String assetName) async {
    return join((await tempDirectory).path, assetName);
  }

  static Future<Directory> get documentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  static Future<Directory> get tempDirectory async {
    return await getTemporaryDirectory();
  }

  static String generateEncodeVideoScript(
      String image1Path,
      String image2Path,
      String image3Path,
      String videoFilePath,
      String videoCodec,
      String customOptions) {
    return generateEncodeVideoScriptWithCustomPixelFormat(
        image1Path,
        image2Path,
        image3Path,
        videoFilePath,
        videoCodec,
        "yuv420p",
        customOptions);
  }

  static generateEncodeVideoScriptWithCustomPixelFormat(
      String image1Path,
      String image2Path,
      String image3Path,
      String videoFilePath,
      String videoCodec,
      String pixelFormat,
      String customOptions) {
    return "-hide_banner -y -loop 1 -i '" +
        image1Path +
        "' " +
        "-loop   1 -i \"" +
        image2Path +
        "\" " +
        "-loop 1   -i \"" +
        image3Path +
        "\" " +
        "-filter_complex " +
        "\"[0:v]setpts=PTS-STARTPTS,scale=w='if(gte(iw/ih,640/427),min(iw,640),-1)':h='if(gte(iw/ih,640/427),-1,min(ih,427))',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream1out1][stream1out2];" +
        "[1:v]setpts=PTS-STARTPTS,scale=w='if(gte(iw/ih,640/427),min(iw,640),-1)':h='if(gte(iw/ih,640/427),-1,min(ih,427))',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream2out1][stream2out2];" +
        "[2:v]setpts=PTS-STARTPTS,scale=w='if(gte(iw/ih,640/427),min(iw,640),-1)':h='if(gte(iw/ih,640/427),-1,min(ih,427))',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream3out1][stream3out2];" +
        "[stream1out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3,select=lte(n\\,90)[stream1overlaid];" +
        "[stream1out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30)[stream1ending];" +
        "[stream2out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=2,select=lte(n\\,60)[stream2overlaid];" +
        "[stream2out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30),split=2[stream2starting][stream2ending];" +
        "[stream3out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=2,select=lte(n\\,60)[stream3overlaid];" +
        "[stream3out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30)[stream3starting];" +
        "[stream2starting][stream1ending]blend=all_expr='if(gte(X,(W/2)*T/1)*lte(X,W-(W/2)*T/1),B,A)':shortest=1[stream2blended];" +
        "[stream3starting][stream2ending]blend=all_expr='if(gte(X,(W/2)*T/1)*lte(X,W-(W/2)*T/1),B,A)':shortest=1[stream3blended];" +
        "[stream1overlaid][stream2blended][stream2overlaid][stream3blended][stream3overlaid]concat=n=5:v=1:a=0,scale=w=640:h=424,format=" +
        pixelFormat +
        "[video]\"" +
        " -map [video] -fps_mode cfr " +
        customOptions +
        "-c:v " +
        videoCodec +
        " -r 30 " +
        videoFilePath;
  }

  static String generateShakingVideoScript(
      final String image1Path,
      final String image2Path,
      final String image3Path,
      final String videoFilePath) {
    return "-hide_banner -y -loop 1 -i \"" +
        image1Path +
        "\" " +
        "-loop 1 -i '" +
        image2Path +
        "' " +
        "-loop 1 -i " +
        image3Path +
        " " +
        "-f lavfi -i color=black:s=640x427 " +
        "-filter_complex \"" +
        "[0:v]setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1[stream1out];" +
        "[1:v]setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1[stream2out];" +
        "[2:v]setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1[stream3out];" +
        "[stream1out]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3[stream1overlaid];" +
        "[stream2out]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3[stream2overlaid];" +
        "[stream3out]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3[stream3overlaid];" +
        "[3:v][stream1overlaid]overlay=x=\'2*mod(n,4)\':y=\'2*mod(n,2)\',trim=duration=3[stream1shaking];" +
        "[3:v][stream2overlaid]overlay=x=\'2*mod(n,4)\':y=\'2*mod(n,2)\',trim=duration=3[stream2shaking];" +
        "[3:v][stream3overlaid]overlay=x=\'2*mod(n,4)\':y=\'2*mod(n,2)\',trim=duration=3[stream3shaking];" +
        "[stream1shaking][stream2shaking][stream3shaking]concat=n=3:v=1:a=0,scale=w=640:h=424,format=yuv420p[video]\"" +
        " -map [video] -fps_mode cfr -c:v mpeg4 -r 30 " +
        videoFilePath;
  }

  ///合并多个音频文件为一个音频文件
  // static String generateConcatAudioScriptList(
  //     List<String> audioPathList, String outputFilePath) {
  //   // Initialize the command with the basic options
  //   String command = '-hide_banner -y';
  //   // Add input files to the command
  //   for (String audioPath in audioPathList) {
  //     command += ' -i "$audioPath"';
  //   }
  //   // Create the filter_complex part to concatenate the audio files
  //   command += ' -filter_complex "';
  //   for (int i = 0; i < audioPathList.length; i++) {
  //     command += "[$i:0]";
  //   }
  //   command +=
  //       'concat=n=${audioPathList.length}:v=0:a=1[out]" -map "[out]" -c:a pcm_s16le $outputFilePath';
  //
  //   return command;
  // }

  ///生成SRT字幕文件
  static generateSrt(String srtPath, List<TweetImage> tweetImageList) async {
    final file = File(srtPath);
    final sink = await file.openWrite();
    double startTime = 0;
    for (int i = 0; i < tweetImageList.length; i++) {
      final tweetImage = tweetImageList[i];
      var endTime = startTime + (tweetImage.tts?.duration ?? 4);
      sink.writeln("${i + 1}");
      // startTime和endTime为秒数，转化为00:00:00,000格式
      String formatTime(double time) {
        int hours = time ~/ 3600;
        int minutes = (time % 3600) ~/ 60;
        int seconds = (time % 60).toInt();
        int milliseconds = ((time - time.toInt()) * 1000).toInt();
        return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')},${milliseconds.toString().padLeft(3, '0')}";
      }

      sink.writeln("${formatTime(startTime)} --> ${formatTime(endTime)}");
      String text = tweetImage.ttsText ?? "";
      //将text中所有的中英文标点替换成空格
      String pattern = r'[^\w\s\u4e00-\u9fff]';
      RegExp regExp = RegExp(pattern);
      text = text.replaceAll(regExp, ' ');
      sink.writeln(text);
      sink.writeln();
      startTime = endTime;
    }
    await sink.close();
  }

  static Future<String> generateConcatAudioScriptList(
      List<String> audioPathList, String outputFilePath) async {
    // 创建一个临时文件来列出所有输入音频文件
    final tempFile = File('${Directory.systemTemp.path}/audio_list.txt');
    final sink = tempFile.openWrite();
    for (String audioPath in audioPathList) {
      sink.writeln("file '$audioPath'");
    }
    await sink.close();

    // 初始化命令并添加基本选项
    String command =
        '-hide_banner -y -f concat -safe 0 -i "${tempFile.path}" -c copy $outputFilePath';

    return command;
  }

  ///将多个视频文件合并为一个视频文件
  static String generateConcatVideoScriptList(
      List<String> videoPathList, String outputFilePath) {
    // Initialize the command with the basic options
    String command = '-hide_banner -y';
    // Add input files to the command
    for (String videoPath in videoPathList) {
      command += ' -i "$videoPath"';
    }

    // Create the filter_complex part to concatenate the video files
    command += ' -filter_complex "';
    for (int i = 0; i < videoPathList.length; i++) {
      command += "[$i:v:0]setsar=1[v$i];";
    }
    for (int i = 0; i < videoPathList.length; i++) {
      command += "[v$i]";
    }
    command +=
        'concat=n=${videoPathList.length}:v=1:a=0[outv]" -map "[outv]" -c:v libx264 $outputFilePath';

    return command;
  }

  static String generateTextOverlayScript(
      String text,
      int fontSize,
      String inputVideoPath,
      String outputFilePath,
      String fontFilePath,
      double startTime,
      double duration) {
    // Initialize the command with the basic options
    String command = '-hide_banner -y';
    // Add input video file to the command
    command += ' -i "$inputVideoPath"';
    // Add the drawtext filter to overlay text on the video with start and end time
    command +=
        ' -vf "drawtext=text=\'$text\':fontfile=$fontFilePath:fontsize=$fontSize:fontcolor=white:x=20:y=20:enable=\'between(t,$startTime,$startTime+$duration)\'"';
    // Specify the output file path
    command += ' -c:v libx264 "$outputFilePath"';
    return command;
  }

  ///将视频中的音频提取出来
  static String generateSeparateAudioScript(
      String videoPath, String saveAudioPath) {
    // Initialize the command with the basic options
    String command = '-hide_banner -y';
    // Add input video file to the command
    command += ' -i "$videoPath"';
    // Add arguments to extract audio and save it to the specified path
    command += ' -vn -c:a mp3 -y "$saveAudioPath"';
    return command;
  }

  ///将视频中的帧提取出来
  static String generateSeparateVideoScript(
      String videoPath, String imageOutPath) {
    // Initialize the command with the basic options
    String command = '-hide_banner -y';
    // Add input video file to the command
    command += ' -i "$videoPath"';
    // Add arguments to extract frames and save them to the specified path
    command += ' -r 1 -vf fps=1 -f image2 "$imageOutPath/image-%4d.jpg"';
    return command;
  }

  static String generateMuxVideoAudioScript(
      String inputVideoPath, String inputAudioPath, String outputVideoPath) {
    // Initialize the command with the basic options
    String command = '-hide_banner -y';
    // Add input video and audio files to the command
    command += ' -i "$inputVideoPath" -i "$inputAudioPath"';
    // Specify the output format and codec
    command += ' -c:v copy -c:a aac -strict experimental $outputVideoPath';
    return command;
  }

  static String generateMovingVideoScriptList(
      List<TweetImage> localImageList,
      int ratio,
      double upScale,
      String videoFilePath,
      bool allVideo,
      int jpgIndex,
      {String videoCodec = 'libx264'}) {
    StringBuffer filterComplex = StringBuffer();
    //根据传入的ratio来确定合成视频的宽高,默认为0，0表示1:1，1表示4:3，2表示16:9，3表示9:16，4表示3:4，5表示2:3，6表示3:2
    //判断ratio来确定width和height的值，对应1080P
    int width = 1024;
    int height = 1024;
    if (ratio == 0) {
      width = (1024 * upScale).toInt();
      height = (1024 * upScale).toInt();
    } else if (ratio == 1) {
      width = (1200 * upScale).toInt();
      height = (900 * upScale).toInt();
    } else if (ratio == 2) {
      width = (1600 * upScale).toInt();
      height = (900 * upScale).toInt();
    } else if (ratio == 3) {
      width = (900 * upScale).toInt();
      height = (1600 * upScale).toInt();
    } else if (ratio == 4) {
      width = (900 * upScale).toInt();
      height = (1200 * upScale).toInt();
    }
    double scale = 1.2;

    logger.d("jpgIndex:$jpgIndex height:$height ratio:$ratio upScale:$upScale");
    // Loop through the images and create the filter chain
    for (int i = 0; i < localImageList.length; i++) {
      TweetImage tweetImage = localImageList[i];
      double duration = tweetImage.tts?.duration ?? 4;
      // logger.d("时长：$duration");
      filterComplex.write("[${i}:v]setpts=PTS-STARTPTS,");

      if (tweetImage.mediaType == 1) {
        filterComplex.write("setsar=sar=1/1,");
        filterComplex.write(
            "scale=${width}:${height}:force_original_aspect_ratio=decrease[stream${i}out];");
        filterComplex.write(
            "[stream${i}out]pad=${width}:${height}:(ow-iw)/2:(oh-ih)/2:");
        // filterComplex.write(
        //     "x=0:y=0,trim=duration=${duration.toStringAsFixed(5)}[stream${i}overlaid];");
        //判断视频时长是否小于duration
        if (duration > 4.8) {
          //重复播放
          // filterComplex.write(
          //     "x=0:y=0,loop=-1:size=${duration * 25}:start=0,");  // 25是帧率，可以根据实际情况调整
          // filterComplex.write(
          //     "trim=0:${duration.toStringAsFixed(5)},setpts=PTS-STARTPTS[stream${i}overlaid];");
          //最后帧填充
          filterComplex.write("x=0:y=0,");
          filterComplex
              .write("tpad=stop_mode=clone:stop_duration=${(duration - 4.8)},");
          filterComplex.write("setpts=PTS-STARTPTS[stream${i}overlaid];");
        } else {
          // 如果视频时长大于或等于duration，直接trim到duration长度
          filterComplex
              .write("x=0:y=0,trim=duration=${duration}[stream${i}overlaid];");
        }
      } else {
        //使得保持宽高比例
        filterComplex.write(
            "scale=w='if(gte(iw/ih,${width}/${height}),min(iw,${width}),-1)':");
        filterComplex.write(
            "h='if(gte(iw/ih,${width}/${height}),-1,min(ih,${height}))',");
        filterComplex.write(
            "scale=trunc(${width}/2)*2:trunc(${height}/2)*2,setsar=sar=1/1,");
        filterComplex.write("scale=iw*1.2:ih*1.2[stream${i}out];");
        filterComplex.write(
            "[stream${i}out]pad=width=${width * scale}:height=${height * scale}:");
        filterComplex.write(
            "x=(${width * scale}-iw)/2:y=(${height * scale}-ih)/2:color=#00000000,trim=duration=${duration.toStringAsFixed(5)}[stream${i}overlaid];");
      }

      // Use the correct stream index based on the number of images
      String overlayStream =
          localImageList.length > 1 ? "[${jpgIndex}:v]" : "[${jpgIndex}:v]";
      if (tweetImage.mediaType == 1) {
        if (!allVideo) {
          logger.d(
              "合成移动视频效果，mediaType:${tweetImage.mediaType}  jpgIndex:$jpgIndex overlayStream:$overlayStream");
          filterComplex.write(
              "$overlayStream[stream${i}overlaid]overlay=x='0':y='0',trim=duration=${duration.toStringAsFixed(5)}[stream${i}moving];");
        }
      } else {
        int imgEffectType = tweetImage.imgEffectType ?? 2;
        // 0: 向上 1: 向下 2: 向左 3: 向右 根据不同的来设置不同的动画效果
        logger.d(
            "合成移动图片效果，mediaType:${tweetImage.mediaType}  jpgIndex:$jpgIndex overlayStream:$overlayStream imgEffectType:$imgEffectType");
        if (imgEffectType == 0) {
          filterComplex.write(
              "$overlayStream[stream${i}overlaid]overlay=x='0':y='-(t/${duration})*0.2*${height}',trim=duration=${duration.toStringAsFixed(5)}[stream${i}moving];");
        } else if (imgEffectType == 1) {
          filterComplex.write(
              "$overlayStream[stream${i}overlaid]overlay=x='0':y='-0.2*${height}+(t/${duration})*0.2*${height}',trim=duration=${duration.toStringAsFixed(5)}[stream${i}moving];");
        } else if (imgEffectType == 2) {
          filterComplex.write(
              "$overlayStream[stream${i}overlaid]overlay=x='-(t/${duration})*0.2*${width}':y='0',trim=duration=${duration.toStringAsFixed(5)}[stream${i}moving];");
        } else if (imgEffectType == 3) {
          filterComplex.write(
              "$overlayStream[stream${i}overlaid]overlay=x='-0.2*${width}+(t/${duration})*0.2*${width}':y='0',trim=duration=${duration.toStringAsFixed(5)}[stream${i}moving];");
        } else {
          //2的效果
          filterComplex.write(
              "$overlayStream[stream${i}overlaid]overlay=x='-(t/${duration})*0.2*${width}':y='0',trim=duration=${duration.toStringAsFixed(5)}[stream${i}moving];");
        }
      }
    }

    // Concatenate all the streams
    for (int i = 0; i < localImageList.length; i++) {
      TweetImage tweetImage = localImageList[i];
      if (allVideo) {
        filterComplex.write("[stream${i}overlaid]");
      } else
        filterComplex.write("[stream${i}moving]");
    }
    filterComplex.write("concat=n=${localImageList.length}:v=1:a=0,");
    filterComplex.write("scale=w=${width}:h=${height},format=yuv420p[video]");

    // Build the full command
    StringBuffer command = StringBuffer();
    command.write("-hide_banner -y ");

    // Add input images
    for (int i = 0; i < localImageList.length; i++) {
      TweetImage tweetImage = localImageList[i];
      if (tweetImage.mediaType == 1) {
        command.write("-i \"${tweetImage.videoUrl}\" ");
      } else {
        command.write("-loop 1 -i \"${tweetImage.url}\" ");
      }
    }

    // Add the black background
    // command.write("-f lavfi -i color=black:s=${width}x${height} ");

    // Add filter complex and output mapping
    command.write("-filter_complex \"${filterComplex.toString()}\" ");
    command.write(
        "-map [video] -fps_mode cfr -crf 18 -preset slow -c:v $videoCodec -r 25 $videoFilePath");

    return command.toString();
  }

  static String generateShakingVideoScriptList(List<String> imagePathList,
      int width, int height, double duration, String videoFilePath) {
    StringBuffer filterComplex = StringBuffer();

    // Loop through the images and create the filter chain
    for (int i = 0; i < imagePathList.length; i++) {
      filterComplex.write("[${i}:v]setpts=PTS-STARTPTS,");
      filterComplex.write(
          "scale=w='if(gte(iw/ih,${width}/${height}),min(iw,${width}),-1)':");
      filterComplex
          .write("h='if(gte(iw/ih,${width}/${height}),-1,min(ih,${height}))',");
      filterComplex.write(
          "scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1[stream${i}out];");
      filterComplex
          .write("[stream${i}out]pad=width=${width}:height=${height}:");
      filterComplex.write(
          "x=(${width}-iw)/2:y=(${height}-ih)/2:color=#00000000,trim=duration=${duration}[stream${i}overlaid];");
      filterComplex.write(
          "[3:v][stream${i}overlaid]overlay=x='2*mod(n,4)':y='2*mod(n,2)',trim=duration=${duration}[stream${i}shaking];");
    }

    // Concatenate all the streams
    for (int i = 0; i < imagePathList.length; i++) {
      filterComplex.write("[stream${i}shaking]");
    }
    filterComplex.write("concat=n=${imagePathList.length}:v=1:a=0,");
    filterComplex.write("scale=w=${width}:h=${height},format=yuv420p[video]");

    // Build the full command
    StringBuffer command = StringBuffer();
    command.write("-hide_banner -y ");

    // Add input images
    for (int i = 0; i < imagePathList.length; i++) {
      command.write("-loop 1 -i \"${imagePathList[i]}\" ");
    }

    // Add the black background
    command.write("-f lavfi -i color=black:s=${width}x${height} ");

    // Add filter complex and output mapping
    command.write("-filter_complex \"${filterComplex.toString()}\" ");
    command.write("-map [video] -r 25 -b:v 2M -crf 18 $videoFilePath");

    return command.toString();
  }

  static String generateCreateVideoWithPipesScript(
      final String image1Pipe,
      final String image2Pipe,
      final String image3Pipe,
      final String videoFilePath) {
    return "-hide_banner -y -i \"" +
        image1Pipe +
        "\" " +
        "-i '" +
        image2Pipe +
        "' " +
        "-i " +
        image3Pipe +
        " " +
        "-filter_complex \"" +
        "[0:v]loop=loop=-1:size=1:start=0,setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream1out1][stream1out2];" +
        "[1:v]loop=loop=-1:size=1:start=0,setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream2out1][stream2out2];" +
        "[2:v]loop=loop=-1:size=1:start=0,setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream3out1][stream3out2];" +
        "[stream1out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3,select=lte(n\\,90)[stream1overlaid];" +
        "[stream1out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30)[stream1ending];" +
        "[stream2out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=2,select=lte(n\\,60)[stream2overlaid];" +
        "[stream2out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30),split=2[stream2starting][stream2ending];" +
        "[stream3out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=2,select=lte(n\\,60)[stream3overlaid];" +
        "[stream3out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30)[stream3starting];" +
        "[stream2starting][stream1ending]blend=all_expr=\'if(gte(X,(W/2)*T/1)*lte(X,W-(W/2)*T/1),B,A)\':shortest=1[stream2blended];" +
        "[stream3starting][stream2ending]blend=all_expr=\'if(gte(X,(W/2)*T/1)*lte(X,W-(W/2)*T/1),B,A)\':shortest=1[stream3blended];" +
        "[stream1overlaid][stream2blended][stream2overlaid][stream3blended][stream3overlaid]concat=n=5:v=1:a=0,scale=w=640:h=424,format=yuv420p[video]\"" +
        " -map [video] -fps_mode cfr -c:v mpeg4 -r 30 " +
        videoFilePath;
  }

  // static String generateCreateVideoWithPipesListScript(
  //     List<String> imagePipes, String videoFilePath, int width, int height) {
  //   // Initialize the command with the basic options
  //   String command = '-y';
  //
  //   // Add input pipes to the command
  //   for (int i = 0; i < imagePipes.length; i++) {
  //     command += ' -loop 1 -t 4 -i "${imagePipes[i]}"';
  //   }
  //
  //   // Start building the filter_complex part
  //   command += ' -filter_complex "';
  //
  //   // Process each image to match the desired width and height
  //   for (int i = 0; i < imagePipes.length; i++) {
  //     command +=
  //     '[${i}:v]scale=$width:$height,setsar=1,pad=$width:$height:0:0:black,format=yuv420p[v$i];';
  //   }
  //
  //   // Concatenate all processed images
  //   command += '[v0]';
  //   for (int i = 1; i < imagePipes.length; i++) {
  //     command += '[v$i]';
  //   }
  //   command += 'concat=n=${imagePipes.length}:v=1:a=0,format=yuv420p[v]"';
  //
  //   // Add the final mapping and output options
  //   // Here we add the bitrate, preset, and some additional quality parameters
  //   command += ' -map [v] -r 25 -b:v 2M -crf 18 $videoFilePath';
  //
  //   return command;
  // }

  static String generateCreateVideoWithPipesListScript(
      List<String> imagePipeList, String videoFilePath, int width, int height) {
    String command = "-hide_banner -y";

    // 动态添加输入管道
    for (int i = 0; i < imagePipeList.length; i++) {
      command += " -i \"" + imagePipeList[i] + "\"";
    }

    // 应用固定的 x 轴移动效果
    command += " -filter_complex \"";

    for (int i = 0; i < imagePipeList.length; i++) {
      // 设置 x 轴移动为传入宽度的 0.2 倍
      double moveX = width * 0.2;

      command +=
          "[$i:v]zoompan=z='zoom+0.00001':x='iw/2-240.0':y='ih/2':d=100:fps=25,trim=duration=4,setpts=PTS-STARTPTS[v$i];";
    }

    // 拼接这些动画流
    for (int i = 0; i < imagePipeList.length; i++) {
      command += "[v$i]";
    }
    command +=
        "concat=n=${imagePipeList.length}:v=1:a=0,format=yuv420p[video]\"";

    // 最终映射和输出选项
    command +=
        " -map [video] -r 25 -b:v 2M -crf 18 -s 1200X900 " + videoFilePath;

    return command;
  }

  static generateZscaleVideoScript(inputVideoFilePath, outputVideoFilePath) {
    return "-y -i " +
        inputVideoFilePath +
        " -vf zscale=tin=smpte2084:min=bt2020nc:pin=bt2020:rin=tv:t=smpte2084:m=bt2020nc:p=bt2020:r=tv,zscale=t=linear,tonemap=tonemap=clip,zscale=t=bt709,format=yuv420p " +
        outputVideoFilePath;
  }
}
