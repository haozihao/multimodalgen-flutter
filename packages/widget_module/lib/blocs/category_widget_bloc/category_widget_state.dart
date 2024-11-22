part of 'category_widget_bloc.dart';

/// create by blueming.wu
/// 全局的风格选择，尺寸选择，和文本导入数据

class CategoryWidgetState extends Equatable{
  @override
  List<Object> get props => [];

}


class CategoryWidgetLoadedState extends CategoryWidgetState {
  final List<WidgetModel> widgets;

  CategoryWidgetLoadedState(this.widgets);

  @override
  List<Object> get props => [widgets];

}

class CategoryWidgetEmptyState extends CategoryWidgetState{
  @override
  List<Object> get props => [];
}


