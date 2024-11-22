import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pieces_ai/app/gen/toly_icon_p.dart';
import 'package:pieces_ai/app/navigation/mobile/state/appState.dart';
import 'package:pieces_ai/app/navigation/mobile/theme/tabItem.dart';
import 'package:pieces_ai/app/navigation/mobile/theme/theme.dart';
import 'package:pieces_ai/widget_ui/mobile/customWidgets.dart';
import 'package:provider/provider.dart';

class BottomMenubar extends StatefulWidget {
  const BottomMenubar({
    Key? key,
  });

  @override
  _BottomMenubarState createState() => _BottomMenubarState();
}

class _BottomMenubarState extends State<BottomMenubar> {
  @override
  void initState() {
    super.initState();
  }

  Widget _iconRow() {
    var state = Provider.of<AppState>(
      context,
    );
    return Container(
      height: 70,
      decoration: BoxDecoration(color: Color(0xFF2D2D2D), boxShadow: const [
        BoxShadow(color: Colors.black12, offset: Offset(0, -2.1), blurRadius: 0)
      ]),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _icon(null, 0, AppLocalizations.of(context)!.create,
              icon: 0 == state.pageIndex ? TolyIconP.home : TolyIconP.home,
              isCustomIcon: true),
          _icon(null, 1, '优秀作品',
              icon: 1 == state.pageIndex
                  ? Icons.video_collection_outlined
                  : Icons.video_collection_outlined,
              isCustomIcon: true),
          _icon(null, 2, '工具',
              icon: 2 == state.pageIndex
                  ? Icons.handyman_outlined
                  : Icons.handyman_outlined,
              isCustomIcon: true),
        ],
      ),
    );
  }

  _buildBottomNavBar() {
    var state = Provider.of<AppState>(
      context,
    );
    var _selectedIndex = state.pageIndex;
    var textStyle = TextStyle(
        color: Colors.white, fontSize: 12);
    return BottomNavyBar(
      backgroundColor: AppColor.piecesBackTwo,
      selectedIndex: _selectedIndex,
      // containerHeight: 70,
      showElevation: true, // use this to remove appBar's elevation
      curve: Curves.easeOut,
      // showInactiveTitle: true,
      onItemSelected: (index) => setState(() {
        setState(() {
          state.setPageIndex = index;
        });
      }),
      items: [
        BottomNavyBarItem(
          icon: Icon(TolyIconP.home),
          title: Text(AppLocalizations.of(context)!.create,style: textStyle,),
          activeColor: Colors.white,
        ),
        BottomNavyBarItem(
            icon: Icon(Icons.video_collection_outlined),
            title: Text('优秀作品',style: textStyle,),
            activeColor: Colors.white),
        // BottomNavyBarItem(
        //     icon: Icon(Icons.handyman_outlined),
        //     title: Text('工具',style: textStyle,),
        //     activeColor: Colors.white),
        // BottomNavyBarItem(
        //     icon: Icon(Icons.people),
        //     title: Text('我的',style: textStyle,),
        //     activeColor: Colors.white),
      ],
    );
  }

  Widget _icon(IconData? iconData, int index, String title,
      {bool isCustomIcon = false, IconData? icon}) {
    if (isCustomIcon) {
      assert(icon != null);
    } else {
      assert(iconData != null);
    }
    var state = Provider.of<AppState>(
      context,
    );
    return Expanded(
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: AnimatedAlign(
          duration: const Duration(milliseconds: ANIM_DURATION),
          curve: Curves.easeIn,
          alignment: const Alignment(0, ICON_ON),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: ANIM_DURATION),
            opacity: ALPHA_ON,
            child: Column(
              children: [
                IconButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  padding: const EdgeInsets.all(0),
                  alignment: const Alignment(0, 2),
                  icon: isCustomIcon
                      ? customIcon(context,
                          icon: icon!,
                          size: 22,
                          isTwitterIcon: true,
                          isEnable: index == state.pageIndex)
                      : Icon(
                          iconData,
                          color: index == state.pageIndex
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).textTheme.bodySmall!.color,
                        ),
                  onPressed: () {
                    //判断是否登录，如果没有登录，跳转到登录页面

                    setState(() {
                      state.setPageIndex = index;
                    });
                  },
                ),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 10,
                      color: index == state.pageIndex
                          ? Theme.of(context).primaryColor
                          : Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBottomNavBar();
  }
}
