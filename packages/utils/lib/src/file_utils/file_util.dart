import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class FileUtil {
  static const String draftFolder = 'drafts';

  //统一的总草稿文件夹
  static const String pieceAiDraftFolder = 'PieceAiDrafts';

  static const String base64Pre = "data:image/jpeg;base64,";

  static final FileUtil _instance = FileUtil._internal();

  static FileUtil get instance => _instance;

  ///通用全局单例，第一次使用时初始化
  FileUtil._internal();

  static String getFileSeparate() {
    String fileSeparate = "/";
    if (Platform.isMacOS) {
      fileSeparate = "/";
    }
    //Android平台使用的是linux内核，所以也是"/"
    if (Platform.isAndroid) {
      fileSeparate = "/";
    }
    return fileSeparate;
  }

  ///获取草稿总目录。
  static Future<String> getPieceAiDraftFolder() async {
    var appDir = await getApplicationDocumentsDirectory();
    String draftsDir =
        appDir.path + FileUtil.getFileSeparate() + pieceAiDraftFolder;
    return draftsDir;
  }

  @Deprecated("已过期")
  static Future<String> getDraftFolder() async {
    var appDir = await getApplicationDocumentsDirectory();
    String draftsDir = appDir.path + FileUtil.getFileSeparate() + draftFolder;
    return draftsDir;
  }

  ///根据草稿名获取本地草稿目录
  static Future<String> getPieceAiDraftFolderByTaskId(String draftName) async {
    var draftRoot = await getPieceAiDraftFolder();
    String draftPath = draftRoot + getFileSeparate() + draftName;
    return draftPath;
  }

  ///根据url地址自动判断是本地图片还是cache图片来获取文件
  static Future<File?> getImageFile(String url) async {
    File? cachedImageFile;
    if (url.startsWith("http")) {
      cachedImageFile = await DefaultCacheManager().getSingleFile(url);
    } else {
      cachedImageFile = File(url);
    }
    return cachedImageFile;
  }


  static String compressString(String input) {
    var bytes = utf8.encode(input); // Convert string to bytes
    var digest = sha256.convert(bytes); // Calculate hash value
    String result = base64Url.encode(digest.bytes).substring(0, 21);
    return result;
  }

  ///获取一键成片视频保存目录
  static String getVideoCopyMp4Folder() {
    return "videoCopy" + getFileSeparate() + "video";
  }

  ///一键追爆款图片路径
  static String getVideoCopyMp4Image() {
    return "videoCopy" + getFileSeparate() + "image";
  }

  static Future<String> getVideoAiFpsFolder(String rootPath) async {
    String dir = rootPath + FileUtil.getFileSeparate() + "AiFps";
    if (!await Directory(dir).exists()) {
      await Directory(dir).create(recursive: true);
    }
    return dir;
  }

  ///Ai生视频保存的目录
  static Future<String> getVideoAiFolder(String rootPath) async {
    String dir = rootPath + FileUtil.getFileSeparate() + "PieceAi";
    if (!await Directory(dir).exists()) {
      await Directory(dir).create(recursive: true);
    }
    return dir;
  }

  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  ///根据文件全路径获取文件命，并且去除后缀
  static String getFileName(String filePath) {
    // 使用路径分隔符将路径分割为部分
    List<String> parts = filePath.split('\\');
    // 获取路径的最后一个部分（即文件名）
    String fileNameWithExtension = parts.last;
    // 使用文件名的最后一个点（.）之前的部分作为文件名
    int dotIndex = fileNameWithExtension.lastIndexOf('.');
    String fileName = fileNameWithExtension.substring(0, dotIndex);

    return fileName;
  }

  ///获取网络资源文件的文件名
  static String getHttpNameWithExtension(String url) {
    // 解析 URL
    Uri uri = Uri.parse(url);
    // 获取文件名
    String fileName = uri.pathSegments.last;
    // 去掉后缀
    // String fileNameWithoutExtension = fileName.split('.').first;
    return fileName;
  }

  ///读取文件
  static Future<Uint8List?> readFileAsBytes(String filePath) async {
    // 读取文件
    File file = File(filePath);
    try {
      // 读取文件的字节数据
      Uint8List bytes = await file.readAsBytes();
      return bytes;
    } catch (e) {
      // 处理读取文件时的异常
      return null;
    }
  }

  // 清理路径中的特殊字符，例如将冒号替换为下划线
  static String sanitizePath(String path) {
    return path.replaceAll(':', '_');
  }

  ///创建文件夹，并去除特殊字符
  static Future<void> createDirectoryIfNotExists(String path) async {
    // 清理路径
    String sanitizedPath = sanitizePath(path);
    Directory directory = Directory(sanitizedPath);
    if (!directory.existsSync()) {
      // 创建目录，包括所有必要的父目录
      try {
        directory.createSync(recursive: true);
      } catch (e) {
        print('Error creating directory: $e');
      }
    } else {}
  }

  ///递归删除文件夹下所有文件
  static void deleteFolderContent(String path) {
    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      // print('Directory not found: $path');
      return;
    }

    // 遍历文件夹中的文件和子文件夹
    directory.listSync().forEach((entity) {
      if (entity is File) {
        // 如果是文件，则直接删除
        entity.deleteSync();
        // print('Deleted file: ${entity.path}');
      } else if (entity is Directory) {
        // 如果是子文件夹，则递归删除子文件夹内容
        deleteFolderContent(entity.path);
        // 删除空的子文件夹
        entity.deleteSync();
        // print('Deleted directory: ${entity.path}');
      }
    });
  }
}
