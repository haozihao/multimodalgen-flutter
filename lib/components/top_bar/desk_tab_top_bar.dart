import 'package:authentication/models/user.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pieces_ai/app/model/user_info_global.dart';

var logger = Logger(printer: PrettyPrinter());

GlobalKey<_DeskTabTopBarState> deskTopBarKey = GlobalKey();

class DeskTabTopBar extends StatefulWidget {
  //是否跳转到登录页面的callback
  final Function(bool) doLogin;

  const DeskTabTopBar({
    Key? key,
    required this.doLogin,
  }) : super(key: key);

  @override
  State<DeskTabTopBar> createState() => _DeskTabTopBarState();
}

class _DeskTabTopBarState extends State<DeskTabTopBar>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DeskTabTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    User user = GlobalInfo.instance.user;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: _buildUserInfoWidget(user),
    );
  }

  Widget _buildUserInfoWidget(User user) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 在这里执行点击事件的操作
        //看是否已经登录
        if (user.pegg > 0 &&
            user.authToken != null &&
            user.authToken!.isNotEmpty) {
        } else {
          widget.doLogin(true);
        }
      },
      child: Row(
        children: [
          SizedBox(
            width: 5,
          ),
        ],
      ),
    );
  }
}
