
import 'package:dio/dio.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/widget_ai_chose/ai_input_content.dart';
import 'package:utils/utils.dart';

import '../../model/ai_image2_video.dart';


const String getVideoLinkUri = '/ai/get_link/detail';
const String getPromptByImage = '/ai/ai_paint/reverse';
const String image2VideoPath = '/ai/ai_video/image_to_video';
const String getPromptByImageLocal = '/sdapi/v1/interrogate';
const String getRemoveSubtitle = '/ai/remove_subtitle';
const String getAsr = '/ai/asr_audio';

class HttpsVideoCopyRepository {

  Future<List<SrtModel>> aiAsr({required String audioUrl,required int pegg}) async{
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    param['pegg'] = pegg*10;//扣除1皮蛋
    // int start = DateTime.now().millisecondsSinceEpoch;
    param['spec'] = {'task_id': "","audio_url":audioUrl};

    try{
      var result = await HttpUtil.instance.client.post(
          HttpUtil.apiBaseUrl + getAsr,
          data: param
      );
      if (result.data != null) {
        if (result.data['code'] == 200) {
          List<dynamic> sentences= result.data['data']['sentences'];
          List<SrtModel> srtModelList = [];
          print("Ai获取字幕文件算法耗时：${sentences}");
          sentences.forEach((element) {
            SrtModel srtModel = SrtModel(start: element['begin_time'].toDouble(), end: element['end_time'].toDouble(), sentence: element['text']);
            srtModelList.add(srtModel);
          });
          return srtModelList;
        } else {
          return []; // Handle the case where the API call was not successful
        }
      }
    } catch (e) {
      return [];
    }
    return [];
  }
}
