import 'package:sqflite/sqflite.dart';
import 'package:storage/src/db_storage/models/sd_config.dart';

class SDConfigDao {
  final Database database;

  SDConfigDao(this.database);

  //表名
  static const String tableName = "local_sd_config";

  //建表
  static const String createTable = """
CREATE TABLE IF NOT EXISTS local_sd_config(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    url TEXT NOT NULL DEFAULT '',
    mode TEXT NOT NULL DEFAULT '',
    lora TEXT NOT NULL DEFAULT '',
    vae TEXT NOT NULL DEFAULT '',
    seed INTEGER DEFAULT -1,
    step INTEGER DEFAULT 20,
    restoration INTEGER DEFAULT 0,
    correlation INTEGER DEFAULT 7,
    redrawRange INTEGER DEFAULT 7,
    sampling TEXT NOT NULL DEFAULT '',
    positivePrompt TEXT NOT NULL DEFAULT '',
    negativePrompt TEXT NOT NULL DEFAULT '',
    baiduId VARCHAR(256) NOT NULL DEFAULT '',
    baiduKey VARCHAR(256) DEFAULT ''
    );""";

  Future<void> createDb(Database db) async {
    print("初始化sd_config数据库.......1");
    db.execute(createTable);
  }

  Future<void> insertOrUpdate(SDConfig po) async {
    await database.insert(
      tableName,
      po.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<SDConfig> query() async {
    List<Map<String, dynamic>> queryResult =
        await database.rawQuery("SELECT * FROM $tableName WHERE id = 1");
    if (queryResult.isNotEmpty) {
      Map<String, dynamic> data = queryResult.first;
      SDConfig sdConfig = SDConfig.fromMap(data);
      return sdConfig;
    } else {
      SDConfig sdConfig =
          SDConfig(1, "", "", "", "", "", 7, -1, 20, 7, 0, "", "", "", "");
      insertOrUpdate(sdConfig);
      return sdConfig;
    }
  }
}
