import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storage/storage.dart';
import 'package:widget_repository/widget_repository.dart';

part 'draft_state.dart';

part 'local_draft_event.dart';

/// 本地草稿数据管理
class DraftBloc extends Bloc<DraftEvent, DraftState> {
  final DraftDbRepository repository;

  DraftBloc({required this.repository}) : super(const CategoryLoadingState()) {
    on<DraftEvent>(_onCategoryEvent);
  }

  void _onCategoryEvent(DraftEvent event, Emitter<DraftState> emit) async {
    if (event is EventLoadDrafts) {
      print('接收到了刷新首页草稿Event,EventLoadCategory');
      emit(const CategoryLoadingState());
      // 使用 repository 加载 收藏集数据
      final drafts = await repository.loadDrafts();
      drafts.isEmpty
          ? emit(const CategoryEmptyState())
          : emit(DraftLoadedState(drafts));
    }

    if (event is EventDeleteCategory) {
      await repository.deleteCategory(event.id);
      add(const EventLoadDrafts());
    }

    if (event is EventToggleWidget) {
      await repository.toggleCategory(event.categoryId, event.widgetId);
      add(const EventLoadDrafts());
    }

    if (event is EventAddDraft) {
      Draft draft = Draft(
          name: event.name,
          taskId: event.taskId,
          created: DateTime.now(),
          updated: DateTime.now(),
          icon: event.icon,
          status: event.status,
          type: event.type ?? 1);

      final id = await repository.addOneDraft(draft);

      if (id > 0) {
        print("收到EventAddCategory更新成功");
        emit(AddDraftSuccess(id));
        add(const EventLoadDrafts());
      } else {
        emit(const AddCategoryFailed());
      }
    }

    if (event is EventUpdateDraft) {
      Draft draft = Draft(
          id: event.id,
          taskId: event.taskId,
          name: event.name,
          updated: DateTime.now(),
          status: event.status,
          icon: event.icon,
          type: event.type);

      final success = await repository.updateCategory(draft);

      if (success) {
        print("收到EventUpdateCategory更新成功");
//        yield AddCategorySuccess();
        add(const EventLoadDrafts());
      } else {
//        yield AddCategoryFailed();
      }
    }
  }

  Future<int> addOneDraft(Draft draft) async {
    int id = await repository.addOneDraft(draft);
    debugPrint("直接插入一条数据："+draft.type.toString()+"  id:"+id.toString());
    return id;
  }

  Future<bool> updateDraft(Draft draft) async {
    return await repository.updateCategory(draft);
  }

  List<Draft> get categories {
    if (state is DraftLoadedState) {
      return (state as DraftLoadedState).drafts;
    } else {
      return [];
    }
  }
}
