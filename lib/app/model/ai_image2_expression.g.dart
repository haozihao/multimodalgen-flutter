// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_image2_expression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Image2Expression _$Image2ExpressionFromJson(Map<String, dynamic> json) =>
    Image2Expression(
      expression: json['expression'] as String?,
      image: json['image'] as String,
      seed: (json['seed'] as num?)?.toInt(),
    );

Map<String, dynamic> _$Image2ExpressionToJson(Image2Expression instance) =>
    <String, dynamic>{
      'expression': instance.expression,
      'image': instance.image,
      'seed': instance.seed,
    };
