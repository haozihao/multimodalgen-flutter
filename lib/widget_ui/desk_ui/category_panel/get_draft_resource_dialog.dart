import 'dart:convert';
import 'dart:io';

import 'package:app/app/router/unit_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path/path.dart' as path;
import 'package:storage/storage.dart';
import 'package:utils/utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:widget_module/blocs/category_bloc/draft_bloc.dart';

import '../../../app/api_https/ai_story_repository.dart';
import '../../../app/model/TweetScript.dart';
import '../../../app/model/ai_draft.dart';
import '../../../app/navigation/mobile/theme/theme.dart';
import '../../../app/utils/draft_util.dart';

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

///获取草稿资源对话框
class GetDraftResourceDialog extends StatefulWidget {
  final Draft draft;
  final AiStoryRepository httpAiStoryRepository;
  final bool reDownload;

  GetDraftResourceDialog({
    Key? key,
    required this.draft,
    required this.httpAiStoryRepository,
    this.reDownload = false,
  }) : super(key: key);

  @override
  State<GetDraftResourceDialog> createState() => _GetDraftResourceDialogState();
}

class _GetDraftResourceDialogState extends State<GetDraftResourceDialog> {
  double progress = 0.0;
  int totalCount = 1;
  int index = 0;
  final player = AudioPlayer();

  @override
  void initState() {
    _startGetResource(widget.draft);
    //保持屏幕常亮
    WakelockPlus.enable();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBar(context),
        _buildTitle(context),
        _buildContent(),
      ],
    );
  }

  _startGetResource(Draft draft) async {
    String draftsDir = await FileUtil.getDraftFolder();
    if (draft.status == 0) {
      MotionToast.info(description: Text("Ai任务进行中...")).show(context);
    } else if (1 == draft.status) {
      //已完成，点领取
      TweetScript? tweetScript = await widget.httpAiStoryRepository
          .getTaskResult(taskId: draft.taskId!);
      if (tweetScript != null) {
        //使用数据库的draft和本地文件的剧本数据，组合跳转。如果本地没有文件，则表示是首次需要请求网络获取任务结果
        String aiScriptPath =
            draftsDir + FileUtil.getFileSeparate() + draft.taskId! + '.json';
        File aiScriptFile = File(aiScriptPath);
        // if (!await Directory(draftsDir).exists()) {
        //   await Directory(draftsDir).create();
        // }

        DraftRender? draftRender;
        if (aiScriptFile.existsSync()) {
          logger.d('本地有提交任务时保存的草稿地址喂：' + aiScriptPath);
          String aiScriptStr = await aiScriptFile.readAsString();
          draftRender = DraftRender.fromJson(jsonDecode(aiScriptStr));
          //覆盖本地json数据
          draftRender.status = 3;
          draftRender.type = draft.type;
          draftRender.id = draft.id;
          draftRender.name = draft.name ?? "";
          draftRender.tweetScript = tweetScript;
        }
        //判断是否需要处理领取的视频文件（Ai补帧、高清处理等操作）
        //遍历处理资源
        setState(() {
          totalCount = tweetScript.scenes[0].imgs.length;
        });

        //获取草稿文件夹，根据草稿名字
        String draftPath =
            await FileUtil.getPieceAiDraftFolderByTaskId(draft.name ?? "新建草稿");

        for (int i = 0; i < tweetScript.scenes[0].imgs.length; i++) {
          TweetImage tweetImage = tweetScript.scenes[0].imgs[i];
          if (tweetImage.mediaType == 1) {
            //视频分镜要同时下载视频和图片文件
            if (tweetImage.videoUrl != null) {
              if (tweetImage.videoUrl!.startsWith("http")) {
                setState(() {
                  index = i + 1;
                  progress = i * 0.95 / tweetScript.scenes[0].imgs.length;
                });
                //先下载视频到本地草稿文件夹，再补帧，然后再重新赋值
                var saveFilePath = await _downLoadResourceByType(
                    draftPath, tweetImage.videoUrl!, DraftFileType.VIDEO);
                tweetImage.videoUrl = saveFilePath;
              } else if (tweetImage.videoUrl!.startsWith("PieceAiDrafts")) {
                logger.d("已经下载过的本地视频：${tweetImage.videoUrl}");
              } else {
                logger.e("视频url异常：${tweetImage.videoUrl}");
              }
            }
            if (tweetImage.url != null) {
              if (tweetImage.url!.startsWith("http")) {
                setState(() {
                  index = i + 1;
                  progress = i * 0.95 / tweetScript.scenes[0].imgs.length;
                });
                //先下载图片到本地草稿文件夹，然后再重新赋值
                var imageFilePath = await _downLoadResourceByType(
                    draftPath, tweetImage.url!, DraftFileType.IMAGE);
                tweetImage.url = imageFilePath;
              } else if (tweetImage.url!.startsWith("PieceAiDrafts")) {
                logger.d("已经下载过的本地图片：${tweetImage.url}");
              } else {
                logger.e("图片url异常：${tweetImage.url}");
              }
            }
          } else if (tweetImage.mediaType == 0) {
            if (tweetImage.url != null) {
              if (tweetImage.url!.startsWith("http")) {
                setState(() {
                  index = i + 1;
                  progress = i * 0.95 / tweetScript.scenes[0].imgs.length;
                });
                //先下载图片到本地草稿文件夹，然后再重新赋值
                var imageFilePath = await _downLoadResourceByType(
                    draftPath, tweetImage.url!, DraftFileType.IMAGE);
                tweetImage.url = imageFilePath;
              } else if (tweetImage.url!.startsWith("PieceAiDrafts")) {
                logger.d("已经下载过的本地图片：${tweetImage.url}");
              } else {
                logger.e("图片url异常：${tweetImage.url}");
              }
            }

            if (tweetImage.tts != null && tweetImage.tts!.url != null) {
              if (tweetImage.tts!.url!.startsWith("http")) {
                setState(() {
                  index = i + 1;
                  progress = i * 0.95 / tweetScript.scenes[0].imgs.length;
                });
                //先下载图片到本地草稿文件夹，然后再重新赋值
                var audioFilePath = await _downLoadResourceByType(
                    draftPath, tweetImage.tts!.url!, DraftFileType.AUDIO);
                tweetImage.tts!.url = audioFilePath;
                //校准音频时间
                double audioDuration = await getAudioDuration(audioFilePath);
                tweetImage.tts!.duration = audioDuration;
              } else if (tweetImage.tts!.url!.startsWith("PieceAiDrafts")) {
                logger.d("已经下载过的本地音频：${tweetImage.tts!.url}");
              } else {
                logger.e("音频url异常：${tweetImage.tts!.url}");
              }
            }
          }
        }

        //覆盖写入
        await aiScriptFile.writeAsString(jsonEncode(draftRender));
        //更新草稿状态为已领取
        BlocProvider.of<DraftBloc>(context).add(EventUpdateDraft(
            name: draft.name,
            taskId: draft.taskId,
            icon: tweetScript.scenes[0].imgs[0].url!,
            id: draft.id!,
            status: 3,
            type: draft.type));
        Navigator.of(context).pop();
        //最后跳转到详情，领取
        Navigator.pushNamed(context, UnitRouter.widget_scene_edit,
            arguments: draftRender);
      }
    } else if (2 == draft.status) {
      MotionToast.error(description: Text("任务生成失败，请联系客服！")).show(context);
    } else if (3 == draft.status || 4 == draft.status) {
      // 直接到分句编辑,已领取直接从本地获取草稿
      String aiScriptPath =
          draftsDir + FileUtil.getFileSeparate() + draft.taskId! + '.json';
      File aiScriptFile = File(aiScriptPath);
      DraftRender? draftRender;
      if (aiScriptFile.existsSync()) {
        logger.d('本地有领取成功的草稿：' + aiScriptPath);
        String aiScriptStr = await aiScriptFile.readAsString();
        draftRender = DraftRender.fromJson(jsonDecode(aiScriptStr));
        draftRender.status = draft.status;
        draftRender.type = draft.type;
        draftRender.id = draft.id;
        draftRender.name = draft.name ?? "";
        Navigator.pushNamed(context, UnitRouter.widget_scene_edit,
            arguments: draftRender);
      } else {
        MotionToast.error(description: Text("本地草稿文件异常，请联系客服！")).show(context);
      }
    } else {
      MotionToast.error(description: Text("草稿status出错，请联系客服！")).show(context);
    }
  }

  ///获取音频文件时长
  Future<double> getAudioDuration(String audioPath) async {
    Duration? duration = await player.setFilePath(audioPath);
    // logger.d("获取到的音频时长：$duration");
    return duration!.inMilliseconds / 1000;
  }

  ///根据草稿文件类型，下载资源
  Future<String> _downLoadResourceByType(
      String draftPath, String url, DraftFileType draftFileType) async {
    //使用join方法实现上述注释代码
    String ppImagePath =
        path.join(draftPath, DraftUtil.getDraftTypeFolderName(draftFileType));
    await FileUtil.createDirectoryIfNotExists(ppImagePath);
    String imageName = FileUtil.getHttpNameWithExtension(url);
    String saveFilePath = path.join(ppImagePath, imageName);
    logger.d("下载资源saveFilePath：" + saveFilePath);
    await _downloadResource(url, saveFilePath);
    return saveFilePath;
  }

  _downloadResource(String url, String path) async {
    logger.d("下载资源：$url");
    await HttpUtil.instance.client.download(url, path,
        onReceiveProgress: (int get, int total) {
      String progress = ((get / total) * 100).toStringAsFixed(2);
    });
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '任务领取',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "资源下载：${index}/${totalCount}",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: 15,
            ),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withAlpha(33),
              valueColor: const AlwaysStoppedAnimation(AppColor.piecesBlue),
            )
          ],
        ));
  }

  _buildBar(context) => Row(
        children: <Widget>[
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 30,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 10, top: 5),
              child: Icon(
                Icons.close,
                color: AppColor.piecesBlue,
              ),
            ),
          ),
        ],
      );
}
