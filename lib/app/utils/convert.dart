import 'package:pieces_ai/painter_system/gallery_factory.dart';
import 'package:widget_repository/widget_repository.dart';

class Convert {
  static WidgetFamily toFamily(int id) {
    switch (id) {
      case 0:
        return WidgetFamily.statelessWidget;
      case 1:
        return WidgetFamily.statefulWidget;
      case 2:
        return WidgetFamily.singleChildRenderObjectWidget;
      case 3:
        return WidgetFamily.multiChildRenderObjectWidget;
      case 4:
        return WidgetFamily.sliver;
      case 5:
        return WidgetFamily.proxyWidget;
      case 6:
        return WidgetFamily.other;
      default:
        return WidgetFamily.statelessWidget;
    }
  }

  static Map<GalleryType, String> galleryTypeMap = {
    GalleryType.image_edit: "简易海报制作",
    GalleryType.ai_generate: "Ai生成",
    GalleryType.video_edit: "免费视频剪辑",
    GalleryType.ai_expression: "Ai表情包",
  };

  static String convertFileSize(int size) {
    double result = size / 1024.0;
    if (result < 1024) {
      return "${result.toStringAsFixed(2)} Kb";
    } else if (result > 1024 && result < 1024 * 1024) {
      return "${(result / 1024).toStringAsFixed(2)} Mb";
    } else {
      return "${(result / 1024 / 1024).toStringAsFixed(2)} Gb";
    }
  }
}
