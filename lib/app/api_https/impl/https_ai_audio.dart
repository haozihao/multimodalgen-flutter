import 'package:pieces_ai/app/model/TweetScript.dart';
import 'package:utils/utils.dart';

const String getAudioTts = '/audio/tts';

///音频相关接口
class HttpsAiAudio {
  ///文字转语音
  Future<ImgTts?> tts(
      {required String sentence,
      required int pegg,
      required String type,
      required int speed,
      required int volume}) async {
    String errorMsg = "";
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    param['pegg'] = pegg * 10; //扣除皮蛋数,vip1皮蛋一张图
    param['spec'] = {
      'format': "wav",
      'text': sentence,
      "type": type,
      "speed": speed,
      "volume": volume
    };
    try {
      var result = await HttpUtil.instance.client.post(
        HttpUtil.apiBaseUrl + getAudioTts,
        data: param,
      );
      if (result.data != null) {
        if (result.data['code'] == 200) {
          // 获取风格数据
          print("音频接口" + result.data['data'].toString());
          int duration = result.data['data']['duration'];
          int fileLength = result.data['data']['file_length'];
          String url = result.data['data']['img'];
          ImgTts imgTts = ImgTts(
              duration: duration / 1000,
              fileLength: fileLength.toDouble(),
              url: url);
          return imgTts;
        } else {
          return null;
        }
      }
    } catch (e) {
      errorMsg = e.toString();
      print(errorMsg);
    }
    return null;
  }
}
