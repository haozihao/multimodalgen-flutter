import 'package:json_annotation/json_annotation.dart';

import 'TweetScript.dart';
import 'config/ai_analyse_role_scene.dart';

part 'ai_draft.g.dart';

@JsonSerializable(explicitToJson: true)
class DraftRender {
  static final int CURRENT_DRAFT_VERSION = 1;

  int? draftVersion;

  int? id;

  String name;

  ///0正在进行中，1已完成，点领取,2任务失败，3已完成的租聘 4:标识未完成 5:预备草稿，未插入数据库的
  int status = -1;

  TweetScript? tweetScript;

  ///Ai识别出来的人物和场景信息
  final RolesAndScenes? rolesAndScenes;

  ///风格的id，看后续是否移动到剧本里
  int? styleId;

  ///风格的类型，默认为0表示云端，1表示SD WEB-UI,2表示FAST-SD
  int? styleType;

  ///0,1，代表短剧，2图集，3追爆款任务， 4 自定义角色，5表示本地SD任务
  int? type;

  ///本地追爆款音频地址/或者一键原创自己上传音频地址，只有type为1和3时有值
  String? audioPath;
  int? audioSeconds;

  ///1现代，2古代
  int? draftShidai;

  ///原文内容，保存的是否不保存
  String? originalContent;

  ///每张图片是否锁定固定人物的种子，默认是锁定。
  bool? lockedSeed;

  DraftRender(
      {this.id,
      required this.name,
      this.tweetScript,
      this.rolesAndScenes,
      this.styleId,
      required this.status,
      this.styleType,
      required this.draftVersion,
      required this.type,
      this.audioPath,
      this.audioSeconds,
      this.draftShidai,
      this.originalContent,
      this.lockedSeed});

  factory DraftRender.fromJson(Map<String, dynamic> json) =>
      _$DraftRenderFromJson(json);

  Map<String, dynamic> toJson() => _$DraftRenderToJson(this);
}
