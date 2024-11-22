import 'package:json_annotation/json_annotation.dart';

part 'ai_roles_official.g.dart';

@JsonSerializable()
class AiRoles {
  ///性别
  @JsonKey(name: "sex")
  final String sex;

  ///性别id, 1男性 2女性
  @JsonKey(name: "sex_id")
  final int sexId;

  ///tag分类
  @JsonKey(name: "tags")
  final List<Tag> tags;

  AiRoles({
    required this.sex,
    required this.sexId,
    required this.tags,
  });

  AiRoles copyWith({
    String? sex,
    int? sexId,
    List<Tag>? tags,
  }) =>
      AiRoles(
        sex: sex ?? this.sex,
        sexId: sexId ?? this.sexId,
        tags: tags ?? this.tags,
      );

  factory AiRoles.fromJson(Map<String, dynamic> json) =>
      _$AiRolesFromJson(json);

  Map<String, dynamic> toJson() => _$AiRolesToJson(this);
}

@JsonSerializable()
class Tag {
  ///人物图Array
  @JsonKey(name: "children")
  final List<AiRole> children;

  ///tagId
  @JsonKey(name: "tagId")
  final int tagId;

  ///tag中文名
  @JsonKey(name: "tagName")
  final String tagName;

  Tag({
    required this.children,
    required this.tagId,
    required this.tagName,
  });

  Tag copyWith({
    List<AiRole>? children,
    int? tagId,
    String? tagName,
  }) =>
      Tag(
        children: children ?? this.children,
        tagId: tagId ?? this.tagId,
        tagName: tagName ?? this.tagName,
      );

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);
}

@JsonSerializable()
class AiRole {
  ///icon
  @JsonKey(name: "icon")
  final String? icon;

  ///人物图名字
  @JsonKey(name: "name")
  final String? name;

  ///价格
  @JsonKey(name: "price")
  final int? price;

  ///人物图信息透传字段
  @JsonKey(name: "role_prompt_info")
  final RolePromptInfo? rolePromptInfo;

  ///性别
  @JsonKey(name: "sex")
  final int? sex;

  ///风格
  @JsonKey(name: "style")
  final int? style;
  @JsonKey(name: "tag_id")
  final int? tagId;

  ///角色id
  final int id;

  AiRole({
    this.icon,
    this.name,
    this.price,
    this.rolePromptInfo,
    this.sex,
    this.style,
    this.tagId,
    required this.id,
  });

  AiRole copyWith({
    String? icon,
    String? name,
    int? price,
    RolePromptInfo? rolePromptInfo,
    int? sex,
    int? style,
    int? tagId,
    required int id,
  }) =>
      AiRole(
          icon: icon ?? this.icon,
          name: name ?? this.name,
          price: price ?? this.price,
          rolePromptInfo: rolePromptInfo ?? this.rolePromptInfo,
          sex: sex ?? this.sex,
          style: style ?? this.style,
          tagId: tagId ?? this.tagId,
          id: this.id);

  factory AiRole.fromJson(Map<String, dynamic> json) => _$AiRoleFromJson(json);

  Map<String, dynamic> toJson() => _$AiRoleToJson(this);
}

///人物图信息透传字段
@JsonSerializable()
class RolePromptInfo {
  ///负向提示词
  @JsonKey(name: "negative_prompt")
  final String negativePrompt;

  ///角色描述
  @JsonKey(name: "prompt")
  final String prompt;

  ///角色图种子号，Long型
  @JsonKey(name: "seed")
  final int? seed;

  ///可不传，角色形象图url，只用于前端进行人物形象展示，后端没有用到
  @JsonKey(name: "url")
  final String? url;

  ///标签列表, 标签列表
  @JsonKey(name: "tags")
  List<DiyTag>? tags;

  RolePromptInfo(
      {required this.negativePrompt,
      required this.prompt,
      required this.seed,
      this.url,
      this.tags});

  RolePromptInfo copyWith({
    String? negativePrompt,
    String? prompt,
    int? seed,
    String? url,
    List<DiyTag>? tags,
  }) =>
      RolePromptInfo(
        negativePrompt: negativePrompt ?? this.negativePrompt,
        prompt: prompt ?? this.prompt,
        seed: seed ?? this.seed,
        url: url ?? this.url,
        tags: tags ?? this.tags,
      );

  factory RolePromptInfo.fromJson(Map<String, dynamic> json) =>
      _$RolePromptInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RolePromptInfoToJson(this);
}

@JsonSerializable()
class DiyTag {
  ///英文标签词
  @JsonKey(name: "en")
  final String en;

  ///类型
  @JsonKey(name: "type")
  final int type;

  ///中文标签词
  @JsonKey(name: "zh")
  final String zh;

  DiyTag({
    required this.en,
    required this.type,
    required this.zh,
  });

  DiyTag copyWith({
    String? en,
    int? type,
    String? zh,
  }) =>
      DiyTag(
        en: en ?? this.en,
        type: type ?? this.type,
        zh: zh ?? this.zh,
      );

  factory DiyTag.fromJson(Map<String, dynamic> json) => _$DiyTagFromJson(json);

  Map<String, dynamic> toJson() => _$DiyTagToJson(this);
}
