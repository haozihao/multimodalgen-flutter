import 'package:flutter/material.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';
import 'package:pieces_ai/components/custom_widget/GifControlWidget.dart';

///剪映出入场动画选择
class JyAnimePanel extends StatefulWidget {
  final Function(Anime) onSave;
  final Anime? anime;

  JyAnimePanel({
    Key? key,
    required this.onSave,
    this.anime,
  }) : super(key: key);

  @override
  State<JyAnimePanel> createState() => _JyAnimePanelState();
}

class _JyAnimePanelState extends State<JyAnimePanel>
    with SingleTickerProviderStateMixin {
  int selectAnimeInIndex = 0;
  int selectAnimeOutIndex = 0;
  int currentSelect = 0;

  final List<String> titles = ["入场动画", "出场动画"];
  final List<String> animeInList = ["无", "渐显", "动感放大", "动感缩小", "向下甩入", "向右甩入"];
  final List<String> animeOutList = ["无", "渐隐"];
  final List<String> icons = [
    "",
    "https://imgs.pencil-stub.com/data/cms/2024-06-03/b307663e1ed74f2891309752082a38fe.gif",
    "https://imgs.pencil-stub.com/data/cms/2024-06-03/8c2a4e8b18ac4346b58724f909c5f8fc.gif",
    "https://imgs.pencil-stub.com/data/cms/2024-06-03/f77dff9d7a66406998379f7c26d8f33b.gif",
    "https://imgs.pencil-stub.com/data/cms/2024-06-03/659153ce7a07487d9f67deda4f324a55.gif",
    "https://imgs.pencil-stub.com/data/cms/2024-06-03/c4f6942a8e3c4cb79c2c8162a9a1b9f4.gif"
  ];
  final List<String> iconsOut = [
    "",
    "https://imgs.pencil-stub.com/data/cms/2024-06-05/50d3b2343b174a5d838aadc3ddfc11f3.gif",
  ];
  late final TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    for (int i = 0; i < animeInList.length; i++) {
      if (widget.anime?.animeIn == animeInList[i]) selectAnimeInIndex = i;
    }
    for (int i = 0; i < animeOutList.length; i++) {
      if (widget.anime?.animeOut == animeOutList[i]) selectAnimeOutIndex = i;
    }
    _tabController =
        TabController(length: 2, vsync: this, animationDuration: Duration.zero);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildGeneralTabBar();
  }

  ///4种生图模式
  Widget _buildGeneralTabBar() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          "动画设置",
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10,
        ),
        TabBar(
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
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  )))
              .toList(),
        ),
        SizedBox(
          height: 8,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              _buildAnimInPanel(),
              _buildAnimOutPanel(),
            ],
          ),
        ),
      ],
    );
  }

  SliverGridDelegate gridDelegate =
      const SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 120,
    mainAxisExtent: 140,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10, //横向的间隔
  );

  ///出场动画选择
  _buildAnimOutPanel() {
    return GridView.builder(
        // scrollDirection: Axis.horizontal,
        itemCount: animeOutList.length,
        gridDelegate: gridDelegate,
        itemBuilder: (_, int index) => animeOutList[index] == "无"
            ? _buildNoneItem(0)
            : _buildAnimSelectItem(index,animeOutList[index],iconsOut[index]));
  }

  ///入场动画选择
  _buildAnimInPanel() {
    return GridView.builder(
        // scrollDirection: Axis.horizontal,
        itemCount: animeInList.length,
        gridDelegate: gridDelegate,
        itemBuilder: (_, int index) => animeInList[index] == "无"
            ? _buildNoneItem(0)
            : _buildAnimSelectItem(index,animeInList[index],icons[index]));
  }

  ///选择无的item
  _buildNoneItem(int index) {
    return GestureDetector(
      onTap: () {
        if (currentSelect == 0) {
          setState(() {
            selectAnimeInIndex = index;
          });
        } else {
          setState(() {
            selectAnimeOutIndex = index;
          });
        }
        var anime = Anime(
            animeIn: animeInList[selectAnimeInIndex],
            animeOut: animeOutList[selectAnimeOutIndex]);
        widget.onSave.call(anime);
      },
      child: Column(
        children: [
          Flexible(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: currentSelect == 0
                        ? selectAnimeInIndex == index
                            ? Color(0xFF12CDD9)
                            : Colors.transparent
                        : selectAnimeOutIndex == index
                            ? Color(0xFF12CDD9)
                            : Colors.transparent,
                    width: 2, // 设置边框宽度
                  ),
                  // image: DecorationImage(
                  //   image: CachedNetworkImageProvider(icons[index]),
                  //   fit: BoxFit.fitWidth,
                  // ),
                ),
                child: const Icon(
                  Icons.not_interested,
                  size: 35,
                ),
              ),
            ),
            flex: 4,
          ),
          const SizedBox(height: 5),
          Text(
            "无",
            maxLines: 1,
            style: const TextStyle(color: Color(0xFFA6A6A6), fontSize: 12),
          ),
        ],
      ),
    );
  }

  ///单个的item
  Widget _buildAnimSelectItem(int index,String name,String icon) => Container(
        alignment: Alignment.center,
        child: Padding(
          child: Column(
            children: [
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: currentSelect == 0
                          ? selectAnimeInIndex == index
                              ? Color(0xFF12CDD9)
                              : Colors.transparent
                          : selectAnimeOutIndex == index
                              ? Color(0xFF12CDD9)
                              : Colors.transparent,
                      width: 2, // 设置边框宽度
                    ),
                    // image: DecorationImage(
                    //   image: CachedNetworkImageProvider(icons[index]),
                    //   fit: BoxFit.fitWidth,
                    // ),
                  ),
                  child: GifControlWidget(
                    selectCallBack: (int select) {
                      if (currentSelect == 0) {
                        setState(() {
                          selectAnimeInIndex = index;
                        });
                      } else {
                        setState(() {
                          selectAnimeOutIndex = index;
                        });
                      }
                      var anime = Anime(
                          animeIn: animeInList[selectAnimeInIndex],
                          animeOut: animeOutList[selectAnimeOutIndex]);
                      widget.onSave.call(anime);
                    },
                    gifUrl: icon,
                    index: index,
                  ),
                ),
                flex: 4,
              ),
              const SizedBox(height: 5),
              Text(
                name,
                maxLines: 1,
                style: const TextStyle(color: Color(0xFFA6A6A6), fontSize: 12),
              ),
            ],
          ),
          padding: const EdgeInsets.only(left: 2, top: 2, right: 2),
        ),
      );
}
