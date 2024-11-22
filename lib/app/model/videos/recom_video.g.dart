// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recom_video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecomVideoData _$RecomVideoDataFromJson(Map<String, dynamic> json) =>
    RecomVideoData(
      children: (json['children'] as List<dynamic>)
          .map((e) => RecomVideo.fromJson(e as Map<String, dynamic>))
          .toList(),
      classId: (json['class_id'] as num).toInt(),
      imageUrl: json['image_url'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$RecomVideoDataToJson(RecomVideoData instance) =>
    <String, dynamic>{
      'children': instance.children,
      'class_id': instance.classId,
      'image_url': instance.imageUrl,
      'name': instance.name,
    };

RecomVideo _$RecomVideoFromJson(Map<String, dynamic> json) => RecomVideo(
      alias: json['alias'] as String?,
      channelId: (json['channel_id'] as num?)?.toInt(),
      childClass: (json['class'] as num?)?.toInt(),
      createTime: (json['create_time'] as num?)?.toInt(),
      desc: json['desc'] as String?,
      dramaId: (json['drama_id'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      groupId: (json['group_id'] as num?)?.toInt(),
      headImage: json['head_image'] as String?,
      imageUrl: json['image_url'] as String?,
      lan: (json['lan'] as num?)?.toInt(),
      linkUrl: json['link_url'] as String?,
      openType: (json['open_type'] as num?)?.toInt(),
      order: (json['order'] as num?)?.toInt(),
      share: json['share'] as String?,
      status: (json['status'] as num?)?.toInt(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      title: json['title'] as String?,
      type: (json['type'] as num?)?.toInt(),
      uname: json['uname'] as String?,
      vip: (json['vip'] as num?)?.toInt(),
      workId: (json['work_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RecomVideoToJson(RecomVideo instance) =>
    <String, dynamic>{
      'alias': instance.alias,
      'channel_id': instance.channelId,
      'class': instance.childClass,
      'create_time': instance.createTime,
      'desc': instance.desc,
      'drama_id': instance.dramaId,
      'duration': instance.duration,
      'group_id': instance.groupId,
      'head_image': instance.headImage,
      'image_url': instance.imageUrl,
      'lan': instance.lan,
      'link_url': instance.linkUrl,
      'open_type': instance.openType,
      'order': instance.order,
      'share': instance.share,
      'status': instance.status,
      'tags': instance.tags,
      'title': instance.title,
      'type': instance.type,
      'uname': instance.uname,
      'vip': instance.vip,
      'work_id': instance.workId,
    };
