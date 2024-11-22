import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/app/router/unit_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:storage/storage.dart';
import 'package:utils/utils.dart';
import 'package:widget_module/blocs/category_bloc/draft_bloc.dart';

import '../../../app/api_https/ai_story_repository.dart';
import '../../../app/api_https/impl/https_ai_story_repository.dart';
import '../../../app/model/ai_draft.dart';
import '../../../app/navigation/mobile/theme/theme.dart';
import '../../desk_ui/category_panel/get_draft_resource_dialog.dart';

/// 本地草稿单个草稿的视图
class DraftListItem extends StatefulWidget {
  final Draft draft;
  final Function(Draft)? onDeleteItemClick;
  final Function(Draft)? onClickItemClick;
  final Function(Draft)? onEditItemClick;
  final Function(Draft)? onExportItemClick;
  final AiStoryRepository httpAiStoryRepository;

  const DraftListItem(
      {Key? key,
      required this.draft,
      this.onDeleteItemClick,
      this.onClickItemClick,
      this.onEditItemClick,
      this.onExportItemClick,
      required this.httpAiStoryRepository})
      : super(key: key);

  @override
  State<DraftListItem> createState() => _DraftListItemState();
}

class _DraftListItemState extends State<DraftListItem> {
  double progress = 0.0;
  Timer? _timer;
  bool isTimerRunning = false;

  @override
  void initState() {
    // debugPrint("initState：" +
    //     widget.draft.status.toString() +
    //     "  name:" +
    //     widget.draft.name.toString());
    //如果这个草稿是没有完成的。
    if (widget.draft.status == 0) {
      var nowRunTask = GlobalConfiguration().get("now_run");
      nowRunTask++;
      GlobalConfiguration().updateValue("now_run", nowRunTask);
      if (!isTimerRunning) {
        _startTimer();
      }
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DraftListItem oldWidget) {
    //如果这个草稿是没有完成的。
    // if (oldWidget.draft.status == 0 || oldWidget.draft.status == 3) {
    //   //老的是进行中的，被复用了。则不启动
    // } else {}
    // debugPrint("didUpdateWidget old：" +
    //     oldWidget.draft.status.toString() +
    //     "  新的：" +
    //     widget.draft.status.toString());
    if (widget.draft.status == 0) {
      var nowRunTask = GlobalConfiguration().get("now_run");
      nowRunTask++;
      debugPrint("更新任务进行个数：$nowRunTask");
      GlobalConfiguration().updateValue("now_run", nowRunTask);
      if (!isTimerRunning) {
        _startTimer();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    isTimerRunning = true;
    _updateProgress();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateProgress();
    });
  }

  Future<void> _updateProgress() async {
    try {
      double newProgress = await widget.httpAiStoryRepository
          .getTaskProgress(taskId: widget.draft.taskId!);
      print("获取到任务进度:{}" + newProgress.toString());
      if (widget.draft.status == 0) {
        if (newProgress >= 1.0) {
          _timer?.cancel();
          // print("跟新的item：" +
          //     widget.draft.name.toString() +
          //     " status:" +
          //     widget.draft.status.toString());
          //发出一个更新这个item的通知
          BlocProvider.of<DraftBloc>(context).add(EventUpdateDraft(
              id: widget.draft.id!,
              status: 1,
              name: widget.draft.name,
              taskId: widget.draft.taskId,
              icon: widget.draft.icon,
              type: widget.draft.type));
          setState(() {
            widget.draft.status = 1;
            progress = newProgress;
          });
        } else {
          setState(() {
            widget.draft.status = 0;
            progress = newProgress;
          });
        }
      }
    } catch (e) {
      // Handle error if necessary
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('点击了item:' + widget.draft.status.toString());
        // widget.draft.status = 3;
        // setState(() {});
        widget.onClickItemClick?.call(widget.draft);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.0, // 1:1 aspect ratio
            child: Container(
              child: _buildChild(context),
              // padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // color: Colors.grey,
                image: widget.draft.icon!.startsWith("http")
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(widget.draft.icon!),
                        fit: BoxFit.cover,
                      )
                    : DecorationImage(
                        image: FileImage(File(widget.draft.icon!)),
                        fit: BoxFit.cover,
                      ),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          const Spacer(),
          Text(
            widget.draft.name!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Text(
            DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.draft.updated),
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  _buildChild(BuildContext context) {
    String statusStr = '';
    if (widget.draft.status == 0) {
      statusStr = '生成中...';
    } else if (1 == widget.draft.status) {
      statusStr = '已完成\n点击领取';
    } else if (2 == widget.draft.status) {
      statusStr = '失败';
    } else if (3 == widget.draft.status) {
      statusStr = '';
    } else if (4 == widget.draft.status) {
      statusStr = '未完成';
    }

    return Stack(
      children: <Widget>[
        // _buildTitle(themeColor),
        Container(
          // 添加叠加的黑色遮罩
          foregroundDecoration: widget.draft.status != 3
              ? BoxDecoration(
                  color: Colors.black.withOpacity(0.7), // 设置半透明黑色
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                )
              : null,
        ),
        Container(
          alignment: Alignment.center,
          width: 50,
          height: 22,
          decoration: BoxDecoration(
            //添加渐变色
            gradient: LinearGradient(
              colors: widget.draft.type == 3
                  ? [
                      Color(0xFFB465DA),
                      Color(0xFFCF6CC9),
                      Color(0xFFEE609C),
                      Color(0xFFEE609C)
                    ]
                  : [Color(0xFFFA709A), Color(0xFFFEE140)],
              stops: widget.draft.type == 3
                  ? [0.0, 0.3333, 0.6666, 1.0]
                  : [0.0, 1.0],
            ),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
          ),
          child: Text(
            widget.draft.type == 3 ? "追爆款" : "原创",
            style: TextStyle(fontSize: 12),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: _buildPop(),
        ),
        Align(
          alignment: Alignment.center,
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(statusStr,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              if (progress < 1.0 && progress > 0 && widget.draft.status == 0)
                Padding(
                  padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withAlpha(33),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF12CDD9)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  final Map<String, IconData> map = const {
    "更名": Icons.info_outline,
    "导出": Icons.help_outline,
    "再次制作": Icons.help_outline,
    "重新领取": Icons.help_outline,
    "删除": Icons.add_comment,
  };

  Widget _buildPop() {
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
      offset: const Offset(0, 20),
      color: const Color(0xFF1C1C1C),
      elevation: 1,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      onSelected: (e) {
        print(e);
        if (e == '更名') {
          widget.onEditItemClick?.call(widget.draft);
        } else if ("导出" == e) {
          widget.onExportItemClick?.call(widget.draft);
        } else if ("删除" == e) {
          widget.onDeleteItemClick?.call(widget.draft);
        } else if ("再次制作" == e) {
          //把图片清空后再次制作，音频不清空。只有原创作品并且已完成的可以再次制作
          if (widget.draft.type == 1) {
            if (widget.draft.status == 3) {
              _toSecondPage(widget.draft);
            } else {
              MotionToast.info(description: Text("只有制作完成的作品才可以再次制作。"))
                  .show(context);
            }
          } else {
            MotionToast.info(description: Text("做同款无法再次制作。")).show(context);
          }
        } else if ("重新领取" == e) {
          widget.draft.status = 1;
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
                      draft: widget.draft,
                      httpAiStoryRepository: HttpAiStoryRepository(),
                    ),
                  )));
        }
      },
      onCanceled: () => print('onCanceled'),
    );
  }

  _toSecondPage(Draft draft) async {
    // 直接到分句编辑,已领取直接从本地获取草稿
    String draftsDir = await FileUtil.getDraftFolder();
    String aiScriptPath =
        draftsDir + FileUtil.getFileSeparate() + draft.taskId! + '.json';
    File aiScriptFile = File(aiScriptPath);
    DraftRender? draftRender;
    if (aiScriptFile.existsSync()) {
      debugPrint('本地有领取成功的草稿：' + aiScriptPath);
      String aiScriptStr = await aiScriptFile.readAsString();
      draftRender = DraftRender.fromJson(jsonDecode(aiScriptStr));
      draftRender.status = draft.status;
      draftRender.type = draft.type;
      draftRender.id = draft.id;
      draftRender.name = (draft.name! + "-" + FileUtil.generateRandomString(5));
      Navigator.pushNamed(context, UnitRouter.ai_style_edit,
          arguments: draftRender);
    } else {
      MotionToast.warning(description: Text("获取本地草稿文件出错，不能再次制作！"))
          .show(context);
    }
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
}
