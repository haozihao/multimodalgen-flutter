import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';
import 'package:pieces_ai/app/model/ai_img.dart';
import 'package:pieces_ai/app/model/ai_story_task.dart';
import 'package:utils/utils.dart';

import '../../model/config/ai_analyse_role_scene.dart';
import '../ai_story_repository.dart';

const String getTaskInfo = '/ai/mini_story/task_info/v2';
const String imgGeneratePath = '/ai/ai_paint/img_generate';
const String imageHdPath = '/ai/ai_paint/hd';
const String aiPromptPath = '/ai/ai_paint/ai_prompt_single';
const String videoGeneratePath = '/ai/ai_video/video_generate';
const String getAllTaskPath = '/ai/mini_story/all_task';
const String sendTask = '/ai/mini_story/add_task/v2';
// const String xianDaiPrompt =
//     "'。Please play the role of a comic artist. Based on the given content, create a comic illustration and then describe the elements of the drawing from the perspective of composition: scene, "
//     "facial expression, gaze, action, and shot. Limit each description to 15 words or less. Choose a suitable shot from the following options:close-up,selfie,medium view,wide shot,panorama,"
//     "vertical view,bird's-eye view,front view,from_side,dutch angle,portrait,full_body,fisheye。The output format must strictly adhere to the JSON format："
//     '{"scene": "","face": "","eyes":"","action":"","shot": ""},All content should be outputted in English, except for this JSON. Do not output any other content.';
const String xianDaiPrompt =
    ".根据上述文本生成一幅电影画面,画面要人物相关,生动艺术,吸引观众注意.输出使用英文限15个单词以内";
const String promptTmp1_1 = "jMBot是一位有艺术气质的Ai助理，帮助人通过将自然语言转化为prompt。\n"
    "jMBot的行动规则如下:\n"
    "1.将输入的自然语言组合想象为一幅完整的画面，你需要根据描述自行随机添加合理的，不少于5处的画面细节;\n"
    "2.第一部分:用简短的英文描述画面的主体，如:A girl sitting in a classroom,输出这段英文:\n"
    "3.第二部分:用英文单词或者词组描述画面的所有主体元素,元素之间用\",\"隔开，如果有哪个元素比较重要，请给代表这个元素的英文词组增加小括号，最多可以增加三层小括号，如:1girl,((blackhair)),smiling,(windowsin background),sunshine,输出这段英文;\n"
    "4.jMBot会将以上生成的两部分文本用英文逗号连接，中间不包含任何换行符的prompt作为最终结果;\n"
    "5.jMBot输出时将直接输出prompt，而不包含任何说明和解释。\n"
    "接下来你将扮演jMBot，要处理的自然语言为:";

const String promptAction =
    "。根据上述文本推理出文本中提及的主要人物的动作和表情以及发生的场景，动作和表情和场景各用一个英文单词表示，每个单词之间用','连接，输出中不要换行";

// const String guDaiPrompt =
//     "'。Please play the role of a comic artist. Based on the given content, describing a story set in ancient times. create a comic illustration and then describe the elements "
//     "of the drawing from the perspective of composition: scene, facial expression, gaze, action, and shot. Limit each description to 15 words or less. Choose a suitable shot from the following "
//     "options:close-up,selfie,medium view,wide shot,panorama,vertical view,bird's-eye view,front view,from_side,dutch angle,portrait,full_body,fisheye。The output format must strictly adhere to the JSON format："
//     '{"scene": "","face": "","eyes":"","action":"","shot": ""},All content should be outputted in English, except for this JSON. Do not output any other content.';
const String guDaiPrompt =
    ".根据上述文本生成一幅电影画面,画面要和文本相关,生动艺术,吸引观众注意.输出使用英文限15个单词以内";

const String reviseArticlePrompt =
    "你接下来将扮演一个网络小说改写专家，我会给你一段小说文案，请对它进行改写。我提供的小说文案格式为一个分行一个句子。你需要理解全文之后进行改写，"
    "改写应遵循的要求如下：不改变原文的意思，结合上下文语境对小说内容进行同义转换改写，比如将高兴改写为开心，伤心改写为忧愁等，还可以改变句子的结构，"
    "比如将我的生活也将被这场末世浩劫彻底摧毁修改为这场末世浩劫彻底摧毁了我的生活。你不必局限于我给的示例，但请记住不要漏下原文中的某一句，"
    "未改写的内容也要返回。输出给我的小说字数要与原文字数相差不大，并且注意严格遵守我发你的分行格式，一定不要改变原文的行数。以下是原文：";

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

class HttpAiStoryRepository extends AiStoryRepository {
  @override
  Future<double> getTaskProgress({required String taskId}) async {
    String errorMsg = "";
    try {
      var result = await HttpUtil.instance.client.get(
        HttpUtil.apiBaseUrl + '/ai/mini_story/get_task_progress',
        queryParameters: {'task_id': taskId},
      );
      if (result.data != null && result.data['code'] == 200) {
        return result.data['data']['progress'];
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return 0;
  }

  @override
  Future<TweetScript?> getTaskResult({required String taskId}) async {
    String errorMsg = "";
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    param['spec'] = {'task_id': taskId};
    var result = await HttpUtil.instance.client
        .post(HttpUtil.apiBaseUrl + getTaskInfo, data: param);
    if (result.data != null) {
      if (result.data['code'] == 200) {
        Map<String, dynamic> map = result.data['data'];
        TweetScript tweetScript = TweetScript.fromJson(map);
        // const isPro = bool.fromEnvironment('dart.vm.product');
        logger.d("获取任务结果：" + tweetScript.toString());

        return tweetScript;
      } else {
        return null; // Handle the case where the API call was not successful
      }
    }
    return null;
  }

  @override
  AiPaintParamsV2 composePrompt(
      {required TweetImage tweetImage,
      required AiPaintParamsV2 aiPaintParamsV2original,
      required List<Role> roles,
      required bool lockedSeed,
      required Scene? scene,
      required int type}) {
    //获取所有的tag词
    String inputStr = "";
    for (var tag in tweetImage.userTags!) {
      // print("用户输入tag:" + tag.tagZh!);
      inputStr += tag.tagEn;
      inputStr += ",";
    }
    //看是否选择了角色
    AiPaintParamsV2 aiPaintParamsV2 = aiPaintParamsV2original.copyWith();
    String prompt = "";
    //2.2模型的一致性角色
    if (aiPaintParamsV2.modelClass == 3) {
      String name = '';
      List<TweetRole> tweetRoles = [];
      if (tweetImage.rolesId!.isNotEmpty) {
        for (int i = 0; i < tweetImage.rolesId!.length; i++) {
          int roleIndex = tweetImage.rolesId![i];
          if (roleIndex >= roles.length) {
            debugPrint("选择的角色超出范围，需要删除：" + roleIndex.toString());
            tweetImage.rolesId!.removeAt(i);
          } else {
            //把选中的人名组装
            var role = roles[roleIndex];
            name += '[';
            name += role.refName ?? "";
            name += ']';
            if (i < tweetImage.rolesId!.length - 1) name += ' and ';
            //选中了几个人，则这次就只传几个人的总roles
            var tweetRole = TweetRole(
                name: role.refName ?? "",
                negativePrompt: aiPaintParamsV2.negativePrompt ?? "",
                prompt: role.prompt ?? '',
                seed: role.seed ?? -1);
            tweetRoles.add(tweetRole);
          }
        }
      } else {
        //没选角色则是场景
        name = "[NC]";
      }
      //seed选第一个角色
      int seed = -1;
      if (lockedSeed) {
        //只取第一个角色seed
        if (tweetRoles.isNotEmpty) {
          seed = tweetRoles.first.seed;
        }
      }
      aiPaintParamsV2.roles = tweetRoles;
      var promptPre = '';
      if (tweetRoles.length > 1) {
        //先出单人再合照
        tweetRoles.forEach((tweetRole) {
          promptPre += "[${tweetRole.name}]\n";
        });
        aiPaintParamsV2.prompt = promptPre + '${name}$inputStr';
      } else {
        //提示词为选中的人物的名字+其他提示词
        aiPaintParamsV2.prompt = '${name}$inputStr';
        // aiPaintParamsV2.prompt = '${name}$inputStr'+'\n[xiaoli]$inputStr';
        //测试
        // aiPaintParamsV2.prompt = "[xiaoming]Nervous, Sweating, Mountains,\n[xiaoming]and[xiaoli]climbing, determined, mountainous,";
      }
      aiPaintParamsV2.seed = seed;
      // aiPaintParamsV2.styleName = "Japanese Anime"+aiPaintParamsV2.styleName;
      debugPrint(
          '2.2模型支持一致性角色:$name，prompt:${aiPaintParamsV2.prompt}，styleName:${aiPaintParamsV2.styleName}');
    } else {
      if (tweetImage.rolesId!.isNotEmpty) {
        if (tweetImage.rolesId!.length == 1) {
          int roleIndex = tweetImage.rolesId![0];
          if (roleIndex < roles.length) {
            Role role = roles[tweetImage.rolesId![0]];
            prompt += role.prompt ?? "";
            if (lockedSeed) {
              aiPaintParamsV2.seed = role.seed ?? -1;
            } else {
              aiPaintParamsV2.seed = -1;
            }
            debugPrint("角色有一个：" + prompt);
          } else {
            debugPrint("选择的角色超出范围只有一个：$roleIndex");
          }
        } else if (tweetImage.rolesId!.length > 1) {
          debugPrint("角色有多个：" + tweetImage.rolesId.toString());
          //遍历，获取两个可行的，超出得删除
          var uselessRoleIndexList = [];
          for (int i = 0; i < tweetImage.rolesId!.length; i++) {
            int roleIndex = tweetImage.rolesId![i];
            debugPrint("遍历所有的已选角色：$roleIndex");
            if (roleIndex >= roles.length) {
              debugPrint("选择的角色超出范围，需要删除：$roleIndex");
              tweetImage.rolesId!.removeAt(i);
            } else {
              uselessRoleIndexList.add(roleIndex);
            }
          }
          if (uselessRoleIndexList.isNotEmpty) {
            Role role1 = roles[uselessRoleIndexList[0]];
            if (lockedSeed) {
              aiPaintParamsV2.seed = role1.seed ?? -1;
            } else {
              aiPaintParamsV2.seed = -1;
            }
            if (uselessRoleIndexList.length > 1) {
              debugPrint("有两个以上的角色：${uselessRoleIndexList}");
              Role role2 = roles[tweetImage.rolesId![1]];
              prompt += "2people\\(";
              prompt += role1.prompt ?? "";
              prompt += " and ";
              prompt += role2.prompt ?? "";
              prompt += "\\)";
            } else {
              prompt += role1.prompt ?? "";
              debugPrint("还是只有一个角色：${uselessRoleIndexList}");
            }
          }
        }
      }

      if (scene != null && scene.prompt.isNotEmpty) {
        prompt += ' ';
        prompt += scene.prompt;
        prompt += "_background:1.2,";
      }
      if (inputStr.isNotEmpty) {
        prompt += " ";
        prompt += inputStr;
      }
      // aiPaintParamsV2.prompt = widget.tweetImage.enPrompt;
      RegExp regex = RegExp("%s");
      String newPrompt =
          aiPaintParamsV2.prompt.replaceFirstMapped(regex, (match) => prompt);
      prompt = newPrompt != aiPaintParamsV2.prompt
          ? newPrompt
          : aiPaintParamsV2.prompt + prompt;
      debugPrint(
          "绘画使用的提示词:" + prompt + "  seed:" + aiPaintParamsV2.seed.toString());
      aiPaintParamsV2.prompt = prompt;
    }
    return aiPaintParamsV2;
  }

  @override
  Future<AiImg> imgGenerate(
      {required BuildContext context,
      required AiPaintParamsV2 aiPaintParamsV2}) async {
    String errorMsg = "";
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    param['pegg'] = 10; //扣除1皮蛋
    param['detect'] = true; //扣除1皮蛋
    param['spec'] = aiPaintParamsV2.toJson();
    // debugPrint("生图参数" + aiPaintParamsV2.toJson().toString());
    // try {
    var result = await HttpUtil.instance.client.post(
      HttpUtil.apiBaseUrl + imgGeneratePath,
      data: param,
    );
    print("Ai生图结果：" + result.data.toString());
    if (result.data != null) {
      if (result.data['code'] == 200) {
        var aiImg = AiImg.fromJson(result.data['data']);
        return aiImg;
      } else {
        Toast.error(context, result.data["msg"].toString());
        return AiImg(
            images: [],
            allSeeds: []); // Handle the case where the API call was not successful
      }
    }
    // } catch (e) {
    //   errorMsg = e.toString();
    //   debugPrint(errorMsg);
    //   return AiImg(images: [], allSeeds: []);
    // }
    return AiImg(images: [], allSeeds: []);
  }

  @override
  Future<List<AiStoryTask>> getAllTask(
      {required String uid,
      required String pageSize,
      required String page}) async {
    // String errorMsg = "";
    // var result = await HttpUtil.instance.client.post(
    //   HttpUtil.apiBaseUrl + videoGeneratePath,
    //   data: {
    //     "channel": "TWEET_Windows",
    //     'channel_id': '7',
    //     'uid': '10030356',
    //   },
    // );
    // print("Ai生视频结果：" + result.data.toString());
    // if (result.data != null) {
    //   if (result.data['code'] == 200) {
    //     List<dynamic> images = result.data['data']['images'];
    //     return images[0]['url'];
    //   } else {
    //     return []; // Handle the case where the API call was not successful
    //   }
    // }
    return [];
  }

  @override
  Future<TaskResult<String>> addTask(
      {required TweetScript tweetScript,
      required int pegg,
      required int type}) async {
    String errorMsg = "";
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    param['pegg'] = pegg * 10; //扣除皮蛋数,vip1皮蛋一张图
    param['spec'] = tweetScript;
    // debugPrint("获取提交任务参数：" + jsonEncode(tweetScript));
    param['type'] = type;
    try {
      var result = await HttpUtil.instance.client.post(
        HttpUtil.apiBaseUrl + sendTask,
        data: param,
      );
      debugPrint("获取提交任务数据返回：" + result.data.toString());

      if (result.data != null) {
        debugPrint(result.data.toString());
        if (result.data['code'] == 200) {
          Map<String, dynamic> responseData = result.data['data'];
          debugPrint("拿到了结果" + responseData.toString());
          return TaskResult(success: true, data: responseData['task_id']);
        } else {
          return TaskResult(success: false, msg: result.data['msg']);
        }
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
      return TaskResult(success: false, msg: errorMsg);
    }
    return TaskResult(success: false, msg: "null");
  }

  Future<String> aiReviseArticle(
      {required String sentence, required int pegg}) async {
    return aiPrompt(sentence: sentence, shidai: 3, pegg: pegg);
  }


  @override
  Future<String> aiPrompt(
      {required String sentence,
      required int shidai,
      int? pegg,
      int? gptType,
      String? template = "default",
      String? imageUrl}) async {
    String errorMsg = "";
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    if (pegg == null)
      param['pegg'] = 10; //扣除1皮蛋
    else
      param['pegg'] = pegg * 10;
    if (pegg != null) param['pegg'] = pegg * 10;
    logger.d("推理提示词模板：$shidai");
    if (shidai == 1) {
      param['spec'] = {
        'prompt': promptTmp1_1 + sentence,
        'temperature': 0.8,
        'type': 4
      };
    } else if (shidai == 2) {
      param['spec'] = {
        'prompt': promptTmp1_1 + sentence,
        'temperature': 0.8,
        'type': 4
      };
    } else if (shidai == 3) {
      //文案改写
      param['spec'] = {
        'prompt': reviseArticlePrompt + sentence,
        'temperature': 0.8,
        'type': 4
      };
    } else if (shidai == 4) {
      //自定义生成脚本提示词模板。完全自定义
      if (gptType != null) {
        param['spec'] = {
          'prompt': sentence,
          'temperature': 0.8,
          'type': 4,
          'gpt_type': gptType,
          'template': template,
          'image_url': imageUrl
        };
      } else {
        param['spec'] = {
          'prompt': sentence,
          'temperature': 0.8,
          'type': 4,
          'template': template,
          'image_url': imageUrl
        };
      }
    } else if (shidai == 5) {
      param['spec'] = {
        'prompt': promptAction + sentence,
        'temperature': 0.8,
        'type': 4
      };
    } else {
      return "不支持的提示词类型!";
    }

    // debugPrint("推理提示词模板：" + param.toString());
    try {
      var result = await HttpUtil.instance.client
          .post(HttpUtil.apiBaseUrl + aiPromptPath, data: param);
      if (result.data != null) {
        if (result.data['code'] == 200) {
          Map<String, dynamic> promptsAll = result.data['data']['prompt'];
          String promptEnStr = promptsAll['en'];
          String newText;
          // if (shidai == 1 || shidai == 3) {
          newText = promptEnStr;
          // } else {
          //   Map<String, dynamic> prompts = jsonDecode(promptEnStr);
          //   List<String> promptValues = [];
          //   prompts.forEach((key, value) {
          //     promptValues.add(value);
          //   });
          //
          //   String promptEn = promptValues.join(",");
          //   newText = promptEn.replaceAll(RegExp(r'\n'), ' ');
          // }

          // print("Ai提示词结果：" + newText);
          // String promptEn = prompts['scene']+","+prompts['face']+","+prompts['eyes']+","+prompts['action']+","+prompts['shot'];
          // String newText = promptEn.replaceAll(RegExp(r'\n'), ' ');
          return newText;
        } else {
          return ''; // Handle the case where the API call was not successful
        }
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
      return '';
    }
    return '';
  }

  @override
  Future<String> textTrans(
      {required String text,
      required String langTo,
      required String langFrom}) async {
    String lanFrom = langFrom;
    String lanTo = langTo;
    int salt = Random().nextInt(10000);
    String key = HttpUtil.baiduKey;
    String tk = HttpUtil.baiduTk;
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
          return data['trans_result'][0]['dst'];
        } else {
          return text;
        }
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return text;
  }
}
