import 'package:json_annotation/json_annotation.dart';

part 'diy_roles.g.dart';
///CustomRolePicture
@JsonSerializable()
class CustomRolePicture {

  ///icon, 传1：1尺寸的path
  @JsonKey(name: "icon")
  String icon;

  ///id
  @JsonKey(name: "id")
  final int? id;

  ///人物图名字
  @JsonKey(name: "name")
  final String name;

  ///价格, 预留字段，暂未使用
  @JsonKey(name: "price")
  final int? price;

  ///透传数据
  @JsonKey(name: "role_prompt_info")
  RolePromptInfo? rolePromptInfo;

  ///性别, 1 男性，2 女性
  @JsonKey(name: "sex")
  final int sex;

  ///状态, 仅用于前端识别：1上线 2下线 3审核中 4用户删除
  @JsonKey(name: "status")
  final int status;

  ///风格, 见获取AI绘画风格模型接口的返回数据
  @JsonKey(name: "style")
  int style;

  ///风格名称，style对应的风格名称
  @JsonKey(name: "style_name")
  final String? styleName;

  ///更新时间, 毫秒级时间戳，Long型
  @JsonKey(name: "update_time")
  final double? updateTime;

  CustomRolePicture({
    required this.icon,
    required this.id,
    required this.name,
    this.price,
    this.rolePromptInfo,
    required this.sex,
    required this.status,
    required this.style,
    this.styleName,
    this.updateTime,
  });

  CustomRolePicture copyWith({
    String? icon,
    int? id,
    String? name,
    int? price,
    RolePromptInfo? rolePromptInfo,
    int? sex,
    int? status,
    int? style,
    String? styleName,
    double? updateTime,
  }) =>
      CustomRolePicture(
        icon: icon ?? this.icon,
        id: id ?? this.id,
        name: name ?? this.name,
        price: price ?? this.price,
        rolePromptInfo: rolePromptInfo ?? this.rolePromptInfo,
        sex: sex ?? this.sex,
        status: status ?? this.status,
        style: style ?? this.style,
        styleName: styleName ?? this.styleName,
        updateTime: updateTime ?? this.updateTime,
      );

  factory CustomRolePicture.fromJson(Map<String, dynamic> json) => _$CustomRolePictureFromJson(json);

  Map<String, dynamic> toJson() => _$CustomRolePictureToJson(this);
}


///透传数据
@JsonSerializable()
class RolePromptInfo {

  ///人物图列表, 索引对应不同尺寸。0表示1:1，1表示4:3，2表示16:9，3表示9:16，4表示3:4，5表示2:3，6表示3:2
  @JsonKey(name: "imgs")
  List<Img> imgs;

  ///负向提示词
  @JsonKey(name: "negative_prompt")
  final String negativePrompt;

  ///正向提示词
  @JsonKey(name: "prompt")
  String prompt;

  ///标签列表, 标签列表
  @JsonKey(name: "tags")
  List<Tag>? tags;

  RolePromptInfo({
    required this.imgs,
    required this.negativePrompt,
    required this.prompt,
    this.tags,
  });

  RolePromptInfo copyWith({
    List<Img>? imgs,
    String? negativePrompt,
    String? prompt,
    List<Tag>? tags,
  }) =>
      RolePromptInfo(
        imgs: imgs ?? this.imgs,
        negativePrompt: negativePrompt ?? this.negativePrompt,
        prompt: prompt ?? this.prompt,
        tags: tags ?? this.tags,
      );

  factory RolePromptInfo.fromJson(Map<String, dynamic> json) => _$RolePromptInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RolePromptInfoToJson(this);
}

@JsonSerializable()
class Img {

  ///预览图路径
  @JsonKey(name: "path")
  final String path;

  ///人物图种子号, Long型
  @JsonKey(name: "seed")
  final double seed;

  Img({
    required this.path,
    required this.seed,
  });

  Img copyWith({
    String? path,
    double? seed,
  }) =>
      Img(
        path: path ?? this.path,
        seed: seed ?? this.seed,
      );

  factory Img.fromJson(Map<String, dynamic> json) => _$ImgFromJson(json);

  Map<String, dynamic> toJson() => _$ImgToJson(this);
}

@JsonSerializable()
class Tag {

  ///英文标签词
  @JsonKey(name: "en")
  final String en;

  ///类型
  @JsonKey(name: "type")
  final int type;

  ///中文标签词
  @JsonKey(name: "zh")
  final String zh;

  Tag({
    required this.en,
    required this.type,
    required this.zh,
  });

  Tag copyWith({
    String? en,
    int? type,
    String? zh,
  }) =>
      Tag(
        en: en ?? this.en,
        type: type ?? this.type,
        zh: zh ?? this.zh,
      );

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);
}
