import 'package:flutter/material.dart';

/// create by 张风捷特烈 on 2020-03-29
/// contact me by email 1981462002@qq.com
/// 说明:
//    {
//      "widgetId": 168,
//      "name": '文字样式-ThemeData#TextTheme',
//      "priority": 1,
//      "subtitle":
//          "子组件可以通过ThemeData.of获取主题的数据进行使用。",
//    }
class TextThemeDemo extends StatelessWidget {
  const TextThemeDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme queryData = Theme.of(context).textTheme;
    Map<String, TextStyle> styles = {
      "headline1: ": queryData.displayLarge!,
      "headline2: ": queryData.displayMedium!,
      "headline3: ": queryData.displaySmall!,
      "headline4: ": queryData.headlineMedium!,
      "headline5: ": queryData.headlineSmall!,
      "headline6: ": queryData.titleLarge!,
      "button: ": queryData.labelLarge!,
      "overline: ": queryData.labelSmall!,
      "subtitle1: ": queryData.titleMedium!,
      "subtitle2: ": queryData.titleSmall!,
      "caption: ": queryData.bodySmall!,
      "bodyText1: ": queryData.bodyLarge!,
      "bodyText2: ": queryData.bodyMedium!,
    };

    return Column(
      children: styles.keys
          .map((String styleInfo) => buildItem(styleInfo, styles[styleInfo]!))
          .toList(),
    );
  }

  TextStyle get textStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );

  Widget buildItem(String styleInfo, TextStyle style) => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(styleInfo, style: textStyle),
                Text("@toly", style: style)
              ],
            ),
          ),
          const Divider(height: 1)
        ],
      );
}