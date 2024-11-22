// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_story_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiStoryTask _$AiStoryTaskFromJson(Map<String, dynamic> json) => AiStoryTask(
      createtime: (json['createtime'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      icon: json['icon'] as String?,
      soundtype: json['soundtype'] as String,
      speed: (json['speed'] as num?)?.toInt(),
      status0: (json['status_0'] as num).toInt(),
      status1: (json['status_1'] as num).toInt(),
      styleName: json['style_name'] as String,
      taskId: json['task_id'] as String,
      time: json['time'],
      title: json['title'] as String,
      width: (json['width'] as num).toInt(),
    );

Map<String, dynamic> _$AiStoryTaskToJson(AiStoryTask instance) =>
    <String, dynamic>{
      'createtime': instance.createtime,
      'height': instance.height,
      'icon': instance.icon,
      'soundtype': instance.soundtype,
      'speed': instance.speed,
      'status_0': instance.status0,
      'status_1': instance.status1,
      'style_name': instance.styleName,
      'task_id': instance.taskId,
      'time': instance.time,
      'title': instance.title,
      'width': instance.width,
    };
