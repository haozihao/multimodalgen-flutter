import 'package:authentication/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pieces_ai/app/api_https/impl/https_diy_roles_repository.dart';
import 'package:pieces_ai/app/gen/toly_icon_p.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';
import 'package:pieces_ai/app/model/diy/diy_roles.dart';
import 'package:pieces_ai/app/model/user_info_global.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/diy_ai_roles_edit_panel.dart';
import 'package:pieces_ai/widget_ui/mobile/category_page/delete_category_dialog.dart';
import 'package:utils/utils.dart';

/// create by blueming.wu
/// Ai推文自定义形象管理页，拉取所有的自定义角色
class DiyAiRolesPanel extends StatefulWidget {
  const DiyAiRolesPanel({
    Key? key,
    required this.onSave,
    required this.aiPaintParamsV2,
    required this.styleId,
  }) : super(key: key);

  // final Function(List<Role>) selectRoles;
  final Function(bool refresh) onSave;
  final AiPaintParamsV2 aiPaintParamsV2;
  final int styleId;

  @override
  _StyleGridViewState createState() => _StyleGridViewState();
}

class _StyleGridViewState extends State<DiyAiRolesPanel> {
  int selectRoleIndex = 0;
  int selectGender = 0;
  int selectTag = 0;
  bool refresh = false;
  late PageController _pageControllerGender;
  late PageController _pageControllerTags;
  late HttpsDiyRolesRepository httpsDiyRolesRepository;
  late Future<List<CustomRolePicture>> _futureAllDiyRoles;

  @override
  void initState() {
    super.initState();
    _pageControllerGender = PageController();
    _pageControllerTags = PageController();
    httpsDiyRolesRepository = HttpsDiyRolesRepository();
    _futureAllDiyRoles = HttpsDiyRolesRepository().getAllDiyRoles();
  }

  @override
  void dispose() {
    _pageControllerGender.dispose();
    _pageControllerTags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildTopBar(),
        Expanded(
            child: PageView(children: <Widget>[
              _buildGridView(),
              // _buildGridViewScenes(widget.rolesAndScenes!.scenes),
            ]))
      ],
    );
  }

  Widget _buildTopBar(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 64,
      color: Color(0xff2C3036),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              widget.onSave.call(true);
              Navigator.pop(context); // 关闭当前页面
            },
          ),
          const SizedBox(
            width: 50,
          ),
          Text(
            '自有人物库',
            style: TextStyle(fontSize: 30),
          ),
          Spacer(),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  ///风格大类别
  Widget _buildButtonListView() {
    return Row(
      children: [
        Container(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                selectGender = 0;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  selectGender == 0 ? Color(0xFF12CDD9) : Colors.grey,
            ),
            child: const Text('男'),
          ),
          padding: EdgeInsets.only(right: 5),
        ),
        Container(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                selectGender = 1;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  selectGender == 1 ? Color(0xFF12CDD9) : Colors.grey,
            ),
            child: const Text('女'),
          ),
          padding: EdgeInsets.only(right: 5),
        ),
      ],
    );
  }

  ///人物选择整个widget
  Widget _buildGridView() => Column(
        children: [
          const Divider(),
          Flexible(
            child: FutureBuilder<List<CustomRolePicture>>(
                future: _futureAllDiyRoles,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Async operation is still in progress
                    return Container(
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    // Error handling
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return _buildRoleWidget(snapshot.data ?? []);
                  }
                }),
            flex: 1,
          )
        ],
      );

  SliverGridDelegate gridDelegate =
      const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 120 / 160, // 控制子项宽高比例
  );

  ///第一行所有主角的UI
  Widget _buildRoleWidget(List<CustomRolePicture> diyAiRoles) {
    return GridView.builder(
      // scrollDirection: Axis.horizontal,
      itemCount: (diyAiRoles.length + 1),
      gridDelegate: gridDelegate,
      itemBuilder: (_, int index) => index == (diyAiRoles.length)
          ? _buildAddBtn(() {
              //看是否超过上线
              User user = GlobalInfo.instance.user;
              int maxNum = 5;
              if (user.vipLevel! >= 3) maxNum = 25;
              if (diyAiRoles.length >= maxNum) {
                MotionToast.warning(
                        title: Text("超过当前自定义角色上限"), description: Text("请升级VIP"))
                    .show(context);
                return;
              }
              showDialog(
                  context: context,
                  builder: (ctx) => Dialog(
                        child: SizedBox(
                          width: 800,
                          height: 800,
                          child: DiyAiRolesEditPanel(
                            onSave: (bool refresh) {
                              //刷新页面
                              setState(() {
                                _futureAllDiyRoles =
                                    HttpsDiyRolesRepository().getAllDiyRoles();
                              });
                            },
                            aiPaintParamsV2: widget.aiPaintParamsV2,
                            styleId: widget.styleId,
                          ),
                        ),
                      ));
            })
          : _buildItem(diyAiRoles[index], index),
    );
  }

  Widget _buildAddBtn(Function onPress) {
    return SizedBox(
      child: IconButton(
        color: Color(0xFF17B4BE),
        icon: Icon(
          TolyIconP.add,
          size: 40,
        ),
        onPressed: () => onPress.call(),
      ),
      width: 120,
      height: 120,
    );
  }

  ///单个主角的item
  Widget _buildItem(CustomRolePicture diyAiRole, int index) => GestureDetector(
        child: Container(
          color: (selectRoleIndex == index) ? Colors.blue : Colors.transparent,
          // alignment: Alignment.center,
          child: Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              Container(
                height: double.infinity,
                padding: EdgeInsets.only(left: 2, top: 2, right: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: diyAiRole.icon,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      diyAiRole.name,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    child: Container(
                      child: Icon(
                        Icons.delete,
                        size: 28,
                        color: Color(0xFF12CDD9),
                      ),
                      color: Colors.white,
                    ),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (ctx) => Dialog(
                                elevation: 5,
                                child: SizedBox(
                                  width: 50,
                                  child: DeleteCategoryDialog(
                                    title: '删除角色',
                                    content: '    删除角色后多端同步删除',
                                    onSubmit: () async {
                                      int code = await httpsDiyRolesRepository
                                          .deleteDiyRole(diyAiRole);
                                      if (200 == code) {
                                        setState(() {
                                          _futureAllDiyRoles =
                                              HttpsDiyRolesRepository()
                                                  .getAllDiyRoles();
                                        });
                                      } else {
                                        Toast.error(context, "删除失败，联系客服!");
                                      }
                                    },
                                  ),
                                ),
                              ));
                    },
                  ),
                  GestureDetector(
                    child: Container(
                      child: Icon(
                        Icons.settings,
                        size: 28,
                        color: Color(0xFF12CDD9),
                      ),
                      color: Colors.white,
                    ),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (ctx) => Dialog(
                                child: SizedBox(
                                  child: DiyAiRolesEditPanel(
                                    onSave: (bool refresh) {
                                      //3级添加成功刷新页面
                                      setState(() {
                                        _futureAllDiyRoles =
                                            HttpsDiyRolesRepository()
                                                .getAllDiyRoles();
                                      });
                                    },
                                    aiPaintParamsV2: widget.aiPaintParamsV2,
                                    customRolePicture: diyAiRole,
                                    styleId: widget.styleId,
                                  ),
                                  width: 800,
                                  height: 800,
                                ),
                              ));
                      refresh = true;
                    },
                  )
                ],
              )
            ],
          ),
        ),
        onTap: () {
          // widget.aiStyleModelChanged(aiStyleModel.children[index]);
          setState(() {
            selectRoleIndex = index;
          });
        },
      );
}
