import 'package:json_annotation/json_annotation.dart';

part 'ai_analyse_role_scene.g.dart';

@JsonSerializable()
class RolesAndScenes {

  ///接口的平均请求时长，单位毫秒，用于制作进度条
  @JsonKey(name: "average_duration")
  final int? averageDuration;

  ///不用管
  @JsonKey(name: "dataType")
  final String? dataType;

  ///接口的请求时长，单位毫秒
  @JsonKey(name: "duration")
  final int? duration;

  ///人物列表
  @JsonKey(name: "roles")
  final List<Role> roles;

  ///背景列表
  @JsonKey(name: "scenes")
  final List<Scene> scenes;

  RolesAndScenes({
    this.averageDuration,
    this.dataType,
    this.duration,
    required this.roles,
    required this.scenes,
  });

  RolesAndScenes copyWith({
    int? averageDuration,
    String? dataType,
    int? duration,
    List<Role>? roles,
    List<Scene>? scenes,
  }) =>
      RolesAndScenes(
        averageDuration: averageDuration ?? this.averageDuration,
        dataType: dataType ?? this.dataType,
        duration: duration ?? this.duration,
        roles: roles ?? this.roles,
        scenes: scenes ?? this.scenes,
      );

  factory RolesAndScenes.fromJson(Map<String, dynamic> json) => _$RolesAndScenesFromJson(json);

  Map<String, dynamic> toJson() => _$RolesAndScenesToJson(this);
}

@JsonSerializable()
class Role {

  ///人物名
  @JsonKey(name: "name")
  String name;

  ///引用的人物图的名字
  @JsonKey(name: "original_name")
  String? refName;

  ///选择对应的官方人物的id
  int? id;

  ///人物预览图
  String? icon;

  String? prompt;

  int? seed;

  Role({
    required this.name,this.refName,this.id,this.icon,required this.prompt,this.seed
  });


  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  Map<String, dynamic> toJson() => _$RoleToJson(this);
}

@JsonSerializable()
class Scene {

  ///背景名
  @JsonKey(name: "name")
  final String name;

  String prompt;

  Scene({
    required this.name,required this.prompt
  });


  factory Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);

  Map<String, dynamic> toJson() => _$SceneToJson(this);
}