import 'package:app/app.dart';
import 'package:components/toly_ui/toly_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storage/storage.dart';
import 'package:widget_module/blocs/blocs.dart';


/// create by bluemingwu
/// 草稿的编辑和增加

enum EditType { add, update }

class EditDraftPanel extends StatefulWidget {
  final Draft? model;
  final EditType type;

  const EditDraftPanel({Key? key, this.model, this.type = EditType.add}) : super(key: key);

  @override
  _EditCategoryPanelState createState() => _EditCategoryPanelState();
}

class _EditCategoryPanelState extends State<EditDraftPanel> {
  String name='';

  int get colorIndex => widget.model == null
      ? 0
      : UnitColor.collectColorSupport
          .map((e) => e.value)
          .toList()
          .indexOf(Colors.red.value);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: InputButton(
            defaultText: '${widget.model?.name??''}',
            config: const InputButtonConfig(iconData: Icons.check),
            onSubmit: _doEdit,
          ),
        ),
      ],
    );
  }

  void _doEdit(String str){
    name = str.trim();
    if (name.isNotEmpty) {
      // if (widget.type == EditType.add) {
      //   BlocProvider.of<CategoryBloc>(context).add(
      //       EventAddCategory(taskId:,name: name, info: info, color: color));
      // }
      if (widget.type == EditType.update) {
        BlocProvider.of<DraftBloc>(context).add(
            EventUpdateDraft(
                id: widget.model!.id!,taskId: widget.model!.taskId,
                name: name,status: widget.model!.status, icon: widget.model!.icon,type: widget.model!.type));
      }
    }
    Navigator.of(context).pop();
  }

}
