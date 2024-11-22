import 'package:app/app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pieces_ai/app/model/videos/recom_video.dart';
import 'package:pieces_ai/app/navigation/mobile/theme/theme.dart';

import '../../api_https/ai_recom_videos_repository.dart';
import '../../api_https/impl/https_recom_videos.dart';

var logger = Logger(printer: PrettyPrinter(methodCount: 0));

///桌面版本的首页本地草稿+云空间
class RecomVideosPage extends StatefulWidget {
  const RecomVideosPage({Key? key}) : super(key: key);

  @override
  State<RecomVideosPage> createState() => _RecomVideosPageState();
}

class _RecomVideosPageState extends State<RecomVideosPage> {
  final RecomVideosRepository recomVideosRepository = HttpsRecomVideos();
  Future<List<RecomVideoData>>? recomVideoData;

  @override
  void initState() {
    recomVideoData = recomVideosRepository.loadRecomVideoData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.piecesBlackGrey,
      appBar: AppBar(
        backgroundColor: AppColor.piecesBlackGrey,
        title: const Text('优秀作品展示'),
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: _buildRecomVideos()),
    );
  }

  _buildRecomVideos() {
    return FutureBuilder<List<RecomVideoData>>(
      future: recomVideoData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('网络请求失败'),
            );
          }
          if (snapshot.hasData) {
            List<RecomVideoData> recomVideoData = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: recomVideoData.map((e) => _buildArea(e)).toList(),
              ),
            );
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildArea(RecomVideoData recomVideoData) {
    logger.d("recomVideoData 个数: ${recomVideoData.children.length}");
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              recomVideoData.name,
              style: TextStyle(color: AppColor.piecesBlue, fontSize: 18),
            )),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            crossAxisCount: 2,
            childAspectRatio: 16 / 14,
          ),
          itemCount: recomVideoData.children.length,
          itemBuilder: (context, index) {
            return _buildItem(recomVideoData.children[index]);
          },
        ),
      ],
    );
  }

  _buildItem(RecomVideo recomVideo) {
    return Ink(
        //圆角
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
          //边缘增加阴影
          // boxShadow: [
          //   BoxShadow(
          //       color: Colors.white12,
          //       offset: const Offset(0.0, 1.0),
          //       blurRadius: 1.0,
          //       spreadRadius: 1.0),
          // ],
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context)
                .pushNamed(UnitRouter.video_detail, arguments: recomVideo);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                          image: CachedNetworkImageProvider(
                              recomVideo.imageUrl ?? ""),
                          fit: BoxFit.cover),
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    recomVideo.alias ?? "",
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 11),
                    maxLines: 2,
                  )),
            ],
          ),
        ));
  }
}
