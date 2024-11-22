import 'dart:async';
import 'dart:io';

import 'package:app/app.dart';
import 'package:app_update/app_update.dart';
import 'package:authentication/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:logger/logger.dart';
import 'package:pieces_ai/app/model/user_info_global.dart';
import 'package:pieces_ai/app/navigation/mobile/theme/theme.dart';
import 'package:pieces_ai/app/views/about/version_force_update.dart';
import 'package:pieces_ai/painter_system/gallery_card_item.dart';
import 'package:pieces_ai/widget_ui/desk_ui/category_panel/get_draft_resource_dialog.dart';
import 'package:pieces_ai/widget_ui/mobile/category_page/edit_draft_panel.dart';
import 'package:storage/storage.dart';
import 'package:utils/utils.dart';
import 'package:widget_module/blocs/blocs.dart';

import '../../../app/api_https/ai_story_repository.dart';
import '../../../app/api_https/impl/https_ai_story_repository.dart';
import '../../../components/top_bar/desk_tab_top_bar.dart';
import '../../../widget_ui/desk_ui/category_panel/new_draft_dialog.dart';
import '../../../widget_ui/mobile/category_page/draft_list_item.dart';

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

///桌面版本的首页本地草稿+云空间
class MobileMainPage extends StatefulWidget {
  //是否跳转到登录页面的callback
  final Function(bool) doLogin;

  const MobileMainPage({Key? key, required this.doLogin}) : super(key: key);

  @override
  State<MobileMainPage> createState() => _MobileMainPageState();
}

class _MobileMainPageState extends State<MobileMainPage> {
  // final List<String> banners = [
  //   "assets/images/banner01.jpg",
  //   "assets/images/banner02.jpg",
  // ];

  @override
  void initState() {
    super.initState();
    //延时1秒检查版本更新
    // Future.delayed(Duration(seconds: 1), () {
    //   BlocProvider.of<UpdateBloc>(context)
    //       .add(const CheckUpdate(appName: 'PiecesAi'));
    // });
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateBloc, UpdateState>(
      listener: (context, state) {
        if (state is ShouldUpdateState) {
          showDialog(
              context: context,
              barrierDismissible: state.info.force_update != 1,
              builder: (ctx) => const Dialog(
                  elevation: 5,
                  child: SizedBox(
                    width: 500,
                    height: 300,
                    child: VersionForceUpdate(),
                  )));
        }
      },
      child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                backgroundColor: AppColor.piecesBlackGrey,
                // expandedHeight: 10,
                floating: false,
                pinned: true,
                snap: false,
                actions: [
                  DeskTabTopBar(
                    doLogin: widget.doLogin,
                  ),
                ],
              ),
              _buildTopBar(),
              // _buildBanner(),
              SliverToBoxAdapter(
                child: const Padding(
                    padding: EdgeInsets.only(left: 0, top: 10),
                    child: Row(
                      children: [
                        Icon(
                          TolyIcon.icon_code,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "我的草稿",
                          style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 3,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    )),
              ),
            ],
            body: _buildDraftArea(),
          )),
    );
  }

  _buildBody() {
    //判断是横屏还是竖屏
    if (MediaQuery.of(context).size.width >
        MediaQuery.of(context).size.height) {
      return _buildBodyLandscape();
    } else {
      return _buildBodyPortrait();
    }
  }

  ///竖屏
  _buildBodyPortrait() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopBar(),
        // _buildBanner(),
        Expanded(child: _buildDraftArea()),
      ],
    );
  }

  _buildBodyLandscape() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(child: _buildTopBar()),
        Flexible(
            child: Column(
          children: [
            // _buildBanner(),
            Expanded(child: _buildDraftArea()),
          ],
        ))
      ],
    );
  }

  _buildDraftArea() {
    return DeskDraftLocalPage(
      onMustLogin: () => widget.doLogin(true),
    );
  }

  // _buildBanner() {
  //   return SliverToBoxAdapter(
  //     // expandedHeight: 200.0,
  //     child: Padding(
  //       padding: const EdgeInsets.only(left: 0, right: 0, top: 10),
  //       child: AspectRatio(
  //           aspectRatio: 51 / 12,
  //           child: CarouselSlider(
  //             options: CarouselOptions(
  //               autoPlay: true,
  //               enlargeCenterPage: true,
  //               viewportFraction: 1.0,
  //               autoPlayInterval: Duration(seconds: 5),
  //               autoPlayAnimationDuration: Duration(milliseconds: 1000),
  //               autoPlayCurve: Curves.fastOutSlowIn,
  //               enableInfiniteScroll: true,
  //               scrollDirection: Axis.horizontal,
  //             ),
  //             items: banners.map((i) {
  //               return Builder(
  //                 builder: (BuildContext context) {
  //                   return GestureDetector(
  //                     onTap: () {
  //                       //点击banner
  //                     },
  //                     child: Container(
  //                       width: MediaQuery.of(context).size.width,
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(5),
  //                       ),
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(5), // 设置图片圆角
  //                         child: Image(
  //                           fit: BoxFit.fill,
  //                           image: AssetImage(i),
  //                         ),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               );
  //             }).toList(),
  //           )),
  //     ),
  //   );
  // }

  _buildTopBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 5, right: 0, left: 0),
        child: AspectRatio(
            aspectRatio: 5 / 4,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: _buildMainItem("一键Ai生成无限长动画视频", "去创作",
                      "https://imgs.pencil-stub.com/data/cms/2024-08-21/807ed7fe19f14f1cb3ddf4a6a11b4410.jpg"),
                  flex: 1,
                ),
              ],
            )),
      ),
    );
  }

  //一键原创Item
  _buildMainItem(String title1, String btnText, String url) {
    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: Ink(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: AppColor.piecesBackTwo,
        ),
        width: double.maxFinite,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          onTap: () async {
            showNewDraftDialog(context, 1);
          },
          child: Column(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(url),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )),
              Container(
                padding: const EdgeInsets.all(5),
                child: Text(
                  title1,
                  style: const TextStyle(
                      fontSize: 18,
                      color: AppColor.piecesBlue,
                      fontWeight: FontWeight.bold),
                ),
                alignment: Alignment.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //
  // Widget _buildOriginalItem(String title1, String btnText, String url) {
  //   return Padding(
  //     padding: const EdgeInsets.only(right: 0),
  //     child: Ink(
  //       decoration: const BoxDecoration(
  //         borderRadius: BorderRadius.all(Radius.circular(5)),
  //         color: AppColor.piecesBackTwo,
  //       ),
  //       width: double.maxFinite,
  //       child: InkWell(
  //         borderRadius: BorderRadius.all(Radius.circular(5)),
  //         onTap: () async {
  //           showNewDraftDialog(context, 1);
  //         },
  //         child: Column(
  //           children: [
  //             Padding(
  //               padding:
  //                   const EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 5),
  //               child: Container(
  //                 height: 70,
  //                 width: 70,
  //                 decoration: BoxDecoration(
  //                   borderRadius: const BorderRadius.all(Radius.circular(10)),
  //                   image: DecorationImage(
  //                     image: CachedNetworkImageProvider(url),
  //                     fit: BoxFit.fill,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(
  //               height: 10,
  //             ),
  //             Text(
  //               title1,
  //               style: const TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.white),
  //             ),
  //             const Spacer(),
  //             Container(
  //               padding: const EdgeInsets.all(5),
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.all(Radius.circular(28)),
  //                 color: Color(0xFF12CDD9),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.grey.withOpacity(0.5),
  //                     spreadRadius: 2,
  //                     blurRadius: 5,
  //                     offset: Offset(0, 3), // 定义阴影偏移量
  //                   ),
  //                 ],
  //               ),
  //               child: Text(
  //                 btnText,
  //                 style: const TextStyle(
  //                   fontSize: 15,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //               width: 100,
  //               alignment: Alignment.center,
  //             ),
  //             SizedBox(
  //               height: 10,
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCopyVideoItem(String title1, String btnText, String url) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 5),
      child: Ink(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: AppColor.piecesBackTwo,
        ),
        width: double.maxFinite,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          onTap: () async {
            showNewDraftDialog(context, 3);
          },
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 5),
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(url),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Text(
                title1,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void showNewDraftDialog(BuildContext context, int type) async {
    //先判断是否登录
    User user = GlobalInfo.instance.user;
    if (user.authToken != null && user.authToken!.isNotEmpty) {
      // 只有会员才能使用
      var user = GlobalInfo.instance.user;
      if (user.vipLevel == 4 || user.vipLevel == 5) {
      } else {

      }
      if (user.pegg <= 0) {
        showDialog(
          context: context,
          barrierDismissible: true, //点击弹窗以外背景是否取消弹窗
          builder: (context) {
            return AlertDialog(
              content: const Text("皮蛋不足,请充值"),
              actions: [
                TextButton(
                  onPressed: () {
                    //关闭弹窗
                    Navigator.of(context).pop();
                  },
                  child: const Text("确定"),
                )
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return NewDraftDialog(type: type);
          },
        );
      }
    } else {
      widget.doLogin(true);
    }
  }
}

///草稿区域的GridView
class DeskDraftLocalPage extends StatelessWidget {
  final AiStoryRepository httpAiStoryRepository = HttpAiStoryRepository();
  final Function onMustLogin;

  DeskDraftLocalPage({Key? key, required this.onMustLogin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DraftBloc, DraftState>(
      builder: (context, state) {
        if (state is DraftLoadedState && state.drafts.isNotEmpty) {
          debugPrint("重新创建首页草稿区域:BlocBuilder");
          GlobalConfiguration().updateValue("now_run", 0);
          return GridView.builder(
            itemCount: state.drafts.length,
            padding: const EdgeInsets.only(top: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 设置每行显示的网格项数量
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (_, index) => DraftListItem(
              draft: state.drafts[index],
              onDeleteItemClick: (draft) => _deleteCollect(context, draft),
              onClickItemClick: (draft) => _toDetailPage(context, draft),
              onEditItemClick: (draft) => _editCollect(context, draft),
              onExportItemClick: (draft) => _exportVideo(context, draft),
              httpAiStoryRepository: httpAiStoryRepository,
            ),
          );
          //使用SliverGrid实现上述注释代码
          // return SliverGrid(
          //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: 3, // 设置每行显示的网格项数量
          //     mainAxisSpacing: 10,
          //     crossAxisSpacing: 10,
          //     childAspectRatio: 0.7,
          //   ),
          //   delegate: SliverChildBuilderDelegate(
          //     (BuildContext context, int index) {
          //       return DraftListItem(
          //         draft: state.drafts[index],
          //         onDeleteItemClick: (draft) => _deleteCollect(context, draft),
          //         onClickItemClick: (draft) => _toDetailPage(context, draft),
          //         onEditItemClick: (draft) => _editCollect(context, draft),
          //         onExportItemClick: (draft) => _exportVideo(context, draft),
          //         httpAiStoryRepository: httpAiStoryRepository,
          //       );
          //     },
          //     childCount: state.drafts.length,
          //   ),
          // );
        }
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/widgets/draft_empty.png'),
              width: 100,
              height: 100,
            ),
            Text(
              '暂无草稿，快去创作吧~',
              style: TextStyle(color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  ShapeBorder get rRectBorder => const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)));

  Future<void> _deleteCollect(BuildContext context, Draft draft) async {
    //使用系统自带dialog实现
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              elevation: 5,
              shape: rRectBorder,
              title: const Text('删除草稿'),
              content: Text('删除【${draft.name}】草稿，是否确定继续执行?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () async {
                    //删除本地的图片和草稿json缓存数据
                    BlocProvider.of<DraftBloc>(context)
                        .add(EventDeleteCategory(id: draft.id!));
                    // Navigator.of(context).pop();
                    //删除本地对应文件
                    String draftsDir = await FileUtil.getDraftFolder();
                    String aiScriptPath = draftsDir +
                        FileUtil.getFileSeparate() +
                        draft.taskId! +
                        '.json';
                    File aiScriptFile = File(aiScriptPath);
                    if (aiScriptFile.existsSync()) {
                      //删除原始视频所有相关文件夹
                      String draftFolder =
                          await FileUtil.getPieceAiDraftFolder() +
                              FileUtil.getFileSeparate() +
                              draft.name.toString();
                      if (Directory(draftFolder).existsSync()) {
                        debugPrint("需要删除的整个草稿文件夹：" + draftFolder);
                        FileUtil.deleteFolderContent(draftFolder);
                        Directory(draftFolder).deleteSync();
                      } else {
                        logger.d("删除草稿时，草稿主文件夹不存在：" + draftFolder);
                      }
                      aiScriptFile.deleteSync(recursive: true);
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('确定'),
                ),
              ],
            ));
  }

  void _exportVideo(BuildContext context, Draft draft) {
    if (3 != draft.status) {
      Toast.green(context, '请先点击草稿领取！');
      return;
    }

    //跳转到导出视频页面
    Navigator.pushNamed(context, UnitRouter.video_export, arguments: draft);
  }

  void _editCollect(BuildContext context, Draft draft) {
    if (3 != draft.status) {
      Toast.green(context, '请先点击草稿领取！');
      return;
    }
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              elevation: 5,
              shape: rRectBorder,
              child: SizedBox(
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
                          '修改名字',
                          style: TextStyle(fontSize: 20),
                        ),
                        const Spacer(),
                        const CloseButton()
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: EditDraftPanel(
                        model: draft,
                        type: EditType.update,
                      ),
                    ),
                  ],
                ),
                width: 200,
              ),
            ));
  }

  ///点击了草稿item
  Future<void> _toDetailPage(BuildContext context, Draft draft) async {
    User user = GlobalInfo.instance.user;
    // 只有会员才能使用
    if (user.vipLevel == 4 || user.vipLevel == 5) {
    } else {
    }
    if (user.pegg <= 0) {
      onMustLogin.call();
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
            elevation: 5,
            backgroundColor: AppColor.piecesBlackGrey,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              height: MediaQuery.of(context).size.height / 5,
              child: GetDraftResourceDialog(
                draft: draft,
                httpAiStoryRepository: httpAiStoryRepository,
              ),
            )));
  }
}
