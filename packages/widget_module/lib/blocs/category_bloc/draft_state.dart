part of 'draft_bloc.dart';

/// create by blueming.wu
/// 草稿全局管理

class DraftState extends Equatable {
  const DraftState();

  @override
  List<Object> get props => [];
}

class DraftLoadedState extends DraftState {
  final List<Draft> drafts;

  const DraftLoadedState(this.drafts);

  @override
  List<Object> get props => [drafts];
}

class CategoryLoadingState extends DraftState {
  const CategoryLoadingState();

  @override
  List<Object> get props => [];
}


class CategoryEmptyState extends DraftState {
  const CategoryEmptyState();

  @override
  List<Object> get props => [];
}

class AddDraftSuccess extends DraftState {
  final int id;
  const AddDraftSuccess(this.id);
  @override
  List<Object> get props => [id];
}

class AddCategoryFailed extends DraftState {
  const AddCategoryFailed();
}
