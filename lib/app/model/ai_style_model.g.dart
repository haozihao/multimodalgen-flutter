// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_style_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiStyleModel _$AiStyleModelFromJson(Map<String, dynamic> json) => AiStyleModel(
      children: (json['children'] as List<dynamic>)
          .map((e) => Child.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      sort: (json['sort'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AiStyleModelToJson(AiStyleModel instance) =>
    <String, dynamic>{
      'children': instance.children,
      'id': instance.id,
      'name': instance.name,
      'sort': instance.sort,
    };

Child _$ChildFromJson(Map<String, dynamic> json) => Child(
      icon: json['icon'] as String,
      id: (json['id'] as num).toInt(),
      loraFileName: json['lora_file_name'] as String?,
      modelClass: (json['model_class'] as num?)?.toInt(),
      modelFileName: json['model_file_name'] as String,
      name: json['name'] as String,
      presetInfo: json['preset_info'] as String,
      type: (json['type'] as num).toInt(),
      uid: (json['uid'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ChildToJson(Child instance) => <String, dynamic>{
      'icon': instance.icon,
      'id': instance.id,
      'lora_file_name': instance.loraFileName,
      'model_class': instance.modelClass,
      'model_file_name': instance.modelFileName,
      'name': instance.name,
      'preset_info': instance.presetInfo,
      'type': instance.type,
      'uid': instance.uid,
    };
