import 'dart:convert';
import 'dart:typed_data';

import 'package:app/app.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:logger/logger.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';
import 'package:pieces_ai/app/navigation/mobile/theme/theme.dart';
import 'package:pieces_ai/components/custom_widget/ProImageEditorZh.dart';
import 'package:pieces_ai/painter_system/gallery_card_item.dart';
import 'package:pieces_ai/painter_system/gallery_factory.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/image_general_widget/image_general_panel.dart';
import 'package:pro_image_editor/models/editor_callbacks/pro_image_editor_callbacks.dart';
import 'package:utils/utils.dart';

import '../../app/model/ai_image2_video.dart';
import '../../widget_ui/desk_ui/category_panel/video/video_general_widget.dart';

/// create by blueming.wu
/// 工具箱 GALLERY
var logger = Logger(printer: PrettyPrinter(methodCount: 0));

class DeskToolsGalleryUnit extends StatefulWidget {
  const DeskToolsGalleryUnit({Key? key}) : super(key: key);

  @override
  _DeskGalleryUnitState createState() => _DeskGalleryUnitState();
}

class _DeskGalleryUnitState extends State<DeskToolsGalleryUnit> {
  final ValueNotifier<double> factor = ValueNotifier<double>(0);

  @override
  void dispose() {
    factor.dispose();
    super.dispose();
  }

  final ScrollController controller = ScrollController();

  Color get color => Colors.blue;

  Color get nextColor => Colors.orangeAccent;

  BoxDecoration get boxDecoration => const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.piecesBlackGrey,
      appBar: AppBar(
        backgroundColor: AppColor.piecesBlackGrey,
        title: const Text('工具箱'),
      ),
      body: _buildContent(),
    );
  }

  ///打开图像编辑器页面
  void _openEditor(String imagePath) async {
    //从本地选一张图片
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProImageEditorZh(
          imagePath: imagePath,
          callback: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {
            logger.d("图片编辑完成");
            ImagePickers.saveByteDataImageToGallery(bytes);
            Toast.success(context, "图片已保存到相册");
            Navigator.pop(context);
          }),
        ),
      ),
    );
    // Navigator.push(
    //     context,
    //     SlidePageRoute(
    //         child: ImageEditor(
    //       onSave: (path) {},
    //       imagePathOrUrl: imagePath,
    //       imageType: ImageType.file,
    //     )));
  }

  ///从本地选择图片
  _selectLocalImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      // allowedExtensions: ['jpg', 'png', 'webp', 'jpeg'],
    );
    if (result != null) {
      PlatformFile file = result.files.single;
      if (file.path?.isNotEmpty == true) {
        _openEditor(file.path!);
      }
    }
  }

  Widget _buildContent() {
    final List<Widget> widgets =
        (json.decode(StrUnit.galleryInfo) as List).map((e) {
      GalleryInfo info = GalleryInfo.fromJson(e);

      return GalleryCardItem(
        onTap: () {
          if (GalleryType.ai_generate == info.type) {
            Navigator.of(context).push(SlidePageRoute(
                child: Scaffold(
              appBar: AppBar(
                title: Text(info.name),
              ),
              body: ImgGeneralPanel(
                  isFromTool: true,
                  imageUrl: "",
                  urls: [],
                  onImageSelected:
                      (String url, String videoUrl, int mediaType) {},
                  localMode: false,
                  draftName: "",
                  aiPaintParamsV2: AiPaintParamsV2(
                      batchSize: 1,
                      cfgScale: 0.7,
                      detection: true,
                      hd: Hd(),
                      height: 450,
                      modelClass: 1,
                      id: 90,
                      prompt: "",
                      ratio: 1,
                      seed: -1,
                      steps: 20,
                      styleName: "唯美国风",
                      width: 600),
                  inputTags: []),
            )));
          } else if (GalleryType.image_edit == info.type) {
            _selectLocalImage();
          } else if (GalleryType.video_edit == info.type) {

          } else if (GalleryType.ai_expression == info.type) {
            Navigator.of(context).push(SlidePageRoute(
                child: VideoGeneralPanel(
              key: videoGeneralPanelKey,
              imageUrl: "",
              videoUrl: "",
              urls: [],
              onImageSelected: (String url, String videoUrl, int mediaType) {},
              localMode: false,
              draftName: "",
              aiPaintParamsV2: AiPaintParamsV2(
                  batchSize: 1,
                  cfgScale: 0.7,
                  detection: true,
                  hd: Hd(),
                  height: 450,
                  modelClass: 1,
                  id: 90,
                  prompt: "",
                  ratio: 1,
                  seed: -1,
                  steps: 20,
                  styleName: "唯美国风",
                  width: 600),
              videoUrls: [],
              motionStrength: 50, image2videoParam: Image2VideoParam(image: '', prompt: ''),
            )));
          } else {
            MotionToast.warning(description: Text("还未实现的功能！")).show(context);
          }
        },
        galleryInfo: info,
        count: 2,
      );
    }).toList();

    SliverGridDelegate gridDelegate =
        const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 400,
      mainAxisSpacing: 10,
      mainAxisExtent: 150,
      crossAxisSpacing: 15,
    );

    return GridView.builder(
        controller: controller,
        gridDelegate: gridDelegate,
        padding: const EdgeInsets.all(20),
        itemCount: widgets.length,
        itemBuilder: (ctx, index) => widgets[index]);
  }
}
