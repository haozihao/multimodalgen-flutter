import 'package:pieces_ai/app/model/videos/recom_video.dart';

abstract class RecomVideosRepository {
  // 获取服务器推荐的精选案例
  Future<List<RecomVideoData>> loadRecomVideoData();
}
