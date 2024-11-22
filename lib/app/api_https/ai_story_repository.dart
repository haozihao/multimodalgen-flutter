import 'package:flutter/material.dart';
import 'package:pieces_ai/app/model/ai_img.dart';
import 'package:pieces_ai/app/model/ai_story_task.dart';
import 'package:utils/utils.dart';

import '../model/TweetScript.dart';
import '../model/config/ai_analyse_role_scene.dart';

abstract class AiStoryRepository {
  // 提交一个短剧人物
  Future<TaskResult<String>> addTask(
      {required TweetScript tweetScript, required int pegg, required int type});

  // 获取Ai短剧任务进度
  Future<double> getTaskProgress({
    required String taskId,
  });

  //获取Ai短剧结果剧本数据
  Future<TweetScript?> getTaskResult({
    required String taskId,
  });

  ///组装生图提示词
  AiPaintParamsV2 composePrompt(
      {required TweetImage tweetImage,
      required AiPaintParamsV2 aiPaintParamsV2original,
      required List<Role> roles,
      required bool lockedSeed,
      required Scene? scene,
      required int type});

  // 获取Ai短剧任务进度
  Future<List<AiStoryTask>> getAllTask({
    required String uid,
    required String pageSize,
    required String page,
  });

  //Ai生图
  Future<AiImg> imgGenerate({
    required BuildContext context,
    required AiPaintParamsV2 aiPaintParamsV2,
  });

  //Ai根据文案推理提示词
  Future<String> aiPrompt({required String sentence, required int shidai});

  Future<String> textTrans(
      {required String text, required String langTo, required String langFrom});
}
