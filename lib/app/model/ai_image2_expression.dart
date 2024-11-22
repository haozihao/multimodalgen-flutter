// To parse this JSON data, do
//
//     final image2Expression = image2ExpressionFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'ai_image2_expression.g.dart';

Image2Expression image2ExpressionFromJson(String str) => Image2Expression.fromJson(json.decode(str));

String image2ExpressionToJson(Image2Expression data) => json.encode(data.toJson());


///Image2Expression
@JsonSerializable()
class Image2Expression {

  ///表情名称，不填则随机，传固定则生成指定的表情，具体表情列表咨询产品
  @JsonKey(name: "expression")
  String? expression;

  ///原始图片，必传。图生视频的图片URL数据。默认传1024X576的图片数据。
  @JsonKey(name: "image")
  String image;

  ///随机种子，传-1则每次生成不同的运动。
  @JsonKey(name: "seed")
  int? seed;

  Image2Expression({
    this.expression,
    required this.image,
    this.seed,
  });

  Image2Expression copyWith({
    String? expression,
    String? image,
    int? seed,
  }) =>
      Image2Expression(
        expression: expression ?? this.expression,
        image: image ?? this.image,
        seed: seed ?? this.seed,
      );

  factory Image2Expression.fromJson(Map<String, dynamic> json) => _$Image2ExpressionFromJson(json);

  Map<String, dynamic> toJson() => _$Image2ExpressionToJson(this);
}