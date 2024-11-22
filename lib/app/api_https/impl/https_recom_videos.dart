import 'package:logger/logger.dart';
import 'package:pieces_ai/app/model/videos/recom_video.dart';
import 'package:utils/utils.dart';

import '../ai_recom_videos_repository.dart';

const String getRecomVideosUrl = '/play_script/work/recom/v2';
var logger = Logger(printer: PrettyPrinter(methodCount: 0));

class HttpsRecomVideos extends RecomVideosRepository {
  @override
  Future<List<RecomVideoData>> loadRecomVideoData() async {
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    param['spec'] = {};
    param['app'] = {'ver_code': 10202001};
    var result = await HttpUtil.instance.client.post(
      HttpUtil.apiBaseUrl + getRecomVideosUrl,
      data: param,
    );

    if (result.data != null) {
      if (result.data['code'] == 200) {
        logger.d("拿到推荐视频数据" + result.data['data'].toString());
        List<RecomVideoData> recomVideoData = [];
        for (var item in result.data['data']) {
          recomVideoData.add(RecomVideoData.fromJson(item));
        }
        return recomVideoData;
      } else {
        return [];
      }
    }
    return [];
  }
}
