import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pieces_ai/app/api_https/ai_config_repository.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_story_fastsd.dart';
import 'package:pieces_ai/app/model/ai_style_model.dart';
import 'package:pieces_ai/app/model/config/ai_analyse_role_scene.dart';
import 'package:pieces_ai/app/model/config/ai_prompt_words.dart';
import 'package:pieces_ai/app/model/config/ai_roles_official.dart';
import 'package:pieces_ai/app/model/config/ai_tts_style.dart';
import 'package:utils/utils.dart';

import '../../../widget_ui/desk_ui/widget_detail/widget_ai_chose/ai_input_content.dart';
import 'https_ai_story_localsd.dart';

const String getAllStyles = '/data/ai_paint/models/v2';
const String getAllAiPromptWords = '/data/ai_paint/prompt/list';
const String getTtsStyles = '/audio/tts/channel/list';
const String getAiRoles = '/ai/ai_role_prompt/list';
const String aiAnalyseRolePath = '/ai/ai_drama//characters';
const String translateApi = '/translate/to';
const String participial = '/sentence/participial';
const String uploadFile = '/user/file/upload';

var logger = Logger(printer: PrettyPrinter(methodCount: 1));

class HttpAiConfigRepository extends AiConfigRepository {
  @override
  Future<List<AiStyleModel>> loadStyleWidgets() async {
    String errorMsg = "";
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    param['mateType'] = 1;
    try {
      var result = await HttpUtil.instance.client.post(
        HttpUtil.apiBaseUrl + getAllStyles,
        data: param,
      );
      logger.d("获取风格数据返回：" + result.data.toString());
      if (result.data != null) {
        if (result.data['code'] == 200) {
          // 获取风格数据
          List<dynamic> styleModels = result.data['data'];
          List<AiStyleModel> aiStyleModelList = [];
          for (var styleStr in styleModels) {
            AiStyleModel aiStyleModel = AiStyleModel.fromJson(styleStr);
            aiStyleModelList.add(aiStyleModel);
          }
          if (HttpUtil.apiLocalUrl.isNotEmpty) {
            //再去获取本地风格分类
            AiStyleModel aiStyleModelLocal = await getLocalStyles();
            aiStyleModelList.add(aiStyleModelLocal);
          }
          if (HttpUtil.apiFastUrl.isNotEmpty) {
            //获取FastSd
            AiStyleModel aiStyleModelFast = await getFastSdStyles();
            aiStyleModelList.add(aiStyleModelFast);
          }

          logger.d("拿到了风格分类" + aiStyleModelList.length.toString());
          return aiStyleModelList;
        } else {
          return []; // Handle the case where the API call was not successful
        }
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return [];
  }

  Future<List<PromptWord>> loadAiPromptsWords() async {
    String errorMsg = "";
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    try {
      var result = await HttpUtil.instance.client.post(
        HttpUtil.apiBaseUrl + getAllAiPromptWords,
        data: param,
      );
      // print("获取风格数据返回：" + result.data.toString());
      if (result.data != null) {
        if (result.data['code'] == 200) {
          // 获取风格数据
          List<dynamic> promptWords = result.data['data'];
          List<PromptWord> promptWordsList = [];

          for (var promptWordsStr in promptWords) {
            PromptWord promptWord = PromptWord.fromJson(promptWordsStr);
            promptWordsList.add(promptWord);
          }
          print("获取到所有提示词" + promptWordsList.length.toString());
          return promptWordsList;
        } else {
          return []; // Handle the case where the API call was not successful
        }
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return [];
  }

  //获取皮皮风格
  Future<List<AiStyleModel>> loadStylePp() async {
    String errorMsg = "";
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    param['mateType'] = 1;
    try {
      var result = await HttpUtil.instance.client.post(
        HttpUtil.apiBaseUrl + getAllStyles,
        data: param,
      );
      // print("获取风格数据返回：" + result.data.toString());
      if (result.data != null) {
        if (result.data['code'] == 200) {
          // 获取风格数据
          List<dynamic> styleModels = result.data['data'];
          List<AiStyleModel> aiStyleModelList = [];

          for (var styleStr in styleModels) {
            AiStyleModel aiStyleModel = AiStyleModel.fromJson(styleStr);
            aiStyleModelList.add(aiStyleModel);
          }
          print("拿到了风格分类" + aiStyleModelList.length.toString());
          return aiStyleModelList;
        } else {
          return []; // Handle the case where the API call was not successful
        }
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return [];
  }

  /// 获取FastSd当前已挂载模型
  Future<List<String>> getFastSdMounted() async {
    HttpAiStoryFastSd httpAiStoryFastSd = HttpAiStoryFastSd();
    List<String> fastStyles = await httpAiStoryFastSd.getMountedModel();
    return fastStyles;
  }

  /// 获取FastSd风格
  Future<AiStyleModel> getFastSdStyles() async {
    HttpAiStoryFastSd httpAiStoryFastSd = HttpAiStoryFastSd();
    List<String> fastStyles = await httpAiStoryFastSd.getFastStyles();
    List<Child> children = [];
    String presetInfo =
        "{\"lora\":\"\",\"negative_prompt\":\"bad-hands-5,easynegative,(worst quality, low quality:1.4), monochrome, \",\"sampling\":\"DPM++ 2M Karras\",\"hd\":{},\"steps\":25,\"prompt\":\"(masterpiece),(highest quality),highres,\",\"cfg_scale\":8,\"style_name\":\"\",\"model_class\":1}";
    for (var fastStyle in fastStyles) {
      Child child = Child(
          icon:
              "https://imgs.pencil-stub.com/data/cms/2024-01-28/722f0c86710c4282a61255b1ddaba3cf.jpg",
          id: -100,
          modelFileName: fastStyle,
          name: fastStyle,
          presetInfo: presetInfo,
          type: 1);
      children.add(child);
    }
    AiStyleModel aiStyleModelLocal =
        AiStyleModel(children: children, id: -100, name: "FastSD");
    return aiStyleModelLocal;
  }

  //挂载模型
  Future<bool> FastSdMounteModel(model) async {
    HttpAiStoryFastSd httpAiStoryFastSd = HttpAiStoryFastSd();
    bool fastStyles = await httpAiStoryFastSd.fastMounteModel(model);
    return fastStyles;
  }

  //卸载模型
  Future<bool> FastSdUnMounteModel(model) async {
    HttpAiStoryFastSd httpAiStoryFastSd = HttpAiStoryFastSd();
    bool fastStyles = await httpAiStoryFastSd.fastUnMounteModel(model);
    return fastStyles;
  }

  /// 获取本地风格，SD配置是先写死的
  Future<AiStyleModel> getLocalStyles() async {
    HttpAiStoryLocalSd httpAiStoryLocalSd = HttpAiStoryLocalSd();
    List<String> localStyles = await httpAiStoryLocalSd.getLocalStyles();
    List<Child> children = [];
    String presetInfo =
        "{\"lora\":\"\",\"negative_prompt\":\"unaestheticXL_Sky3.1,watercolor, oil painting, photo, deformed, realism, disfigured, lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry\",\"sampling\":\"DPM++ 2M Karras\",\"hd\":{},\"steps\":25,\"prompt\":\"(masterpiece),(highest quality),highres,\",\"cfg_scale\":8,\"style_name\":\"\",\"model_class\":1}";
    for (var localStyle in localStyles) {
      Child child = Child(
          icon:
              "https://imgs.pencil-stub.com/data/cms/2024-01-28/722f0c86710c4282a61255b1ddaba3cf.jpg",
          id: -123,
          modelFileName: localStyle,
          name: localStyle,
          presetInfo: presetInfo,
          type: 1);
      children.add(child);
    }
    AiStyleModel aiStyleModelLocal =
        AiStyleModel(children: children, id: -123, name: "本地SD");
    return aiStyleModelLocal;
  }

  @override
  Future<List<AiTtsStyle>> loadTtsStyles() async {
    String errorMsg = "";
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    param['spec'] = {'channel': 1};
    try {
      var result = await HttpUtil.instance.client.post(
        HttpUtil.apiBaseUrl + getTtsStyles,
        data: param,
      );
      // print("获取风格数据返回：" + result.data.toString());
      if (result.data != null) {
        if (result.data['code'] == 200) {
          // 获取风格数据
          List<dynamic> ttsStyles = result.data['data'];
          List<AiTtsStyle> aiTtsStyleList = [];

          for (var aiTtsStr in ttsStyles) {
            AiTtsStyle aiTtsStyle = AiTtsStyle.fromJson(aiTtsStr);
            aiTtsStyleList.add(aiTtsStyle);
          }
          print("拿到了TTS分类" + aiTtsStyleList.length.toString());
          return aiTtsStyleList;
        } else {
          return []; // Handle the case where the API call was not successful
        }
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return [];
  }

  @override
  Future<List<AiRoles>> loadAiRolesOfficial(
      {required int styleId, required int ratio}) async {
    String errorMsg = "";
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    param['spec'] = {'style_id': styleId, 'ratio_type': ratio};
    var result = await HttpUtil.instance.client.post(
      HttpUtil.apiBaseUrl + getAiRoles,
      data: param,
    );
    // print("获取官方人物数据返回：" + result.data.toString());
    if (result.data != null) {
      if (result.data['code'] == 200) {
        // 获取风格数据
        List<dynamic> aiRolesOfficialStr = result.data['data'];
        List<AiRoles> aiRolesOfficial = [];

        for (var aiRoleStr in aiRolesOfficialStr) {
          AiRoles aiRoles = AiRoles.fromJson(aiRoleStr);
          aiRolesOfficial.add(aiRoles);
          // print("拿到了AiRole" + jsonEncode(aiRoles));
        }

        return aiRolesOfficial;
      } else {
        return []; // Handle the case where the API call was not successful
      }
    }
    return [];
  }

  @override
  Future<RolesAndScenes> aiAnalyseRolesAndScenes(
      {required String prompt}) async {
    String errorMsg = "";
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    param['prompt'] = prompt;
    try {
      var result = await HttpUtil.instance.client.post(
        HttpUtil.apiBaseUrl + aiAnalyseRolePath,
        data: param,
      );
      if (result.data != null) {
        if (result.data['code'] == 200) {
          // 获取风格数据
          print("Ai识别角色和场景结果" + result.data['data'].toString());
          return RolesAndScenes.fromJson(result.data['data']);
        } else {
          return RolesAndScenes(roles: [], scenes: []);
        }
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return RolesAndScenes(roles: [], scenes: []);
  }

  @override
  Future<String> translate(
      {required String content, required String lanTo}) async {
    String errorMsg = "";
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    param['spec'] = {'fromContent': content, 'lanTo': lanTo};
    try {
      var result = await HttpUtil.instance.client.post(
        HttpUtil.apiBaseUrl + translateApi,
        data: param,
      );
      if (result.data != null) {
        if (result.data['code'] == 200) {
          // 获取风格数据
          logger.d("翻译接口返回结果" + result.data['data'].toString());
          return result.data['data']['content'];
        } else {
          return '';
        }
      }
    } catch (e) {
      errorMsg = e.toString();
      logger.e(errorMsg);
    }
    return '';
  }

  ///分句接口
  Future<List<SrtModel>> loadSentence(String sentence) async {
    var result = await HttpUtil.instance.client.post(
      'https://file.pencil-stub.com' + participial,
      data: {
        'spec': {'content': sentence}
      },
    );
    // print("获取分句数据返回：" + result.data.toString());

    if (result.data != null) {
      if (result.data['code'] == 200) {
        // Assuming 'data' is a list of categories and each category has a 'children' list
        //大类别
        List<dynamic> sentenceList = result.data['data'];
        List<SrtModel> sentences = [];
        for (var sentence in sentenceList) {
          sentences.add(SrtModel(start: 0, end: 0, sentence: sentence));
        }
        return sentences;
      } else {
        return []; // Handle the case where the API call was not successful
      }
    }
    return [];
  }

  Future<String> fileUpload(
      {required String filePath, String? specFolder, String? format}) async {
    // Map<String, dynamic> baseParam = await HttpUtil.withBaseParam();
    // FormData formData = FormData.fromMap(baseParam);
    // // 添加文件参数
    // formData.files.add(MapEntry(
    //     "file",
    //     await MultipartFile.fromFile(filePath, contentType: MediaType('application', 'octet-stream'))
    // ));
    print("上传的文件:" +
        filePath +
        " 地址:" +
        'https://file.pencil-stub.com' +
        uploadFile);
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath),
      "content_type": 2,
      "format": format == null ? "mp3" : format,
      "biz": specFolder == null
          ? "tweet_web/copyHot"
          : "tweet_web/copyHot/" + specFolder
    });

    var result = await HttpUtil.instance.client.post(
      'https://file.pencil-stub.com' + uploadFile,
      data: formData,
      onSendProgress: (int sent, int total) {
        print('$sent $total');
      },
    );
    // print("上传文件返回：" + result.data.toString());
    if (result.data != null) {
      if (result.data['code'] == 200) {
        String url = result.data['data']['img'];
        return url;
      } else {
        return ""; // Handle the case where the API call was not successful
      }
    }
    return "";
  }
}
