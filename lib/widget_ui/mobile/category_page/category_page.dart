import 'package:app/app.dart';
import 'package:components/project_ui/project_ui.dart';
import 'package:components/toly_ui/toly_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pieces_ai/widget_ui/mobile/category_page/delete_category_dialog.dart';
import 'package:storage/storage.dart';
import 'package:widget_module/blocs/blocs.dart';

import '../../../app/api_https/ai_story_repository.dart';
import '../../../app/api_https/impl/https_ai_story_repository.dart';
import 'draft_list_item.dart';
import 'edit_draft_panel.dart';

///首页竖版手机的适配页面
class CategoryPage extends StatelessWidget {

  final AiStoryRepository httpAiStoryRepository = HttpAiStoryRepository();
  final SliverGridDelegateWithMaxCrossAxisExtent gridDelegate =
      const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 200,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
    // crossAxisCount: 2,

    // childAspectRatio: 0.8,
  );

  final SliverGridDelegateWithFixedCrossAxisCount deskGridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 0.9,
  );
  
  CategoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DraftBloc, DraftState>(builder: (ctx, state) {
      if (state is DraftLoadedState) {
        return CustomScrollView(
          slivers: <Widget>[
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctx),
            ),
            _buildContent(context, state),
          ],
        );
      }
      if (state is CategoryLoadingState) return const LoadingShower();
      return const Text('你还没有收藏东西');
    });
  }

  _buildContent(BuildContext context, DraftLoadedState state) {
    double bottom = MediaQuery.of(context).padding.bottom;

    return SliverPadding(
      padding:  EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 20+bottom),
      sliver: SliverLayoutBuilder(
          builder: (_,c){
            SliverGridDelegate delegate = gridDelegate;
            if(c.crossAxisExtent>500){
              delegate = deskGridDelegate;
            }
            return SliverGrid(
            delegate: SliverChildBuilderDelegate(
                (_, index) => GestureDetector(
                    onTap: () =>
                        _toDetailPage(context, state.drafts[index]),
                    child: DraftListItem(
                      draft: state.drafts[index],
                      onDeleteItemClick: (model) =>
                          _deleteCollect(context, model),
                      onEditItemClick: (model) =>
                          _editCollect(context, model),httpAiStoryRepository: httpAiStoryRepository,
                    )),
                childCount: state.drafts.length),
            gridDelegate: delegate); }
      ),
    );
  }

  ShapeBorder get rRectBorder => const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)));

  void _deleteCollect(BuildContext context, Draft model) {
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              elevation: 5,
              shape: rRectBorder,
              child: SizedBox(
                width: 50,
                child: DeleteCategoryDialog(
                  title: '删除收藏集',
                  content: '    删除【${model.name}】收藏集，你将会失去其中的所有收藏组件，是否确定继续执行?',
                  onSubmit: () {
                    BlocProvider.of<DraftBloc>(context)
                        .add(EventDeleteCategory(id: model.id!));
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ));
  }

  void _editCollect(BuildContext context, Draft model) {
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              backgroundColor: const Color(0xFFF2F2F2),
              elevation: 5,
              shape: rRectBorder,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Gap.H5,
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 10),
                        child: Circle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const Text(
                        '修改收藏集',
                        style: TextStyle(fontSize: 20),
                      ),
                      const Spacer(),
                      const CloseButton()
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: EditDraftPanel(model: model,type: EditType.update,),
                  ),
                ],
              ),
            ));
  }

  void _toDetailPage(BuildContext context, Draft model) {
    // print('点击草稿是否是+号'+model.name);
    BlocProvider.of<CategoryWidgetBloc>(context).add(EventLoadCategoryWidget(model.id!));
    Navigator.pushNamed(context, UnitRouter.ai_style_edit, arguments: model);
  }


}
