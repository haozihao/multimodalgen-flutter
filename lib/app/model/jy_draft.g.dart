// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jy_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JyDraft _$JyDraftFromJson(Map<String, dynamic> json) => JyDraft(
      name: json['name'] as String,
      scenes: (json['scenes'] as List<dynamic>)
          .map((e) => Scene.fromJson(e as Map<String, dynamic>))
          .toList(),
      ratio: (json['ratio'] as num).toInt(),
    );

Map<String, dynamic> _$JyDraftToJson(JyDraft instance) => <String, dynamic>{
      'name': instance.name,
      'ratio': instance.ratio,
      'scenes': instance.scenes.map((e) => e.toJson()).toList(),
    };

Scene _$SceneFromJson(Map<String, dynamic> json) => Scene(
      anime: json['anime'] == null
          ? null
          : Anime.fromJson(json['anime'] as Map<String, dynamic>),
      filePath: json['file_path'] as String?,
      height: (json['height'] as num).toInt(),
      imageEffect: json['image_effect'] as String?,
      text: json['text'] as String?,
      time: (json['time'] as num).toInt(),
      trackIndex: (json['track_index'] as num?)?.toInt(),
      start: (json['start'] as num?)?.toInt(),
      trackType: json['track_type'] as String,
      width: (json['width'] as num).toInt(),
    );

Map<String, dynamic> _$SceneToJson(Scene instance) => <String, dynamic>{
      'anime': instance.anime?.toJson(),
      'file_path': instance.filePath,
      'height': instance.height,
      'image_effect': instance.imageEffect,
      'text': instance.text,
      'time': instance.time,
      'track_index': instance.trackIndex,
      'start': instance.start,
      'track_type': instance.trackType,
      'width': instance.width,
    };
