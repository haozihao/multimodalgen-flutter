// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_analyse_role_scene.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RolesAndScenes _$RolesAndScenesFromJson(Map<String, dynamic> json) =>
    RolesAndScenes(
      averageDuration: (json['average_duration'] as num?)?.toInt(),
      dataType: json['dataType'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      roles: (json['roles'] as List<dynamic>)
          .map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
      scenes: (json['scenes'] as List<dynamic>)
          .map((e) => Scene.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RolesAndScenesToJson(RolesAndScenes instance) =>
    <String, dynamic>{
      'average_duration': instance.averageDuration,
      'dataType': instance.dataType,
      'duration': instance.duration,
      'roles': instance.roles,
      'scenes': instance.scenes,
    };

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
      name: json['name'] as String,
      refName: json['original_name'] as String?,
      id: (json['id'] as num?)?.toInt(),
      icon: json['icon'] as String?,
      prompt: json['prompt'] as String?,
      seed: (json['seed'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
      'name': instance.name,
      'original_name': instance.refName,
      'id': instance.id,
      'icon': instance.icon,
      'prompt': instance.prompt,
      'seed': instance.seed,
    };

Scene _$SceneFromJson(Map<String, dynamic> json) => Scene(
      name: json['name'] as String,
      prompt: json['prompt'] as String,
    );

Map<String, dynamic> _$SceneToJson(Scene instance) => <String, dynamic>{
      'name': instance.name,
      'prompt': instance.prompt,
    };
