import 'package:app/app/cons/cons.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

/// create by 张风捷特烈 on 2020-04-11
/// contact me by email 1981462002@qq.com
/// 说明: 全局状态类

Map<ThemeMode, String> themeMode2Str = const {
  ThemeMode.system: "跟随系统",
  ThemeMode.light: "浅色模式",
  ThemeMode.dark: "深色模式",
};

class AppState extends Equatable {
  /// [fontFamily] 文字字体
  final String fontFamily;

  /// [themeColor] 主题色
  final MaterialColor themeColor;

  /// [showBackGround] 是否显示主页背景图
  final bool showBackGround;

  /// [jyDraftDir] 剪映草稿
  final String jyDraftDir;

  ///[sdWebUi] SD自有未知
  final String sdWebUi;

  ///[fastSd] SD自有未知
  final String fastSd;

  // ///[aiPromptScene] Ai单分镜推理画面提示词模板
  // final String aiPromptScene;

  ///[baiduKey] 百度key
  final String baiduKey;

  ///[baiduTk] 百度TK
  final String baiduTk;

  /// [itemStyleIndex] 主页item样式 索引
  final int itemStyleIndex;

  /// [showPerformanceOverlay] 是否显示性能浮层
  final bool showPerformanceOverlay;

  /// [showOverlayTool] 是否显示浮动工具
  final bool showOverlayTool;

  /// [appStyle] app 深色样式;
  final ThemeMode themeMode;
  final ConnectivityResult netConnect;
  final String dbPath;

  const AppState({
    this.fontFamily = 'ComicNeue',
    this.themeColor = Colors.blue,
    this.themeMode = ThemeMode.dark,
    this.showBackGround = true,
    this.jyDraftDir = '',
    this.sdWebUi = '',
    this.fastSd = '',
    this.baiduKey = '',
    this.baiduTk = '',
    this.itemStyleIndex = 0,
    this.showPerformanceOverlay = false,
    this.showOverlayTool = true,
    this.dbPath = '',
    this.netConnect = ConnectivityResult.none,
  });

  @override
  List<Object> get props => [
        fontFamily,
        themeColor,
        showBackGround,
        jyDraftDir,
        sdWebUi,
        fastSd,
        baiduKey,
        baiduTk,
        itemStyleIndex,
        themeMode,
        showOverlayTool,
        showPerformanceOverlay,
        netConnect,
      ];

  AppState copyWith({
    String? fontFamily,
    String? dbPath,
    MaterialColor? themeColor,
    bool? showBackGround,
    String? jyDraftDir,
    String? sdWebUi,
    String? fastSd,
    String? baiduKey,
    String? baiduTk,
    int? itemStyleIndex,
    bool? showPerformanceOverlay,
    bool? showOverlayTool,
    ThemeMode? themeMode,
    ConnectivityResult? netConnect,
  }) =>
      AppState(
        fontFamily: fontFamily ?? this.fontFamily,
        themeColor: themeColor ?? this.themeColor,
        showBackGround: showBackGround ?? this.showBackGround,
        jyDraftDir: jyDraftDir ?? this.jyDraftDir,
        sdWebUi: sdWebUi ?? this.sdWebUi,
        fastSd: fastSd ?? this.fastSd,
        baiduKey: baiduKey ?? this.baiduKey,
        baiduTk: baiduTk ?? this.baiduTk,
        showOverlayTool: showOverlayTool ?? this.showOverlayTool,
        itemStyleIndex: itemStyleIndex ?? this.itemStyleIndex,
        themeMode: themeMode ?? this.themeMode,
        showPerformanceOverlay:
            showPerformanceOverlay ?? this.showPerformanceOverlay,
        netConnect: netConnect ?? this.netConnect,
        dbPath: dbPath ?? this.dbPath,
      );

  // 将 AppState 状态数据转换为配置对象，以便存储
  AppConfigPo toAppConfigPo() => AppConfigPo(
        showBackGround: showBackGround,
        showOverlayTool: showOverlayTool,
        showPerformanceOverlay: showPerformanceOverlay,
        fontFamilyIndex: Cons.kFontFamilySupport.indexOf(fontFamily),
        themeColorIndex:
            Cons.kThemeColorSupport.keys.toList().indexOf(themeColor),
        jyDraftDir: jyDraftDir,
        sdWebUi: sdWebUi,
        fastSd: fastSd,
        baiduKey: baiduKey,
        baiduTk: baiduTk,
        themeModeIndex: themeMode.index,
        itemStyleIndex: itemStyleIndex,
      );

  // 根据存储的配置信息对象，形成 AppState 状态数据
  factory AppState.fromPo(AppConfigPo po) {
    return AppState(
      fontFamily: Cons.kFontFamilySupport[po.fontFamilyIndex],
      themeColor: Cons.kThemeColorSupport.keys.toList()[po.themeColorIndex],
      showBackGround: po.showBackGround,
      jyDraftDir: po.jyDraftDir,
      sdWebUi: po.sdWebUi,
      fastSd: po.fastSd,
      baiduKey: po.baiduKey,
      baiduTk: po.baiduTk,
      itemStyleIndex: po.itemStyleIndex,
      showPerformanceOverlay: po.showPerformanceOverlay,
      showOverlayTool: po.showOverlayTool,
      themeMode: ThemeMode.values[po.themeModeIndex],
    );
  }

  String get _jyDraftDir => jyDraftDir;

  @override
  String toString() {
    return 'AppState{fontFamily: $fontFamily, themeColor: $themeColor, showBackGround: $showBackGround, jyDraftDir: $jyDraftDir, itemStyleIndex: $itemStyleIndex, showPerformanceOverlay: $showPerformanceOverlay}';
  }
}
