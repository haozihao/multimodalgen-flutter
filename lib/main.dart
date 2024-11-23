import 'package:app/app.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';

import 'app/bloc_wrapper.dart';
import 'app/pieces_ai.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // //滚动性能优化 1.22.0
  // GestureBinding.instance.resamplingEnabled = true;
  //加载全局配置文件
  await GlobalConfiguration().loadFromAsset("app_settings");
  runApp(
      const BlocWrapper(child: FlutterUnit())
  );
  WindowsAdapter.setSize();
}
