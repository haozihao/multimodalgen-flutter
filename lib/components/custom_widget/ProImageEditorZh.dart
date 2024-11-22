import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class ProImageEditorZh extends StatelessWidget {
  final String imagePath;
  final ProImageEditorCallbacks callback;

  const ProImageEditorZh(
      {super.key, required this.imagePath, required this.callback});

  @override
  Widget build(BuildContext context) {
    return _buildEditor(context);
  }

  Widget _buildEditor(BuildContext context) {
    return ProImageEditor.file(
      File(imagePath),
      callbacks: callback,
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        blurEditorConfigs: const BlurEditorConfigs(enabled: false),
        cropRotateEditorConfigs:
            const CropRotateEditorConfigs(initAspectRatio: 2),
        i18n: const I18n(
          various: I18nVarious(
              closeEditorWarningTitle: "关闭警告！",
              closeEditorWarningMessage: "你确定要关闭吗？关闭后所有图片效果将丢失！",
              closeEditorWarningConfirmBtn: "确定",
              closeEditorWarningCancelBtn: "取消",
              loadingDialogMsg: "请稍等..."),
          paintEditor: I18nPaintingEditor(bottomNavigationBarText: "画笔"),
          textEditor: I18nTextEditor(bottomNavigationBarText: "文字"),
          cropRotateEditor:
              I18nCropRotateEditor(bottomNavigationBarText: "裁剪/旋转"),
          blurEditor: I18nBlurEditor(bottomNavigationBarText: "模糊"),
          filterEditor: I18nFilterEditor(
              filters: I18nFilters(),
              bottomNavigationBarText: "滤镜",
              back: "返回",
              done: "完成"),
          emojiEditor: I18nEmojiEditor(bottomNavigationBarText: "表情"),
          stickerEditor: I18nStickerEditor(bottomNavigationBarText: "贴纸"),
          // More translations...
        ),
        layerInteraction: LayerInteraction(initialSelected: true),
        textEditorConfigs: TextEditorConfigs(
            showSelectFontStyleBottomBar: true,
            customTextStyles: [
              TextStyle(fontFamily: "HanYiDaHei"),
              TextStyle(fontFamily: "Neucha")
            ]),
        stickerEditorConfigs: StickerEditorConfigs(
          enabled: true,
          initWidth: 200,
          buildStickers: (setLayer, scrollController) {
            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 80,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                controller: scrollController,
                itemCount: 5,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Widget widget = ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.network(
                      'https://picsum.photos/id/${(index + 3) * 3}/2000',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  );
                  return GestureDetector(
                    onTap: () => setLayer(widget),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Sticker(index: index),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class Sticker extends StatefulWidget {
  final int index;

  const Sticker({
    super.key,
    required this.index,
  });

  @override
  State<Sticker> createState() => StickerState();
}

class StickerState extends State<Sticker> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: Image.network(
        "https://imgs.pencil-stub.com/data/cms/prop/2024-07-13/ce6d2f500d8f4c18a36d4d55efef3cc8.png",
        width: 450,
        height: 600,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          return AnimatedSwitcher(
            layoutBuilder: (currentChild, previousChildren) {
              return SizedBox(
                width: 450,
                height: 600,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                ),
              );
            },
            duration: const Duration(milliseconds: 200),
            child: loadingProgress == null
                ? child
                : Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
