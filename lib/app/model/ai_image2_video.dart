import 'package:json_annotation/json_annotation.dart';

part 'ai_image2_video.g.dart';


///业务参数
@JsonSerializable()
class Image2VideoParam {
  ///时长（单位秒），目前只支持3秒，4秒，5秒，6秒
  @JsonKey(name: "duration")
  int? duration;

  ///是否需要服务器进行Ai补FPS,默认返回6fps，另外可传24
  @JsonKey(name: "fps")
  int? fps;

  ///必传。图生视频的图片base64数据。默认传1024X576的图片数据。
  @JsonKey(name: "image")
  String image;

  ///模型版本，1表示1号版本，2表示5B版本。默认为1
  @JsonKey(name: "model_version")
  int? modelVersion;

  ///运动生成都幅度，10-1023之间，越大表示运动幅度越大，默认不传为80
  @JsonKey(name: "motion_strength")
  int? motionStrength;

  ///引导图生视频的提示词
  @JsonKey(name: "prompt")
  String? prompt;

  ///生成视频宽高比例，保持和上传图片一致,默认为2，0表示1:1，1表示4:3，2表示16:9,3表示9:16，4表示3:4
  @JsonKey(name: "ratio")
  int? ratio;

  ///采样算法，默认为dpm++2m
  @JsonKey(name: "sampler")
  final String? sampler;

  ///随机种子，传-1则每次生成不同的运动。传固定则每次生成一致的运动，默认位固定
  @JsonKey(name: "seed")
  int? seed;

  ///迭代步数，默认为30.步数越大，计算时间越久
  @JsonKey(name: "steps")
  int? steps;

  Image2VideoParam({
    this.duration,
    this.fps,
    required this.image,
    this.modelVersion,
    this.motionStrength,
    this.prompt,
    this.ratio,
    this.sampler,
    this.seed,
    this.steps,
  });

  Image2VideoParam copyWith({
    int? duration,
    int? fps,
    String? image,
    int? modelVersion,
    int? motionStrength,
    String? prompt,
    int? ratio,
    String? sampler,
    int? seed,
    int? steps,
  }) =>
      Image2VideoParam(
        duration: duration ?? this.duration,
        fps: fps ?? this.fps,
        image: image ?? this.image,
        modelVersion: modelVersion ?? this.modelVersion,
        motionStrength: motionStrength ?? this.motionStrength,
        prompt: prompt ?? this.prompt,
        ratio: ratio ?? this.ratio,
        sampler: sampler ?? this.sampler,
        seed: seed ?? this.seed,
        steps: steps ?? this.steps,
      );

  factory Image2VideoParam.fromJson(Map<String, dynamic> json) => _$Image2VideoParamFromJson(json);

  Map<String, dynamic> toJson() => _$Image2VideoParamToJson(this);
}
