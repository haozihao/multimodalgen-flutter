import 'package:json_annotation/json_annotation.dart';

part 'ai_img.g.dart';

@JsonSerializable()
class AiImg {
  @JsonKey(name: "all_seeds")
  final List<double> allSeeds;

  ///接口返回平均耗时（毫秒）
  @JsonKey(name: "average_duration")
  final double? averageDuration;

  ///接口返回耗时（毫秒）
  @JsonKey(name: "duration")
  final double? duration;

  ///生成的图片的数组
  @JsonKey(name: "images")
  final List<Image> images;

  ///接口访问AI绘画服务的最终参数（包含用户请求参数+服务器优化参数）
  @JsonKey(name: "param")
  final String? param;

  ///服务器绘图耗时（秒）
  @JsonKey(name: "time")
  final double? time;

  AiImg({
    required this.allSeeds,
    this.averageDuration,
    this.duration,
    required this.images,
    this.param,
    this.time,
  });

  AiImg copyWith({
    List<double>? allSeeds,
    double? averageDuration,
    double? duration,
    List<Image>? images,
    String? param,
    double? time,
  }) =>
      AiImg(
        allSeeds: allSeeds ?? this.allSeeds,
        averageDuration: averageDuration ?? this.averageDuration,
        duration: duration ?? this.duration,
        images: images ?? this.images,
        param: param ?? this.param,
        time: time ?? this.time,
      );

  factory AiImg.fromJson(Map<String, dynamic> json) => _$AiImgFromJson(json);

  Map<String, dynamic> toJson() => _$AiImgToJson(this);
}

@JsonSerializable()
class Image {

  ///图片审核结果，目前前端用不上，不用管
  // @JsonKey(name: "labels")
  // final List<String>? labels;

  ///true表示图片没有问题，false表示图片检测不通过，包含敏感内容，此时url失败图片URL
  @JsonKey(name: "pass")
  final bool pass;

  ///生成图片的url，若生成结果审核不通过则为空串
  @JsonKey(name: "url")
  final String url;

  Image({
    // this.labels,
    required this.pass,
    required this.url,
  });

  Image copyWith({
    List<String>? labels,
    bool? pass,
    String? url,
  }) =>
      Image(
        pass: pass ?? this.pass,
        url: url ?? this.url,
      );

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);

  Map<String, dynamic> toJson() => _$ImageToJson(this);
}
