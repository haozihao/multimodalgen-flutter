import 'dart:async';
import 'dart:convert';

import 'package:storage/storage.dart';
import 'package:widget_repository/widget_repository.dart';


///从sql操作草稿数据的增删改查
class DraftDbRepository implements DraftRepository {
  DraftDao get draftDao => FlutterDbStorage.instance.draftDao;

  LikeDao get likeDao => FlutterDbStorage.instance.likeDao;

  @override
  Future<List<WidgetModel>> loadCategoryWidgets({int categoryId = 0}) async {
    List<Map<String, dynamic>> rawData =
        await draftDao.loadCollectWidgets(categoryId);
    List<WidgetPo> widgets = rawData.map((e) => WidgetPo.fromJson(e)).toList();
    return widgets.map(WidgetModel.fromPo).toList();
  }

  @override
  Future<int> addOneDraft(Draft draft) async {
    int id = await draftDao.insert(draft);
    return id;
  }

  @override
  Future<bool> check(int categoryId, int widgetId) async {
    return await draftDao.existWidgetInCollect(categoryId, widgetId);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await draftDao.deleteCollect(id);
  }

  @override
  Future<List<Draft>> loadDrafts() async {
    List<Map<String, dynamic>> data = await draftDao.queryAll();
    List<Draft> collects =
        data.map((e) => Draft.fromJson(e)).toList();
    return collects;
  }

  @override
  Future<void> toggleCategory(int categoryId, int widgetId) async {
    return await draftDao.toggleCollect(categoryId, widgetId);
  }

  @override
  Future<List<int>> getCategoryByWidget(int widgetId) async {
    return await draftDao.categoryWidgetIds(widgetId);
  }

  @override
  Future<bool> updateCategory(Draft draft) async {
    int success = await draftDao.update(draft);
    return success != -1;
  }

  @override
  Future<List<Draft>> loadCategoryData() async {
    List<Map<String, dynamic>> data = await draftDao.queryAll();

    Completer<List<Draft>> completer = Completer();
    List<Draft> collects = [];

    if (data.isEmpty) {
      completer.complete([]);
    }

    for (int i = 0; i < data.length; i++) {
      List<int> ids = await draftDao.loadCollectWidgetIds(data[i]['id']);
      // collects
      //     .add(Draft(widgetIds: ids, model: Draft.fromJson(data[i])));

      if (i == data.length - 1) {
        completer.complete(collects);
      }
    }

    return completer.future;
  }

  @override
  Future<bool> syncCategoryByData(String data, String likeData) async {
    try {
      await draftDao.clear();
      List<dynamic> dataMap = json.decode(data);
      for (int i = 0; i < dataMap.length; i++) {
        Draft draft = Draft.fromNetJson(dataMap[i]["model"]);
        List<dynamic> widgetIds = dataMap[i]["widgetIds"];
        await addOneDraft(draft);
        if (widgetIds.isNotEmpty && draft.id != null) {
          await draftDao.addWidgets(draft.id!, widgetIds);
        }
      }
      List<int> likeWidgets =
          (json.decode(likeData) as List).map<int>((e) => e).toList();
      for (int i = 0; i < likeWidgets.length; i++) {
        await likeDao.like(likeWidgets[i]);
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
