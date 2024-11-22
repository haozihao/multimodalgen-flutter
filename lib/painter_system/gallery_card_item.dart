import 'package:flutter/material.dart';
import 'package:pieces_ai/app/utils/convert.dart';

import '../app/navigation/mobile/theme/theme.dart';
import 'gallery_factory.dart';

/// create by blueming.wu on 2024/4/14

class GalleryCardItem extends StatelessWidget {
  final GalleryInfo galleryInfo;
  final int count;

  //点击回调
  final VoidCallback? onTap;

  const GalleryCardItem({
    Key? key,
    required this.galleryInfo,
    this.count = 0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      // alignment: Alignment.center,
      child: InkWell(
        onTap: () => onTap?.call(),
        child: Stack(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Container(
                      width: 70,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.contain,
                            image: AssetImage(galleryInfo.image)),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 15, right: 15, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        galleryInfo.name,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                  color: Theme.of(context).primaryColor,
                                  offset: const Offset(.2, .2),
                                  blurRadius: .5)
                            ]),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        galleryInfo.info,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            shadows: [
                              Shadow(
                                  color: Theme.of(context).primaryColor,
                                  offset: const Offset(.2, .2),
                                  blurRadius: .5)
                            ]),
                      )
                    ],
                  ),
                ),
              ],
            ),
            if (galleryInfo.vip == 0)
              Positioned(
                top: 0,
                right: 0,
                child: Transform.rotate(
                  angle: 0.785398, // 45 degrees in radians
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    color: Colors.red,
                    child: Text(
                      '免费',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      decoration: BoxDecoration(
          color: AppColor.piecesBackTwo,
          // border: Border.all(color: Color(0xFFA6A6A6)),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          )),
    );
  }
}

class GalleryInfo {
  final int count;
  final int vip;
  final String name;
  final String info;
  final String image;
  final String router;

  GalleryType get type {
    GalleryType galleryType = GalleryType.ai_generate;
    Convert.galleryTypeMap.forEach((key, value) {
      if (value == name) {
        galleryType = key;
      }
    });
    return galleryType;
  }

  const GalleryInfo(
      {this.count = 0,
      this.vip = 0,
      required this.name,
      required this.info,
      required this.image,
      required this.router});

  factory GalleryInfo.fromJson(Map<String, dynamic> map) {
    return GalleryInfo(
        vip: map['vip'] ?? 0,
        count: map['count'] ?? 0,
        name: map["name"] ?? "",
        image: map["image"] ?? "assets/images/draw_bg4.webp",
        router: map["router"] ?? "",
        info: map["info"] ?? "");
  }
}
