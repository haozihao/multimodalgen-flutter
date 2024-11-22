

///草稿文件工具类
class DraftUtil {
  ///通用全局单例，第一次使用时初始化
  DraftUtil._internal();

  ///根据传入的草稿文件类型，返回对应的文件夹名称
  static String getDraftTypeFolderName(DraftFileType type) {
    switch (type) {
      case DraftFileType.VIDEO:
        return 'video';
      case DraftFileType.AUDIO:
        return 'audio';
      case DraftFileType.IMAGE:
        return 'image';
    }
  }
}

///定义一个DART枚举类型，表示草稿文件的三种类型，分别为视频、音频、图片
enum DraftFileType { VIDEO, AUDIO, IMAGE }
