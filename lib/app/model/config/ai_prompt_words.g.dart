// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_prompt_words.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromptWord _$PromptWordFromJson(Map<String, dynamic> json) => PromptWord(
      children: (json['children'] as List<dynamic>)
          .map((e) => DatumChild.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String,
      type: (json['type'] as num).toInt(),
    );

Map<String, dynamic> _$PromptWordToJson(PromptWord instance) =>
    <String, dynamic>{
      'children': instance.children,
      'name': instance.name,
      'type': instance.type,
    };

DatumChild _$DatumChildFromJson(Map<String, dynamic> json) => DatumChild(
      children: (json['children'] as List<dynamic>)
          .map((e) => PurpleChild.fromJson(e as Map<String, dynamic>))
          .toList(),
      classNum: (json['class_num'] as num).toInt(),
      enName: json['en_name'] as String,
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      parentId: (json['parent_id'] as num).toInt(),
      type: (json['type'] as num).toInt(),
    );

Map<String, dynamic> _$DatumChildToJson(DatumChild instance) =>
    <String, dynamic>{
      'children': instance.children,
      'class_num': instance.classNum,
      'en_name': instance.enName,
      'id': instance.id,
      'name': instance.name,
      'parent_id': instance.parentId,
      'type': instance.type,
    };

PurpleChild _$PurpleChildFromJson(Map<String, dynamic> json) => PurpleChild(
      children: (json['children'] as List<dynamic>)
          .map((e) => FluffyChild.fromJson(e as Map<String, dynamic>))
          .toList(),
      classNum: (json['class_num'] as num).toInt(),
      enName: json['en_name'] as String,
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      parentId: (json['parent_id'] as num).toInt(),
      type: (json['type'] as num).toInt(),
    );

Map<String, dynamic> _$PurpleChildToJson(PurpleChild instance) =>
    <String, dynamic>{
      'children': instance.children,
      'class_num': instance.classNum,
      'en_name': instance.enName,
      'id': instance.id,
      'name': instance.name,
      'parent_id': instance.parentId,
      'type': instance.type,
    };

FluffyChild _$FluffyChildFromJson(Map<String, dynamic> json) => FluffyChild(
      classNum: (json['class_num'] as num).toInt(),
      enName: json['en_name'] as String,
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      parentId: (json['parent_id'] as num).toInt(),
      type: (json['type'] as num).toInt(),
    );

Map<String, dynamic> _$FluffyChildToJson(FluffyChild instance) =>
    <String, dynamic>{
      'class_num': instance.classNum,
      'en_name': instance.enName,
      'id': instance.id,
      'name': instance.name,
      'parent_id': instance.parentId,
      'type': instance.type,
    };
