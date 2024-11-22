import 'package:sqflite/sqflite.dart';
import '../models/draft_po.dart';

// """
// CREATE TABLE IF NOT EXISTS category_widget(
//     id INTEGER PRIMARY KEY AUTOINCREMENT,
//     name VARCHAR(64) NOT NULL,
//     color VARCHAR(9) DEFAULT '#FF2196F3',
//     info VARCHAR(256) DEFAULT '这里什么都没有...',
//     created DATETIME NOT NULL,
//     updated DATETIME NOT NULL,
//     priority INTEGER DEFAULT 0,
//     image VARCHAR(128) NULL image DEFAULT ''
//     );
// """;

class DraftDao {
  final Database db;

  DraftDao(this.db);

  Future<void> createTable() async {
    // String deleteSql = "DROP TABLE IF EXISTS category;";
    String deleteDraft = "DROP TABLE IF EXISTS draft;";
    //升级库增加列
    String updateSql = "ALTER TABLE draft ADD COLUMN type INTEGER DEFAULT 0;";
    //插入方法
    String addSql = //插入数据
        """
CREATE TABLE IF NOT EXISTS draft(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(64) NOT NULL,
    task_id VARCHAR(128) NOT NULL DEFAULT '',
    info VARCHAR(256) DEFAULT '这里什么都没有...',
    created DATETIME NOT NULL,
    updated DATETIME NOT NULL,
    priority INTEGER DEFAULT 0,
    icon VARCHAR(128) DEFAULT '',
    status INTEGER DEFAULT 0
    );"""; //建表语句
    // await db.transaction((tran) async => await tran.execute(deleteSql));
    // await db.transaction((tran) async => await tran.execute(deleteDraft));
    try{
      await db.transaction((tran) async => await tran.execute(updateSql));
    }catch(e){

    }
  }

  // Future<int> insert(Draft draft) async {
  //   //插入方法
  //   String addSql = //插入数据
  //       "INSERT INTO "
  //       "draft(id,task_id,name,info,priority,icon,created,updated,status,type) "
  //       "VALUES (?,?,?,?,?,?,?,?,?,?);";
  //   return await db.transaction((tran) async => await tran.rawInsert(addSql, [
  //         draft.id,
  //         draft.taskId,
  //         draft.name,
  //         draft.info,
  //         draft.priority,
  //         draft.icon,
  //         draft.created?.toIso8601String(),
  //         draft.updated.toIso8601String(),
  //         draft.status,
  //         draft.type,
  //       ]));
  // }

  Future<int> insert(Draft draft) async {
    // 插入方法
    String addSql = // 插入数据
        "INSERT INTO "
        "draft(task_id,name,info,priority,icon,created,updated,status,type) "
        "VALUES (?,?,?,?,?,?,?,?,?);";
    return await db.transaction((tran) async {
      int id = await tran.rawInsert(addSql, [
        draft.taskId,
        draft.name,
        draft.info,
        draft.priority,
        draft.icon,
        draft.created?.toIso8601String(),
        draft.updated.toIso8601String(),
        draft.status,
        draft.type,
      ]);
      return id;
    });
  }


  Future<int> update(Draft draft) async {
    print("更新草稿数据：" + draft.toString());

    // Prepare the SQL statement
    final StringBuffer updateSql = StringBuffer("UPDATE draft SET ");

    // Add non-null columns to the update statement
    final List<Object?> updateParams = [];
    if (draft.name != null) {
      updateSql.write("name=?, ");
      updateParams.add(draft.name);
    }
    if (draft.taskId != null) {
      updateSql.write("task_id=?, ");
      updateParams.add(draft.taskId);
    }
    if (draft.info != null) {
      updateSql.write("info=?, ");
      updateParams.add(draft.info);
    }
    if (draft.priority != null) {
      updateSql.write("priority=?, ");
      updateParams.add(draft.priority);
    }
    if (draft.icon != null) {
      updateSql.write("icon=?, ");
      updateParams.add(draft.icon);
    }
    updateSql.write("updated=?, status=? WHERE id = ?");
    updateParams.addAll([
      draft.updated.toIso8601String(),
      draft.status,
      draft.id,
    ]);

    // Execute the update query with a transaction
    return await db.transaction((tran) async =>
    await tran.rawUpdate(updateSql.toString(), updateParams));
  }


  Future<int> addWidget(
    int categoryId,
    int widgetId,
  ) async {
    String addSql = //插入数据
        "INSERT INTO "
        "category_widget(widgetId,categoryId) "
        "VALUES (?,?);";
    return await db.transaction((tran) async => await tran.rawInsert(addSql, [
          widgetId,
          categoryId,
        ]));
  }

  Future<int> addWidgets(int categoryId, List<dynamic> widgetIds) async {
    String addSql = //插入数据
        "INSERT INTO "
        "category_widget(widgetId,categoryId) VALUES ";

    String args = '';

    for (int i = 0; i < widgetIds.length; i++) {
      args += "(${widgetIds[i]},$categoryId)";
      if (i == widgetIds.length - 1) {
        args += ";";
      } else {
        args += ",";
      }
    }
    addSql += args;
    return await db.transaction((tran) async => await tran.rawInsert(addSql));
  }

  Future<bool> existByName(String name) async {
    String sql = //插入数据
        "SELECT COUNT(name) as count FROM draft "
        "WHERE name = ?";
    List<Map<String, dynamic>> rawData = await db.rawQuery(sql, [name]);
    if (rawData.isNotEmpty) {
      return rawData[0]['count'] > 0;
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    List<Map<String, dynamic>> data = await db.rawQuery(
        "SELECT c.id,c.name,c.info,c.task_id,c.icon,c.created,c.updated,c.status,c.type "
        "FROM draft AS c "
        "ORDER BY updated DESC",
        []);
    return data;
  }

  Future<List<int>> categoryWidgetIds(int id) async {
    List<Map<String, dynamic>> data = await db.rawQuery(
        "SELECT categoryId FROM `category_widget`"
        "WHERE widgetId = ?",
        [id]);
    return data.toList().map<int>((e) => e["categoryId"]).toList();
  }

  Future<void> deleteCollect(int id) async {
    await db.execute(
        "DELETE FROM category_widget "
        "WHERE categoryId = ?",
        [id]);
    return await db.execute(
        "DELETE FROM draft "
        "WHERE id = ?",
        [id]);
  }

  Future<void> clear() async {
    await db.execute("DELETE FROM category_widget "
        "WHERE categoryId >0");
    return await db.execute("DELETE FROM category "
        "WHERE id > 0");
  }

  Future<int> removeWidget(int categoryId, int widgetId) async {
    //插入方法
    String deleteSql = //插入数据
        "DELETE FROM "
        "category_widget WHERE categoryId = ? AND widgetId = ? ";
    return await db
        .transaction((tran) async => await tran.rawInsert(deleteSql, [
              categoryId,
              widgetId,
            ]));
  }

  Future<bool> existWidgetInCollect(int categoryId, int widgetId) async {
    String sql = //插入数据
        "SELECT COUNT(id) as count FROM category_widget "
        "WHERE categoryId = ? AND widgetId = ?";
    List<Map<String, dynamic>> rawData =
        await db.rawQuery(sql, [categoryId, widgetId]);
    if (rawData.isNotEmpty) {
      return rawData[0]['count'] > 0;
    }
    return false;
  }

  Future<void> toggleCollect(int categoryId, int widgetId) async {
    if (await existWidgetInCollect(categoryId, widgetId)) {
      //已存在: 移除
      await removeWidget(categoryId, widgetId);
    } else {
      await addWidget(categoryId, widgetId);
    }
  }

  Future<void> toggleCollectDefault(int widgetId) async {
    await toggleCollect(1, widgetId);
  }

  Future<List<Map<String, dynamic>>> loadCollectWidgets(int categoryId) async {
    String querySql = //插入数据
        "SELECT * FROM widget "
        "WHERE id IN (SELECT widgetId FROM category_widget WHERE categoryId = ?) "
        "ORDER BY lever DESC";

    return await db.rawQuery(querySql, [categoryId]);
  }

  Future<List<int>> loadCollectWidgetIds(int categoryId) async {
    String querySql = //插入数据
        "SELECT id FROM widget "
        "WHERE id IN (SELECT widgetId FROM category_widget WHERE categoryId = ?) "
        "ORDER BY lever DESC";

    var data = await db.rawQuery(querySql, [categoryId]);
    return data.map<int>((e) => e["id"] as int).toList();
  }
}
