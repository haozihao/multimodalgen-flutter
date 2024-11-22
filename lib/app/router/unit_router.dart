// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:app/app.dart';
import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:pieces_ai/app/model/ai_draft.dart';
import 'package:pieces_ai/app/model/videos/recom_video.dart';
import 'package:pieces_ai/app/navigation/unit_navigation.dart';
import 'package:pieces_ai/app/views/about/version_info.dart';
import 'package:pieces_ai/app/views/detail/recom_video_detail.dart';
import 'package:pieces_ai/app/views/export/export_video.dart';
import 'package:pieces_ai/app/views/setting/setting_page.dart';
import 'package:pieces_ai/widget_ui/mobile/category_page/ai_style_voice_edit.dart';
import 'package:pieces_ai/widget_ui/mobile/widget_detail/article_detail_page.dart';
import 'package:storage/storage.dart';

import '../../widget_ui/desk_ui/widget_detail/ai_scenes_edit.dart';

class UnitRouters {
  static const String widget_scene_edit = '/widget_scene_edit';
  static const String text_2_video = '/text_2_video';

  static const String detail = 'detail';

  // static const String search = 'search_bloc';

  static const String collect = 'CollectPage';
  static const String setting = 'SettingPage';
  static const String font_setting = 'FountSettingPage';
  static const String theme_color_setting = 'ThemeColorSettingPage';
  static const String code_style_setting = 'CodeStyleSettingPage';
  static const String item_style_setting = 'ItemStyleSettingPage';
  static const String version_info = 'VersionInfo';
  static const String login = 'login';

  static const String ai_style_edit = 'ai_style_edit';
  static const String about_me = 'AboutMePage';
  static const String about_app = 'AboutAppPage';
  static const String register = 'register';

  //跳转到ArticleDetailPage，内置webview
  static const String article_detail = 'article_detail';

  //视频导出页面
  static const String video_export = 'video_export';

  //视频播放详情页
  static const String video_detail = 'video_detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      //
      case UnitRouter.nav:
        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          return ZeroPageRoute(child: UnitNavigation());
        }
        return ZeroPageRoute(child: UnitNavigation());

      // 分句编辑页面
      case widget_scene_edit:
        Widget child;
        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          child = SliverListSceneEdit(
            draft: settings.arguments as DraftRender,
          );
        } else {
          child = SliverListSceneEdit(
            draft: settings.arguments as DraftRender,
          );
        }

        return ZeroPageRoute(child: child);

      case article_detail:
        return SlidePageRoute(
            child: ArticleDetailPage(url: settings.arguments as String));
      case setting:
        return SlidePageRoute(child: const SettingPage());
      // return Right2LeftRouter(builder:(_)=> const SettingPage());
      // return MaterialPageRoute(builder:(_)=> const SettingPage());

      case version_info:
        return ZeroPageRoute(child: const VersionInfo());


      case video_export:
        return SlidePageRoute(
            child: ExportVideo(
          draft: settings.arguments as Draft,
        ));

      ///Ai短剧任务风格选择页面
      case ai_style_edit:
        return SlidePageRoute(
            child: AiStyleEdit(
          draftRender: settings.arguments as DraftRender,
        ));

      case video_detail:
        return SlidePageRoute(
            child: VideoDetail(
          recomVideo: settings.arguments as RecomVideo,
        ));

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ));
    }
  }
}
