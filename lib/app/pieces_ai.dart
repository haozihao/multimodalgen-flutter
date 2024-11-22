import 'package:app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pieces_ai/app/router/unit_router.dart';
import 'package:pieces_ai/app/views/splash/standard_unit_splash.dart';
// #docregion app-localizations-import
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// #enddocregion app-localizations-import

/// create by blueming.wu
/// 说明: 主程序启动

class FlutterUnit extends StatelessWidget {
  const FlutterUnit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(builder: (_, state) {
      return DefaultTextStyle(
        style: TextStyle(fontFamily: state.fontFamily),
        child: MaterialApp(
          // routes: ,
          showPerformanceOverlay: state.showPerformanceOverlay,
          title: StrUnit.appName,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: UnitRouters.generateRoute,
          localizationsDelegates: [
            AppLocalizations.delegate, // Add this line
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CN'),
            Locale('en', 'US'),
            //西班牙语
            Locale('es', 'ES'),
          ],
          themeMode: ThemeMode.dark,
          // themeMode: state.themeMode,
          darkTheme: AppTheme.darkTheme(state),
          theme: AppTheme.lightTheme(state),
          // theme: ThemeData(
          //   primarySwatch: state.themeColor,
          //   fontFamily: state.fontFamily,
          // ),
          //全局单例的loading
          builder: EasyLoading.init(),
          home: const StandardUnitSplash(),
        ),
      );
    });
  }
}
