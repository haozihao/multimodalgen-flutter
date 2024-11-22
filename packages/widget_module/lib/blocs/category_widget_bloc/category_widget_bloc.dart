import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widget_repository/widget_repository.dart';


import '../category_bloc/draft_bloc.dart';

part 'category_widget_event.dart';
part 'category_widget_state.dart';

/// create by blueming.wu

class CategoryWidgetBloc
    extends Bloc<CategoryWidgetEvent, CategoryWidgetState> {
  final DraftBloc categoryBloc;

  CategoryWidgetBloc({required this.categoryBloc})
      : super(CategoryWidgetEmptyState()){
    on<EventLoadCategoryWidget>(_onEventLoadCategoryWidget);
    on<EventToggleCategoryWidget>(_onEventToggleCategoryWidget);
  }

  DraftDbRepository get repository => categoryBloc.repository;

  void _onEventLoadCategoryWidget(EventLoadCategoryWidget event, Emitter<CategoryWidgetState> emit) async{
    final widgets =
    await repository.loadCategoryWidgets(categoryId: event.categoryId);
     widgets.isNotEmpty
        ? emit(CategoryWidgetLoadedState(widgets))
        : emit(CategoryWidgetEmptyState());
    categoryBloc.add(const EventLoadDrafts());
  }

  void _onEventToggleCategoryWidget(EventToggleCategoryWidget event, Emitter<CategoryWidgetState> emit) async{
    await repository.toggleCategory(event.categoryId, event.widgetId);
    add(EventLoadCategoryWidget(event.categoryId));
  }
}
