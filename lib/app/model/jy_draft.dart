import 'package:json_annotation/json_annotation.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';

part 'jy_draft.g.dart';

@JsonSerializable(explicitToJson: true)
class JyDraft {
  ///草稿名称
  @JsonKey(name: "name")
  final String name;

  ///画面比例:默认为0，0表示1:1，1表示4:3，2表示16:9，3表示9:16，4表示3:4，5表示2:3，6表示3:2
  @JsonKey(name: "ratio")
  final int ratio;

  @JsonKey(name: "scenes")
  final List<Scene> scenes;

  JyDraft({
    required this.name,
    required this.scenes,
    required this.ratio,
  });

  JyDraft copyWith({String? name, List<Scene>? scenes, int? ratio}) => JyDraft(
        name: name ?? this.name,
        scenes: scenes ?? this.scenes,
        ratio: ratio ?? this.ratio,
      );

  factory JyDraft.fromJson(Map<String, dynamic> json) =>
      _$JyDraftFromJson(json);

  Map<String, dynamic> toJson() => _$JyDraftToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Scene {
  ///动画组合类型
  @JsonKey(name: "anime")
  final Anime? anime;

  ///资源的相对路径，如果上面track_type为text时可不传
  @JsonKey(name: "file_path")
  final String? filePath;

  ///同width释义
  @JsonKey(name: "height")
  final int height;

  ///动效类型，当前track为视频或图片时的运动类型。具体见前端定义的向左、向右、向上、向下
  @JsonKey(name: "image_effect")
  final String? imageEffect;

  ///当track_type为text时，传递字幕的文字
  @JsonKey(name: "text")
  final String? text;

  ///持续时间，ms为单位
  @JsonKey(name: "time")
  final int time;

  ///多条同类型轨道时使用
  @JsonKey(name: "track_index")
  final int? trackIndex;

  ///起始时间，ms为单位
  @JsonKey(name: "start")
  final int? start;

  ///增加的媒体类型，从下面选"image","text","video","audio"
  @JsonKey(name: "track_type")
  final String trackType;

  ///资源的宽度，如image时，表示图片宽度
  @JsonKey(name: "width")
  final int width;

  Scene({
    this.anime,
    this.filePath,
    required this.height,
    this.imageEffect,
    this.text,
    required this.time,
    this.trackIndex,
    this.start,
    required this.trackType,
    required this.width,
  });

  Scene copyWith({
    Anime? anime,
    String? filePath,
    int? height,
    String? imageEffect,
    String? text,
    int? time,
    int? trackIndex,
    int? start,
    String? trackType,
    int? width,
  }) =>
      Scene(
        anime: anime ?? this.anime,
        filePath: filePath ?? this.filePath,
        height: height ?? this.height,
        imageEffect: imageEffect ?? this.imageEffect,
        text: text ?? this.text,
        time: time ?? this.time,
        trackIndex: trackIndex ?? this.trackIndex,
        start: start ?? this.start,
        trackType: trackType ?? this.trackType,
        width: width ?? this.width,
      );

  factory Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);

  Map<String, dynamic> toJson() => _$SceneToJson(this);
}
