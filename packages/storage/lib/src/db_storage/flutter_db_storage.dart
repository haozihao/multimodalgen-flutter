import 'dart:io';
import 'package:storage/storage.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:path/path.dart' as path;


class FlutterDbStorage {
  Database? _database;

  FlutterDbStorage._();

  static FlutterDbStorage instance = FlutterDbStorage._();

  late WidgetDao _widgetDao;
  late DraftDao _draftDao;
  late NodeDao _nodeDao;
  late LikeDao _likeDao;

  WidgetDao get widgetDao => _widgetDao;

  DraftDao get draftDao => _draftDao;

  NodeDao get nodeDao => _nodeDao;

  LikeDao get likeDao => _likeDao;

  Database get db => _database!;

  Future<void> initDb({String name = "flutter.db"}) async {
    if (_database != null) return;
    String databasesPath = await DbOpenHelper.getDbDirPath();
    String dbPath = path.join(databasesPath, name);

    if (Platform.isWindows||Platform.isLinux) {
      DatabaseFactory databaseFactory = databaseFactoryFfi;
      _database = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
            // version: DbUpdater.VERSION,
            // onCreate: _onCreate,
            // onUpgrade: _onUpgrade,
            // onOpen: _onOpen
        ),
      );
    }else{
      _database = await openDatabase(dbPath);
    }

    _widgetDao = WidgetDao(_database!);
    _draftDao = DraftDao(_database!);
    //临时用，创建新表
    _draftDao.createTable();

    _nodeDao = NodeDao(_database!);
    _likeDao = LikeDao(_database!);

    print('初始化数据库....');
  }

  Future<void> closeDb() async {
    await _database?.close();
    _database = null;
  }
}
