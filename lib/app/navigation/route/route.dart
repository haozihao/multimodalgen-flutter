import 'dart:io';

import 'package:app/app.dart';
import 'package:flutter/material.dart';

import '../unit_navigation.dart';

class RoutePath {

  static const String nav = 'nav';

  static const String themeColorSetting = 'ThemeColorSettingPage';
  static const String codeStyleSetting = 'CodeStyleSettingPage';
  static const String itemStyleSetting = 'ItemStyleSettingPage';
  static const String fontSetting = 'FountSettingPage';

  Map<String, WidgetBuilder> get routes =>
      {
      };


  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case nav:
        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          return ZeroPageRoute(child: UnitNavigation());
        }
        return SlidePageRoute(child: UnitNavigation());
    }

    return null;
  }

}