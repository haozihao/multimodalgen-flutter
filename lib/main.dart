import 'package:app/app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';

import 'app/bloc_wrapper.dart';
import 'app/pieces_ai.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // //滚动性能优化 1.22.0
  // GestureBinding.instance.resamplingEnabled = true;
  //加载全局配置文件
  await GlobalConfiguration().loadFromAsset("app_settings");
  runApp(
    EasyLocalization(
        supportedLocales: [Locale('en', 'US'), Locale('jp', 'JP')],
        path: 'assets/translations',
        // <-- change the path of the translation files
        fallbackLocale: Locale('jp', 'JP'),
        child: const BlocWrapper(child: FlutterUnit())),
  );
  WindowsAdapter.setSize();
}
