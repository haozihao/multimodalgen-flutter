import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storage/storage.dart';

import 'package:utils/utils.dart';
import '../repository/app_state_repository.dart';
import '../model/global_state.dart';

/// blueming.wu
/// 全局设置信息

class AppBloc extends Cubit<AppState> {
  final Connectivity _connectivity = Connectivity();

  final AppStateRepository storage;
  late StreamSubscription<ConnectivityResult> _subscription;

  AppBloc(this.storage) : super(const AppState()) {
    _subscription =
        _connectivity.onConnectivityChanged.listen(_onNetConnectChange);
  }

  void _onNetConnectChange(ConnectivityResult event) {
    emit(state.copyWith(
      netConnect: event,
    ));
  }

  @override
  Future<void> close() async {
    _subscription.cancel();
    super.close();
  }

  // 程序初始化事件处理: 使用 AppStorage 进行初始化
  void initApp() async {
    emit(await storage.initApp());
    HttpUtil.apiLocalUrl = state.sdWebUi;
    HttpUtil.apiFastUrl = state.fastSd;
    HttpUtil.baiduKey = state.baiduKey;
    HttpUtil.baiduTk = state.baiduTk;
    if (kDebugMode) {
      print("初始化配置信息apiLocalUrl:" + HttpUtil.apiLocalUrl);
    }
  }

  AppConfigCao get cao => storage.sp.appConfig;

  // 切换字体事件处理 : 固化索引 + 产出新状态
  void switchFontFamily(String family) async {
    AppState newState = state.copyWith(fontFamily: family);
    cao.write(newState.toAppConfigPo());
    emit(newState);
  }

  // 切换主题色事件处理 : 固化索引 + 产出新状态
  void switchThemeColor(MaterialColor color) async {
    AppState newState = state.copyWith(themeColor: color);
    cao.write(newState.toAppConfigPo());
    emit(newState);
  }

  // 切换背景显示事件处理 : 固化数据 + 产出新状态
  void switchShowBg(bool show) async {
    AppState newState = state.copyWith(showBackGround: show);
    cao.write(newState.toAppConfigPo());
    emit(newState);
  }

  // 切换背景显示事件处理 : 产出新状态
  void switchShowOver(bool show) async {
    AppState newState = state.copyWith(showPerformanceOverlay: show);
    cao.write(newState.toAppConfigPo());
    emit(newState);
  }

  // 切换code样式事件处理 : 固化索引 + 产出新状态
  void switchJyDraftDir(String jyDraftDir) async {
    AppState newState = state.copyWith(jyDraftDir: jyDraftDir);
    cao.write(newState.toAppConfigPo());
    emit(newState);
  }

  void switchSdWebUiUrl(String sdWebUiUrl) async {
    AppState newState = state.copyWith(sdWebUi: sdWebUiUrl);
    cao.write(newState.toAppConfigPo());
    emit(newState);
  }

  void switchFastSdUrl(String fastSdUrl) async {
    AppState newState = state.copyWith(fastSd: fastSdUrl);
    cao.write(newState.toAppConfigPo());
    emit(newState);
  }

  void switchBaiduTrans(String appId, String tk) async {
    AppState newState = state.copyWith(baiduKey: appId, baiduTk: tk);
    cao.write(newState.toAppConfigPo());
    emit(newState);
  }

  // 切换item样式事件处理 : 固化索引 + 产出新状态
  void changeItemStyle(int index) async {
    AppState newState = state.copyWith(itemStyleIndex: index);
    cao.write(newState.toAppConfigPo());
    emit(newState);
  }

  void changeThemeMode(ThemeMode style) async {
    AppState newState = state.copyWith(themeMode: style);
    cao.write(newState.toAppConfigPo());
    emit(newState);
  }

  void switchShowTool(bool show) async {
    AppState newState = state.copyWith(showOverlayTool: show);
    cao.write(newState.toAppConfigPo());
    emit(newState);
  }
}
