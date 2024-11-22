import 'dart:async';
import 'dart:io';

import 'package:app/app.dart';
import 'package:components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_story_fastsd.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_story_localsd.dart';
import 'package:pieces_ai/app/gen/toly_icon_p.dart';
import 'package:pieces_ai/app/navigation/mobile/theme/theme.dart';
import 'package:utils/utils.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? selectedDirectory = '';
  final _sdPathController = TextEditingController(text: '');
  final _fastSdPathController = TextEditingController(text: '');
  final _baiduKeyController = TextEditingController(text: '');
  final _baiduTkController = TextEditingController(text: '');
  bool _isLoading = false; // 加载状态
  bool _isLoadingBiaud = false; // 加载状态
  late Future<String> _futureCache;

  @override
  void initState() {
    _futureCache = _getAllCacheSize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const Widget divider = Divider(height: 1);

    return Scaffold(
      backgroundColor: AppColor.piecesBackTwo,
      appBar: AppBar(
        backgroundColor: AppColor.piecesBlackGrey,
        title: GestureDetector(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('应用设置', style: TextStyle()),
              Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    TolyIconP.hat,
                    color: Color(0xFF17B4BE),
                    size: 18,
                  )),
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text('教程', style: TextStyle(color: Color(0xFF17B4BE))),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Tooltip(
                  message: '点击查看完整教程',
                  child: Icon(
                    Icons.help_outline,
                    color: Color(0xFF17B4BE),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            //使用内置webview打开
            Navigator.of(context).pushNamed(UnitRouter.article_detail,
                arguments:
                    'https://aqy5in0fc54.feishu.cn/wiki/WJmQwrnHGiHGl7kfsYMcIxZNniz?from=from_copylink');
          },
        ),
      ),
      body: Container(
          color: AppColor.piecesBackTwo,
          // height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
          child: Container(
            //圆角
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: AppColor.piecesBlackGrey),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Text("SD-WEBUI："),
                  title: BlocBuilder<AppBloc, AppState>(
                    builder: (_, state) {
                      String hintText = "";
                      print('重新取得webui地址:' + state.sdWebUi);
                      if (HttpUtil.apiLocalUrl.isNotEmpty) {
                        _sdPathController.text = HttpUtil.apiLocalUrl;
                      } else {
                        if (state.sdWebUi.isEmpty) {
                          hintText = "请输入SD-WebUi地址:";
                        } else {
                          _sdPathController.text = state.sdWebUi;
                        }
                      }
                      return TextField(
                        controller: _sdPathController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: hintText,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                  ),
                  trailing: _isLoading
                      ? SizedBox(
                          child: const CircularProgressIndicator(),
                          width: 20,
                          height: 20,
                        ) // 加载控件
                      : ElevatedButton(
                          child: const Text('检查'),
                          onPressed: _isLoading ? null : _checkWebUI,
                        ),
                ),
                ListTile(
                  leading: const Text("FAST-SD："),
                  title: BlocBuilder<AppBloc, AppState>(
                    builder: (_, state) {
                      String hintText = "";
                      print('重新取得FAST-SD地址:' + state.fastSd);
                      if (HttpUtil.apiFastUrl.isNotEmpty) {
                        _fastSdPathController.text = HttpUtil.apiFastUrl;
                      } else {
                        if (state.fastSd.isEmpty) {
                          hintText = "请输入FAST-SD地址:";
                        } else {
                          _fastSdPathController.text = state.fastSd;
                        }
                      }
                      return TextField(
                        controller: _fastSdPathController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: hintText,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                  ),
                  trailing: _isLoading
                      ? SizedBox(
                          child: const CircularProgressIndicator(),
                          width: 20,
                          height: 20,
                        ) // 加载控件
                      : ElevatedButton(
                          child: const Text('检查'),
                          onPressed: _isLoading ? null : _checkFastSd,
                        ),
                ),
                ListTile(
                  leading: const Text("百度KEY："),
                  title: BlocBuilder<AppBloc, AppState>(
                    builder: (_, state) {
                      String hintText = "";
                      print('重新取得百度key:' + state.baiduKey);
                      if (state.baiduKey.isEmpty) {
                        hintText = "百度翻译APP-ID:";
                      } else {
                        _baiduKeyController.text = state.baiduKey;
                      }
                      return TextField(
                        controller: _baiduKeyController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: hintText,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const Text("翻译密钥："),
                  title: BlocBuilder<AppBloc, AppState>(
                    builder: (_, state) {
                      String hintText = "";
                      print('重新取得百度tk:' + state.baiduTk);
                      if (state.baiduTk.isEmpty) {
                        hintText = "百度翻译密钥:";
                      } else {
                        _baiduTkController.text = state.baiduTk;
                      }
                      return TextField(
                        controller: _baiduTkController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: hintText,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                  ),
                  trailing: _isLoadingBiaud
                      ? SizedBox(
                          child: const CircularProgressIndicator(),
                          width: 20,
                          height: 20,
                        ) // 加载控件
                      : ElevatedButton(
                          child: const Text('检查'),
                          onPressed: _isLoadingBiaud ? null : _checkBaidu,
                        ),
                ),
                // ListTile(
                //   leading: Icon(
                //     Icons.translate,
                //     color: Theme.of(context).primaryColor,
                //   ),
                //   title: const Text('字体设置', style: TextStyle(fontSize: 16)),
                //   subtitle: BlocBuilder<AppBloc, AppState>(
                //     builder: (_, state) => Text(
                //       state.fontFamily,
                //       style: TextStyle(fontSize: 12),
                //     ),
                //   ),
                //   trailing: _nextIcon(context),
                //   onTap: () =>
                //       Navigator.of(context).pushNamed(UnitRouter.font_setting),
                // ),
                // divider,
                divider,
                // Container(
                //   height: 10,
                // ),
                // _buildShowBg(context),
                // divider,
                // _buildShowOver(context),
                // divider,
                // _buildShowTool(context),
                // divider,
                // Container(height: 10),

                ListTile(
                  leading: Icon(
                    Icons.cached,
                  ),
                  title: Row(
                    children: [
                      FutureBuilder<String>(
                          future: _futureCache,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox(
                                child: const CircularProgressIndicator(),
                                width: 20,
                                height: 20,
                              );
                            } else if (snapshot.hasError) {
                              // Error handling
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Text('缓存清理(${snapshot.data.toString()}mb)',
                                  style: TextStyle(fontSize: 16));
                            }
                          }),
                      Spacer(),
                      isDeleting
                          ? SizedBox(
                              child: const CircularProgressIndicator(),
                              width: 20,
                              height: 20,
                            )
                          : TextButton(
                              onPressed: () => _deleteCache(context),
                              child: Text("点击清理"))
                    ],
                  ),
                  trailing: _nextIcon(context),
                  // onTap: () => _deleteCache(),
                  // Navigator.of(context).pushReplacementNamed(UnitRouter.version_info),
                ),
                divider,
                ListTile(
                  title: const Text('版本信息', style: TextStyle(fontSize: 16)),
                  trailing: _nextIcon(context),
                  onTap: () =>
                      Navigator.of(context).pushNamed(UnitRouter.version_info),
                  // Navigator.of(context).pushReplacementNamed(UnitRouter.version_info),
                ),
                divider,
                ListTile(
                  title: const Text('关于', style: TextStyle(fontSize: 16)),
                  trailing: _nextIcon(context),
                  onTap: () =>
                      Navigator.of(context).pushNamed(UnitRouter.about_app),
                  // Navigator.of(context).pushReplacementNamed(UnitRouter.version_info),
                ),
                divider,
              ],
            ),
          )),
    );
  }

  ///获取可清理的缓存数据大小
  Future<String> _getAllCacheSize() async {
    var appDir = await getApplicationDocumentsDirectory();
    debugPrint("缓存路径:" + appDir.path);
    int totalSizeInBytes = 0;

    // 获取目录下所有文件
    var list = appDir.list(recursive: true);
    await for (FileSystemEntity entity in list) {
      // 检查是否为文件
      if (entity is File) {
        // 检查文件后缀是否为.exe
        if (entity.path.endsWith('.exe')) {
          // 获取文件大小，并累加到总大小中
          totalSizeInBytes += await entity.length();
        }
      }
    }

    // 将字节数转换为MB，并返回字符串
    double totalSizeInMB = totalSizeInBytes / (1024 * 1024);
    return totalSizeInMB.toStringAsFixed(2); // 保留两位小数
  }

  ///清理范村
  bool isDeleting = false;

  Future<void> _deleteCache(BuildContext context) async {
    setState(() {
      isDeleting = true;
    });
    var appDir = await getApplicationDocumentsDirectory();
    // 获取目录下所有文件
    var list = appDir.list(recursive: true);
    await for (FileSystemEntity entity in list) {
      // 检查是否为文件
      if (entity is File) {
        // 检查文件后缀是否为.exe
        if (entity.path.endsWith('.exe')) {
          //删除
          await entity.delete();
        }
      }
    }
    setState(() {
      isDeleting = false;
    });
    _futureCache = _getAllCacheSize();
    MotionToast.success(description: Text("清理完成")).show(context);
  }

  // 检查FastSd地址
  Future<void> _checkFastSd() async {
    String fastSdUrl = _fastSdPathController.text;
    print('检查fastSd是否通常1111:' + fastSdUrl);
    setState(() {
      _isLoading = true; // 设置加载状态为 true
    });
    RegExp pattern = RegExp(r'/(?!.*/)');
    Iterable<Match> matches = pattern.allMatches(fastSdUrl);

    if (matches.isNotEmpty) {
      int lastIndex = matches.last.start;
      // print('Last slash index: $lastIndex');
      // print('Last slash character: ${sdUrl[lastIndex]}');
      if (lastIndex > 10) {
        fastSdUrl = fastSdUrl.substring(0, lastIndex);
      }
    }
    print('检查fastSd是否通常:' + fastSdUrl);
    if (fastSdUrl.isNotEmpty) {
      bool fastSdUrlPing =
          await HttpAiStoryFastSd().fastPing(newUrl: fastSdUrl);
      if (fastSdUrlPing) {
        // 获取 AppBloc 实例
        final appBloc = BlocProvider.of<AppBloc>(context);
        // 派发事件以更新文件夹
        appBloc.switchFastSdUrl(fastSdUrl);
        HttpUtil.apiFastUrl = fastSdUrl;
        MotionToast.success(description: Text("设置成功")).show(context);
      } else {
        MotionToast.warning(description: Text("FAST-SD地址无法连接")).show(context);
      }
    } else {
      //清除fast-sd配置
      final appBloc = BlocProvider.of<AppBloc>(context);
      // 派发事件以更新文件夹
      appBloc.switchFastSdUrl(fastSdUrl);
      HttpUtil.apiFastUrl = fastSdUrl;
      MotionToast.success(description: Text("FAST-SD配置已清除")).show(context);
    }

    setState(() {
      _isLoading = false; // 恢复加载状态为 false
    });
  }

  // 检查 Web UI 地址
  Future<void> _checkWebUI() async {
    setState(() {
      _isLoading = true; // 设置加载状态为 true
    });

    String sdUrl = _sdPathController.text;
    print('检查webui是否通常1111:' + sdUrl);
    RegExp pattern = RegExp(r'/(?!.*/)');
    Iterable<Match> matches = pattern.allMatches(sdUrl);

    if (matches.isNotEmpty) {
      int lastIndex = matches.last.start;
      // print('Last slash index: $lastIndex');
      // print('Last slash character: ${sdUrl[lastIndex]}');
      if (lastIndex > 10) {
        sdUrl = sdUrl.substring(0, lastIndex);
      }
    }
    print('检查webui是否通常:' + sdUrl);
    if (sdUrl.isNotEmpty) {
      bool sdPing = await HttpAiStoryLocalSd().sdPing(newUrl: sdUrl);
      if (sdPing) {
        // 获取 AppBloc 实例
        final appBloc = BlocProvider.of<AppBloc>(context);
        // 派发事件以更新文件夹
        appBloc.switchSdWebUiUrl(sdUrl);
        HttpUtil.apiLocalUrl = sdUrl;
        MotionToast.success(description: Text("设置成功")).show(context);
      } else {
        MotionToast.warning(description: Text("SD地址无法连接")).show(context);
      }
    }

    setState(() {
      _isLoading = false; // 恢复加载状态为 false
    });
  }

  Future<void> _checkBaidu() async {
    setState(() {
      _isLoadingBiaud = true; // 设置加载状态为 true
    });

    String appId = _baiduKeyController.text;
    String tk = _baiduTkController.text;
    // if (appId.isEmpty || tk.isEmpty) {
    //   Toast.error(context, "key和密钥不能为空！");
    //   setState(() {
    //     _isLoadingBiaud = false; // 恢复加载状态为 false
    //   });
    //   return;
    // }
    // print('检查百度key:' + appId);
    if (appId.isNotEmpty && tk.isNotEmpty) {
      bool sdPing = await HttpAiStoryLocalSd()
          .sdPingBaidu(key: appId, tk: tk, text: "测试一下");
      if (sdPing) {
        MotionToast.success(description: Text("设置成功")).show(context);
      } else {
        MotionToast.warning(description: Text("百度翻译密钥错误")).show(context);
      }
    } else {
      MotionToast.warning(description: Text("百度翻译密钥设置为空")).show(context);
    }
    // 获取 AppBloc 实例
    final appBloc = BlocProvider.of<AppBloc>(context);
    // 派发事件以更新文件夹
    appBloc.switchBaiduTrans(appId, tk);
    HttpUtil.baiduKey = appId;
    HttpUtil.baiduTk = tk;

    setState(() {
      _isLoadingBiaud = false; // 恢复加载状态为 false
    });
  }

  ///检测磁盘上的剪映草稿位置
  Future<String?> listDrives() async {
    // 获取所有盘符
    // Stream<FileSystemEntity> drives = Directory('D:/').list(followLinks: false);
    List<String> drives = [];
    drives.add("C:");
    drives.add("D:");
    drives.add("E:");
    drives.add("F:");
    drives.add("G:");
    drives.add("H:");

    for (String drive in drives) {
      //先检测当前盘符是否有
      String jianyingProDraftsPath = '$drive/JianyingPro Drafts';
      Directory pan = Directory(jianyingProDraftsPath);
      if (await pan.exists()) {
        // 返回JianyingPro Drafts文件夹的路径，你可以在这里进行进一步处理或返回路径
        return pan.path;
      }

      // 构建Program Files路径
      String programFilesPath86 = '${drive}/Program Files (x86)';
      String programFilesPath = '${drive}/Program Files';
      // 检查Program Files文件夹是否存在
      Directory programFilesDir86 = Directory(programFilesPath86);
      Directory programFilesDir = Directory(programFilesPath);

      if (await programFilesDir86.exists()) {
        print('找到Program Files (x86)文件夹：${programFilesDir86.path}');
        // 构建JianyingPro Drafts路径
        String jianyingProDraftsPath =
            '${programFilesDir86.path}/JianyingPro Drafts';
        // 检查JianyingPro Drafts文件夹是否存在
        Directory jianyingProDraftsDir = Directory(jianyingProDraftsPath);
        if (await jianyingProDraftsDir.exists()) {
          print('X86找到JianyingPro Drafts文件夹：${jianyingProDraftsDir.path}');
          // 返回JianyingPro Drafts文件夹的路径，你可以在这里进行进一步处理或返回路径
          return jianyingProDraftsDir.path;
        }
      }
      if (await programFilesDir.exists()) {
        print('找到Program Files文件夹：${programFilesDir.path}');
        String jianyingProDraftsPath =
            '${programFilesDir.path}/JianyingPro Drafts';
        // 检查JianyingPro Drafts文件夹是否存在
        Directory jianyingProDraftsDir = Directory(jianyingProDraftsPath);
        if (await jianyingProDraftsDir.exists()) {
          print('找到JianyingPro Drafts文件夹：${jianyingProDraftsDir.path}');
          // 返回JianyingPro Drafts文件夹的路径，你可以在这里进行进一步处理或返回路径
          return jianyingProDraftsDir.path;
        }
      }
    }
    return null;
  }

//SwitchListTile(
  Widget _buildShowBg(BuildContext context) => BlocBuilder<AppBloc, AppState>(
        builder: (_, state) => TolySwitchListTile(
          secondary: Icon(
            TolyIcon.icon_background,
            color: Theme.of(context).primaryColor,
          ),
          title: const Text('显示背景',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          value: state.showBackGround,
          onChanged: (bool value) {
            BlocProvider.of<AppBloc>(context).switchShowBg(value);
          },
        ),
      );

  Widget _buildShowOver(BuildContext context) => BlocBuilder<AppBloc, AppState>(
      builder: (_, state) => TolySwitchListTile(
            secondary: Icon(
              TolyIcon.icon_background,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('显示性能浮层',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            value: state.showPerformanceOverlay,
            onChanged: (bool value) {
              BlocProvider.of<AppBloc>(context).switchShowOver(value);
            },
          ));

  Widget _nextIcon(BuildContext context) =>
      Icon(Icons.chevron_right, color: Theme.of(context).primaryColor);
}
