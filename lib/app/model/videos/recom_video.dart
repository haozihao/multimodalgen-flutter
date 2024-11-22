// To parse this JSON data, do
//
//     final recomVideo = recomVideoFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';

part 'recom_video.g.dart';

@JsonSerializable()
class RecomVideoData {
  @JsonKey(name: "children")
  List<RecomVideo> children;

  ///系列课程的id，1官方视频 2基础课程 3进阶课程
  @JsonKey(name: "class_id")
  int classId;

  ///系列课程的封面图的url
  @JsonKey(name: "image_url")
  String imageUrl;

  ///系列课程的名称
  @JsonKey(name: "name")
  String name;

  RecomVideoData({
    required this.children,
    required this.classId,
    required this.imageUrl,
    required this.name,
  });

  RecomVideoData copyWith({
    List<RecomVideo>? children,
    int? classId,
    String? imageUrl,
    String? name,
  }) =>
      RecomVideoData(
        children: children ?? this.children,
        classId: classId ?? this.classId,
        imageUrl: imageUrl ?? this.imageUrl,
        name: name ?? this.name,
      );

  factory RecomVideoData.fromJson(Map<String, dynamic> json) => _$RecomVideoDataFromJson(json);

  Map<String, dynamic> toJson() => _$RecomVideoDataToJson(this);
}

@JsonSerializable()
class RecomVideo {
  ///视频描述的别称
  @JsonKey(name: "alias")
  String? alias;
  @JsonKey(name: "channel_id")
  int? channelId;
  @JsonKey(name: "class")
  int? childClass;
  @JsonKey(name: "create_time")
  int? createTime;
  @JsonKey(name: "desc")
  String? desc;
  @JsonKey(name: "drama_id")
  int? dramaId;
  @JsonKey(name: "duration")
  int? duration;
  @JsonKey(name: "group_id")
  int? groupId;
  @JsonKey(name: "head_image")
  String? headImage;

  ///封面链接
  @JsonKey(name: "image_url")
  String? imageUrl;

  ///视频所归属的语言地区1中文，2英语，3日语
  @JsonKey(name: "lan")
  int? lan;

  ///视频播放链接
  @JsonKey(name: "link_url")
  String? linkUrl;
  @JsonKey(name: "open_type")
  int? openType;
  @JsonKey(name: "order")
  int? order;
  @JsonKey(name: "share")
  String? share;
  @JsonKey(name: "status")
  int? status;
  @JsonKey(name: "tags")
  List<String>? tags;
  @JsonKey(name: "title")
  String? title;

  ///视频内容 默认为1 视频教程 2 每日精品内容
  @JsonKey(name: "type")
  int? type;
  @JsonKey(name: "uname")
  String? uname;

  ///会员专享 1会员专享 2所有用户
  @JsonKey(name: "vip")
  int? vip;
  @JsonKey(name: "work_id")
  int? workId;

  RecomVideo({
    this.alias,
    this.channelId,
    this.childClass,
    this.createTime,
    this.desc,
    this.dramaId,
    this.duration,
    this.groupId,
    this.headImage,
    this.imageUrl,
    this.lan,
    this.linkUrl,
    this.openType,
    this.order,
    this.share,
    this.status,
    this.tags,
    this.title,
    this.type,
    this.uname,
    this.vip,
    this.workId,
  });

  RecomVideo copyWith({
    String? alias,
    int? channelId,
    int? childClass,
    int? createTime,
    String? desc,
    int? dramaId,
    int? duration,
    int? groupId,
    String? headImage,
    String? imageUrl,
    int? lan,
    String? linkUrl,
    int? openType,
    int? order,
    String? share,
    int? status,
    List<String>? tags,
    String? title,
    int? type,
    String? uname,
    int? vip,
    int? workId,
  }) =>
      RecomVideo(
        alias: alias ?? this.alias,
        channelId: channelId ?? this.channelId,
        childClass: childClass ?? this.childClass,
        createTime: createTime ?? this.createTime,
        desc: desc ?? this.desc,
        dramaId: dramaId ?? this.dramaId,
        duration: duration ?? this.duration,
        groupId: groupId ?? this.groupId,
        headImage: headImage ?? this.headImage,
        imageUrl: imageUrl ?? this.imageUrl,
        lan: lan ?? this.lan,
        linkUrl: linkUrl ?? this.linkUrl,
        openType: openType ?? this.openType,
        order: order ?? this.order,
        share: share ?? this.share,
        status: status ?? this.status,
        tags: tags ?? this.tags,
        title: title ?? this.title,
        type: type ?? this.type,
        uname: uname ?? this.uname,
        vip: vip ?? this.vip,
        workId: workId ?? this.workId,
      );

  factory RecomVideo.fromJson(Map<String, dynamic> json) => _$RecomVideoFromJson(json);

  Map<String, dynamic> toJson() => _$RecomVideoToJson(this);
}