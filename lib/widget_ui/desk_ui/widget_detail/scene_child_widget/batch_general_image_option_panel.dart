import 'package:components/toly_ui/toly_ui.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pieces_ai/app/model/TweetScript.dart';

import '../../../../app/model/user_info_global.dart';

/// create by blueming.wu
///批量生图弹窗选项
class BatchGeneralImageOptionPanel extends StatefulWidget {
  final String title;
  final int styleType;
  final TweetScript tweetScript;
  final Function(bool refresh)? onSubmit;

  const BatchGeneralImageOptionPanel({
    Key? key,
    this.title = '',
    this.onSubmit,
    required this.styleType,
    required this.tweetScript,
  }) : super(key: key);

  @override
  State<BatchGeneralImageOptionPanel> createState() =>
      _BatchGeneralImageOptionPanelState();
}

class _BatchGeneralImageOptionPanelState
    extends State<BatchGeneralImageOptionPanel> {
  bool reGeneral = false;
  int peggAll = 0;

  @override
  void initState() {
    _calculatePegg(reGeneral);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildBar(context),
        _buildTitle(context),
        _buildContent(),
        _buildFooter(context),
      ],
    );
  }

  ///计算扣除的皮蛋
  _calculatePegg(bool reGeneral) {
    peggAll = 0;
    if (widget.styleType == 1 || widget.styleType == 2) {
      //本地模式，图片不扣
    } else {
      for (var tweetImg in widget.tweetScript.scenes[0].imgs) {
        if (reGeneral) {
          peggAll += 1;
        } else {
          if (tweetImg.url?.isEmpty ?? true) {
            if (tweetImg.mediaType != 1) peggAll += 1;
          }
        }
      }
    }
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Row(
            children: [],
          ),
          Row(
            children: [
              Circle(
                color: Color(0xFF12CDD9),
                radius: 7,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  "是否覆盖原有图片",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Checkbox(
                value: reGeneral,
                activeColor: Colors.white,
                checkColor: Color(0xFF12CDD9),
                onChanged: (bool? value) {
                  _calculatePegg(value ?? false);
                  setState(() {
                    reGeneral = value ?? false;
                  });
                },
              ),
              Spacer()
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              '皮蛋  -$peggAll',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.justify,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFooter(context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 15.0, top: 10, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          InkWell(
            onTap: () async {
              //看是否皮蛋足够
              var user = GlobalInfo.instance.user;
              if (widget.styleType == 0 && user.pegg < peggAll) {
                MotionToast.info(description: Text('皮蛋不足！')).show(context);
                return;
              }
              widget.onSubmit?.call(reGeneral);
              Navigator.of(context).pop();
            },
            child: Container(
              alignment: Alignment.center,
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  color: Theme.of(context).primaryColor),
              child: const Text('确 定',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              alignment: Alignment.center,
              height: 40,
              width: 100,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  color: Colors.orangeAccent),
              child: const Text('取 消',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  _buildBar(context) => Row(
        children: <Widget>[
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 30,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 10, top: 5),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      );
}
