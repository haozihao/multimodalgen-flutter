import 'package:app_update/app_update.dart';
import 'package:components/toly_ui/toly_ui.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'version/version_shower.dart';

/// create by blueming.wu on 2024/2/7

class VersionInfo extends StatelessWidget {
  const VersionInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF383838),
      appBar: AppBar(
        backgroundColor: Color(0xFF383838),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.grey),
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildTop(),
            _buildCenter(context),
            const Divider(
              height: 1,
            ),
            Spacer(),
            Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: <Widget>[
                // FeedbackWidget(
                //     onPressed: (){
                //       _launchURL("https://github.com/toly1994328/FlutterUnit");
                //     },
                //     child: const Text('《查看本项目Github仓库》',style: TextStyle(fontSize: 12,color: Color(0xff616C84),),)),
                const Text(
                  'Power By 铅笔头（深圳）科技有限公司',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Text(
                  'Copyright © 2020-2024 ',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: <Widget>[
                // FeedbackWidget(
                //     onPressed: (){
                //       _launchURL("https://github.com/toly1994328/FlutterUnit");
                //     },
                //     child: const Text('《查看本项目Github仓库》',style: TextStyle(fontSize: 12,color: Color(0xff616C84),),)),
                GestureDetector(
                  child: const Text(
                    '粤ICP备2020090975号-1',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () =>
                      launchUrl(Uri.parse("https://beian.miit.gov.cn")),
                ),
                GestureDetector(
                  child: const Text(
                    '网信算备440305023552001240019号\n网信算备440305023552001240027号',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () => launchUrl(Uri.parse("https://beian.cac.gov.cn")),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTop() {
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 40,
      children: const [
        Text(
          '版本信息',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 60,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CircleImage(
              borderSize: 1,
              image: AssetImage("assets/images/ic_launcher.png"),
              size: 80,
            ),
            Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Pieces Ai(Pro)',
                  style: TextStyle(fontSize: 20),
                ),
                VersionShower()
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildCenter(BuildContext context) {
    // const TextStyle labelStyle = TextStyle(fontSize: 13);
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
      child: const AppUpdatePanel(),
    );
  }
}
