
import 'package:app_update/app_update.dart';
import 'package:components/toly_ui/toly_ui.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'version/version_shower.dart';

/// create by blueming.wu on 2024/2/7

class VersionForceUpdate extends StatelessWidget {
  const VersionForceUpdate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF383838),
        title: const Text('版本升级'),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFF383838),
      body:ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildTop(),
              _buildCenter(context),
              const Spacer(),
              Divider(indent: 10,),
              Padding(
                padding: const EdgeInsets.only(bottom:5.0),
                child: buildBottom(),
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
      spacing: 10,
      children: const [
        Wrap(
          spacing: 30,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CircleImage(
              borderSize: 1,
              image: AssetImage("assets/images/ic_launcher.png"),
              size: 50,
            ),
            Wrap(
              direction: Axis.vertical,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Pieces Ai(Pro)',
                  style: TextStyle(fontSize: 16),
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
    return Padding(
      padding: const EdgeInsets.only(left:20.0,right: 20,top: 20),
      child: AppUpdatePanel(),
    );
  }

  Widget _nextIcon(BuildContext context) =>
      const Icon(Icons.chevron_right, color: Colors.grey);

  Widget buildBottom() {
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        // FeedbackWidget(
        //     onPressed: (){
        //       _launchURL("https://github.com/toly1994328/FlutterUnit");
        //     },
        //     child: const Text('《查看本项目Github仓库》',style: TextStyle(fontSize: 12,color: Color(0xff616C84),),)),
        const Text('Power By 铅笔头（深圳）科技有限公司',style: TextStyle(fontSize: 10,color: Colors.grey),),
        const Text('Copyright © 2020-2024 ',style: TextStyle(fontSize: 10,color: Colors.grey),),
      ],
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {

    }
  }
}
