import 'package:flutter/material.dart';
import 'package:pieces_ai/app/api_https/ai_story_repository.dart';
import 'package:pieces_ai/app/api_https/impl/https_ai_config_repository.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';
import 'package:pieces_ai/app/model/config/ai_prompt_words.dart';

import '../../../app/navigation/mobile/theme/theme.dart';

/// create by bluemingwu
/// 添加关键词

class EditPromptWordsPanel extends StatefulWidget {
  final int index;
  final String? hint;
  final int? promptType;
  final List<UserTag>? initPrompts;
  final AiStoryRepository httpAiStoryRepository;
  final Function(UserTag inputTag)? onEditCallback;
  final Function(Map<int, FluffyChild>)? onUserTagModify;

  const EditPromptWordsPanel({
    Key? key,
    this.onEditCallback,
    required this.index,
    this.hint,
    this.initPrompts,
    this.promptType,
    required this.httpAiStoryRepository,
    this.onUserTagModify,
  }) : super(key: key);

  @override
  _EditCategoryPanelState createState() => _EditCategoryPanelState();
}

class _EditCategoryPanelState extends State<EditPromptWordsPanel>
    with SingleTickerProviderStateMixin {
  bool modify = false;
  late TabController _tabController;
  late Map<int, FluffyChild> userTagList = {};
  late Map<int, VoidCallback> cancelCallBacks = {};

  // final FocusNode _focusNode = FocusNode();
  bool _showClearButton = false;
  late Future<List<PromptWord>> _futureAllTypePrompts;
  int initUserInputTagId = -9999;

  @override
  void initState() {
    // _textEditingController.addListener(() {
    //   setState(() {
    //     _showClearButton = _textEditingController.text.isNotEmpty;
    //   });
    // });
    int idUser = -998;
    widget.initPrompts?.forEach((tag) {
      FluffyChild initTag = FluffyChild(
          classNum: -1,
          enName: tag.tagEn,
          id: idUser,
          name: tag.tagZh ?? "",
          parentId: 0,
          type: 3);
      userTagList[idUser] = initTag;
      idUser--;
    });
    widget.onUserTagModify?.call(userTagList);

    // 焦点设置在文本框上
    // _focusNode.requestFocus();
    print("类别:" + widget.promptType.toString());
    _tabController = TabController(
        length: widget.promptType == 1 ? 4 : 5,
        vsync: this,
        animationDuration: Duration.zero);
    _futureAllTypePrompts = HttpAiConfigRepository().loadAiPromptsWords();
    super.initState();
  }

  @override
  void dispose() {
    // _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: FutureBuilder<List<PromptWord>>(
          future: _futureAllTypePrompts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Async operation is still in progress
              return Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              // Error handling
              return Text('Error: ${snapshot.error}');
            } else {
              return _buildPromptTypeItem(snapshot.data ?? []);
            }
          },
        )),
        if (widget.onEditCallback != null)
          SizedBox(
            child: ElevatedButton(
              onPressed: () {
                if (userTagList.isNotEmpty) {
                  List<UserTag> saveTagList = [];
                  for (FluffyChild fluffyChild in userTagList.values) {
                    saveTagList.add(UserTag(
                        tagEn: fluffyChild.enName, tagZh: fluffyChild.name));
                  }
                  // widget.onEditCallback
                  //     ?.call(widget.index, saveTagList, modify);
                }
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFF12CDD9)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // 设置圆角
                  ),
                ),
              ),
              child: Text(
                "保存并退出",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          )
      ],
    );
  }

  _buildPromptTypeItem(List<PromptWord> promptTypeList) {
    List<DatumChild> promptChild = [];
    for (var element in promptTypeList) {
      debugPrint("promptType:${element.type}");
      if (widget.promptType != null) {
        if (widget.promptType == element.type) {
          promptChild.addAll(element.children);
          break;
        }
      } else {
        if (element.type == 3 || element.type == 5) {
          promptChild.addAll(element.children);
        }
      }
    }
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          // padding: EdgeInsets.only(left: 10, right: 10),
          labelPadding: EdgeInsets.only(left: 10, right: 10),
          indicatorColor: AppColor.piecesBlue,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 2,
          labelColor: AppColor.piecesBlue,
          unselectedLabelColor: AppColor.lightGrey,
          tabs:
              promptChild.reversed.map((child) => _buildTopTag(child)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: promptChild.reversed
                .map((child) => _buildPromptContent(child.children))
                .toList(),
          ),
        ),
      ],
    );
  }

  //顶部标签
  Widget _buildTopTag(DatumChild datumChild) {
    return Tab(
        child: Text(
      datumChild.name,
      style: TextStyle(fontSize: 15),
    ));
  }

  //每个页面的prompt内容
  Widget _buildPromptContent(List<PurpleChild> purpleChildList) {
    //还有多个子分类
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: purpleChildList.reversed
            .map((e) => _buildPromptContentItem(e))
            .toList(),
      ),
    );
  }

  //单个最底层的子分类prompt
  Widget _buildPromptContentItem(PurpleChild purpleChild) {
    //将最终子分类转化成UserTag数据
    //还有多个子分类
    return PromptContentItem(
      purpleChild: purpleChild,
      onSelected: (index, select) {
        //点击左边的tag
        if (select) {
          setState(() {
            userTagList[purpleChild.id] = purpleChild.children[index];
          });
          widget.onEditCallback?.call(UserTag(
              tagEn: purpleChild.children[index].enName,
              tagZh: purpleChild.children[index].name));
        } else {
          setState(() {
            userTagList.remove(purpleChild.id);
          });
        }
        widget.onUserTagModify?.call(userTagList);
      },
    );
  }
}

///最终使用的最后两级的提示词分类，因为需要单选，所以单独提取出来
class PromptContentItem extends StatefulWidget {
  final PurpleChild purpleChild;
  final Function(int, bool) onSelected;

  const PromptContentItem(
      {required this.purpleChild,
      required this.onSelected,});

  @override
  _PromptContentItemState createState() => _PromptContentItemState();
}

class _PromptContentItemState extends State<PromptContentItem> {
  int selectPromptIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5,left: 10,right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.purpleChild.name + "：",
              style: TextStyle(fontSize: 12, color: Colors.white)),
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Wrap(
              spacing: 2, // 水平间距
              // runSpacing: 2, // 垂直间距
              // alignment: WrapAlignment.start,
              children: List.generate(
                widget.purpleChild.children.length,
                (index) => _buildChoiceChip(widget.purpleChild.children[index],
                    index, widget.onSelected),
              ),
            ),
          )
        ],
      ),
    );
  }

  //单个标签
  _buildChoiceChip(
      FluffyChild fluffyChild, int index, Function(int, bool) onSelect) {
    bool select = selectPromptIndex == index;
    return ChoiceChip(
      // labelPadding: EdgeInsets.only(left: 5, right: 5),
      // padding: EdgeInsets.zero,
      label: Text(
        fluffyChild.name,
        style: TextStyle(
            color: select ? AppColor.piecesBlue : Color(0xFFA6A6A6),
            fontSize: 9),
      ),
      selectedColor: Colors.transparent,
      surfaceTintColor: Colors.white,
      selected: select,
      onSelected: (select) {
        if (select)
          selectPromptIndex = index;
        else
          selectPromptIndex = -1;
        onSelect.call(index, select);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), // 调整圆角大小
        side: BorderSide(
            color: select ? AppColor.piecesBlue : Color(0xFFA6A6A6)), // 添加边框并指定颜色
      ),
    );
  }
}
