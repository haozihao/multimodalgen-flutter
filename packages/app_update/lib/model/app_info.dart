import 'package:app/app.dart';
import 'package:equatable/equatable.dart';
import 'package:utils/utils.dart';

class AppInfoApi {
  static Future<TaskResult<AppInfo>> getAppVersion(
      {required String appName}) async {
    String errorMsg = "";
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    print("获取最新版本参数："+param.toString());
    var result;
    try {
      result = await HttpUtil.instance.client.post(
          HttpUtil.apiBaseUrl + PathUnit.appInfo, data: param);
    } catch (err) {
      errorMsg = err.toString();
    }
    print("=====${result}=====");
    // 获取的数据非空且 status = true
    if (result.data != null) {
      // 说明有数据
      if (result.data['data'] != null) {
        return TaskResult.success(
            data: AppInfo(
          appName: result.data['data']['update_title'],
          appVersion: result.data['data']['version_name'],
          appUrl: result.data['data']['apk_url'],
          appSize: result.data['data']['version_code'],version_code: result.data['data']['version_code'],
              force_update: result.data['data']['force_update'],update_title: result.data['data']['update_title'],
              update_content: result.data['data']['update_content'],
        ), token: '');
      } else {
        return const TaskResult.success(data: null, token: '');
      }
    }
    return TaskResult.error(msg: '请求错误: $errorMsg');
  }
}

class AppInfo extends Equatable {
  final String appName;
  final String appVersion;
  final String appUrl;
  final int appSize;
  final int version_code;
  final int force_update;
  final String update_content;
  final String update_title;

  const AppInfo({
    required this.appName,
    required this.appVersion,
    required this.appUrl,
    required this.appSize,
    required this.version_code,
    required this.force_update,
    required this.update_title,
    required this.update_content,
  });

  @override
  List<Object?> get props => [appName, appVersion, appUrl, appSize,version_code,force_update,update_title,update_content];

  @override
  String toString() {
    return 'AppInfo{appName: $appName, appVersion: $appVersion, appUrl: $appUrl, appSize: $appSize, version_code: $version_code}'
        ', force_update: $force_update}, update_title: $update_title}, update_content: $update_content}';
  }
}
