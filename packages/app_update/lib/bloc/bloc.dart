import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:utils/utils.dart';

import '../model/app_info.dart';
import 'event.dart';
import 'state.dart';

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  UpdateBloc() : super(const NoUpdateState()) {
    on<CheckUpdate>(_onCheckUpdate);
    on<ResetNoUpdate>(_onResetNoUpdate);
    on<DownloadEvent>(_onDownloadEvent);
    on<DownloadingEvent>(_onDownloadingEvent);
  }

  void _onCheckUpdate(CheckUpdate event, Emitter<UpdateState> emit) async {
    emit(const CheckLoadingState());
    // await Future.delayed(Duration(seconds: 1));
    // 检测更新逻辑
    TaskResult<AppInfo> result =
        await AppInfoApi.getAppVersion(appName: event.appName);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    print("本地版本信息：" + packageInfo.toString());

    if (result.success && result.data != null) {
      if (result.data!.version_code <= int.parse(packageInfo.buildNumber)) {
        emit(NoUpdateState(
          isChecked: true,
          checkTime: DateTime.now().millisecondsSinceEpoch,
        ));
      } else {
        if (result.data != null) {
          emit(ShouldUpdateState(
              oldVersion: packageInfo.version, info: result.data!));
        }
      }
    } else {
      emit(CheckErrorState(error: result.msg));
    }
  }

  void _onResetNoUpdate(ResetNoUpdate event, Emitter<UpdateState> emit) {
    emit(const NoUpdateState());
  }

  late int? id;

  // late StreamSubscription<DownloadInfo>? subscription;

  void _onDownloadEvent(DownloadEvent event, Emitter<UpdateState> emit) async {
    print("版本更新信息：" + event.toString());
    String exeUrl = event.appInfo.appUrl;
    String fileSeprate = FileUtil.getFileSeparate();
    var appDir = await getApplicationCacheDirectory();
    String savePath =
        "${appDir.path}$fileSeprate${event.appInfo.appVersion}.apk";
    print("开始下载保存位置：" + savePath);
    await HttpUtil.instance.client.download(exeUrl, savePath,
        onReceiveProgress: (int get, int total) {
      // print('$get $total');
      add(DownloadingEvent(
          state: DownloadingState(appSize: total, progress: get / total)));
    });
    openExeUpdata(savePath);
    // subscription = RUpgrade.stream.listen((DownloadInfo info) {
    //   double progress = (info.percent ?? 0) / 100;
    //   if (info.status! == DownloadStatus.STATUS_SUCCESSFUL) {
    //     progress = 1;
    //     subscription?.cancel();
    //     add(const ResetNoUpdate());
    //   }
    //   add(DownloadingEvent(state: DownloadingState(
    //       appSize: event.appInfo.appSize,
    //       progress: progress
    //   )));
    // });
  }

  void openExeUpdata(String exeSavePath) async {
    if (Platform.isWindows) {
      String exePath;
      add(const ResetNoUpdate());
      if (kReleaseMode) {
        //release
        exePath = exeSavePath;
      } else {
        //debug
        exePath = exeSavePath;
      }
      Process.run(exePath, ['arg1', 'arg2']).then((result) {
        print(result.stdout);
        print(result.stderr);
        SystemNavigator.pop();
      }).onError((error, stackTrace) {});
    } else if (Platform.isAndroid) {
      OpenResult openResult = await OpenFilex.open(exeSavePath);
      print("打开结果：${openResult.message}");
      // bool? isSuccess = await RUpgrade.installByPath(exeSavePath);
      // if (kDebugMode) {
      //   print("安装结果：$isSuccess");
      // }
    }
  }

  void _onDownloadingEvent(DownloadingEvent event, Emitter<UpdateState> emit) {
    emit(event.state);
  }
}
