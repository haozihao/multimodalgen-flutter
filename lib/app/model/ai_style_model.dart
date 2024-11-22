import 'package:json_annotation/json_annotation.dart';

part 'ai_style_model.g.dart';

@JsonSerializable()
class AiStyleModel {
  @JsonKey(name: "children")
  final List<Child> children;
  @JsonKey(name: "id")
  final int id;

  ///风格类别名称
  @JsonKey(name: "name")
  final String name;

  ///下发顺序
  @JsonKey(name: "sort")
  final int? sort;

  AiStyleModel({
    required this.children,
    required this.id,
    required this.name,
    this.sort,
  });

  AiStyleModel copyWith({
    List<Child>? children,
    int? id,
    String? name,
    int? sort,
  }) =>
      AiStyleModel(
        children: children ?? this.children,
        id: id ?? this.id,
        name: name ?? this.name,
        sort: sort ?? this.sort,
      );

  factory AiStyleModel.fromJson(Map<String, dynamic> json) => _$AiStyleModelFromJson(json);

  Map<String, dynamic> toJson() => _$AiStyleModelToJson(this);
}

@JsonSerializable()
class Child {

  ///图示
  @JsonKey(name: "icon")
  final String icon;

  ///风格id
  @JsonKey(name: "id")
  final int id;

  ///lora文件名
  @JsonKey(name: "lora_file_name")
  final String? loraFileName;

  ///模型大类, 0表示1.5模型 1表示2.0模型
  @JsonKey(name: "model_class")
  final int? modelClass;

  ///底模文件名
  @JsonKey(name: "model_file_name")
  final String modelFileName;

  ///风格名称, 仅做前端展示用
  @JsonKey(name: "name")
  final String name;

  ///风格预置信息, Ai绘画时的透传字段，json解析后的结构详见数据模型PresetInfo
  @JsonKey(name: "preset_info")
  final String presetInfo;

  ///风格类别
  @JsonKey(name: "type")
  final int type;

  ///uid, -1表示官方风格，其他表示用户风格
  @JsonKey(name: "uid")
  final int? uid;

  Child({
    required this.icon,
    required this.id,
    this.loraFileName,
    this.modelClass,
    required this.modelFileName,
    required this.name,
    required this.presetInfo,
    required this.type,
    this.uid,
  });

  Child copyWith({
    String? icon,
    int? id,
    String? loraFileName,
    int? modelClass,
    String? modelFileName,
    String? name,
    String? presetInfo,
    int? type,
    int? uid,
  }) =>
      Child(
        icon: icon ?? this.icon,
        id: id ?? this.id,
        loraFileName: loraFileName ?? this.loraFileName,
        modelClass: modelClass ?? this.modelClass,
        modelFileName: modelFileName ?? this.modelFileName,
        name: name ?? this.name,
        presetInfo: presetInfo ?? this.presetInfo,
        type: type ?? this.type,
        uid: uid ?? this.uid,
      );

  factory Child.fromJson(Map<String, dynamic> json) => _$ChildFromJson(json);

  Map<String, dynamic> toJson() => _$ChildToJson(this);
}