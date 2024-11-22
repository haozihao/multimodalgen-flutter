import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:app/app.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:authentication/authentication.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utils/utils.dart';
import 'package:widget_module/blocs/blocs.dart';

import 'pieces_ai_text.dart';

/// 说明: app 闪屏页

class StandardUnitSplash extends StatefulWidget {
  const StandardUnitSplash({Key? key}) : super(key: key);

  @override
  _StandardUnitSplashState createState() => _StandardUnitSplashState();
}

class _StandardUnitSplashState extends State<StandardUnitSplash>
    with TickerProviderStateMixin {
  static const int _minCost = 1500;

  int _recorder = 0;


  @override
  void initState() {
    super.initState();
    _recorder = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    final Size winSize = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark),
      child: Material(
        child: BlocListener<AppBloc, AppState>(
            listener: _listenStart,
            listenWhen: (p, n) => p.dbPath.isEmpty && n.dbPath.isNotEmpty,
            child: Column(
              children: [
                const Spacer(),
                Expanded(
                    child: Wrap(
                  direction: Axis.vertical,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Image.asset(
                          'assets/images/ic_launcher.png',
                          width: 120,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    _buildFlutterUnitText(winSize.height, winSize.width),
                  ],
                )),
                const Expanded(
                    child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(
                        bottom: 15,
                        child: Wrap(
                          direction: Axis.vertical,
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text("",
                                style: UnitTextStyle.splashShadows),
                            Text("",
                                style: UnitTextStyle.splashShadows),
                          ],
                        )),
                  ],
                ))
              ],
            )),
      ),
    );
  }

  Widget _buildFlutterUnitText(double winH, double winW) {
    return FlutterUnitText(
      text: StrUnit.appName,
      color: Theme.of(context).primaryColor,
    );
  }
  
  // 监听资源加载完毕，启动，触发事件
  void _listenStart(BuildContext context, AppState state) async {
    HttpUtil.instance.rebase(PathUnit.baseUrl);
    int cost = DateTime.now().millisecondsSinceEpoch - _recorder;
    // BlocProvider.of<WidgetsBloc>(context)
    //     .add(const EventTabTap(WidgetFamily.statelessWidget));
    // BlocProvider.of<LikeWidgetBloc>(context).add(const EventLoadLikeData());
    BlocProvider.of<DraftBloc>(context).add(const EventLoadDrafts());
    // //发送登录验证
    BlocProvider.of<AuthBloc>(context).add(const AppStarted());

    // 启动耗时小于 _minCost 时，等待 delay 毫秒
    int delay = cost < _minCost ? _minCost - cost : 0;

    // UmengCommonSdk.initCommon("", "5fb4fc8a257f6b73c0970a37", "TWEET_IOS_Pro");
    Future.delayed(Duration(milliseconds: delay)).then((value) {
      Navigator.of(context).pushReplacementNamed(UnitRouter.nav);
    });

  }
}
