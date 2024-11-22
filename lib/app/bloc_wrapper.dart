import 'package:app/app.dart';
import 'package:app_update/app_update.dart';
import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pieces_ai/painter_system/bloc/gallery_unit/bloc.dart';
import 'package:storage/storage.dart';
import 'package:widget_module/blocs/blocs.dart';
import 'package:widget_repository/widget_repository.dart';
import 'package:provider/provider.dart';
import 'package:pieces_ai/app/navigation/mobile/state/appState.dart' as mobile;

/// create by blueming.wu
/// 说明: Bloc提供器包裹层

// final AppStart storage = AppStart();

class BlocWrapper extends StatefulWidget {
  final Widget child;

  const BlocWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _BlocWrapperState createState() => _BlocWrapperState();
}

class _BlocWrapperState extends State<BlocWrapper> {
  final DraftBloc draftBloc= DraftBloc(repository: DraftDbRepository());

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          // 全局 bloc : 维护应用存储状态、更新、认证
          ChangeNotifierProvider<mobile.AppState>(create: (_) => mobile.AppState()),
          BlocProvider<AuthBloc>(create: (_) => AuthBloc()..add(const AppStarted())),
          // BlocProvider<AuthBloc>(create: (_) => AuthBloc(repository: authRepository)),
          BlocProvider<AppBloc>(create: (_) => AppBloc(AppStateRepository())..initApp()),
          BlocProvider<UpdateBloc>(create: (_) => UpdateBloc()),
          BlocProvider<UserBloc>(create: (_) => UserBloc()),

          BlocProvider<DraftBloc>(create: (_) => draftBloc),
          BlocProvider<CategoryWidgetBloc>(create: (_) => CategoryWidgetBloc(categoryBloc: draftBloc)),
          BlocProvider<GalleryUnitBloc>(create: (_) => GalleryUnitBloc()..loadGalleryInfo()),
        ], child: widget.child);
  }

  @override
  void dispose() {
    draftBloc.close();
    FlutterDbStorage.instance.closeDb();
    super.dispose();
  }
}
