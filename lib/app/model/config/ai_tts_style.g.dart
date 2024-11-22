// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_tts_style.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiTtsStyle _$AiTtsStyleFromJson(Map<String, dynamic> json) => AiTtsStyle(
      age: (json['age'] as num).toInt(),
      icon: json['icon'] as String,
      id: (json['id'] as num).toInt(),
      mode: (json['mode'] as num).toInt(),
      name: json['name'] as String,
      order: (json['order'] as num).toInt(),
      sex: (json['sex'] as num).toInt(),
      type: json['type'] as String,
      url: json['url'] as String,
      vip: (json['vip'] as num).toInt(),
      voiceType: json['voice_type'] as String,
    )..style = json['style'] as String?;

Map<String, dynamic> _$AiTtsStyleToJson(AiTtsStyle instance) =>
    <String, dynamic>{
      'age': instance.age,
      'icon': instance.icon,
      'id': instance.id,
      'mode': instance.mode,
      'name': instance.name,
      'style': instance.style,
      'order': instance.order,
      'sex': instance.sex,
      'type': instance.type,
      'url': instance.url,
      'vip': instance.vip,
      'voice_type': instance.voiceType,
    };
