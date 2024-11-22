import 'dart:convert';
import 'dart:io';
import 'dart:math';

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

class HttpAiStoryFastSd extends HttpAiStoryRepository {
  @override
  Future<aiImg.AiImg> imgGenerate(
      {required BuildContext context,
      required AiPaintParamsV2 aiPaintParamsV2}) async {
    String errorMsg = "";

    Map<String, dynamic> requestData = {};
    Map<String, dynamic> data = {};
    Map<String, dynamic> jsonObjectOverSetting = {};
    jsonObjectOverSetting["sd_model_checkpoint"] = aiPaintParamsV2.styleName;
    // jsonObjectOverSetting["sd_vae"] = 'vae-ft-mse-840000-ema-pruned.safetensors';
    jsonObjectOverSetting["sd_vae"] = 'auto';
    jsonObjectOverSetting["CLIP_stop_at_last_layers"] = 2;
    jsonObjectOverSetting["samples_format"] = "jpg";

    // requestData["steps"] = aiPaintParamsV2.steps;
    data["steps"] = 20;
    switch (aiPaintParamsV2.ratio) {
      case 1:
        data["width"] = 600;
        data["height"] = 450;
        break;
      case 2:
        data["width"] = 800;
        data["height"] = 450;
        break;
      case 3:
        data["width"] = 450;
        data["height"] = 800;
        break;
      case 4:
        data["width"] = 450;
        data["height"] = 600;
        break;
      case 5:
        data["width"] = 400;
        data["height"] = 600;
        break;
      case 6:
        data["width"] = 600;
        data["height"] = 400;
        break;
    }

    data["prompt"] = aiPaintParamsV2.prompt;
    data["negative_prompt"] = aiPaintParamsV2.negativePrompt;
    if (aiPaintParamsV2.seed == -1) {
      var random = Random();
      data["seed"] = random.nextInt(90000000) + 10000000;
    } else {
      data["seed"] = aiPaintParamsV2.seed;
    }
    data["guidance_scale"] = aiPaintParamsV2.cfgScale; //CFG

    data["batch_size"] = aiPaintParamsV2.batchSize; //出图数量
    data["batch_count"] = 1;
    data["scheduler"] = 9; //采样方法，必须
    data["sigmas"] = "automatic"; //未知参数，必须
    String path = "/api/generate/txt2img";
    if (aiPaintParamsV2.image != null &&
        aiPaintParamsV2.image!.startsWith("data:image/")) {
      path = "/api/generate/img2img";
      data["image"] = aiPaintParamsV2.image;
      print("重绘幅度" + requestData["denoising_strength"].toString());
      requestData["enable_hr"] = false;
      Map<String, dynamic> flags = {};
      Map<String, dynamic> highres_fix = {};
      highres_fix["mode"] = "latent";
      highres_fix["image_upscaler"] = "RealESRGAN_x4plus_anime_6B";
      highres_fix["scale"] = aiPaintParamsV2.hd.scale;
      highres_fix["latent_scale_mode"] = "bislerp";
      highres_fix["strength"] = "0.3";
      highres_fix["steps"] = aiPaintParamsV2.hd.step;
      flags["highres_fix"] = highres_fix;
      requestData["flags"] = flags;
    } else {
      //放大高清
      if (aiPaintParamsV2.hd.scale != null) {
        Map<String, dynamic> flags = {};
        Map<String, dynamic> highres_fix = {};
        highres_fix["mode"] = "image";
        highres_fix["image_upscaler"] = "RealESRGAN_x4plus_anime_6B";
        highres_fix["scale"] = aiPaintParamsV2.hd.scale;
        highres_fix["latent_scale_mode"] = "bislerp";
        highres_fix["strength"] = "0.3";
        highres_fix["steps"] = aiPaintParamsV2.hd.step;
        flags["highres_fix"] = highres_fix;
        requestData["flags"] = flags;
      }
    }

    requestData["data"] = data;
    requestData["model"] = aiPaintParamsV2.styleName;

    print("批量生图参数" + requestData.toString());

    try {
      HttpUtil.instance.client.options = BaseOptions(
          connectTimeout: Duration(seconds: 180),
          sendTimeout: Duration(seconds: 180),
          receiveTimeout: Duration(seconds: 180));
      var result = await HttpUtil.instance.client.post(
        HttpUtil.apiFastUrl + path,
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
            base64data.toString().substring(23),
            imagesDir + fileSeprate + imageName);
        List<aiImg.Image> imageList = [];
        aiImg.Image image = aiImg.Image(pass: true, url: path);
        imageList.add(image);
        var img = aiImg.AiImg(images: imageList, allSeeds: [data["seed"].toDouble()]);
        return img;
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return aiImg.AiImg(images: [], allSeeds: []);
  }

  //生图请求
  Future<aiImg.AiImg> imgGenerateSenior(
      {required AiPaintParamsV2 aiPaintParamsV2,
      required String draftName,
      required bool hd}) async {
    String errorMsg = "";

    Map<String, dynamic> requestData = {};
    Map<String, dynamic> data = {};
    Map<String, dynamic> jsonObjectOverSetting = {};
    jsonObjectOverSetting["sd_model_checkpoint"] = aiPaintParamsV2.styleName;
    // jsonObjectOverSetting["sd_vae"] = 'vae-ft-mse-840000-ema-pruned.safetensors';
    jsonObjectOverSetting["sd_vae"] = 'auto';
    jsonObjectOverSetting["CLIP_stop_at_last_layers"] = 2;
    jsonObjectOverSetting["samples_format"] = "jpg";

    // requestData["steps"] = aiPaintParamsV2.steps;
    data["steps"] = 20;
    switch (aiPaintParamsV2.ratio) {
      case 1:
        data["width"] = 600;
        data["height"] = 450;
        break;
      case 2:
        data["width"] = 800;
        data["height"] = 450;
        break;
      case 3:
        data["width"] = 450;
        data["height"] = 800;
        break;
      case 4:
        data["width"] = 450;
        data["height"] = 600;
        break;
      case 5:
        data["width"] = 400;
        data["height"] = 600;
        break;
      case 6:
        data["width"] = 600;
        data["height"] = 400;
        break;
    }

    data["prompt"] = aiPaintParamsV2.prompt;
    data["negative_prompt"] = aiPaintParamsV2.negativePrompt;
    if (aiPaintParamsV2.seed == -1) {
      var random = Random();
      data["seed"] = random.nextInt(90000000) + 10000000;
    } else {
      data["seed"] = aiPaintParamsV2.seed;
    }
    // data["seed"] = "648123936806";
    data["guidance_scale"] = aiPaintParamsV2.cfgScale; //CFG

    data["batch_size"] = 1; //出图数量
    data["batch_count"] = aiPaintParamsV2.batchSize;
    data["scheduler"] = 9; //采样方法，必须
    data["sigmas"] = "automatic"; //未知参数，必须

    // data["prompt_to_prompt_settings"] = {
    //   "prompt_to_prompt_model": "lllyasviel/Fooocus-Expansion",
    //   "prompt_to_prompt_model_settings": "gpu",
    //   "prompt_to_prompt": "false",
    // };
    // requestData["backend"] = "PyTorch";
    // requestData["autoload"] = false;
    // requestData["sampler_name"] = aiPaintParamsV2.sampling;

    // if (alwaysonScripts != null) {
    //   requestData["alwayson_scripts"] = alwaysonScripts;
    // }
    String path = "/api/generate/txt2img";
    if (aiPaintParamsV2.image != null &&
        aiPaintParamsV2.image!.startsWith("data:image/")) {
      path = "/api/generate/img2img";
      data["image"] = aiPaintParamsV2.image;
      print("重绘幅度" + requestData["denoising_strength"].toString());
      requestData["enable_hr"] = false;
      Map<String, dynamic> flags = {};
      Map<String, dynamic> highres_fix = {};
      highres_fix["mode"] = "latent";
      highres_fix["image_upscaler"] = "RealESRGAN_x4plus_anime_6B";
      highres_fix["scale"] = aiPaintParamsV2.hd.scale;
      highres_fix["latent_scale_mode"] = "bislerp";
      highres_fix["strength"] = "0.3";
      highres_fix["steps"] = aiPaintParamsV2.hd.step;
      flags["highres_fix"] = highres_fix;
      requestData["flags"] = flags;
    } else {
      //放大高清
      if (aiPaintParamsV2.hd.scale != null) {
        Map<String, dynamic> flags = {};
        Map<String, dynamic> highres_fix = {};
        highres_fix["mode"] = "image";
        highres_fix["image_upscaler"] = "RealESRGAN_x4plus_anime_6B";
        highres_fix["scale"] = aiPaintParamsV2.hd.scale;
        highres_fix["latent_scale_mode"] = "bislerp";
        highres_fix["strength"] = "0.3";
        highres_fix["steps"] = aiPaintParamsV2.hd.step;
        flags["highres_fix"] = highres_fix;
        if (hd) {
          //高清放大
          Map<String, dynamic> upscale = {};
          upscale["model"] = "RealESRGAN_x4plus_anime_6B";
          upscale["tile_padding"] = 10;
          upscale["tile_size"] = 128;
          upscale["upscale_factor"] = 2;
          flags["upscale"] = upscale;
        }
        requestData["flags"] = flags;
      }
    }

    requestData["data"] = data;
    requestData["model"] = aiPaintParamsV2.styleName;
    print("单张生图参数" + requestData.toString());
    //上面参数拼接没问题，将上述的参数放到apifox发送，可以正常生图，但是使用下面的post请求，在fastSd中会出现500错误
    try {
      var result = await HttpUtil.instance.client.post(
        HttpUtil.apiFastUrl + path,
        data: requestData,
      );
      // print("Ai生图结果：" + result.data.toString());
      if (result.data != null) {
        List<dynamic> images = result.data['images'];
        //解析成图片保存到本地，并返回本地路径
        String draftPath =
            await FileUtil.getPieceAiDraftFolderByTaskId(draftName.trim());
        String sdImagePath = draftPath +
            FileUtil.getFileSeparate() +
            "fast_sd_image" +
            FileUtil.getFileSeparate();
        if (!Directory(sdImagePath).existsSync()) {
          Directory(sdImagePath).createSync(recursive: true);
        }
        List<aiImg.Image> imageList = [];
        await Future.forEach(images, (element) async {
          String imageName =
              DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
          element = element.toString().substring(23);
          String path =
              await saveBase64ImageToFile(element, sdImagePath + imageName);
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

  //获取本地FastSd的所有支持的大模型风格
  Future<List<String>> getFastStyles() async {
    String path = "/api/models/available";
    String errorMsg = "";
    Map<String, dynamic> requestData = {};
    print("获取Fast模型列表HttpUtil.apiFastUrl：" + HttpUtil.apiFastUrl);
    try {
      var result = await HttpUtil.instance.client.get(
        HttpUtil.apiFastUrl + path,
        data: requestData,
      );
      if (result.data != null) {
        List<dynamic> data = result.data;
        List<String> styles = [];
        for (var element in data) {
          if (element["backend"] == "PyTorch" && element["valid"] == true) {
            styles.add(element["path"]);
          }
        }
        print("获取本地FastSd模型列表：" + styles.toString());
        return styles;
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return [];
  }

  //获取本地FastSd当前挂载的模型
  Future<List<String>> getMountedModel() async {
    String path = "/api/models/loaded";

    String errorMsg = "";
    print("获取当前挂载模型HttpUtil.apiFastUrl：" + HttpUtil.apiFastUrl);
    try {
      var result =
          await HttpUtil.instance.client.get(HttpUtil.apiFastUrl + path);
      List<String> styles = [];

      if (result.data.length > 0) {
        List<dynamic> data = result.data;
        for (var element in data) {
          styles.add(element["path"]);
        }
      }
      print("获取当前挂载模型列表：" + styles.toString());
      return styles;
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return [];
  }

  //测试联通性
  Future<bool> fastPing({required String newUrl}) async {
    String path = "/api/test/alive";
    String errorMsg = "";
    Map<String, dynamic> requestData = {};
    try {
      var result = await HttpUtil.instance.client.get(
        newUrl + path,
        data: requestData,
      );
      if (result.data != null) {
        print("获取本地FastSd sdPing：" + result.data.toString());
        return true;
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return false;
  }

  //挂载模型
  Future<bool> fastMounteModel(String model) async {
    String path = "/api/models/load";
    String errorMsg = "";

    try {
      var result = await HttpUtil.instance.client.post(
        HttpUtil.apiFastUrl +
            path +
            '?' +
            'model=' +
            model +
            '&backend=PyTorch&type=SD2.x',
      );
      if (result.data != null) {
        debugPrint("FastSd 挂载模型：" + result.data.toString());
        return true;
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return false;
  }

  //卸载模型
  Future<bool> fastUnMounteModel(String model) async {
    String path = "/api/models/unload";
    String errorMsg = "";
    try {
      var result = await HttpUtil.instance.client
          .post(HttpUtil.apiFastUrl + path + '?' + 'model=' + model);
      if (result.data != null) {
        debugPrint("卸载FastSd模型：$result.data   model:$model");
        return true;
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return false;
  }
}
