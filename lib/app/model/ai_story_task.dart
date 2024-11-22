import 'package:json_annotation/json_annotation.dart';

part 'ai_story_task.g.dart';


///单个任务（包括已完成的和正在进行的）
@JsonSerializable()
class AiStoryTask {
    
    ///任务创建时间
    @JsonKey(name: "createtime")
    final int createtime;
    
    ///分辨率高度
    @JsonKey(name: "height")
    final int height;
    
    ///任务的图标url
    @JsonKey(name: "icon")
    final String? icon;
    
    ///tts音色风格
    @JsonKey(name: "soundtype")
    final String soundtype;
    
    ///tts音频速度，默认速度为50表示1.0倍，取值0~100
    @JsonKey(name: "speed")
    final int? speed;
    
    ///web端状态码，0表示排队中，1表示正在进行，2表示完成，3表示web端已领取，4表示已删除
    @JsonKey(name: "status_0")
    final int status0;
    
    ///客户端状态码，0表示排队中，1表示正在进行，2表示完成，3表示客户端已领取，4表示已删除
    @JsonKey(name: "status_1")
    final int status1;
    
    ///AI绘画的模型风格
    @JsonKey(name: "style_name")
    final String styleName;
    
    ///任务id
    @JsonKey(name: "task_id")
    final String taskId;
    
    ///任务耗时，单位是秒
    @JsonKey(name: "time")
    final dynamic time;
    
    ///标题
    @JsonKey(name: "title")
    final String title;
    
    ///分辨率宽度
    @JsonKey(name: "width")
    final int width;

    AiStoryTask({
        required this.createtime,
        required this.height,
        this.icon,
        required this.soundtype,
        this.speed,
        required this.status0,
        required this.status1,
        required this.styleName,
        required this.taskId,
        required this.time,
        required this.title,
        required this.width,
    });

    AiStoryTask copyWith({
        int? createtime,
        int? height,
        String? icon,
        String? soundtype,
        int? speed,
        int? status0,
        int? status1,
        String? styleName,
        String? taskId,
        dynamic time,
        String? title,
        int? width,
    }) =>
        AiStoryTask(
            createtime: createtime ?? this.createtime,
            height: height ?? this.height,
            icon: icon ?? this.icon,
            soundtype: soundtype ?? this.soundtype,
            speed: speed ?? this.speed,
            status0: status0 ?? this.status0,
            status1: status1 ?? this.status1,
            styleName: styleName ?? this.styleName,
            taskId: taskId ?? this.taskId,
            time: time ?? this.time,
            title: title ?? this.title,
            width: width ?? this.width,
        );

    factory AiStoryTask.fromJson(Map<String, dynamic> json) => _$AiStoryTaskFromJson(json);

    Map<String, dynamic> toJson() => _$AiStoryTaskToJson(this);
}