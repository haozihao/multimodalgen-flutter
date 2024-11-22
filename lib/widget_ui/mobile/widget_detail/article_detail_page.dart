import 'package:app/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:webview_flutter/webview_flutter.dart';

/// create by blueming.wu on 2024/8/8
class ArticleDetailPage extends StatefulWidget {
  final String url;

  const ArticleDetailPage({Key? key, required this.url}) : super(key: key);

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late WebViewController controller;

  int progress = 0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          print(progress);
          this.progress = progress;
          setState(() {});
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
      ));
    if (widget.url.startsWith("http")) {
      controller.loadRequest(Uri.parse(widget.url));
    } else {
      controller.loadFlutterAsset(widget.url);
    }
  }

  _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("网页详情"),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          WebViewWidget(controller: controller),
          if (progress != 100)
            const Center(
              child: CupertinoActivityIndicator(),
            )
        ],
      ),
    );
  }
}
