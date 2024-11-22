import 'package:cached_network_image/cached_network_image.dart';
import 'package:components/toly_ui/ti/circle.dart';
import 'package:flutter/material.dart';
import 'package:pieces_ai/app/model/ai_style_model.dart';
import 'package:pieces_ai/app/navigation/mobile/theme/theme.dart';

/// create by blueming.wu
/// Ai推文风格专用的gridView
//    {
//      "widgetId": 163,
//      "name": 'GridView.count构造',
//      "priority": 1,
//      "subtitle":
//          "【children】 : 子组件列表   【List<Widget>】\n"
//          "【crossAxisCount】 : 主轴一行box数量  【int】\n"
//          "【mainAxisSpacing】 : 主轴每行间距  【double】\n"
//          "【crossAxisSpacing】 : 交叉轴每行间距  【double】\n"
//          "【childAspectRatio】 : box主长/交叉轴长  【double】\n"
//          "【crossAxisCount】 : 主轴一行数量  【int】",
//    }
class StyleGridView extends StatefulWidget {
  const StyleGridView(
      {Key? key,
      required this.aiStyleModels,
      required this.aiStyleModelChanged,
      required this.selectStyleId,
      required this.countPerLine})
      : super(key: key);

  final List<AiStyleModel> aiStyleModels;
  final int selectStyleId;
  final int countPerLine;
  final Function(Child) aiStyleModelChanged;

  @override
  _StyleGridViewState createState() => _StyleGridViewState();
}

class _StyleGridViewState extends State<StyleGridView>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0; //默认选中第一个风格
  int selectedCategoryIndex = 0; //大类别默认选中第一个
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    //看是否选中
    for (int j = 0; j < widget.aiStyleModels.length; j++) {
      var aiStyleModel = widget.aiStyleModels[j];
      for (int i = 0; i < aiStyleModel.children.length; i++) {
        if (widget.selectStyleId == aiStyleModel.children[i].id) {
          selectedIndex = i;
          selectedCategoryIndex = j;
          break;
        }
      }
    }
    // widget.aiStyleModelChanged(
    //     widget.aiStyleModels[selectedCategoryIndex].children[selectedIndex]);
    _tabController =
        TabController(length: widget.aiStyleModels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose(); // 释放控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for (var element in widget.aiStyleModels) {
      widgets.add(_buildGridView(element));
    }
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (widget.countPerLine < 10)
          Row(
            children: [
              Circle(
                color: Color(0xFF12CDD9),
                radius: 5,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  "画面风格",
                  style: TextStyle(fontSize: 14),
                ),
              )
            ],
          ),
        const SizedBox(height: 5),
        _buildButtonListView(widget.aiStyleModels),
        const SizedBox(height: 5),
        Expanded(
            child: TabBarView(
          controller: _tabController,
          children: widgets,
        )),
      ],
    );
  }

  //风格大类别
  Widget _buildButtonListView(List<AiStyleModel> aiStyleModels) {
    //使用TabBar实现
    return SizedBox(
      height: 25,
      child: DefaultTabController(
        length: aiStyleModels.length,
        child: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelPadding: EdgeInsets.symmetric(horizontal: 5.0),
          // 设置Tab之间的间隔
          indicatorWeight: 2,
          tabs: List.generate(
            aiStyleModels.length,
            (index) => Tab(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    aiStyleModels[index].name,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )),
            ),
          ),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0), // 设置圆角边框
            border: Border.all(
              color: AppColor.piecesBlue, // 设置边框颜色
              width: 1.0, // 设置边框宽度
            ),
          ),
          controller: _tabController,
          onTap: (index) {
            setState(() {
              selectedCategoryIndex = index;
              selectedIndex = 0;
              widget.aiStyleModelChanged(widget
                  .aiStyleModels[selectedCategoryIndex]
                  .children[selectedIndex]);
            });
          },
        ),
      ),
    );
  }

  Widget _buildGridView(AiStyleModel aiStyleModel) => GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.countPerLine,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: 3 / 4,
        ),
        itemCount: aiStyleModel.children.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return _buildItem(
            aiStyleModel.children[index].name,
            aiStyleModel.children[index].icon,
            index,
            aiStyleModel,
          );
        },
      );

  Container _buildItem(
      String title, String imageUrl, int index, AiStyleModel aiStyleModel) {
    var aiStyleModelChild = aiStyleModel.children[index];
    return Container(
      height: 68,
      width: 68,
      alignment: Alignment.center,
      child: Padding(
        child: GestureDetector(
          onTap: () {
            widget.aiStyleModelChanged(aiStyleModelChild);
            setState(() {
              selectedIndex = index;
            });
          },
          child: Column(
            children: [
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: selectedIndex == index
                          ? Color(0xFF12CDD9)
                          : Colors.transparent,
                      width: 2, // 设置边框宽度
                    ),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                flex: 4,
              ),
              const SizedBox(height: 5),
              Text(
                title,
                maxLines: 1,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
        padding: const EdgeInsets.only(left: 2, top: 2, right: 2),
      ),
    );
  }
}
