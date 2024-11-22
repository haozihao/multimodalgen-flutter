import 'package:json_annotation/json_annotation.dart';

part 'ai_prompt_words.g.dart';

@JsonSerializable()
class PromptWord {
  @JsonKey(name: "children")
  final List<DatumChild> children;

  ///大类名称
  @JsonKey(name: "name")
  final String name;

  ///大类标识字段
  @JsonKey(name: "type")
  final int type;

  PromptWord({
    required this.children,
    required this.name,
    required this.type,
  });

  PromptWord copyWith({
    List<DatumChild>? children,
    String? name,
    int? type,
  }) =>
      PromptWord(
        children: children ?? this.children,
        name: name ?? this.name,
        type: type ?? this.type,
      );

  factory PromptWord.fromJson(Map<String, dynamic> json) => _$PromptWordFromJson(json);

  Map<String, dynamic> toJson() => _$PromptWordToJson(this);
}

@JsonSerializable()
class DatumChild {
  @JsonKey(name: "children")
  final List<PurpleChild> children;

  ///分类层级，为-1表示最底层，无children
  @JsonKey(name: "class_num")
  final int classNum;

  ///英文名
  @JsonKey(name: "en_name")
  final String enName;
  @JsonKey(name: "id")
  final int id;

  ///中文名
  @JsonKey(name: "name")
  final String name;

  ///父类的id，如果为0表示无父类
  @JsonKey(name: "parent_id")
  final int parentId;

  ///所属大类
  @JsonKey(name: "type")
  final int type;

  DatumChild({
    required this.children,
    required this.classNum,
    required this.enName,
    required this.id,
    required this.name,
    required this.parentId,
    required this.type,
  });

  DatumChild copyWith({
    List<PurpleChild>? children,
    int? classNum,
    String? enName,
    int? id,
    String? name,
    int? parentId,
    int? type,
  }) =>
      DatumChild(
        children: children ?? this.children,
        classNum: classNum ?? this.classNum,
        enName: enName ?? this.enName,
        id: id ?? this.id,
        name: name ?? this.name,
        parentId: parentId ?? this.parentId,
        type: type ?? this.type,
      );

  factory DatumChild.fromJson(Map<String, dynamic> json) => _$DatumChildFromJson(json);

  Map<String, dynamic> toJson() => _$DatumChildToJson(this);
}

@JsonSerializable()
class PurpleChild {
  @JsonKey(name: "children")
  List<FluffyChild> children;
  @JsonKey(name: "class_num")
  final int classNum;
  @JsonKey(name: "en_name")
  final String enName;
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "parent_id")
  final int parentId;
  @JsonKey(name: "type")
  final int type;

  PurpleChild({
    required this.children,
    required this.classNum,
    required this.enName,
    required this.id,
    required this.name,
    required this.parentId,
    required this.type,
  });

  PurpleChild copyWith({
    List<FluffyChild>? children,
    int? classNum,
    String? enName,
    int? id,
    String? name,
    int? parentId,
    int? type,
  }) =>
      PurpleChild(
        children: children ?? this.children,
        classNum: classNum ?? this.classNum,
        enName: enName ?? this.enName,
        id: id ?? this.id,
        name: name ?? this.name,
        parentId: parentId ?? this.parentId,
        type: type ?? this.type,
      );

  factory PurpleChild.fromJson(Map<String, dynamic> json) => _$PurpleChildFromJson(json);

  Map<String, dynamic> toJson() => _$PurpleChildToJson(this);
}

@JsonSerializable()
class FluffyChild {
  @JsonKey(name: "class_num")
  final int classNum;
  @JsonKey(name: "en_name")
  String enName;
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "parent_id")
  final int parentId;
  @JsonKey(name: "type")
  final int type;

  FluffyChild({
    required this.classNum,
    required this.enName,
    required this.id,
    required this.name,
    required this.parentId,
    required this.type,
  });

  FluffyChild copyWith({
    int? classNum,
    String? enName,
    int? id,
    String? name,
    int? parentId,
    int? type,
  }) =>
      FluffyChild(
        classNum: classNum ?? this.classNum,
        enName: enName ?? this.enName,
        id: id ?? this.id,
        name: name ?? this.name,
        parentId: parentId ?? this.parentId,
        type: type ?? this.type,
      );

  factory FluffyChild.fromJson(Map<String, dynamic> json) => _$FluffyChildFromJson(json);

  Map<String, dynamic> toJson() => _$FluffyChildToJson(this);
}