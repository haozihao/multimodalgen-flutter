import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../../../app/model/TweetScript.dart';

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

///分镜组件的画面动画运动调整
class AnimePreviewPanel extends StatefulWidget {
  final TweetImage tweetImage;
  final int ratio;
  final String direction;

  AnimePreviewPanel({
    Key? key,
    required this.tweetImage,
    required this.ratio,
    required this.direction,
  }) : super(key: key);

  @override
  State<AnimePreviewPanel> createState() => _AnimePreviewPanelState();
}

class _AnimePreviewPanelState extends State<AnimePreviewPanel> {
  var control = Control.play;
  late MovieTween tween;
  double ratio = 1;
  double width = 400;
  double height = 400;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {;
// if (widget.tweetImage.videoUrl?.isNotEmpty??true) playerAi.open(Media(widget.tweetImage.videoUrl!));
//0表示1:1，1表示4:3，2表示16:9，3表示9:16，4表示3:4，5表示2:3，6表示3:2
    switch (widget.ratio) {
      case 1:
        ratio = 4 / 3;
        height = width / ratio;
        break;
      case 2:
        ratio = 16 / 9;
        height = width / ratio;
        break;
      case 3:
        ratio = 9 / 16;
        width = height / ratio;
        break;
      case 4:
        ratio = 3 / 4;
        width = height / ratio;
        break;
      case 5:
        ratio = 2 / 3;
        break;
      case 6:
        ratio = 3 / 2;
        break;
    }
    tween = MovieTween();
//向上、向下、向左、向右
    switch (widget.direction) {
      case "0":
        tween
            .tween('y', Tween<double>(begin: height, end: 100.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInCubic)
            .tween('x', Tween<double>(begin: 0, end: 0.0))
            .thenTween('y', Tween<double>(begin: 100.0, end: 0.0),
                duration: const Duration(milliseconds: 3000));
        break;
      case "1":
        tween
            .tween('y', Tween<double>(begin: -height, end: -100.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInCubic)
            .tween('x', Tween<double>(begin: 0, end: 0.0))
            .thenTween('y', Tween<double>(begin: -100.0, end: 0.0),
                duration: const Duration(milliseconds: 3000));
        break;
      case "2":
        tween
            .tween('x', Tween<double>(begin: width, end: 100.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInCubic)
            .tween('y', Tween<double>(begin: 0, end: 0.0))
            .thenTween('x', Tween<double>(begin: 100.0, end: 0.0),
                duration: const Duration(milliseconds: 3000));
        break;
      case "3":
        tween
            .tween('x', Tween<double>(begin: -width, end: -100.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInCubic)
            .tween('y', Tween<double>(begin: 0, end: 0.0))
            .thenTween('x', Tween<double>(begin: -100.0, end: 0.0),
                duration: const Duration(milliseconds: 3000));
        break;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // double height = 400;
    // double width = height * ratio;
    // logger.d("width: $width, height: $height");
    return SizedBox(
      child: Stack(alignment: AlignmentDirectional.center, children: [
        CustomAnimationBuilder<Movie>(
          control: control,
          onCompleted: () {
            debugPrint("anime onCompleted!");
          },
          developerMode: false,
          tween: tween,
          duration: tween.duration,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(value.get("x"), value.get("y")),
// child: Container(
//   width: 720,
//   height: 640,
//   child: Video(controller: controllerAi),
// ),
              child: widget.tweetImage.url!.startsWith("http")
                  ? CachedNetworkImage(
                      fit: BoxFit.contain,
                      imageUrl: widget.tweetImage.url!,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                  : Image.file(
                      File(widget.tweetImage.url!),
                      fit: BoxFit.contain),
            );
          },
        ),
        IconButton(
            onPressed: () {
              setState(() {
                control = Control.playFromStart;
              });
            },
            icon: Icon(
              Icons.play_arrow_outlined,
              size: 38,
            )),
      ]),
    );
  }
}
