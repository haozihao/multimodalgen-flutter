// 用于维护 App 配置信息的存储类
// 配置信息将通过 sp 存储在 xml 中
class AppConfigPo {
  final bool showBackGround;
  final bool showOverlayTool;
  final bool showPerformanceOverlay;
  final int fontFamilyIndex;
  final String jyDraftDir;
  final String sdWebUi;
  final String fastSd;
  final String baiduKey;
  final String baiduTk;
  final int themeModeIndex;
  final int itemStyleIndex;
  final int themeColorIndex;

  AppConfigPo({
    this.showBackGround = false,
    this.showOverlayTool = false,
    this.showPerformanceOverlay = false,
    this.fontFamilyIndex = 1,
    this.themeColorIndex = 4,
    this.jyDraftDir = '',
    this.sdWebUi = '',
    this.fastSd = '',
    this.baiduKey = '',
    this.baiduTk = '',
    this.themeModeIndex = 2,
    this.itemStyleIndex = 0,
  });

  factory AppConfigPo.fromPo(dynamic map) {
    return AppConfigPo(
      showBackGround: map['showBackGround'] ?? false,
      showOverlayTool: map['showOverlayTool'] ?? false,
      showPerformanceOverlay: map['showPerformanceOverlay'] ?? false,
      fontFamilyIndex: map['fontFamilyIndex'] ?? 1,
      themeColorIndex: map['themeColorIndex'] ?? 4,
      jyDraftDir: map['jyDraftDir'] ?? '',
      sdWebUi: map['sdWebUi'] ?? '',
      fastSd: map['fastSd'] ?? '',
      baiduKey: map['baiduKey'] ?? '',
      baiduTk: map['baiduTk'] ?? '',
      themeModeIndex: map['themeModeIndex'] ?? 2,
      itemStyleIndex: map['itemStyleIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'showBackGround': showBackGround,
        'showOverlayTool': showOverlayTool,
        'showPerformanceOverlay': showPerformanceOverlay,
        'fontFamilyIndex': fontFamilyIndex,
        'themeColorIndex': themeColorIndex,
        'jyDraftDir': jyDraftDir,
        'sdWebUi': sdWebUi,
        'fastSd': fastSd,
        'baiduKey': baiduKey,
        'baiduTk': baiduTk,
        'themeModeIndex': themeModeIndex,
        'itemStyleIndex': itemStyleIndex,
      };
}
