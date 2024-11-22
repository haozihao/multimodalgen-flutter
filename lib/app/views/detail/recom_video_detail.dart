import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:pieces_ai/app/model/videos/recom_video.dart';
import 'package:video_player/video_player.dart';

class VideoDetail extends StatefulWidget {
  final RecomVideo recomVideo;

  const VideoDetail({Key? key, required this.recomVideo}) : super(key: key);

  @override
  State<VideoDetail> createState() => _VideoDetailState();
}

class _VideoDetailState extends State<VideoDetail> {
  late final videoPlayerController;
  late final chewieController = ChewieController(
    videoPlayerController: videoPlayerController,
    autoPlay: true,
    looping: false,
  );

  @override
  void initState() {
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.recomVideo.linkUrl!))
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
    super.initState();
  }

  dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recomVideo.title ?? "视频详情"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Text(
            "所有素材均由PieceAi生成",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          _buildVideoPlayer()
        ],
      ),
    );
  }

  _buildVideoPlayer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      child: videoPlayerController.value.isInitialized
          ? AspectRatio(
              aspectRatio: videoPlayerController.value.aspectRatio,
              child: Chewie(
                controller: chewieController,
              ),
            )
          : SizedBox.shrink(),
    );
  }
}
