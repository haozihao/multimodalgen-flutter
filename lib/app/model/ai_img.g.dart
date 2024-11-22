// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_img.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiImg _$AiImgFromJson(Map<String, dynamic> json) => AiImg(
      allSeeds: (json['all_seeds'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      averageDuration: (json['average_duration'] as num?)?.toDouble(),
      duration: (json['duration'] as num?)?.toDouble(),
      images: (json['images'] as List<dynamic>)
          .map((e) => Image.fromJson(e as Map<String, dynamic>))
          .toList(),
      param: json['param'] as String?,
      time: (json['time'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AiImgToJson(AiImg instance) => <String, dynamic>{
      'all_seeds': instance.allSeeds,
      'average_duration': instance.averageDuration,
      'duration': instance.duration,
      'images': instance.images,
      'param': instance.param,
      'time': instance.time,
    };

Image _$ImageFromJson(Map<String, dynamic> json) => Image(
      pass: json['pass'] as bool,
      url: json['url'] as String,
    );

Map<String, dynamic> _$ImageToJson(Image instance) => <String, dynamic>{
      'pass': instance.pass,
      'url': instance.url,
    };
