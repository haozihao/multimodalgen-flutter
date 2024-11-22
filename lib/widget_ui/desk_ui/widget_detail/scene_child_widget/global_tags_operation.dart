import 'package:flutter/material.dart';
import 'package:pieces_ai/widget_ui/desk_ui/widget_detail/scene_child_widget/ReplaceText.dart';

import '../../../../app/api_https/ai_story_repository.dart';
import '../../../../app/model/TweetScript.dart';
import '../edit_prompt_words_panel.dart';

///全局提示词操作页面
class GlobalTagsOperation extends StatefulWidget {
  final AiStoryRepository httpAiStoryRepository;
  final Function(UserTag)? onEditCallback;
  final Function(String targetText, String originalText) onReplace;

  GlobalTagsOperation({
    Key? key,
    required this.httpAiStoryRepository,
    this.onEditCallback,
    required this.onReplace,
  }) : super(key: key);

  @override
  State<GlobalTagsOperation> createState() => _GlobalTagsOperationState();
}

class _GlobalTagsOperationState extends State<GlobalTagsOperation>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int currentSelect = 0;
  final List<String> titles = ["添加关键词", "替换关键词"];

  @override
  void initState() {
    _tabController =
        TabController(length: 2, vsync: this, animationDuration: Duration.zero);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        SizedBox(
          child: TabBar(
            controller: _tabController,
            indicatorWeight: 3,
            onTap: (index) {
              debugPrint("选中动画类型...$index");
              setState(() {
                currentSelect = index;
              });
            },
            tabs: titles
                .map((e) => Tab(
                        child: Text(
                      e,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    )))
                .toList(),
          ),
          width: 400,
        ),
        SizedBox(
          height: 8,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              Padding(
                child: EditPromptWordsPanel(
                  initPrompts: [],
                  index: -1,
                  onEditCallback: widget.onEditCallback,
                  httpAiStoryRepository: widget.httpAiStoryRepository,
                ),
                padding: EdgeInsets.only(left: 25),
              ),
              _replaceTag(),
            ],
          ),
        ),
      ],
    );
  }

  ///文字替换组件
  Widget _replaceTag() {
    return ReplaceText(
      onReplace: (String targetText, String originalText) {
        widget.onReplace.call(targetText, originalText);
      },
    );
  }
}
