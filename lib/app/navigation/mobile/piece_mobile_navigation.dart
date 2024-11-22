import 'package:app/app/router/slide_page_route.dart';
import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:pieces_ai/app/navigation/mobile/bottomMenuBar.dart';
import 'package:pieces_ai/app/navigation/mobile/mobile_main_page.dart';
import 'package:pieces_ai/app/navigation/mobile/recom_videos_page.dart';
import 'package:pieces_ai/app/navigation/mobile/state/appState.dart';
import 'package:pieces_ai/app/navigation/mobile/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:utils/utils.dart';

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

class PieceMobileNavigation extends StatefulWidget {
  const PieceMobileNavigation({super.key});

  @override
  _UnitDeskNavigationState createState() => _UnitDeskNavigationState();
}

class _UnitDeskNavigationState extends State<PieceMobileNavigation> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var state = Provider.of<AppState>(context, listen: false);
      state.setPageIndex = 0;
    });
    // ActionUnit.searchAction.onSearch = () {
    //   Navigator.of(context).pushNamed(UnitRouter.search);
    // };
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _body() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: _listenLoginState,
      builder: (context, state) {
        return _getPage(context.watch<AppState>().pageIndex);
      },
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return MobileMainPage(doLogin: (bool isLogin) {
          if (isLogin) {
            showLoginDialog(context);
          }
        });
      case 1:
        return const RecomVideosPage();
      default:
        return MobileMainPage(doLogin: (bool isLogin) {
          if (isLogin) {
            showLoginDialog(context);
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          int currentIndex = context.read<AppState>().pageIndex;
          logger.d("didPop:$didPop,result:$result,currentIndex:$currentIndex");
          if (currentIndex != 0) {
            Provider.of<AppState>(context, listen: false).setPageIndex = 0;
          } else {
            //退出应用
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.zero,
            child: AppBar(
              backgroundColor: AppColor.piecesBlackGrey,
              title: const Text('Pieces AI'),
            ),
          ),
          backgroundColor: AppColor.piecesBlackGrey,
          bottomNavigationBar: const BottomMenubar(),
          body: _body(),
        ));
  }

  void showLoginDialog(BuildContext context) {
    logger.d("跳转到登录");
  }

  void _listenLoginState(BuildContext context, AuthState state) {
    logger.d("首页顶部 收到登录成功通知:$state, User:${state.props}");
    if (state is AuthSuccess) {
      //发送用户登录成功通知
      // setState(() {});
    }
    // if (state is AuthInitial) {
    //   setState(() {});
    // }
    if (state is AuthFailure) {
      Toast.error(context, '登录失败！');
    }
  }

}
