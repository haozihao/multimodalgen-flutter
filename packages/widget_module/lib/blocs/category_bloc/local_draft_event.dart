part of 'draft_bloc.dart';

/// 说明:  本地草稿相关事件

abstract class DraftEvent extends Equatable{
  const DraftEvent();
  @override
  List<Object?> get props => [];
}
// 加载 收藏集 事件
class EventLoadDrafts extends DraftEvent{
  const EventLoadDrafts();
  @override
  List<Object> get props => [];
}

// 将一个 widget 添加/移除 收藏集
class EventToggleWidget extends DraftEvent{
  final int widgetId;
  final int categoryId;
  const EventToggleWidget({
    required this.widgetId,
    required this.categoryId,
  });

  @override
  List<Object> get props => [widgetId,categoryId];
}

// 删除 收藏集
class EventDeleteCategory extends DraftEvent{
  final int id;

  const EventDeleteCategory({required this.id});

  @override
  List<Object> get props => [id];
}

// 添加 草稿事件
class EventAddDraft extends DraftEvent{
  final String name;
  final String taskId;
  final int? type;
  final int status;
  final String icon;

  const EventAddDraft({
    required this.name,
    required this.taskId,
    required this.icon,
    required this.status,
    this.type,
  });

  @override
  List<Object?> get props => [name, taskId, type,status,icon];
}

// 更新 草稿数据
class EventUpdateDraft extends DraftEvent {
  final int id;
  final String? taskId;
  final String? name;
  final String? icon;
  final int status;
  final int type;

  const EventUpdateDraft({
    this.name,
    this.taskId,
    this.icon,
    required this.id,required this.status,required this.type,
  });

  @override
  List<Object?> get props => [name, icon, id,status,taskId,type];
}