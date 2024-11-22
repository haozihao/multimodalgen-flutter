// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TweetScript.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TweetScript _$TweetScriptFromJson(Map<String, dynamic> json) => TweetScript(
      aiPaint:
          AiPaintParamsV2.fromJson(json['ai_paint'] as Map<String, dynamic>),
      aiPrompt: json['ai_prompt'] as bool?,
      icon: json['icon'] as String,
      detection: json['detection'] as bool?,
      roles: (json['roles'] as List<dynamic>)
          .map((e) => TweetRole.fromJson(e as Map<String, dynamic>))
          .toList(),
      sceneList: (json['scene_list'] as List<dynamic>)
          .map((e) => TweetPrompt.fromJson(e as Map<String, dynamic>))
          .toList(),
      scenes: (json['scenes'] as List<dynamic>)
          .map((e) => TweetScene.fromJson(e as Map<String, dynamic>))
          .toList(),
      showText: json['show_text'] as bool?,
      taskId: json['task_id'] as String?,
      title: json['title'] as String,
      tts: TweetScriptTts.fromJson(json['tts'] as Map<String, dynamic>),
      ttsEnable: json['tts_enable'] as bool?,
      bgm: json['bgm'] == null
          ? null
          : Bgm.fromJson(json['bgm'] as Map<String, dynamic>),
      useOrigin: json['use_origin'] as bool?,
    );

Map<String, dynamic> _$TweetScriptToJson(TweetScript instance) =>
    <String, dynamic>{
      'ai_paint': instance.aiPaint,
      if (instance.aiPrompt case final value?) 'ai_prompt': value,
      'icon': instance.icon,
      'roles': instance.roles,
      'scene_list': instance.sceneList,
      'scenes': instance.scenes,
      if (instance.showText case final value?) 'show_text': value,
      if (instance.taskId case final value?) 'task_id': value,
      'title': instance.title,
      'tts': instance.tts,
      if (instance.bgm case final value?) 'bgm': value,
      if (instance.detection case final value?) 'detection': value,
      if (instance.ttsEnable case final value?) 'tts_enable': value,
      if (instance.useOrigin case final value?) 'use_origin': value,
    };

AiPaintParamsV2 _$AiPaintParamsV2FromJson(Map<String, dynamic> json) =>
    AiPaintParamsV2(
      batchSize: (json['batch_size'] as num).toInt(),
      cfgScale: (json['cfg_scale'] as num).toDouble(),
      detection: json['detection'] as bool,
      hd: Hd.fromJson(json['hd'] as Map<String, dynamic>),
      height: (json['height'] as num).toInt(),
      id: (json['id'] as num?)?.toInt(),
      image: json['image'] as String?,
      lora: json['lora'] as String?,
      modelClass: (json['model_class'] as num).toInt(),
      negativePrompt: json['negative_prompt'] as String?,
      prompt: json['prompt'] as String,
      ratio: (json['ratio'] as num).toInt(),
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => TweetRole.fromJson(e as Map<String, dynamic>))
          .toList(),
      sampling: json['sampling'] as String?,
      seed: (json['seed'] as num).toInt(),
      steps: (json['steps'] as num).toInt(),
      strength: (json['strength'] as num?)?.toDouble(),
      styleName: json['style_name'] as String,
      width: (json['width'] as num).toInt(),
    );

Map<String, dynamic> _$AiPaintParamsV2ToJson(AiPaintParamsV2 instance) =>
    <String, dynamic>{
      'batch_size': instance.batchSize,
      'cfg_scale': instance.cfgScale,
      'detection': instance.detection,
      'hd': instance.hd,
      'height': instance.height,
      if (instance.id case final value?) 'id': value,
      if (instance.image case final value?) 'image': value,
      if (instance.lora case final value?) 'lora': value,
      'model_class': instance.modelClass,
      if (instance.negativePrompt case final value?) 'negative_prompt': value,
      'prompt': instance.prompt,
      'ratio': instance.ratio,
      if (instance.roles case final value?) 'roles': value,
      if (instance.sampling case final value?) 'sampling': value,
      'seed': instance.seed,
      'steps': instance.steps,
      if (instance.strength case final value?) 'strength': value,
      'style_name': instance.styleName,
      'width': instance.width,
    };

Hd _$HdFromJson(Map<String, dynamic> json) => Hd(
      modelType: (json['model_type'] as num?)?.toInt(),
      scale: (json['scale'] as num?)?.toDouble(),
      step: (json['step'] as num?)?.toInt(),
      strength: (json['strength'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$HdToJson(Hd instance) => <String, dynamic>{
      if (instance.modelType case final value?) 'model_type': value,
      if (instance.scale case final value?) 'scale': value,
      if (instance.step case final value?) 'step': value,
      if (instance.strength case final value?) 'strength': value,
    };

Bgm _$BgmFromJson(Map<String, dynamic> json) => Bgm(
      bgmUrl: json['bgm_url'] as String,
      duratuion: (json['duratuion'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BgmToJson(Bgm instance) => <String, dynamic>{
      'bgm_url': instance.bgmUrl,
      if (instance.duratuion case final value?) 'duratuion': value,
    };

TweetRole _$TweetRoleFromJson(Map<String, dynamic> json) => TweetRole(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      negativePrompt: json['negative_prompt'] as String,
      prompt: json['prompt'] as String,
      seed: (json['seed'] as num).toInt(),
      url: json['url'] as String?,
    );

Map<String, dynamic> _$TweetRoleToJson(TweetRole instance) => <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      'name': instance.name,
      'negative_prompt': instance.negativePrompt,
      'prompt': instance.prompt,
      'seed': instance.seed,
      if (instance.url case final value?) 'url': value,
    };

TweetPrompt _$TweetPromptFromJson(Map<String, dynamic> json) => TweetPrompt(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      prompt: json['prompt'] as String,
    );

Map<String, dynamic> _$TweetPromptToJson(TweetPrompt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'prompt': instance.prompt,
    };

TweetScene _$TweetSceneFromJson(Map<String, dynamic> json) => TweetScene(
      effects: (json['effects'] as List<dynamic>?)
          ?.map((e) => TweetEffect.fromJson(e as Map<String, dynamic>))
          .toList(),
      imgs: (json['imgs'] as List<dynamic>)
          .map((e) => TweetImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TweetSceneToJson(TweetScene instance) =>
    <String, dynamic>{
      if (instance.effects case final value?) 'effects': value,
      'imgs': instance.imgs,
    };

TweetEffect _$TweetEffectFromJson(Map<String, dynamic> json) => TweetEffect(
      name: json['name'] as String,
      start: (json['start'] as num).toDouble(),
      tTime: (json['t_time'] as num).toDouble(),
      time: (json['time'] as num).toDouble(),
      url: json['url'] as String,
    );

Map<String, dynamic> _$TweetEffectToJson(TweetEffect instance) =>
    <String, dynamic>{
      'name': instance.name,
      'start': instance.start,
      't_time': instance.tTime,
      'time': instance.time,
      'url': instance.url,
    };

TweetImage _$TweetImageFromJson(Map<String, dynamic> json) => TweetImage(
      anime: json['anime'] == null
          ? null
          : Anime.fromJson(json['anime'] as Map<String, dynamic>),
      effect: json['effect'] as String?,
      enPrompt: json['en_prompt'] as String,
      fileLength: (json['file_length'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      imgEffectType: (json['img_effect_type'] as num?)?.toInt(),
      mediaType: (json['media_type'] as num?)?.toInt(),
      origin: json['origin'] == null
          ? null
          : Origin.fromJson(json['origin'] as Map<String, dynamic>),
      prompt: json['prompt'] as String,
      promptList: (json['prompt_list'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      rolesId: (json['roles_id'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      sceneId: (json['scene_id'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      seed: (json['seed'] as num?)?.toInt(),
      sensitiveWords: (json['sensitive_words'] as List<dynamic>?)
          ?.map((e) => SensitiveWord.fromJson(e as Map<String, dynamic>))
          .toList(),
      sentence: json['sentence'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      tts: json['tts'] == null
          ? null
          : ImgTts.fromJson(json['tts'] as Map<String, dynamic>),
      ttsText: json['tts_text'] as String?,
      url: json['url'] as String?,
      userTags: (json['user_tags'] as List<dynamic>?)
          ?.map((e) => UserTag.fromJson(e as Map<String, dynamic>))
          .toList(),
      videoUrl: json['video_url'] as String?,
      width: (json['width'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TweetImageToJson(TweetImage instance) =>
    <String, dynamic>{
      if (instance.anime case final value?) 'anime': value,
      if (instance.effect case final value?) 'effect': value,
      'en_prompt': instance.enPrompt,
      if (instance.fileLength case final value?) 'file_length': value,
      if (instance.height case final value?) 'height': value,
      if (instance.imgEffectType case final value?) 'img_effect_type': value,
      if (instance.mediaType case final value?) 'media_type': value,
      if (instance.origin case final value?) 'origin': value,
      'prompt': instance.prompt,
      'prompt_list': instance.promptList,
      if (instance.rolesId case final value?) 'roles_id': value,
      if (instance.sceneId case final value?) 'scene_id': value,
      if (instance.seed case final value?) 'seed': value,
      if (instance.sensitiveWords case final value?) 'sensitive_words': value,
      'sentence': instance.sentence,
      if (instance.tags case final value?) 'tags': value,
      if (instance.tts case final value?) 'tts': value,
      if (instance.ttsText case final value?) 'tts_text': value,
      if (instance.url case final value?) 'url': value,
      if (instance.userTags case final value?) 'user_tags': value,
      if (instance.videoUrl case final value?) 'video_url': value,
      if (instance.width case final value?) 'width': value,
    };

Anime _$AnimeFromJson(Map<String, dynamic> json) => Anime(
      animeIn: json['anime_in'] as String?,
      animeOut: json['anime_out'] as String?,
    );

Map<String, dynamic> _$AnimeToJson(Anime instance) => <String, dynamic>{
      'anime_in': instance.animeIn,
      'anime_out': instance.animeOut,
    };

Origin _$OriginFromJson(Map<String, dynamic> json) => Origin(
      controlNetUnit: (json['controlNetUnit'] as List<dynamic>?)
          ?.map((e) => ControlNetUnit.fromJson(e as Map<String, dynamic>))
          .toList(),
      image2expression: json['expression_script'] == null
          ? null
          : Image2Expression.fromJson(
              json['expression_script'] as Map<String, dynamic>),
      image: json['image'] as String,
      localUrl: json['local_url'] as String?,
      strength: (json['strength'] as num).toDouble(),
      image2VideoParam: json['video_script'] == null
          ? null
          : Image2VideoParam.fromJson(
              json['video_script'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OriginToJson(Origin instance) => <String, dynamic>{
      'controlNetUnit': instance.controlNetUnit,
      'image': instance.image,
      'local_url': instance.localUrl,
      'strength': instance.strength,
      'video_script': instance.image2VideoParam,
      'expression_script': instance.image2expression,
    };

ControlNetUnit _$ControlNetUnitFromJson(Map<String, dynamic> json) =>
    ControlNetUnit(
      inputType: (json['input_type'] as num).toInt(),
      model: json['model'] as String,
      module: json['module'] as String,
      weight: (json['weight'] as num).toDouble(),
    );

Map<String, dynamic> _$ControlNetUnitToJson(ControlNetUnit instance) =>
    <String, dynamic>{
      'input_type': instance.inputType,
      'model': instance.model,
      'module': instance.module,
      'weight': instance.weight,
    };

SensitiveWord _$SensitiveWordFromJson(Map<String, dynamic> json) =>
    SensitiveWord(
      position: (json['position'] as num).toInt(),
      replaced: json['replaced'] as String,
      sensitive: json['sensitive'] as String,
    );

Map<String, dynamic> _$SensitiveWordToJson(SensitiveWord instance) =>
    <String, dynamic>{
      'position': instance.position,
      'replaced': instance.replaced,
      'sensitive': instance.sensitive,
    };

ImgTts _$ImgTtsFromJson(Map<String, dynamic> json) => ImgTts(
      duration: (json['duration'] as num?)?.toDouble(),
      fileLength: (json['file_length'] as num?)?.toDouble(),
      url: json['url'] as String?,
    );

Map<String, dynamic> _$ImgTtsToJson(ImgTts instance) => <String, dynamic>{
      if (instance.duration case final value?) 'duration': value,
      if (instance.fileLength case final value?) 'file_length': value,
      if (instance.url case final value?) 'url': value,
    };

UserTag _$UserTagFromJson(Map<String, dynamic> json) => UserTag(
      tagEn: json['tag_en'] as String,
      tagZh: json['tag_zh'] as String?,
    );

Map<String, dynamic> _$UserTagToJson(UserTag instance) => <String, dynamic>{
      'tag_en': instance.tagEn,
      if (instance.tagZh case final value?) 'tag_zh': value,
    };

TweetScriptTts _$TweetScriptTtsFromJson(Map<String, dynamic> json) =>
    TweetScriptTts(
      format: json['format'] as String,
      speed: (json['speed'] as num?)?.toInt(),
      style: json['style'] as String?,
      type: json['type'] as String,
      vip: (json['vip'] as num?)?.toInt(),
      volume: (json['volume'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TweetScriptTtsToJson(TweetScriptTts instance) =>
    <String, dynamic>{
      'format': instance.format,
      if (instance.speed case final value?) 'speed': value,
      if (instance.style case final value?) 'style': value,
      'type': instance.type,
      if (instance.vip case final value?) 'vip': value,
      if (instance.volume case final value?) 'volume': value,
    };
