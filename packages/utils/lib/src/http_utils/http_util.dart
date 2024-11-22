import 'dart:convert';
import 'dart:io';

import 'package:app/app.dart';
import 'package:authentication/models/user.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Duration _kReceiveTimeout = Duration(seconds: 120);
const Duration _kSendTimeout = Duration(seconds: 120);
const Duration _kConnectTimeout = Duration(seconds: 120);

class HttpUtil {
  // TokenInterceptors? tokenInterceptors;

  static const String apiBaseUrl = 'https://api.pencil-stub.com';
  static String apiLocalUrl = '';
  static String apiFastUrl = '';
  static String baiduKey = '';
  static String baiduTk = '';

  static final HttpUtil _instance = HttpUtil._internal();

  Dio? _dio;

  static HttpUtil get instance => _instance;

  ///通用全局单例，第一次使用时初始化
  HttpUtil._internal() {
    _dio ??= Dio(
      BaseOptions(
          connectTimeout: _kConnectTimeout,
          sendTimeout: _kSendTimeout,
          receiveTimeout: _kReceiveTimeout),
    );
    // _dio!.interceptors.add(LogsInterceptors());
    // _dio.interceptors.add(ResponseInterceptors());
  }

  Dio get client => _dio!;

  static Future<Map<String, dynamic>> withBaseParam() async {
    Map<String, dynamic> queryParameters = {};
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userJson = sp.getString(SpKey.userKey);
    String? token = sp.getString(SpKey.tokenKey);
    if (userJson == null) {
      print("本地没有user信息");
      queryParameters['uid'] = 10001086;
    } else {
      User user = User.fromJson(jsonDecode(userJson));
      queryParameters['uid'] = user.userId;
      queryParameters['auth_token'] = token;
    }
    if (Platform.isWindows) {
      queryParameters['channel'] = "TWEET_Windows_Pro";
      try {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
      } catch (e) {
        //windows未激活
      }
    } else if (Platform.isMacOS) {
      queryParameters['channel'] = "TWEET_MacOS_Pro";
    } else if (Platform.isAndroid) {
      queryParameters['channel'] = "TWEET_Android_Pro";
    } else if (Platform.isIOS) {
      queryParameters['channel'] = "TWEET_IOS_Pro";
    }

    queryParameters['channel_id'] = 8;

    return queryParameters;
  }

  void setToken(String token) {
    print('---token---$token-------');
    // tokenInterceptors = TokenInterceptors(token: token);
    // _dio!.interceptors.add(tokenInterceptors!);
  }

  void deleteToken() {
    // _dio!.interceptors.remove(tokenInterceptors);
  }

  void rebase(String baseIp) {
    // _dio!.options.baseUrl = baseIp;
  }

  Future<String?> fetchData(String url302) async {
    var response = await http.get(
      Uri.parse(url302),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'Accept-encoding': 'gzip, deflate, br, zstd',
        'Accept-language': 'zh-CN,zh;q=0.9,en-GB;q=0.8,en;q=0.7,en-US;q=0.6',
        'cookie':
            'bd_ticket_guard_client_web_domain=2; passport_csrf_token=9ab118246a28089ae1fd4e5de6d4461d; passport_csrf_token_default=9ab118246a28089ae1fd4e5de6d4461d; _bd_ticket_crypt_doamin=2; __security_server_data_status=1; store-region-src=uid; UIFID_TEMP=3c3e9d4a635845249e00419877a3730e2149197a63ddb1d8525033ea2b3354c25de94c89708bb1306efc1a3864dc3143aa5a9481270e453e7ee039c3b6e713d2f39b1010326800e949ca12d643fed088; s_v_web_id=verify_lxvu5nvn_lr5w28xL_u9qd_4p01_90z9_8ZWMhqmLlMCk; fpk1=U2FsdGVkX1+0HyEAkGH1wwFMWgU/m50U+6AUpBAn+umQ3Q85Stjr0P423JnaL578h9eUL/5QMjXRXklP5P9gvQ==; fpk2=f1f6b29a6cc1f79a0fea05b885aa33d0; xgplayer_device_id=46143781690; xgplayer_user_id=390814247356; SEARCH_RESULT_LIST_TYPE=%22single%22; UIFID=3c3e9d4a635845249e00419877a3730e2149197a63ddb1d8525033ea2b3354c243f0018084b1d391ab68074e2604a2d14348f50a50780dd14cbce285746f9d30219dc27c446cfb9758a83f882cdf9ecadd52f034ef9800f7e344a44c5643ef899fc1c7b6eb2762a1031ee62271ac927e228129c8280ca7555e8534562ad0f220229bd75a18309683ae6f220028d9e02b9a62b2c4527a71884516f0c5826dac62; n_mh=U3-RzPErIu6IDFvo5FFGq_NlERZ2kseGeY97-gcLcUA; store-region=cn-gd; d_ticket=37fd68cf4294a8818ca5e889ecaed7e3f9ede; passport_assist_user=CkGNhwijcDXxos3ann0SUUNjabLsflTawt5Eh8wkrNNLzXE265aZN3ll_ALkBHS9Q-HEnLxThMzt1QGQueqJazB-2BpKCjzOXJ-eBi7H80QzOWyEllOB6kXy4mFOBys7HQEJ4-B6L0U9X0lNbuEN27Dh1mLve1wNbf08fYPFEbfgbk8Qq9PWDRiJr9ZUIAEiAQOKSuOT; sso_uid_tt=f42971fa7fa534cc074d7caedf0d69ee; sso_uid_tt_ss=f42971fa7fa534cc074d7caedf0d69ee; toutiao_sso_user=5a7f560da5ad3fb7487531dbc5e5790e; toutiao_sso_user_ss=5a7f560da5ad3fb7487531dbc5e5790e; sid_ucp_sso_v1=1.0.0-KDRjM2Y4Y2VlMmVkYmNhNzkzZTQ4OWYzZWNhOGM0NTIwNTEwNWM4NDUKIQiTtpCH4Y2tAxDasc-0BhjvMSAMMK6fhJcGOAVA-wdIBhoCbGYiIDVhN2Y1NjBkYTVhZDNmYjc0ODc1MzFkYmM1ZTU3OTBl; ssid_ucp_sso_v1=1.0.0-KDRjM2Y4Y2VlMmVkYmNhNzkzZTQ4OWYzZWNhOGM0NTIwNTEwNWM4NDUKIQiTtpCH4Y2tAxDasc-0BhjvMSAMMK6fhJcGOAVA-wdIBhoCbGYiIDVhN2Y1NjBkYTVhZDNmYjc0ODc1MzFkYmM1ZTU3OTBl; uid_tt=8affc489ffad9dca1eacb31e723889ef; uid_tt_ss=8affc489ffad9dca1eacb31e723889ef; sid_tt=0115e09ac447e915b1e16e71e646fc6f; sessionid=0115e09ac447e915b1e16e71e646fc6f; sessionid_ss=0115e09ac447e915b1e16e71e646fc6f; _bd_ticket_crypt_cookie=e078a10619856ee9961963392ee9c278; ttwid=1%7CokQrsjYRMeWYY0iIpg994hgGWNSliyUjSIQ2d_ucPog%7C1721704203%7C932cfd1852a991110b51f9f8cdd907b5013fadd57548c4ca4226fa521bab7e3e; sid_guard=0115e09ac447e915b1e16e71e646fc6f%7C1723002992%7C5184000%7CSun%2C+06-Oct-2024+03%3A56%3A32+GMT; sid_ucp_v1=1.0.0-KGVlZWU1NzE4YTBkOWM4Y2I0MjBiZTU3MGVmMGQwZDI5YTBkYzk4ZTgKGwiTtpCH4Y2tAxDw4Mu1BhjvMSAMOAVA-wdIBBoCaGwiIDAxMTVlMDlhYzQ0N2U5MTViMWUxNmU3MWU2NDZmYzZm; ssid_ucp_v1=1.0.0-KGVlZWU1NzE4YTBkOWM4Y2I0MjBiZTU3MGVmMGQwZDI5YTBkYzk4ZTgKGwiTtpCH4Y2tAxDw4Mu1BhjvMSAMOAVA-wdIBBoCaGwiIDAxMTVlMDlhYzQ0N2U5MTViMWUxNmU3MWU2NDZmYzZm; dy_sheight=1440; FOLLOW_LIVE_POINT_INFO=%22MS4wLjABAAAArhnsR0vrEHewVrzB7yXRsyZW0Eo7wTq0ADkiaQ3C68Sobf-3gj6WSJmJqs-dM4CJ%2F1723910400000%2F0%2F1723894059546%2F0%22; strategyABtestKey=%221723894059.733%22; publish_badge_show_info=%220%2C0%2C0%2C1723894060364%22; stream_player_status_params=%22%7B%5C%22is_auto_play%5C%22%3A0%2C%5C%22is_full_screen%5C%22%3A0%2C%5C%22is_full_webscreen%5C%22%3A0%2C%5C%22is_mute%5C%22%3A1%2C%5C%22is_speed%5C%22%3A1%2C%5C%22is_visible%5C%22%3A0%7D%22; __ac_nonce=066c0b9a700c4aa9e683b; __ac_signature=_02B4Z6wo00f016O8THwAAIDCf8XTyWroZ--jnEjAAI4413; douyin.com; device_web_cpu_core=12; device_web_memory_size=8; architecture=amd64; dy_swidth=5120; stream_recommend_feed_params=%22%7B%5C%22cookie_enabled%5C%22%3Atrue%2C%5C%22screen_width%5C%22%3A5120%2C%5C%22screen_height%5C%22%3A1440%2C%5C%22browser_online%5C%22%3Atrue%2C%5C%22cpu_core_num%5C%22%3A12%2C%5C%22device_memory%5C%22%3A8%2C%5C%22downlink%5C%22%3A10%2C%5C%22effective_type%5C%22%3A%5C%224g%5C%22%2C%5C%22round_trip_time%5C%22%3A50%7D%22; csrf_session_id=f2706adfabf04e4fb0edca1faf98f185; bd_ticket_guard_client_data=eyJiZC10aWNrZXQtZ3VhcmQtdmVyc2lvbiI6MiwiYmQtdGlja2V0LWd1YXJkLWl0ZXJhdGlvbi12ZXJzaW9uIjoxLCJiZC10aWNrZXQtZ3VhcmQtcmVlLXB1YmxpYy1rZXkiOiJCR3VDU0h5TUxEYXdpUTdDeWRTQllkQjE4QlF2dlB1YTNBVmgrTWJUcWJqVUk1VFh2VitoeHhLbWRTWnhsaDFTOWFZTmdPakUwaktQdzFJNHR4cWMxd1k9IiwiYmQtdGlja2V0LWd1YXJkLXdlYi12ZXJzaW9uIjoxfQ%3D%3D; passport_fe_beating_status=true; home_can_add_dy_2_desktop=%221%22; xg_device_score=7.478185374092298; FOLLOW_NUMBER_YELLOW_POINT_INFO=%22MS4wLjABAAAArhnsR0vrEHewVrzB7yXRsyZW0Eo7wTq0ADkiaQ3C68Sobf-3gj6WSJmJqs-dM4CJ%2F1723910400000%2F0%2F1723906475961%2F0%22; volume_info=%7B%22isMute%22%3Afalse%2C%22isUserMute%22%3Afalse%2C%22volume%22%3A0.5%7D; download_guide=%222%2F20240817%2F0%22; pwa2=%220%7C0%7C2%7C0%22; odin_tt=a45be8885ad99dc4eef35f6ebcd62f7a9b1a2d6193697ee649c5666c06f0257ab14130b17ba8ba5919b6726920a2fa40; IsDouyinActive=false',
      },
    );
    if (response.statusCode == 302) {
      return response.headers['location'];
    }
    return null;
  }

  Future<String> fetchRedirectedUrl({required String url}) async {
    final myRequest = await HttpClient().getUrl(Uri.parse(url));
    myRequest.followRedirects = false;
    final myResponse = await myRequest.close();
    return myResponse.headers.value(HttpHeaders.locationHeader).toString();
  }
}
