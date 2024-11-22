import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mobile/piece_mobile_navigation.dart';

/// 说明: 主题结构 左右滑页 + 底部导航栏

class UnitNavigation extends StatelessWidget {
  const UnitNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark),
        child: PieceMobileNavigation());
  }
}