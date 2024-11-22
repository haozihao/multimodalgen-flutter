import 'package:json_annotation/json_annotation.dart';
import 'package:pieces_ai/app/model/config/ai_analyse_role_scene.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/widget_ai_chose/ai_input_content.dart';

import 'ai_image2_expression.dart';
import 'ai_image2_video.dart';

part 'TweetScript.g.dart';

///TweetScript
@JsonSerializable(includeIfNull: false)
class TweetScript {
  ///当前剧本的全局Ai绘画配置参数
  @JsonKey(name: "ai_paint")
  AiPaintParamsV2 aiPaint;

  ///是否需要服务器根据原文推理提示词。默认为false，
  @JsonKey(name: "ai_prompt")
  bool? aiPrompt;

  ///封面图url
  @JsonKey(name: "icon")
  String icon;

  ///当前剧本的可用角色列表
  @JsonKey(name: "roles")
  List<TweetRole> roles;

  ///当前剧本的可用场景列表
  @JsonKey(name: "scene_list")
  List<TweetPrompt> sceneList;

  ///短剧场景配置
  @JsonKey(name: "scenes")
  List<TweetScene> scenes;

  ///是否显示字幕，默认为true
  @JsonKey(name: "show_text")
  bool? showText;

  ///短剧任务id
  @JsonKey(name: "task_id")
  String? taskId;

  ///标题
  @JsonKey(name: "title")
  String title;

  ///当前剧本的全局TTS配置参数
  @JsonKey(name: "tts")
  TweetScriptTts tts;

  ///bgm资源
  @JsonKey(name: "bgm")
  Bgm? bgm;

  ///是否鉴黄，默认为true
  @JsonKey(name: "detection")
  bool? detection;

  ///是否需要服务器生成TTS资源，默认为false，当为true时，scenes下面的imgs结构中每句话会返回TTS资源
  @JsonKey(name: "tts_enable")
  bool? ttsEnable;

  ///追爆款任务是否使用图生图
  @JsonKey(name: "use_origin")
  bool? useOrigin;

  TweetScript({
    required this.aiPaint,
    this.aiPrompt,
    required this.icon,
    this.detection,
    required this.roles,
    required this.sceneList,
    required this.scenes,
    this.showText,
    required this.taskId,
    required this.title,
    required this.tts,
    this.ttsEnable,
    this.bgm,
    required this.useOrigin,
  });

  TweetScript copyWith({
    AiPaintParamsV2? aiPaint,
    bool? aiPrompt,
    String? icon,
    bool? detection,
    List<TweetRole>? roles,
    List<TweetPrompt>? sceneList,
    List<TweetScene>? scenes,
    bool? showText,
    String? taskId,
    String? title,
    Bgm? bgm,
    TweetScriptTts? tts,
    bool? ttsEnable,
    bool? useOrigin,
  }) =>
      TweetScript(
        aiPaint: aiPaint ?? this.aiPaint,
        aiPrompt: aiPrompt ?? this.aiPrompt,
        bgm: bgm ?? this.bgm,
        detection: detection ?? this.detection,
        icon: icon ?? this.icon,
        roles: roles ?? this.roles,
        sceneList: sceneList ?? this.sceneList,
        scenes: scenes ?? this.scenes,
        showText: showText ?? this.showText,
        taskId: taskId ?? this.taskId,
        title: title ?? this.title,
        tts: tts ?? this.tts,
        ttsEnable: ttsEnable ?? this.ttsEnable,
        useOrigin: useOrigin ?? this.useOrigin,
      );

  factory TweetScript.fromJson(Map<String, dynamic> json) =>
      _$TweetScriptFromJson(json);

  Map<String, dynamic> toJson() => _$TweetScriptToJson(this);

  ///生成一个图集任务数据
  ///type 默认 =0 为普通生视频，type=1 为生成表情
  static TweetScript generateImage2VideoData(
      int ratio, int batchSize, Image2VideoParam image2videoParam, int type,String? expression) {
    //构建Ai短剧任务数据
    final Hd hd = Hd(scale: 2, modelType: 1, step: 30, strength: 0.65);
    //Ai绘画相关参数
    final AiPaintParamsV2 aiPaintParamsV2 = AiPaintParamsV2(
        batchSize: 1,
        cfgScale: 7,
        detection: true,
        hd: hd,
        height: 512,
        modelClass: 0,
        prompt: '1girl',
        ratio: ratio,
        seed: -1,
        steps: 20,
        styleName: '',
        id: -1,
        width: 512);
    //构建Ai短剧任务数据
    final List<TweetRole> roles = List.empty();
    final List<TweetPrompt> sceneList = List.empty();
    final TweetScriptTts tts =
        TweetScriptTts(format: 'wav', style: '', type: '', vip: 0);
    //构造分句
    final List<TweetScene> scenes = [];
    final List<TweetImage> imgs = [];

    for (int i = 0; i < batchSize; i++) {
      Origin origin;
      if (0 == type) {
        origin = Origin(
            image2VideoParam: image2videoParam,
            image: "",
            strength: image2videoParam.motionStrength!.toDouble());
      } else {
        origin = Origin(
            image2expression: Image2Expression(
                expression: expression,
                image: image2videoParam.image,
                seed: image2videoParam.seed!),
            image: "",
            strength: image2videoParam.motionStrength!.toDouble());
      }

      //构建分句，第一个分镜默认为视频片头分镜
      TweetImage tweetImage = TweetImage(
          mediaType: 1,
          effect: '',
          enPrompt: 'video',
          imgEffectType: -1,
          prompt: 'video',
          rolesId: [],
          sceneId: [],
          tags: ['video'],
          seed: -1,
          origin: origin,
          sentence: "image2video",
          url: '',
          promptList: [],
          ttsText: '');
      imgs.add(tweetImage);
    }
    //暂时只有一个分镜
    TweetScene tweetScene = TweetScene(effects: [], imgs: imgs);
    scenes.add(tweetScene);

    final TweetScript tweetScript = TweetScript(
        aiPaint: aiPaintParamsV2,
        icon: 'icon',
        roles: roles,
        sceneList: sceneList,
        scenes: scenes,
        taskId: '',
        title: 'imageTask',
        tts: tts,
        ttsEnable: false,
        useOrigin: true);
    return tweetScript;
  }

  ///生成一个图集任务数据，高级生图使用
  static TweetScript generateEmptyImgData(
      String prompt, AiPaintParamsV2 aiPaintParamsV2, int batchSize) {
    //构建Ai短剧任务数据
    final List<TweetRole> roles = List.empty();
    final List<TweetPrompt> sceneList = List.empty();
    final TweetScriptTts tts =
        TweetScriptTts(format: 'wav', style: '', type: '', vip: 0);
    //构造分句
    final List<TweetScene> scenes = [];
    final List<TweetImage> imgs = [];

    for (int i = 0; i < batchSize; i++) {
      TweetImage tweetImage = TweetImage(
          mediaType: 0,
          effect: '',
          enPrompt: prompt,
          imgEffectType: -1,
          prompt: prompt,
          rolesId: [],
          sceneId: [],
          tags: [prompt],
          seed: -1,
          sentence: "",
          url: '',
          promptList: [],
          ttsText: '');
      //2.1模型支持ControlNet模式
      if (aiPaintParamsV2.image != null && aiPaintParamsV2.modelClass >= 2) {
        ControlNetUnit controlNetUnit = ControlNetUnit(
            inputType: 0,
            model: "diffusers_xl_canny_full [2b69fca4]",
            module: "canny",
            weight: 1.0);
        List<ControlNetUnit> ControlNetUnitList = [controlNetUnit];
        Origin origin = Origin(
            image: '', strength: 0.5, controlNetUnit: ControlNetUnitList);
        tweetImage.origin = origin;
      }
      imgs.add(tweetImage);
    }
    //暂时只有一个分镜
    TweetScene tweetScene = TweetScene(effects: [], imgs: imgs);
    scenes.add(tweetScene);

    final TweetScript tweetScript = TweetScript(
        aiPaint: aiPaintParamsV2,
        icon: 'icon',
        roles: roles,
        sceneList: sceneList,
        scenes: scenes,
        taskId: '',
        title: 'imageTask',
        tts: tts,
        ttsEnable: false,
        useOrigin: false);
    return tweetScript;
  }

  ///基于已有的文案分句后，或者Ai写的文章，生成剧本数据
  static TweetScript generateEmpty(
      List<SrtModel> sentences, bool video, int styleId) {
    //构建Ai短剧任务数据
    final Hd hd = Hd(scale: 2, modelType: 1, step: 30, strength: 0.65);
    //Ai绘画相关参数
    final AiPaintParamsV2 aiPaintParamsV2 = AiPaintParamsV2(
        batchSize: 1,
        cfgScale: 7,
        detection: true,
        hd: hd,
        height: 512,
        modelClass: 0,
        prompt: '1girl',
        ratio: 0,
        seed: -1,
        steps: 20,
        styleName: '',
        id: styleId,
        width: 512);

    final List<TweetRole> roles = List.empty();
    final List<TweetPrompt> sceneList = List.empty();
    final TweetScriptTts tts =
        TweetScriptTts(format: 'wav', style: '', type: '', vip: 0);
    //构造分句
    final List<TweetScene> scenes = [];
    final List<TweetImage> imgs = [];

    for (int i = 0; i < sentences.length; i++) {
      SrtModel srtModel = sentences[i];
      //构建分句，第一个分镜默认为视频片头分镜
      TweetImage tweetImage = TweetImage(
          mediaType: 0,
          effect: '',
          enPrompt: '',
          anime: Anime(animeIn: "动感放大", animeOut: "无"),
          imgEffectType: -1,
          prompt: '',
          rolesId: [],
          sceneId: [],
          seed: -1,
          sentence: srtModel.sentence,
          url: '',
          userTags: srtModel.prompt == null
              ? null
              : [
                  UserTag(
                      tagEn: srtModel.enPrompt ?? "",
                      tagZh: srtModel.prompt ?? '')
                ],
          promptList: [],
          tts: ImgTts(duration: (srtModel.end - srtModel.start) / 1000),
          ttsText: '');
      imgs.add(tweetImage);
    }
    //暂时只有一个分镜
    TweetScene tweetScene = TweetScene(effects: [], imgs: imgs);
    scenes.add(tweetScene);

    final TweetScript tweetScript = TweetScript(
        aiPaint: aiPaintParamsV2,
        icon: 'icon',
        roles: roles,
        sceneList: sceneList,
        scenes: scenes,
        taskId: '',
        title: 'title',
        tts: tts,
        ttsEnable: true,
        useOrigin: false);
    return tweetScript;
  }

  ///基于已有图片组生成草稿数据
  static TweetScript generateEmptyByImages(List<String> images) {
    //构建Ai短剧任务数据
    final Hd hd = Hd(scale: 2, modelType: 1, step: 30, strength: 0.65);
    //Ai绘画相关参数
    final AiPaintParamsV2 aiPaintParamsV2 = AiPaintParamsV2(
        batchSize: 1,
        cfgScale: 7,
        detection: true,
        hd: hd,
        height: 512,
        modelClass: 0,
        prompt: '1girl',
        ratio: 0,
        seed: -1,
        steps: 20,
        styleName: '',
        width: 512);

    final List<TweetRole> roles = List.empty();
    final List<TweetPrompt> sceneList = List.empty();
    final TweetScriptTts tts =
        TweetScriptTts(format: 'wav', style: '', type: '', vip: 0);
    //构造分句
    final List<TweetScene> scenes = [];
    final List<TweetImage> imgs = [];
    for (String url in images) {
      Origin origin = Origin(image: url, localUrl: url, strength: 0.4);
      //构建分句
      TweetImage tweetImage = TweetImage(
          tts: ImgTts(duration: 0),
          effect: '',
          enPrompt: '',
          imgEffectType: -1,
          prompt: '',
          rolesId: [],
          sceneId: [],
          seed: -1,
          sentence: "",
          url: '',
          origin: origin,
          promptList: [],
          ttsText: '',
          mediaType: 0);
      imgs.add(tweetImage);
    }
    //暂时只有一个分镜
    TweetScene tweetScene = TweetScene(effects: [], imgs: imgs);
    scenes.add(tweetScene);

    final TweetScript tweetScript = TweetScript(
        aiPaint: aiPaintParamsV2,
        icon: 'icon',
        roles: roles,
        sceneList: sceneList,
        scenes: scenes,
        taskId: '',
        title: 'title',
        tts: tts,
        ttsEnable: true,
        useOrigin: false);
    return tweetScript;
  }
}

///当前剧本的全局Ai绘画配置参数
///
///AiPaintParamsV2，AI绘画所需参数
@JsonSerializable(includeIfNull: false)
class AiPaintParamsV2 {
  ///生成图片数量
  @JsonKey(name: "batch_size")
  int batchSize;

  ///文字相关性，建议动漫风格使用11，其他风格使用7
  @JsonKey(name: "cfg_scale")
  double cfgScale;

  ///是否开启图片鉴黄，默认传true，影响获取到的场景图片的格式（详见”获取任务结果“接口的返回数据说明）
  @JsonKey(name: "detection")
  bool detection;

  ///高清设置
  @JsonKey(name: "hd")
  Hd hd;

  ///生成图片高度，默认512
  @JsonKey(name: "height")
  int height;

  ///仅前端使用，用于保存并之后复用使用的绘画风格id
  @JsonKey(name: "id")
  int? id;

  ///非必传，需要图生图时通过此参数传递图片的标准base64字符串
  @JsonKey(name: "image")
  String? image;

  ///lora模型，可不填
  @JsonKey(name: "lora")
  String? lora;

  ///0表示1.5模型，1表示SDXL模型，
  @JsonKey(name: "model_class")
  int modelClass;

  ///负向提示词，可不填
  @JsonKey(name: "negative_prompt")
  String? negativePrompt;

  ///正向提示词
  @JsonKey(name: "prompt")
  String prompt;

  ///
  ///画面比例:默认为0，0表示1:1，1表示4:3，2表示16:9，3表示9:16，4表示3:4，5表示2:3，6表示3:2。提交任务后端生图时，若传width和height，则忽视ratio，使用width和height
  @JsonKey(name: "ratio")
  int ratio;

  @JsonKey(name: "roles")
  List<TweetRole>? roles;

  ///采样方法，可不填
  @JsonKey(name: "sampling")
  String? sampling;

  ///Long型，种子号，传 -1 表示随机
  @JsonKey(name: "seed")
  int seed;

  ///AI迭代次数，次数越高生成速度越慢，理论上质量越好。默认值30
  @JsonKey(name: "steps")
  int steps;

  ///非必传，和image成对使用，当需要图生图时，通过此参数确定图生图的相似度。0.1-1之间，值越小和原图越相似
  @JsonKey(name: "strength")
  double? strength;

  ///底模名
  @JsonKey(name: "style_name")
  String styleName;

  ///生成图片宽度，默认512
  @JsonKey(name: "width")
  int width;

  AiPaintParamsV2({
    required this.batchSize,
    required this.cfgScale,
    required this.detection,
    required this.hd,
    required this.height,
    this.id,
    this.image,
    this.lora,
    required this.modelClass,
    this.negativePrompt,
    required this.prompt,
    required this.ratio,
    this.roles,
    this.sampling,
    required this.seed,
    required this.steps,
    this.strength,
    required this.styleName,
    required this.width,
  });

  AiPaintParamsV2 copyWith({
    int? batchSize,
    double? cfgScale,
    bool? detection,
    Hd? hd,
    int? height,
    int? id,
    String? image,
    String? lora,
    int? modelClass,
    String? negativePrompt,
    String? prompt,
    int? ratio,
    List<TweetRole>? roles,
    String? sampling,
    int? seed,
    int? steps,
    double? strength,
    String? styleName,
    int? width,
  }) =>
      AiPaintParamsV2(
        batchSize: batchSize ?? this.batchSize,
        cfgScale: cfgScale ?? this.cfgScale,
        detection: detection ?? this.detection,
        hd: hd ?? this.hd,
        height: height ?? this.height,
        id: id ?? this.id,
        image: image ?? this.image,
        lora: lora ?? this.lora,
        modelClass: modelClass ?? this.modelClass,
        negativePrompt: negativePrompt ?? this.negativePrompt,
        prompt: prompt ?? this.prompt,
        ratio: ratio ?? this.ratio,
        roles: roles ?? this.roles,
        sampling: sampling ?? this.sampling,
        seed: seed ?? this.seed,
        steps: steps ?? this.steps,
        strength: strength ?? this.strength,
        styleName: styleName ?? this.styleName,
        width: width ?? this.width,
      );

  factory AiPaintParamsV2.fromJson(Map<String, dynamic> json) =>
      _$AiPaintParamsV2FromJson(json);

  Map<String, dynamic> toJson() => _$AiPaintParamsV2ToJson(this);

  ///画面比例:默认为0，0表示1:1，1表示4:3，2表示16:9，3表示9:16，4表示3:4，5表示2:3，6表示3:2
  static double getTrueRatio(int ratio) {
    double trueRatio = 0;
    switch (ratio) {
      case 0:
        trueRatio = 1 / 1;
        break;
      case 1:
        trueRatio = 4 / 3;
        break;
      case 2:
        trueRatio = 16 / 9;
        break;
      case 3:
        trueRatio = 9 / 16;
        break;
      case 4:
        trueRatio = 3 / 4;
        break;
      case 5:
        trueRatio = 2 / 3;
        break;
      case 6:
        trueRatio = 3 / 2;
        break;
    }
    return trueRatio;
  }
}

///高清设置
@JsonSerializable(includeIfNull: false)
class Hd {
  ///放大算法类型，默认0，0表示官方自带latent算法，1动漫算法，2写实算法
  @JsonKey(name: "model_type")
  int? modelType;

  ///放大倍数，推荐取2.0（放大到两倍）
  @JsonKey(name: "scale")
  double? scale;

  ///放大算法迭代步数，默认30
  @JsonKey(name: "step")
  int? step;

  ///细节补充幅度，推荐取0.65，取值0.0～1.0，取0代表和原图一模一样，取1.0代表与原图没有关系
  @JsonKey(name: "strength")
  double? strength;

  Hd({
    this.modelType,
    this.scale,
    this.step,
    this.strength,
  });

  Hd copyWith({
    int? modelType,
    double? scale,
    int? step,
    double? strength,
  }) =>
      Hd(
        modelType: modelType ?? this.modelType,
        scale: scale ?? this.scale,
        step: step ?? this.step,
        strength: strength ?? this.strength,
      );

  factory Hd.fromJson(Map<String, dynamic> json) => _$HdFromJson(json);

  Map<String, dynamic> toJson() => _$HdToJson(this);
}

///bgm资源
@JsonSerializable(includeIfNull: false)
class Bgm {
  ///bgm音频的url地址
  @JsonKey(name: "bgm_url")
  final String bgmUrl;

  ///bgm的总时长。
  @JsonKey(name: "duratuion")
  final double? duratuion;

  Bgm({
    required this.bgmUrl,
    this.duratuion,
  });

  Bgm copyWith({
    String? bgmUrl,
    double? duratuion,
  }) =>
      Bgm(
        bgmUrl: bgmUrl ?? this.bgmUrl,
        duratuion: duratuion ?? this.duratuion,
      );

  factory Bgm.fromJson(Map<String, dynamic> json) => _$BgmFromJson(json);

  Map<String, dynamic> toJson() => _$BgmToJson(this);
}

///TweetRole
@JsonSerializable(includeIfNull: false)
class TweetRole {
  ///角色id，只用于前端进行唯一标识，后端没有用到（不是TweetImage的roles_id中的值）
  @JsonKey(name: "id")
  int? id;

  ///角色名
  @JsonKey(name: "name")
  String name;

  ///负向提示词
  @JsonKey(name: "negative_prompt")
  String negativePrompt;

  ///角色描述
  @JsonKey(name: "prompt")
  String prompt;

  ///角色图种子号，Long型
  @JsonKey(name: "seed")
  int seed;

  ///可不传，角色形象图url，只用于前端进行人物形象展示，后端没有用到
  @JsonKey(name: "url")
  String? url;

  TweetRole({
    this.id,
    required this.name,
    required this.negativePrompt,
    required this.prompt,
    required this.seed,
    this.url,
  });

  TweetRole copyWith({
    int? id,
    String? name,
    String? negativePrompt,
    String? prompt,
    int? seed,
    String? url,
  }) =>
      TweetRole(
        id: id ?? this.id,
        name: name ?? this.name,
        negativePrompt: negativePrompt ?? this.negativePrompt,
        prompt: prompt ?? this.prompt,
        seed: seed ?? this.seed,
        url: url ?? this.url,
      );

  factory TweetRole.fromJson(Map<String, dynamic> json) =>
      _$TweetRoleFromJson(json);

  factory TweetRole.fromRole(Role role) => TweetRole(
        id: role.id,
        name: role.name,
        negativePrompt: '',
        prompt: role.prompt ?? '',
        seed: role.seed ?? -1,
        url: role.icon ?? '',
      );

  Map<String, dynamic> toJson() => _$TweetRoleToJson(this);
}

///TweetPrompt
@JsonSerializable(includeIfNull: false)
class TweetPrompt {
  ///提示词id，只用于前端进行唯一标识，后端没有用到（不是TweetImage的scene_id中的值）
  @JsonKey(name: "id")
  int id;

  ///提示词名字
  @JsonKey(name: "name")
  String name;

  ///绘画时使用的提示词文本
  @JsonKey(name: "prompt")
  String prompt;

  TweetPrompt({
    required this.id,
    required this.name,
    required this.prompt,
  });

  TweetPrompt copyWith({
    int? id,
    String? name,
    String? prompt,
  }) =>
      TweetPrompt(
        id: id ?? this.id,
        name: name ?? this.name,
        prompt: prompt ?? this.prompt,
      );

  factory TweetPrompt.fromJson(Map<String, dynamic> json) =>
      _$TweetPromptFromJson(json);

  Map<String, dynamic> toJson() => _$TweetPromptToJson(this);
}

///每个场景
///
///TweetScene
@JsonSerializable(includeIfNull: false)
class TweetScene {
  ///场景音效列表
  @JsonKey(name: "effects")
  List<TweetEffect>? effects;

  ///场景分镜列表
  @JsonKey(name: "imgs")
  List<TweetImage> imgs;

  TweetScene({
    this.effects,
    required this.imgs,
  });

  TweetScene copyWith({
    List<TweetEffect>? effects,
    List<TweetImage>? imgs,
  }) =>
      TweetScene(
        effects: effects ?? this.effects,
        imgs: imgs ?? this.imgs,
      );

  factory TweetScene.fromJson(Map<String, dynamic> json) =>
      _$TweetSceneFromJson(json);

  Map<String, dynamic> toJson() => _$TweetSceneToJson(this);
}

///TweetEffect
@JsonSerializable(includeIfNull: false)
class TweetEffect {
  ///音效名
  @JsonKey(name: "name")
  String name;

  ///音效起始时长，单位/秒，支持小数点后五位
  @JsonKey(name: "start")
  double start;

  ///音效实际时长，单位/秒，支持小数点后五位
  @JsonKey(name: "t_time")
  double tTime;

  ///音效停留/播放时长，单位/秒，支持小数点后五位
  @JsonKey(name: "time")
  double time;

  ///音效资源的链接
  @JsonKey(name: "url")
  String url;

  TweetEffect({
    required this.name,
    required this.start,
    required this.tTime,
    required this.time,
    required this.url,
  });

  TweetEffect copyWith({
    String? name,
    double? start,
    double? tTime,
    double? time,
    String? url,
  }) =>
      TweetEffect(
        name: name ?? this.name,
        start: start ?? this.start,
        tTime: tTime ?? this.tTime,
        time: time ?? this.time,
        url: url ?? this.url,
      );

  factory TweetEffect.fromJson(Map<String, dynamic> json) =>
      _$TweetEffectFromJson(json);

  Map<String, dynamic> toJson() => _$TweetEffectToJson(this);
}

///TweetImage
@JsonSerializable(includeIfNull: false)
class TweetImage {
  ///图片动画，包括入场，出场。
  @JsonKey(name: "anime")
  Anime? anime;

  ///glsl3D特效种类，预留字段
  @JsonKey(name: "effect")
  final String? effect;

  ///英语版的：Ai绘画使用的完整提示词，直接用这个进行Ai绘画
  @JsonKey(name: "en_prompt")
  final String enPrompt;

  ///文件的长度大小（用来检查文件是否下载完整），单位为byte。如60kb大小的文件，则为60X1024=61440
  @JsonKey(name: "file_length")
  final int? fileLength;

  ///AI生图时是否覆盖外层的标准宽高
  @JsonKey(name: "height")
  final int? height;

  ///图片动效种类，预留字段
  @JsonKey(name: "img_effect_type")
  int? imgEffectType;

  ///当前分镜媒体类型，默认为0。0表示jpg图片，1表示MP4视频，2表示gif
  @JsonKey(name: "media_type")
  int? mediaType;

  ///非必传，需要图生图或者图生视频时传递图片的数据
  @JsonKey(name: "origin")
  Origin? origin;

  ///Ai绘画使用的完整提示词，主要用于显示，如果需要Ai绘画需要进行翻译成英文赋值给en_prompt
  @JsonKey(name: "prompt")
  final String prompt;

  ///后台拆分后的prompt列表，索引0 表示系统推理
  @JsonKey(name: "prompt_list")
  final List<String> promptList;

  ///表示当前这个分句选择了哪些角色。索引化的角色列表，其中数字为外层roles中每项的索引值（不是id值）
  @JsonKey(name: "roles_id")
  List<int>? rolesId;

  ///表示当前这个分句选择了哪些场景，索引化的场景列表，其中数字为外层scene_list中每项的索引值（不是id值）
  @JsonKey(name: "scene_id")
  List<int>? sceneId;

  ///绘图时的seed号
  @JsonKey(name: "seed")
  final int? seed;

  ///非必传，本句中出现的敏感词相关信息，只在tts用原文字朗读时使用，有有多个敏感词时要确保按sentence_Index的大小排列
  @JsonKey(name: "sensitive_words")
  final List<SensitiveWord>? sensitiveWords;

  ///镜头字幕，字幕可能会出现*，但是下面tts_text可以原文朗读
  @JsonKey(name: "sentence")
  String sentence;

  ///表示当前分句的其他推理关键字，包括用户输入的关键词
  @JsonKey(name: "tags")
  final List<String>? tags;

  ///Ai服务器生成的TTS音频资源
  @JsonKey(name: "tts")
  ImgTts? tts;

  ///图片旁白，提交任务时使用该字段生成tts，若该字段为空串或null则使用sentence生成tts，获取结果时为tts音频的文字
  @JsonKey(name: "tts_text")
  String? ttsText;

  ///Ai生成的图片资源的链接，提交任务时如果填写了地址，则服务器不再生图
  @JsonKey(name: "url")
  String? url;

  ///表示当前分句的Ai推理关键字，包括用户输入的关键词
  @JsonKey(name: "user_tags")
  List<UserTag>? userTags;

  ///Ai直接生短视频时使用的链接。提交任务时如果填写了地址，则服务器不再生成
  @JsonKey(name: "video_url")
  String? videoUrl;

  ///AI生图时是否覆盖外层的标准宽高
  @JsonKey(name: "width")
  final int? width;

  TweetImage({
    this.anime,
    this.effect,
    required this.enPrompt,
    this.fileLength,
    this.height,
    this.imgEffectType,
    required this.mediaType,
    this.origin,
    required this.prompt,
    required this.promptList,
    this.rolesId,
    this.sceneId,
    this.seed,
    this.sensitiveWords,
    required this.sentence,
    this.tags,
    this.tts,
    this.ttsText,
    this.url,
    this.userTags,
    this.videoUrl,
    this.width,
  });

  TweetImage copyWith({
    Anime? anime,
    String? effect,
    String? enPrompt,
    int? fileLength,
    int? height,
    int? imgEffectType,
    int? mediaType,
    Origin? origin,
    String? prompt,
    List<String>? promptList,
    List<int>? rolesId,
    List<int>? sceneId,
    int? seed,
    List<SensitiveWord>? sensitiveWords,
    String? sentence,
    List<String>? tags,
    ImgTts? tts,
    String? ttsText,
    String? url,
    List<UserTag>? userTags,
    String? videoUrl,
    int? width,
  }) =>
      TweetImage(
        anime: anime ?? this.anime,
        effect: effect ?? this.effect,
        enPrompt: enPrompt ?? this.enPrompt,
        fileLength: fileLength ?? this.fileLength,
        height: height ?? this.height,
        imgEffectType: imgEffectType ?? this.imgEffectType,
        mediaType: mediaType ?? this.mediaType,
        origin: origin ?? this.origin,
        prompt: prompt ?? this.prompt,
        promptList: promptList ?? this.promptList,
        rolesId: rolesId ?? this.rolesId,
        sceneId: sceneId ?? this.sceneId,
        seed: seed ?? this.seed,
        sensitiveWords: sensitiveWords ?? this.sensitiveWords,
        sentence: sentence ?? this.sentence,
        tags: tags ?? this.tags,
        tts: tts ?? this.tts,
        ttsText: ttsText ?? this.ttsText,
        url: url ?? this.url,
        userTags: userTags ?? this.userTags,
        videoUrl: videoUrl ?? this.videoUrl,
        width: width ?? this.width,
      );

  factory TweetImage.fromJson(Map<String, dynamic> json) =>
      _$TweetImageFromJson(json);

  Map<String, dynamic> toJson() => _$TweetImageToJson(this);
}

///图片动画，包括入场，出场。
@JsonSerializable()
class Anime {
  ///入场动画
  @JsonKey(name: "anime_in")
  final String? animeIn;

  ///出场动画
  @JsonKey(name: "anime_out")
  final String? animeOut;

  Anime({
    this.animeIn,
    this.animeOut,
  });

  Anime copyWith({
    String? animeIn,
    String? animeOut,
  }) =>
      Anime(
        animeIn: animeIn ?? this.animeIn,
        animeOut: animeOut ?? this.animeOut,
      );

  factory Anime.fromJson(Map<String, dynamic> json) => _$AnimeFromJson(json);

  Map<String, dynamic> toJson() => _$AnimeToJson(this);
}

///非必传，需要图生图或者图生视频时传递图片的数据
@JsonSerializable()
class Origin {
  ///图生图是否使用controlnet
  @JsonKey(name: "controlNetUnit")
  List<ControlNetUnit>? controlNetUnit;

  ///图生图或者图生视频时的base64数据
  @JsonKey(name: "image")
  String image;

  ///参考图的本地透传uri地址
  @JsonKey(name: "local_url")
  String? localUrl;

  ///图生图的相似度。0.1-1之间，值越小和原图越相似。图生视频时表示运动强度，取值为0-255
  @JsonKey(name: "strength")
  double strength;

  @JsonKey(name: "video_script")
  Image2VideoParam? image2VideoParam;

  ///是否使用图生表情服务
  @JsonKey(name: "expression_script")
  Image2Expression? image2expression;

  Origin({
    this.controlNetUnit,
    this.image2expression,
    required this.image,
    this.localUrl,
    required this.strength,
    this.image2VideoParam,
  });

  Origin copyWith({
    List<ControlNetUnit>? controlNetUnit,
    Image2Expression? image2expression,
    String? image,
    String? localUrl,
    double? strength,
    Image2VideoParam? image2VideoParam,
  }) =>
      Origin(
        controlNetUnit: controlNetUnit ?? this.controlNetUnit,
        image2expression: image2expression ?? this.image2expression,
        image: image ?? this.image,
        localUrl: localUrl ?? this.localUrl,
        strength: strength ?? this.strength,
        image2VideoParam: image2VideoParam ?? this.image2VideoParam,
      );

  factory Origin.fromJson(Map<String, dynamic> json) => _$OriginFromJson(json);

  Map<String, dynamic> toJson() => _$OriginToJson(this);
}

@JsonSerializable()
class ControlNetUnit {
  ///0表示canny，默认0
  @JsonKey(name: "input_type")
  final int inputType;

  ///模型型号:diffusers_xl_canny_full [2b69fca4]
  @JsonKey(name: "model")
  final String model;

  ///canny
  @JsonKey(name: "module")
  final String module;

  ///controlNet权重，0-2之间，默认为1
  @JsonKey(name: "weight")
  final double weight;

  ControlNetUnit({
    required this.inputType,
    required this.model,
    required this.module,
    required this.weight,
  });

  ControlNetUnit copyWith({
    int? inputType,
    String? model,
    String? module,
    double? weight,
  }) =>
      ControlNetUnit(
        inputType: inputType ?? this.inputType,
        model: model ?? this.model,
        module: module ?? this.module,
        weight: weight ?? this.weight,
      );

  factory ControlNetUnit.fromJson(Map<String, dynamic> json) =>
      _$ControlNetUnitFromJson(json);

  Map<String, dynamic> toJson() => _$ControlNetUnitToJson(this);
}

@JsonSerializable()
class SensitiveWord {
  ///敏感词（replaced为空串时）或替换词（replaced不为空串时）在sentence中的索引。
  @JsonKey(name: "position")
  final int position;

  ///用户输入的 sensitive 的替换词。若replaced为空串，说明没有替换过；反之则替换过
  @JsonKey(name: "replaced")
  final String replaced;

  ///检测出来的敏感词
  @JsonKey(name: "sensitive")
  final String sensitive;

  SensitiveWord({
    required this.position,
    required this.replaced,
    required this.sensitive,
  });

  SensitiveWord copyWith({
    int? position,
    String? replaced,
    String? sensitive,
  }) =>
      SensitiveWord(
        position: position ?? this.position,
        replaced: replaced ?? this.replaced,
        sensitive: sensitive ?? this.sensitive,
      );

  factory SensitiveWord.fromJson(Map<String, dynamic> json) =>
      _$SensitiveWordFromJson(json);

  Map<String, dynamic> toJson() => _$SensitiveWordToJson(this);
}

///Ai服务器生成的TTS音频资源
@JsonSerializable(includeIfNull: false)
class ImgTts {
  ///旁白TTS音频时长，单位/秒，支持小数点后五位
  @JsonKey(name: "duration")
  double? duration;

  ///文件的长度大小（用来检查文件是否下载完整），单位为byte。如60kb大小的文件，则为60X1024=61440
  @JsonKey(name: "file_length")
  double? fileLength;

  ///图片tts旁白音频的url
  @JsonKey(name: "url")
  String? url;

  ImgTts({
    this.duration,
    this.fileLength,
    this.url,
  });

  ImgTts copyWith({
    double? duration,
    double? fileLength,
    String? url,
  }) =>
      ImgTts(
        duration: duration ?? this.duration,
        fileLength: fileLength ?? this.fileLength,
        url: url ?? this.url,
      );

  factory ImgTts.fromJson(Map<String, dynamic> json) => _$ImgTtsFromJson(json);

  Map<String, dynamic> toJson() => _$ImgTtsToJson(this);
}

@JsonSerializable(includeIfNull: false)
class UserTag {
  ///英文Ai绘画原词
  @JsonKey(name: "tag_en")
  String tagEn;

  ///对应中文
  @JsonKey(name: "tag_zh")
  String? tagZh;

  UserTag({
    required this.tagEn,
    this.tagZh,
  });

  UserTag copyWith({
    String? tagEn,
    String? tagZh,
  }) =>
      UserTag(
        tagEn: tagEn ?? this.tagEn,
        tagZh: tagZh ?? this.tagZh,
      );

  factory UserTag.fromJson(Map<String, dynamic> json) =>
      _$UserTagFromJson(json);

  Map<String, dynamic> toJson() => _$UserTagToJson(this);
}

///当前剧本的全局TTS配置参数
@JsonSerializable(includeIfNull: false)
class TweetScriptTts {
  ///必填，返回音频的格式，默认请填写“wav”
  @JsonKey(name: "format")
  String format;

  ///音频速度，默认速度为50表示原速，取值0~100，取值75则代表1.5倍速（50*1.5），以此类推
  @JsonKey(name: "speed")
  int? speed;

  ///音色风格，TTS音色列表的"style"
  @JsonKey(name: "style")
  String? style;

  ///音色模型，TTS音色列表的"type"
  @JsonKey(name: "type")
  String type;

  ///是否付费，0 免费；1会员免费；2会员收费
  @JsonKey(name: "vip")
  int? vip;

  ///音频音量，默认大小为50，取值0~100
  @JsonKey(name: "volume")
  int? volume;

  TweetScriptTts({
    required this.format,
    this.speed,
    this.style,
    required this.type,
    required this.vip,
    this.volume,
  });

  TweetScriptTts copyWith({
    String? format,
    int? speed,
    String? style,
    String? type,
    int? vip,
    int? volume,
  }) =>
      TweetScriptTts(
        format: format ?? this.format,
        speed: speed ?? this.speed,
        style: style ?? this.style,
        type: type ?? this.type,
        vip: vip ?? this.vip,
        volume: volume ?? this.volume,
      );

  factory TweetScriptTts.fromJson(Map<String, dynamic> json) =>
      _$TweetScriptTtsFromJson(json);

  Map<String, dynamic> toJson() => _$TweetScriptTtsToJson(this);
}
