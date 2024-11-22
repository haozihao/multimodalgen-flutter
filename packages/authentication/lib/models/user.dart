import 'package:json_annotation/json_annotation.dart';

/// create by
part 'user.g.dart';

@JsonSerializable()
class User {
  final String name;

  @JsonKey(name: "auth_Token")
  String? authToken = "09078be9ebf444b5ac2be1a30775df66";

  @JsonKey(name: 'head_icon')
  final String headIcon;
  final int gender;

  @JsonKey(name: 'v_type')
  final int vType;
  int pegg = 1000;

  @JsonKey(name: 'id')
  int userId = 10001086;

  @JsonKey(name: 'vip_end_time')
  final int? vipEnd;

  ///1非会员 2月卡等级 3季卡等级 4年卡等级 5终身等级
  @JsonKey(name: 'v_right_level')
  int? vipLevel = 4;

  User({
    required this.name,
    required this.pegg,
    required this.gender,
    required this.vType,
    required this.userId,
    required this.headIcon,
    this.vipEnd,
    this.vipLevel,
    required this.authToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
