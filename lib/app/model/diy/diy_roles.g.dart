// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diy_roles.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomRolePicture _$CustomRolePictureFromJson(Map<String, dynamic> json) =>
    CustomRolePicture(
      icon: json['icon'] as String,
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      price: (json['price'] as num?)?.toInt(),
      rolePromptInfo: json['role_prompt_info'] == null
          ? null
          : RolePromptInfo.fromJson(
              json['role_prompt_info'] as Map<String, dynamic>),
      sex: (json['sex'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      style: (json['style'] as num).toInt(),
      styleName: json['style_name'] as String?,
      updateTime: (json['update_time'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CustomRolePictureToJson(CustomRolePicture instance) =>
    <String, dynamic>{
      'icon': instance.icon,
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'role_prompt_info': instance.rolePromptInfo,
      'sex': instance.sex,
      'status': instance.status,
      'style': instance.style,
      'style_name': instance.styleName,
      'update_time': instance.updateTime,
    };

RolePromptInfo _$RolePromptInfoFromJson(Map<String, dynamic> json) =>
    RolePromptInfo(
      imgs: (json['imgs'] as List<dynamic>)
          .map((e) => Img.fromJson(e as Map<String, dynamic>))
          .toList(),
      negativePrompt: json['negative_prompt'] as String,
      prompt: json['prompt'] as String,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RolePromptInfoToJson(RolePromptInfo instance) =>
    <String, dynamic>{
      'imgs': instance.imgs,
      'negative_prompt': instance.negativePrompt,
      'prompt': instance.prompt,
      'tags': instance.tags,
    };

Img _$ImgFromJson(Map<String, dynamic> json) => Img(
      path: json['path'] as String,
      seed: (json['seed'] as num).toDouble(),
    );

Map<String, dynamic> _$ImgToJson(Img instance) => <String, dynamic>{
      'path': instance.path,
      'seed': instance.seed,
    };

Tag _$TagFromJson(Map<String, dynamic> json) => Tag(
      en: json['en'] as String,
      type: (json['type'] as num).toInt(),
      zh: json['zh'] as String,
    );

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
      'en': instance.en,
      'type': instance.type,
      'zh': instance.zh,
    };
