import 'dart:io';

import 'package:authentication/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:components/toly_ui/ti/circle.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_config_repository.dart';
import 'package:pieces_ai/app/api_https/impl/https_diy_roles_repository.dart';
import 'package:pieces_ai/app/gen/toly_icon_p.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';
import 'package:pieces_ai/app/model/config/ai_analyse_role_scene.dart';
import 'package:pieces_ai/app/model/config/ai_roles_official.dart';
import 'package:pieces_ai/app/model/diy/diy_roles.dart' as diyRole;
import 'package:pieces_ai/app/model/user_info_global.dart';
import 'package:pieces_ai/app/navigation/mobile/theme/theme.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/diy_ai_roles_edit_panel.dart';

import 'edit_words_panel.dart';

/// create by blueming.wu
/// Ai推文人物场景固定专用的弹窗
class AiRoleSceneSelectWidget extends StatefulWidget {
  const AiRoleSceneSelectWidget(
      {Key? key,
      // required this.selectRoles,
      this.rolesAndScenes,
      required this.onSave,
      required this.styleId,
      required this.ratio,
      required this.aiPaintParamsV2})
      : super(key: key);

  // final Function(List<Role>) selectRoles;
  final Function(bool refresh) onSave;
  final RolesAndScenes? rolesAndScenes;
  final AiPaintParamsV2 aiPaintParamsV2;
  final int styleId;
  final int ratio;

  @override
  _StyleGridViewState createState() => _StyleGridViewState();
}

class _StyleGridViewState extends State<AiRoleSceneSelectWidget>
    with SingleTickerProviderStateMixin {
  int selectRoleIndex = 0;
  int selectGender = 1;
  int selectTag = 0;
  bool refresh = false;
  late TabController _pageControllerGender;

  // late TabController _pageControllerTags;
  // late TabController _pageControllerTagsBoy;
  late Future<List<AiRoles>> _futureAllRoles;
  late HttpsDiyRolesRepository httpsDiyRolesRepository;

  @override
  void initState() {
    super.initState();
    _pageControllerGender = TabController(length: 2, vsync: this);
    _futureAllRoles = HttpAiConfigRepository()
        .loadAiRolesOfficial(styleId: widget.styleId, ratio: widget.ratio);
    httpsDiyRolesRepository = HttpsDiyRolesRepository();
  }

  @override
  void didUpdateWidget(covariant AiRoleSceneSelectWidget oldWidget) {
    print("人物选择页面didUpdateWidget:");
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _pageControllerGender.dispose();
    // _pageControllerTags.dispose();
    // _pageControllerTagsBoy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('固定人物角色'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 5,
          ),
          _buildButtonListView(),
          SizedBox(
            height: 5,
          ),
          Expanded(
              child: PageView(children: <Widget>[
            _buildGridView(widget.rolesAndScenes!.roles),
            // _buildGridViewScenes(widget.rolesAndScenes!.scenes),
          ])),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Container(
              width: 200,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(refresh);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF12CDD9),
                ),
                child: const Text(
                  '保存',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              padding: EdgeInsets.only(bottom: 20),
            ),
          )
        ],
      ),
    );
  }

  ///风格大类别
  Widget _buildButtonListView() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(5),
          //蓝色圆角线框边框
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColor.piecesBlue, width: 1),
          ),
          child: Text(
            '作品角色',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  ///人物选择整个widget
  Widget _buildGridView(List<Role> roles) => Column(
        children: [
          SizedBox(
            child: _buildRoleWidget(roles),
            height: 200,
          ),
          const Divider(),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Circle(
                radius: 5,
                color: AppColor.piecesBlue,
              ),
              SizedBox(
                width: 5,
              ),
              const Text('选择形象：'),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Flexible(
            child: FutureBuilder<List<AiRoles>>(
                future: _futureAllRoles,
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
                    return _buildGridViewAllOfficialRoles(snapshot.data ?? []);
                  }
                }),
            flex: 1,
          )
        ],
      );

  SliverGridDelegate gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    childAspectRatio: 3 / 4,
    crossAxisCount: 4,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10, //横向的间隔
  );

  ///第一行所有主角的UI
  Widget _buildRoleWidget(List<Role> roles) {
    return GridView.builder(
      // scrollDirection: Axis.horizontal,
      // physics: NeverScrollableScrollPhysics(),
      // shrinkWrap: true,
      itemCount: (roles.length + 1),
      gridDelegate: gridDelegate,
      itemBuilder: (_, int index) => index == (roles.length)
          ? _buildAddBtn(() {
              showDialog(
                  context: context,
                  builder: (ctx) => Dialog(
                        backgroundColor:
                            Theme.of(context).dialogBackgroundColor,
                        elevation: 5,
                        child: SizedBox(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 10),
                                    child: Circle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const Text(
                                    '新增角色',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  const Spacer(),
                                  const CloseButton()
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: EditKeyWordsPanel(
                                  type: EditType.add,
                                  hint: "输入角色名",
                                  index: 0,
                                  onEditCallback: (index, words, type, modify) {
                                    Role role = new Role(
                                        name: words, prompt: '', icon: '');
                                    //表示有新增角色，需要刷新
                                    refresh = true;
                                    setState(() {
                                      roles.add(role);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          width: 200,
                        ),
                      ));
            })
          : _buildItem(roles[index].name, roles[index].icon ?? '', index),
    );
  }

  Widget _buildAddBtn(Function onPress) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1 / 1,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFFCCCCCC)),
            child: IconButton(
              color: Color(0xFF808080),
              icon: Icon(
                TolyIconP.add,
                size: 40,
              ),
              onPressed: () => onPress.call(),
            ),
          ),
        )
      ],
    );
  }

  ///官方人物库，男女为一级，下设二级标签
  Widget _buildGridViewAllOfficialRoles(List<AiRoles> allAiRoles) {
    //先分tag男女
    Widget tagGender = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "性别：",
          style: TextStyle(fontSize: 12),
        ),
        //使用TabBar实现男女选择
        DefaultTabController(
          length: 2,
          child: TabBar(
            tabAlignment: TabAlignment.start,
            tabs: [
              SizedBox(
                child: Tab(
                  child: Text(
                    "男",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                width: 50,
                height: 20,
              ),
              SizedBox(
                child: Tab(
                  child: Text(
                    "女",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                width: 50,
                height: 20,
              ),
            ],
            isScrollable: true,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0), // 设置圆角边框
              border: Border.all(
                color: AppColor.piecesBlue, // 设置边框颜色
                width: 1.0, // 设置边框宽度
              ),
            ),
            controller: _pageControllerGender,
            onTap: (index) {
              setState(() {
                selectGender = index + 1;
                selectTag = 0;
              });
            },
          ),
        )
      ],
    );

    AiRoles aiRolesBoy = allAiRoles[0];
    AiRoles aiRolesGirl = allAiRoles[1];

    Tag? tagMineBoy;
    for (int i = 0; i < aiRolesBoy.tags.length; i++) {
      Tag tag = aiRolesBoy.tags[i];
      if (tag.tagName == "我的") {
        tagMineBoy = aiRolesBoy.tags.removeAt(i);
        break;
      }
    }
    if (tagMineBoy == null) {
      tagMineBoy = Tag(children: [], tagId: 0, tagName: "我的");
    }
    aiRolesBoy.tags.add(tagMineBoy);
    List<Widget> gridViewListBoy = [];
    for (var tag in aiRolesBoy.tags) {
      gridViewListBoy.add(
        GridView.count(
          crossAxisCount: 4,
          childAspectRatio: 3 / 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: "我的" == tag.tagName
              ? List.generate(
                  tag.children.length + 1,
                  (index) => (index == 0)
                      ? _buildAddBtn(() {
                          _jumpToDiyRole(true, null);
                        })
                      : _buildOfficialItem(
                          tag.children[index - 1], index, true),
                )
              : List.generate(
                  tag.children.length,
                  (index) =>
                      _buildOfficialItem(tag.children[index], index, false),
                ),
        ),
      );
    }

    Tag? tagMineGirl;
    for (int i = 0; i < aiRolesGirl.tags.length; i++) {
      Tag tag = aiRolesGirl.tags[i];
      if (tag.tagName == "我的") {
        tagMineGirl = aiRolesGirl.tags.removeAt(i);
        break;
      }
    }
    if (tagMineGirl == null) {
      tagMineGirl = Tag(children: [], tagId: 0, tagName: "我的");
    }
    aiRolesGirl.tags.add(tagMineGirl);
    List<Widget> gridViewListGirl = [];
    for (var tag in aiRolesGirl.tags) {
      gridViewListGirl.add(
        GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 3 / 4,
          children: "我的" == tag.tagName
              ? List.generate(
                  tag.children.length + 1,
                  (index) => (index == 0)
                      ? _buildAddBtn(() {
                          _jumpToDiyRole(true, null);
                        })
                      : _buildOfficialItem(
                          tag.children[index - 1], index, true),
                )
              : List.generate(
                  tag.children.length,
                  (index) =>
                      _buildOfficialItem(tag.children[index], index, false),
                ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          child: tagGender,
          padding: EdgeInsets.only(bottom: 10),
        ),
        Expanded(
            child: TabBarView(
          children: <Widget>[
            DefaultTabController(
              length: aiRolesBoy.tags.length,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '分类：',
                        style: TextStyle(fontSize: 12),
                      ),
                      TabBar(
                        tabAlignment: TabAlignment.start,
                        //tab之间的间距
                        labelPadding: EdgeInsets.only(left: 5, right: 5),
                        tabs: List.generate(
                            aiRolesBoy.tags.length,
                            (index) =>
                                _buildTagItem(aiRolesBoy.tags[index], index)),
                        isScrollable: true,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          // 设置圆角边框
                          border: Border.all(
                            color: AppColor.piecesBlue, // 设置边框颜色
                            width: 1.0, // 设置边框宽度
                          ),
                        ),
                        // controller: _pageControllerTagsBoy,
                        onTap: (index) {
                          setState(() {
                            selectTag = index;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: TabBarView(
                    children: gridViewListBoy,
                  )),
                ],
              ),
            ),
            DefaultTabController(
              length: aiRolesGirl.tags.length,
              child: Column(
                children: [
                  Row(children: [
                    Text(
                      '分类：',
                      style: TextStyle(fontSize: 12),
                    ),
                    TabBar(
                      tabAlignment: TabAlignment.start,
                      //tab之间的间距
                      labelPadding: EdgeInsets.only(left: 5, right: 5),
                      tabs: List.generate(
                          aiRolesGirl.tags.length,
                          (index) =>
                              _buildTagItem(aiRolesGirl.tags[index], index)),
                      isScrollable: true,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        // 设置圆角边框
                        border: Border.all(
                          color: AppColor.piecesBlue, // 设置边框颜色
                          width: 1.0, // 设置边框宽度
                        ),
                      ),
                      // controller: _pageControllerTagsBoy,
                      onTap: (index) {
                        setState(() {
                          selectTag = index;
                        });
                      },
                    )
                  ]),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: gridViewListGirl,
                    ),
                  )
                ],
              ),
            ),
            // TabBarView(
            //   children: gridViewListGirl,
            //   // controller: _pageControllerTags,
            // )
          ],
          controller: _pageControllerGender,
        ))
      ],
    );
  }

  ///角色分类选择
  Widget _buildTagItem(Tag tag, int index) {
    return SizedBox(
      width: 60,
      height: 20,
      child: Tab(
        child: Text(
          tag.tagName == "我的" ? "+我的角色" : tag.tagName,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  _jumpToDiyRole(bool add, AiRole? aiRole) async {
    diyRole.CustomRolePicture? customRolePicture;
    if (add) {
      //看是否超过上线
      User user = GlobalInfo.instance.user;
      int maxNum = 5;
      if (user.vipLevel! >= 3) maxNum = 50;
      List<diyRole.CustomRolePicture> roleList =
          await httpsDiyRolesRepository.getAllDiyRoles();
      int allNum = roleList.length;
      if (allNum >= maxNum) {
        MotionToast.info(
          description: Text("自定义角色上限为50"),
          title: Text("超出当前会员类型上限!"),
        ).show(context);
        return;
      }
    } else {
      List<diyRole.Img> imgs = [];
      diyRole.Img img = diyRole.Img(
          path: aiRole!.icon!, seed: aiRole.rolePromptInfo!.seed!.toDouble());
      imgs.add(img);
      List<diyRole.Tag> tags = [];
      aiRole.rolePromptInfo?.tags?.forEach((element) {
        tags.add(
            diyRole.Tag(en: element.en, zh: element.zh, type: element.type));
      });
      diyRole.RolePromptInfo rolePromptInfo = diyRole.RolePromptInfo(
          negativePrompt: aiRole.rolePromptInfo!.negativePrompt,
          prompt: aiRole.rolePromptInfo!.prompt,
          tags: tags,
          imgs: imgs);
      customRolePicture = diyRole.CustomRolePicture(
        icon: aiRole.icon!,
        id: aiRole.id,
        name: aiRole.name!,
        sex: aiRole.sex!,
        status: 1,
        rolePromptInfo: rolePromptInfo,
        style: aiRole.style!,
      );
    }
    //修改成跳转到页面
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DiyAiRolesEditPanel(
                  onSave: (bool refresh) {
                    //刷新页面
                    setState(() {
                      selectGender = 1;
                      selectTag = 0;
                      _futureAllRoles = HttpAiConfigRepository()
                          .loadAiRolesOfficial(
                              styleId: widget.styleId, ratio: widget.ratio);
                    });
                  },
                  customRolePicture: customRolePicture,
                  aiPaintParamsV2: widget.aiPaintParamsV2,
                  styleId: widget.styleId,
                )));
  }

  //官方人物item
  Widget _buildOfficialItem(AiRole aiRole, int index, bool del) =>
      GestureDetector(
        child: Container(
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFFCCCCCC),
                        image:
                            widget.styleId == -1111 || widget.styleId == -1112
                                ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(File(aiRole.icon!
                                        .split("imgs.pencil-stub.com")[1])),
                                  )
                                : DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                      aiRole.icon!,
                                    )),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      aiRole.name!,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (del) _buildPop(aiRole)
            ],
          ),
          width: 120,
          height: 140,
        ),
        onTap: () {
          debugPrint('选中的官方角色name:' +
              aiRole.name.toString() +
              aiRole.rolePromptInfo!.prompt.toString() +
              "  seed:" +
              aiRole.rolePromptInfo!.seed.toString());
          refresh = true;
          //选中角色给与到上面
          setState(() {
            widget.rolesAndScenes!.roles[selectRoleIndex].id = aiRole.id;
            widget.rolesAndScenes!.roles[selectRoleIndex].refName =
                aiRole.name ?? "";
            widget.rolesAndScenes!.roles[selectRoleIndex].icon = aiRole.icon;
            widget.rolesAndScenes!.roles[selectRoleIndex].prompt =
                aiRole.rolePromptInfo!.prompt;
            widget.rolesAndScenes!.roles[selectRoleIndex].seed =
                aiRole.rolePromptInfo!.seed;
          });
        },
      );

  final Map<String, IconData> map = const {
    "删除": Icons.delete,
    "编辑": Icons.edit,
  };

  Widget _buildPop(AiRole aiRole) {
    return PopupMenuButton<String>(
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0x8C000000),
        ),
        child: Icon(Icons.more_horiz),
        width: 30,
        height: 30,
      ),
      itemBuilder: (context) => buildItems(),
      offset: const Offset(0, 40),
      color: const Color(0xFF1C1C1C),
      elevation: 1,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      onSelected: (e) {
        print(e);
        if (e == '删除') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('删除自定义角色？'),
                content: Text('删除后多端会同步删除！'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('取消'),
                  ),
                  TextButton(
                    onPressed: () async {
                      //访问服务器删除角色
                      diyRole.CustomRolePicture diy = diyRole.CustomRolePicture(
                        icon: aiRole.icon!,
                        id: aiRole.id,
                        name: aiRole.name!,
                        sex: aiRole.sex!,
                        status: 1,
                        style: aiRole.style!,
                      );
                      int code =
                          await httpsDiyRolesRepository.deleteDiyRole(diy);
                      if (200 == code) {
                        setState(() {
                          selectGender = 1;
                          selectTag = 0;
                          _futureAllRoles = HttpAiConfigRepository()
                              .loadAiRolesOfficial(
                                  styleId: widget.styleId, ratio: widget.ratio);
                        });
                      } else {
                        MotionToast.warning(description: Text("删除失败，联系客服!"));
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text('确认'),
                  ),
                ],
              );
            },
          );
        } else if ("编辑" == e) {
          _jumpToDiyRole(false, aiRole);
        }
      },
      onCanceled: () => print('onCanceled'),
    );
  }

  List<PopupMenuItem<String>> buildItems() {
    return map.keys
        .toList()
        .map((e) => PopupMenuItem<String>(
            value: e,
            height: 30,
            child: Wrap(
              spacing: 5,
              children: <Widget>[
                // Icon(map[e], color: Colors.blue),
                Text(e,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            )))
        .toList();
  }

  ///单个主角的item
  Widget _buildItem(String name, String icon, int index) => GestureDetector(
        child: Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: (selectRoleIndex == index)
                                ? Color(0xFF12CDD9)
                                : Colors.transparent,
                            width: 2),
                        image: icon.isNotEmpty
                            ? widget.styleId == -1111 || widget.styleId == -1112
                                ? DecorationImage(
                                    image: FileImage(File(
                                        icon.split("imgs.pencil-stub.com")[1])),
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                                    image: CachedNetworkImageProvider(icon),
                                    fit: BoxFit.cover,
                                  )
                            : null),
                    child: icon.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFFCCCCCC)),
                            child: Text(
                              "请选择\n形象",
                              style: TextStyle(color: Color(0xFF808080)),
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Text(
                    name,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              child: Container(
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: Color(0xFF12CDD9),
                ),
                color: Colors.white,
              ),
              onTap: () {
                refresh = true;
                setState(() {
                  widget.rolesAndScenes!.roles.removeAt(index);
                });
              },
            )
          ],
        ),
        onTap: () {
          // widget.aiStyleModelChanged(aiStyleModel.children[index]);
          setState(() {
            selectRoleIndex = index;
          });
        },
      );
}
