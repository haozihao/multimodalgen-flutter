/// 说明: 草稿数据-数据模型

// """
// CREATE TABLE IF NOT EXISTS category(
//     id INTEGER PRIMARY KEY AUTOINCREMENT,
//     name VARCHAR(64) NOT NULL,
//     color VARCHAR(9) DEFAULT '#FF2196F3',
//     info VARCHAR(256) DEFAULT '这里什么都没有...',
//     created DATETIME NOT NULL,
//     updated DATETIME NOT NULL,
//     priority INTEGER DEFAULT 0,
//     image VARCHAR(128) NULL image DEFAULT ''
//     );"""; //建表语句

class Draft {
  final int? id;
  final String? taskId;
  final String? name;//草稿名称
  final String? info;
  final DateTime? created;
  final DateTime updated;
  final String? icon;//草稿封面图url地址
  final int? priority;
  int status;//默认0表示进行中，1表示完成，2表示失败,3表示已领取,4表示未完成的本地草稿
  int type;

  Draft({
    this.id,
    required this.icon,
    required this.taskId,
    required this.name,
     this.created,
    required this.updated,
    this.priority = 0,
    this.info = '这里什么都没有...',
    required this.status,required this.type,
  });

  factory Draft.fromJson(Map<String, dynamic> map) {
    return Draft(
        id: map['id'],
        taskId: map['task_id'],
        name: map['name'],
        created: DateTime.parse(map["created"]),
        icon: map["icon"],
        status: map["status"],
        type: map["type"],
        updated: DateTime.parse(map["updated"]),
        info: map["info"]);
  }

  factory Draft.fromNetJson(Map<String, dynamic> map) {
    return Draft(
        id: map['id'],
        taskId: map['task_id'],
        name: map['name'],
        created: DateTime.fromMillisecondsSinceEpoch(map["created"]),
        icon: map["icon"],
        priority: map["priority"],
        updated: DateTime.fromMillisecondsSinceEpoch(map["updated"]),
        info: map["info"], status: map['status'], type: map['type']);
  }

  Map toJson() => {
    "id": id,
    "task_id":taskId,
    "name": name,
    "info": info,
    "created": created?.millisecondsSinceEpoch,
    "updated": updated.millisecondsSinceEpoch,
    "icon": icon,
    "priority": priority,
    "type":type,
  };

  @override
  String toString() {
    return '{id: $id, name: $name, taskId: $taskId, info: $info, created: $created, updated: $updated, icon: $icon, priority: $priority,status: $status,type: $type}';
  }

  @override
  List<Object?> get props =>
      [id, taskId,name, created, icon, info, updated, priority,status,type];
}
