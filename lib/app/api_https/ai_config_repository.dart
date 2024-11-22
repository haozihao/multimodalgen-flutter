

import 'package:pieces_ai/app/model/config/ai_analyse_role_scene.dart';
import 'package:pieces_ai/app/model/config/ai_roles_official.dart';
import 'package:pieces_ai/app/model/config/ai_tts_style.dart';

import '../model/ai_style_model.dart';

abstract class AiConfigRepository {

  // 获取Ai模型风格列表数据
  Future<List<AiStyleModel>> loadStyleWidgets();

  // 获取Ai音色TTS列表数据
  Future<List<AiTtsStyle>> loadTtsStyles();

  // 获取Ai角色数据
  Future<List<AiRoles>> loadAiRolesOfficial({required int styleId,required int ratio});

  // AiS识别文案的场景和角色
  Future<RolesAndScenes> aiAnalyseRolesAndScenes({required String prompt});

  //翻译接口
  Future<String> translate({required String content,required String lanTo});
}
