import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_story_repository.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';
import 'package:pieces_ai/app/model/ai_img.dart' as aiImg;
import 'package:utils/utils.dart';

const String getTaskInfo = '/ai/mini_story/task_info/v2';
const String imgGeneratePath = '/ai/ai_paint/img_generate';
const String videoGeneratePath = '/ai/ai_video/video_generate';
const String getAllTaskPath = '/ai/mini_story/all_task';

class HttpAiStoryLocalSd extends HttpAiStoryRepository {
  @override
  Future<aiImg.AiImg> imgGenerate(
      {required BuildContext context,
      required AiPaintParamsV2 aiPaintParamsV2}) async {
    String errorMsg = "";

    Map<String, dynamic> requestData = {};
    Map<String, dynamic> jsonObjectOverSetting = {};
    jsonObjectOverSetting["sd_model_checkpoint"] = aiPaintParamsV2.styleName;
    // jsonObjectOverSetting["sd_vae"] = 'vae-ft-mse-840000-ema-pruned.safetensors';
    jsonObjectOverSetting["sd_vae"] = 'auto';
    jsonObjectOverSetting["CLIP_stop_at_last_layers"] = 2;
    jsonObjectOverSetting["samples_format"] = "jpg";

    // requestData["steps"] = aiPaintParamsV2.steps;
    requestData["steps"] = 20;
    switch (aiPaintParamsV2.ratio) {
      case 1:
        requestData["width"] = 600;
        requestData["height"] = 450;
        break;
      case 2:
        requestData["width"] = 800;
        requestData["height"] = 450;
        break;
      case 3:
        requestData["width"] = 450;
        requestData["height"] = 800;
        break;
      case 4:
        requestData["width"] = 450;
        requestData["height"] = 600;
        break;
      case 5:
        requestData["width"] = 400;
        requestData["height"] = 600;
        break;
      case 6:
        requestData["width"] = 600;
        requestData["height"] = 400;
        break;
    }

    requestData["seed"] = -1;
    requestData["batch_size"] = aiPaintParamsV2.batchSize;
    requestData["override_settings_restore_afterwards"] = true;
    requestData["prompt"] = aiPaintParamsV2.prompt;
    requestData["negative_prompt"] = aiPaintParamsV2.negativePrompt;
    requestData["override_settings"] = jsonObjectOverSetting;
    requestData["sampler_name"] = aiPaintParamsV2.sampling;
    requestData["cfg_scale"] = aiPaintParamsV2.cfgScale;

    // if (alwaysonScripts != null) {
    //   requestData["alwayson_scripts"] = alwaysonScripts;
    // }
    String path = "/sdapi/v1/txt2img";
    if (aiPaintParamsV2.image != null &&
        aiPaintParamsV2.image!.startsWith("data:image/")) {
      path = "/sdapi/v1/img2img";
      final initImages = [aiPaintParamsV2.image];
      requestData["init_images"] = initImages;
      requestData["denoising_strength"] = aiPaintParamsV2.strength;
      print("重绘幅度" + requestData["denoising_strength"].toString());
      requestData["width"] = requestData["width"] * 2;
      requestData["height"] = requestData["height"] * 2;
      requestData["steps"] = 20;
      requestData["enable_hr"] = false;
    } else {
      if (aiPaintParamsV2.hd.scale != null) {
        requestData["enable_hr"] = true;
        // requestData["hr_scale"] = aiPaintParamsV2.hd.scale;
        requestData["hr_scale"] = 2.0;
        requestData["denoising_strength"] = 0.3;
        requestData["hr_upscaler"] = "R-ESRGAN 4x+ Anime6B";
      }
    }
    print("生图参数" + requestData.toString());

    try {
      HttpUtil.instance.client.options = BaseOptions(
          connectTimeout: Duration(seconds: 180),
          sendTimeout: Duration(seconds: 180),
          receiveTimeout: Duration(seconds: 180));
      var result = await HttpUtil.instance.client.post(
        HttpUtil.apiLocalUrl + path,
        data: requestData,
      );
      // print("Ai生图结果：" + result.data.toString());
      if (result.data != null) {
        List<dynamic> images = result.data['images'];
        String base64data = images[0];
        //解析成图片保存到本地，并返回本地路径
        var appDir = await getApplicationDocumentsDirectory();
        String fileSeprate = FileUtil.getFileSeparate();
        String imgCache = "images";
        if (Platform.isMacOS) {
          fileSeprate = "/";
        }
        String imagesDir = appDir.path + fileSeprate + imgCache;
        if (!await Directory(imagesDir).exists()) {
          await Directory(imagesDir).create();
        }
        String imageName =
            DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
        String path = await saveBase64ImageToFile(
            base64data, imagesDir + fileSeprate + imageName);
        List<aiImg.Image> imageList = [];
        aiImg.Image image = aiImg.Image(pass: true, url: path);
        imageList.add(image);
        var img = aiImg.AiImg(images: imageList, allSeeds: [-1]);
        return img;
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return aiImg.AiImg(images: [], allSeeds: []);
  }

  Future<aiImg.AiImg> imgGenerateSenior(
      {
        required AiPaintParamsV2 aiPaintParamsV2,required String draftName}) async {
    String errorMsg = "";

    Map<String, dynamic> requestData = {};
    Map<String, dynamic> jsonObjectOverSetting = {};
    jsonObjectOverSetting["sd_model_checkpoint"] = aiPaintParamsV2.styleName;
    // jsonObjectOverSetting["sd_vae"] = 'vae-ft-mse-840000-ema-pruned.safetensors';
    jsonObjectOverSetting["sd_vae"] = 'auto';
    jsonObjectOverSetting["CLIP_stop_at_last_layers"] = 2;
    jsonObjectOverSetting["samples_format"] = "jpg";

    // requestData["steps"] = aiPaintParamsV2.steps;
    requestData["steps"] = 20;
    switch (aiPaintParamsV2.ratio) {
      case 1:
        requestData["width"] = 600;
        requestData["height"] = 450;
        break;
      case 2:
        requestData["width"] = 800;
        requestData["height"] = 450;
        break;
      case 3:
        requestData["width"] = 450;
        requestData["height"] = 800;
        break;
      case 4:
        requestData["width"] = 450;
        requestData["height"] = 600;
        break;
      case 5:
        requestData["width"] = 400;
        requestData["height"] = 600;
        break;
      case 6:
        requestData["width"] = 600;
        requestData["height"] = 400;
        break;
    }

    requestData["seed"] = -1;
    requestData["batch_size"] = aiPaintParamsV2.batchSize;
    requestData["override_settings_restore_afterwards"] = true;
    requestData["prompt"] = aiPaintParamsV2.prompt;
    requestData["negative_prompt"] = aiPaintParamsV2.negativePrompt;
    requestData["override_settings"] = jsonObjectOverSetting;
    requestData["sampler_name"] = aiPaintParamsV2.sampling;
    requestData["cfg_scale"] = aiPaintParamsV2.cfgScale;

    // if (alwaysonScripts != null) {
    //   requestData["alwayson_scripts"] = alwaysonScripts;
    // }
    String path = "/sdapi/v1/txt2img";
    if (aiPaintParamsV2.image != null &&
        aiPaintParamsV2.image!.startsWith("data:image/")) {
      path = "/sdapi/v1/img2img";
      final initImages = [aiPaintParamsV2.image];
      requestData["init_images"] = initImages;
      requestData["denoising_strength"] = aiPaintParamsV2.strength;
      print("重绘幅度" + requestData["denoising_strength"].toString());
      requestData["width"] = requestData["width"] * 2;
      requestData["height"] = requestData["height"] * 2;
      requestData["steps"] = 20;
      requestData["enable_hr"] = false;
    } else {
      if (aiPaintParamsV2.hd.scale != null) {
        requestData["enable_hr"] = true;
        // requestData["hr_scale"] = aiPaintParamsV2.hd.scale;
        requestData["hr_scale"] = 2.0;
        requestData["denoising_strength"] = 0.3;
        requestData["hr_upscaler"] = "R-ESRGAN 4x+ Anime6B";
      }
    }
    print("生图参数" + requestData.toString());

    try {
      HttpUtil.instance.client.options = BaseOptions(
          connectTimeout: Duration(seconds: 180),
          sendTimeout: Duration(seconds: 180),
          receiveTimeout: Duration(seconds: 180));
      var result = await HttpUtil.instance.client.post(
        HttpUtil.apiLocalUrl + path,
        data: requestData,
      );
      // print("Ai生图结果：" + result.data.toString());
      if (result.data != null) {
        List<dynamic> images = result.data['images'];
        //解析成图片保存到本地，并返回本地路径
        String draftPath =
        await FileUtil.getPieceAiDraftFolderByTaskId(draftName);
        String sdImagePath = draftPath +
            FileUtil.getFileSeparate() +
            "sd_image" +
            FileUtil.getFileSeparate();
        if (!Directory(sdImagePath).existsSync()) {
          Directory(sdImagePath).createSync();
        }
        List<aiImg.Image> imageList = [];
        await Future.forEach(images, (element) async {
          String imageName =
              DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
          String path = await saveBase64ImageToFile(
              element, sdImagePath + imageName);
          aiImg.Image image = aiImg.Image(pass: true, url: path);
          imageList.add(image);
        });
        var img = aiImg.AiImg(images: imageList, allSeeds: [-1]);
        return img;
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return aiImg.AiImg(images: [], allSeeds: []);
  }


  Future<String> saveBase64ImageToFile(
      String base64ImageString, String filePath) async {
    List<int> imageBytes = base64Decode(base64ImageString);
    File file = File(filePath);
    await file.writeAsBytes(imageBytes);
    return filePath;
  }

  //获取本地SD的所有支持的大模型风格
  Future<List<String>> getLocalStyles() async {
    String path = "/sdapi/v1/sd-models";
    String errorMsg = "";
    Map<String, dynamic> requestData = {};
    print("获取本地SD模型列表HttpUtil.apiLocalUrl：" + HttpUtil.apiLocalUrl);
    try {
      var result = await HttpUtil.instance.client.get(
        HttpUtil.apiLocalUrl + path,
        data: requestData,
      );
      if (result.data != null) {
        List<dynamic> data = result.data;
        List<String> styles = [];
        for (var element in data) {
          styles.add(element["model_name"]);
        }
        print("获取本地SD模型列表：" + styles.toString());
        return styles;
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return [];
  }

  //获取本地SD的所有支持的lora
  Future<List<String>> getLocalLora() async {
    String path = "/sdapi/v1/loras";

    String errorMsg = "";
    Map<String, dynamic> requestData = {};
    print("获取本地lora模型列表HttpUtil.apiLocalUrl：" + HttpUtil.apiLocalUrl);
    try {
      var result = await HttpUtil.instance.client.get(
        HttpUtil.apiLocalUrl + path,
        data: requestData,
      );
      if (result.data != null) {
        List<dynamic> data = result.data;
        List<String> styles = [];
        for (var element in data) {
          styles.add(element["name"]);
        }
        print("获取本地lora列表：" + styles.toString());
        return styles;
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return [];
  }

  //获取本地SD的所有支持的vaes
  Future<List<String>> getLocalVaes() async {
    String path = "/sdapi/v1/sd-vae";

    String errorMsg = "";
    Map<String, dynamic> requestData = {};
    print("获取本地vae列表HttpUtil.apiLocalUrl：" + HttpUtil.apiLocalUrl);
    try {
      var result = await HttpUtil.instance.client.get(
        HttpUtil.apiLocalUrl + path,
        data: requestData,
      );
      if (result.data != null) {
        List<dynamic> data = result.data;
        List<String> styles = [];
        for (var element in data) {
          styles.add(element["model_name"]);
        }
        print("获取本地vae列表：" + styles.toString());
        return styles;
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return [];
  }

  Future<bool> sdPing({required String newUrl}) async {
    String path = "/sdapi/v1/memory";
    String errorMsg = "";
    Map<String, dynamic> requestData = {};
    try {
      var result = await HttpUtil.instance.client.get(
        newUrl + path,
        data: requestData,
      );
      if (result.data != null) {
        print("获取本地SD sdPing：" + result.data.toString());
        return true;
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return false;
  }

  Future<bool> sdPingBaidu(
      {required String key, required String tk, required String text}) async {
    String lanFrom = "zh";
    String lanTo = "en";
    int salt = Random().nextInt(10000);
    String md5String = '$key$text$salt$tk'; // Concatenate the values
    String sign = md5.convert(utf8.encode(md5String)).toString(); // MD5 hashing
    String url =
        'https://api.fanyi.baidu.com/api/trans/vip/translate?q=$text&from=$lanFrom&to=$lanTo&appid=$key&salt=$salt&sign=$sign';
    String errorMsg = "";
    Map<String, dynamic> requestData = {};
    try {
      var result = await HttpUtil.instance.client.get(
        url,
        data: requestData,
      );
      if (result.data != null) {
        Map<String, dynamic> data = result.data;
        if (data.containsKey("trans_result")) {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return false;
  }
}
