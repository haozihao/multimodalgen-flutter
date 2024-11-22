import 'package:pieces_ai/app/model/diy/diy_roles.dart';
import 'package:utils/utils.dart';

const String getAllDiyRolesPath = '/ai/ai_role_prompt/custom_list';
const String updateDiyRolePath = '/ai/ai_role_prompt/edit';
const String deleteDiyRolePath = '/ai/ai_role_prompt/delete';

class HttpsDiyRolesRepository {
  Future<List<CustomRolePicture>> getAllDiyRoles() async {
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    param['spec'] = {};
    try {
      var result = await HttpUtil.instance.client.post(
        HttpUtil.apiBaseUrl + getAllDiyRolesPath,
        data: param,
      );
      if (result.data != null) {
        if (result.data['code'] == 200) {
          // print("获取自定义形象" + result.data['data'].toString());
          List<dynamic> vipWaysDy = result.data['data'];
          List<CustomRolePicture> diyAiRoleList = [];
          vipWaysDy.forEach((element) {
            CustomRolePicture diyAiRole = CustomRolePicture.fromJson(element);
            diyAiRoleList.add(diyAiRole);
          });
          return diyAiRoleList;
        } else {
          return [];
        }
      }
      return [];
    } catch (e) {
      print("获取自定义形象失败");
      return [];
    }
  }

  Future<int> updateDiyRole(CustomRolePicture diyAiRole) async {
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    param['spec'] = diyAiRole;
    var result = await HttpUtil.instance.client.post(
      HttpUtil.apiBaseUrl + updateDiyRolePath,
      data: param,
    );
    // print("更新自定义角色:" + param.toString());
    if (result.data != null) {
      if (result.data['code'] == 200) {
        print("更新角色返回" + result.data['data'].toString());
        return 200;
      } else {
        return 500;
      }
    }
    return 500;
  }

  Future<int> deleteDiyRole(CustomRolePicture diyAiRole) async {
    Map<String, dynamic> param = await HttpUtil.withBaseParam();
    param['spec'] = {
      "ids": [diyAiRole.id]
    };
    var result = await HttpUtil.instance.client.post(
      HttpUtil.apiBaseUrl + deleteDiyRolePath,
      data: param,
    );
    print("删除自定义角色:" + param.toString());
    if (result.data != null) {
      if (result.data['code'] == 200) {
        print("获取自定义形象" + result.data.toString());
        return 200;
      } else {
        return 500;
      }
    }
    return 500;
  }
}
