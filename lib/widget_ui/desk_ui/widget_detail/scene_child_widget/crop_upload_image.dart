import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:utils/utils.dart';

import '../../../../components/custom_widget/ProImageEditorZh.dart';

///上传和切割本地文件
class CropUploadImagePanel extends StatefulWidget {
  final String selectImgPath;
  final String taskSavePath;

  ///如果有传入，则表示保存图片用这个作为命名的最后部分累加，如果为空则随机生成8位字符串保存
  final String? baseSaveName;
  final double ratio;
  final Function(String) onCropped;

  CropUploadImagePanel({
    Key? key,
    required this.selectImgPath,
    required this.onCropped,
    required this.taskSavePath,
    required this.ratio,
    this.baseSaveName,
  }) : super(key: key);

  @override
  State<CropUploadImagePanel> createState() => _CropUploadImagePanelState();
}

class _CropUploadImagePanelState extends State<CropUploadImagePanel> {
  final _controller = CropController();
  late Future<Uint8List?> _futureImg;
  late String baseSaveName;
  late String saveFolderPath;

  @override
  void initState() {
    //图片存入upload文件夹，但是文件名一样，加一个随机字符串的前缀
    saveFolderPath = widget.taskSavePath;
    baseSaveName = widget.baseSaveName ?? "";
    debugPrint(
        "传入的保存目录:" + widget.taskSavePath + " baseSaveName:" + baseSaveName);
    _futureImg = FileUtil.readFileAsBytes(widget.selectImgPath);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("裁剪图片"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: Padding(
            padding: EdgeInsets.all(10),
            child: FutureBuilder(
                future: _futureImg,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      child: const CircularProgressIndicator(),
                      width: 20,
                      height: 20,
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    // return ProImageEditorZh(
                    //   imagePath: widget.selectImgPath,
                    //   callback: ProImageEditorCallbacks(
                    //       onImageEditingComplete: (Uint8List croppedData) async {
                    //         String newPath = saveFolderPath +
                    //             FileUtil.getFileSeparate() +
                    //             FileUtil.generateRandomString(8) +
                    //             baseSaveName +
                    //             ".jpg"; //覆盖原图片，因为需要根据图片名字来计算offset
                    //         String savePath = await saveImage(croppedData, newPath);
                    //         if (savePath.isNotEmpty) {
                    //           debugPrint("切割成功:" + savePath);
                    //           Navigator.of(context).pop();
                    //           widget.onCropped.call(savePath);
                    //         }
                    //       }),
                    // );
                    return Crop(
                        image: snapshot.data!,
                        controller: _controller,
                        aspectRatio: widget.ratio,
                        willUpdateScale: (newScale) => newScale < 5,
                        // withCircleUi: true,
                        interactive: true,
                        // fixCropRect: true,
                        // radius: 20,
                        // initialRectBuilder: (viewportRect, imageRect) {
                        //   return Rect.fromLTRB(
                        //     viewportRect.left + 24,
                        //     viewportRect.top + 24,
                        //     viewportRect.right - 24,
                        //     viewportRect.bottom - 24,
                        //   );
                        // },
                        // initialSize: 0.5,
                        // initialArea: Rect.fromLTWH(240, 212, 800, 600),
                        onCropped: (croppedData) async {
                          String newPath = saveFolderPath +
                              FileUtil.getFileSeparate() +
                              FileUtil.generateRandomString(8) +
                              baseSaveName +
                              ".jpg"; //覆盖原图片，因为需要根据图片名字来计算offset
                          String savePath =
                              await saveImage(croppedData, newPath);
                          if (savePath.isNotEmpty) {
                            debugPrint("切割成功:" + savePath);
                            Navigator.of(context).pop();
                            widget.onCropped.call(savePath);
                          }
                        });
                  }
                }),
          )),
          SizedBox(
            height: 15,
          ),
          SizedBox(
            child: ElevatedButton(
                onPressed: () {
                  _controller.crop();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // 设置圆角半径
                  ),
                  backgroundColor: Color(0xFF12CDD9),
                ),
                child: Text(
                  "确定",
                  style: TextStyle(color: Colors.white),
                )),
            width: 100,
            height: 35,
          ),
          SizedBox(
            height: 15,
          )
        ],
      ),
    );
  }

  Future<String> saveImage(Uint8List imageBytes, String filePath,
      {int quality = 80}) async {
    // 使用 Image 包解码图片数据
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return "";
    // 将图片编码为 JPG 格式的字节数据，并设置压缩质量
    List<int> jpgBytes = img.encodeJpg(image, quality: quality);

    // 创建文件对象
    File file = File(filePath);
    try {
      // 检查文件是否存在，如果存在则删除
      if (await file.exists()) {
        await file.delete();
      }
      // 将字节数据写入文件
      await file.writeAsBytes(jpgBytes);
      return filePath;
    } catch (e) {
      // 处理写入文件时的异常
      print('Error saving image: $e');
      return "";
    }
  }
}
