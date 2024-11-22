// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_image2_video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Image2VideoParam _$Image2VideoParamFromJson(Map<String, dynamic> json) =>
    Image2VideoParam(
      duration: (json['duration'] as num?)?.toInt(),
      fps: (json['fps'] as num?)?.toInt(),
      image: json['image'] as String,
      modelVersion: (json['model_version'] as num?)?.toInt(),
      motionStrength: (json['motion_strength'] as num?)?.toInt(),
      prompt: json['prompt'] as String?,
      ratio: (json['ratio'] as num?)?.toInt(),
      sampler: json['sampler'] as String?,
      seed: (json['seed'] as num?)?.toInt(),
      steps: (json['steps'] as num?)?.toInt(),
    );

Map<String, dynamic> _$Image2VideoParamToJson(Image2VideoParam instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'fps': instance.fps,
      'image': instance.image,
      'model_version': instance.modelVersion,
      'motion_strength': instance.motionStrength,
      'prompt': instance.prompt,
      'ratio': instance.ratio,
      'sampler': instance.sampler,
      'seed': instance.seed,
      'steps': instance.steps,
    };
