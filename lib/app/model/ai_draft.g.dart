// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DraftRender _$DraftRenderFromJson(Map<String, dynamic> json) => DraftRender(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      tweetScript: json['tweetScript'] == null
          ? null
          : TweetScript.fromJson(json['tweetScript'] as Map<String, dynamic>),
      rolesAndScenes: json['rolesAndScenes'] == null
          ? null
          : RolesAndScenes.fromJson(
              json['rolesAndScenes'] as Map<String, dynamic>),
      styleId: (json['styleId'] as num?)?.toInt(),
      status: (json['status'] as num).toInt(),
      styleType: (json['styleType'] as num?)?.toInt(),
      draftVersion: (json['draftVersion'] as num?)?.toInt(),
      type: (json['type'] as num?)?.toInt(),
      audioPath: json['audioPath'] as String?,
      audioSeconds: (json['audioSeconds'] as num?)?.toInt(),
      draftShidai: (json['draftShidai'] as num?)?.toInt(),
      originalContent: json['originalContent'] as String?,
      lockedSeed: json['lockedSeed'] as bool?,
    );

Map<String, dynamic> _$DraftRenderToJson(DraftRender instance) =>
    <String, dynamic>{
      'draftVersion': instance.draftVersion,
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'tweetScript': instance.tweetScript?.toJson(),
      'rolesAndScenes': instance.rolesAndScenes?.toJson(),
      'styleId': instance.styleId,
      'styleType': instance.styleType,
      'type': instance.type,
      'audioPath': instance.audioPath,
      'audioSeconds': instance.audioSeconds,
      'draftShidai': instance.draftShidai,
      'originalContent': instance.originalContent,
      'lockedSeed': instance.lockedSeed,
    };
