import 'package:json_annotation/json_annotation.dart';

part 'ai_tts_style.g.dart';

@JsonSerializable()
class AiTtsStyle {
    
    ///适合年龄段 1老年2青年3少年4孩童
    @JsonKey(name: "age")
    final int age;
    
    ///图标url
    @JsonKey(name: "icon")
    final String icon;
    @JsonKey(name: "id")
    final int id;
    
    ///1 阿里TTS 2 思必驰3微软
    @JsonKey(name: "mode")
    final int mode;
    
    ///音色名
    @JsonKey(name: "name")
    final String name;

    ///音色风格，TTS音色列表的"style"
    @JsonKey(name: "style")
    String? style;
    
    ///排序层级
    @JsonKey(name: "order")
    final int order;
    
    ///适合性别1男性2女性
    @JsonKey(name: "sex")
    final int sex;
    
    ///合成tts所需音色type（由voice_type和mode组合而来）
    @JsonKey(name: "type")
    final String type;
    
    ///试听声音链接，原速
    @JsonKey(name: "url")
    final String url;
    
    ///1会员免费；2会员收费
    @JsonKey(name: "vip")
    final int vip;
    
    ///音色类型
    @JsonKey(name: "voice_type")
    final String voiceType;

    AiTtsStyle({
        required this.age,
        required this.icon,
        required this.id,
        required this.mode,
        required this.name,
        required this.order,
        required this.sex,
        required this.type,
        required this.url,
        required this.vip,
        required this.voiceType,
    });

    AiTtsStyle copyWith({
        int? age,
        String? icon,
        int? id,
        int? mode,
        String? name,
        int? order,
        int? sex,
        String? type,
        String? url,
        int? vip,
        String? voiceType,
    }) =>
        AiTtsStyle(
            age: age ?? this.age,
            icon: icon ?? this.icon,
            id: id ?? this.id,
            mode: mode ?? this.mode,
            name: name ?? this.name,
            order: order ?? this.order,
            sex: sex ?? this.sex,
            type: type ?? this.type,
            url: url ?? this.url,
            vip: vip ?? this.vip,
            voiceType: voiceType ?? this.voiceType,
        );

    factory AiTtsStyle.fromJson(Map<String, dynamic> json) => _$AiTtsStyleFromJson(json);

    Map<String, dynamic> toJson() => _$AiTtsStyleToJson(this);
}