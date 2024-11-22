import 'package:flutter/material.dart';

import 'desk_ui/desk_gallery_unit.dart';

/// blueming.wu
/// 工具箱

class GalleryToolsUnit extends StatelessWidget {
  const GalleryToolsUnit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      return const DeskToolsGalleryUnit();
    });
  }
}
