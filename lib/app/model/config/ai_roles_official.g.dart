// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_roles_official.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiRoles _$AiRolesFromJson(Map<String, dynamic> json) => AiRoles(
      sex: json['sex'] as String,
      sexId: (json['sex_id'] as num).toInt(),
      tags: (json['tags'] as List<dynamic>)
          .map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AiRolesToJson(AiRoles instance) => <String, dynamic>{
      'sex': instance.sex,
      'sex_id': instance.sexId,
      'tags': instance.tags,
    };

Tag _$TagFromJson(Map<String, dynamic> json) => Tag(
      children: (json['children'] as List<dynamic>)
          .map((e) => AiRole.fromJson(e as Map<String, dynamic>))
          .toList(),
      tagId: (json['tagId'] as num).toInt(),
      tagName: json['tagName'] as String,
    );

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
      'children': instance.children,
      'tagId': instance.tagId,
      'tagName': instance.tagName,
    };

AiRole _$AiRoleFromJson(Map<String, dynamic> json) => AiRole(
      icon: json['icon'] as String?,
      name: json['name'] as String?,
      price: (json['price'] as num?)?.toInt(),
      rolePromptInfo: json['role_prompt_info'] == null
          ? null
          : RolePromptInfo.fromJson(
              json['role_prompt_info'] as Map<String, dynamic>),
      sex: (json['sex'] as num?)?.toInt(),
      style: (json['style'] as num?)?.toInt(),
      tagId: (json['tag_id'] as num?)?.toInt(),
      id: (json['id'] as num).toInt(),
    );

Map<String, dynamic> _$AiRoleToJson(AiRole instance) => <String, dynamic>{
      'icon': instance.icon,
      'name': instance.name,
      'price': instance.price,
      'role_prompt_info': instance.rolePromptInfo,
      'sex': instance.sex,
      'style': instance.style,
      'tag_id': instance.tagId,
      'id': instance.id,
    };

RolePromptInfo _$RolePromptInfoFromJson(Map<String, dynamic> json) =>
    RolePromptInfo(
      negativePrompt: json['negative_prompt'] as String,
      prompt: json['prompt'] as String,
      seed: (json['seed'] as num?)?.toInt(),
      url: json['url'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => DiyTag.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RolePromptInfoToJson(RolePromptInfo instance) =>
    <String, dynamic>{
      'negative_prompt': instance.negativePrompt,
      'prompt': instance.prompt,
      'seed': instance.seed,
      'url': instance.url,
      'tags': instance.tags,
    };

DiyTag _$DiyTagFromJson(Map<String, dynamic> json) => DiyTag(
      en: json['en'] as String,
      type: (json['type'] as num).toInt(),
      zh: json['zh'] as String,
    );

Map<String, dynamic> _$DiyTagToJson(DiyTag instance) => <String, dynamic>{
      'en': instance.en,
      'type': instance.type,
      'zh': instance.zh,
    };
