// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      name: json['name'] as String,
      pegg: json['pegg'] as int,
      gender: json['gender'] as int,
      vType: json['v_type'] as int,
      userId: json['id'] as int,
      headIcon: json['head_icon'] as String,
      vipEnd: json['vip_end_time'] as int?,
      vipLevel: json['v_right_level'] as int?,
      authToken: json['auth_Token'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'auth_Token': instance.authToken,
      'head_icon': instance.headIcon,
      'gender': instance.gender,
      'v_type': instance.vType,
      'pegg': instance.pegg,
      'id': instance.userId,
      'vip_end_time': instance.vipEnd,
      'v_right_level': instance.vipLevel,
    };
