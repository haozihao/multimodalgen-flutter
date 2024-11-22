
import 'package:components/toly_ui/toly_ui.dart';
import 'package:flutter/material.dart';

/// create by blueming.wu
///可以调节一键追爆款通用数值的弹窗
class ConfirmSeekDialog extends StatefulWidget {
  final String title;
  final String content;
  final Function(bool,double)? onSubmit;

  const ConfirmSeekDialog({
    Key? key,
    this.title = '',
    this.content = '',
    this.onSubmit,
  }) : super(key: key);

  @override
  State<ConfirmSeekDialog> createState() => _DownloadJyDialogState();
}

class _DownloadJyDialogState extends State<ConfirmSeekDialog> {
  double progress = 0.50;
  bool allItem = true;

  @override
  void initState() {
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

  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          widget.title,
          style: const TextStyle(color: Colors.red, fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Row(
          children: [
            Slider(
              value: progress,
              min: 0.1,
              max: 1.0,
              label: progress.toStringAsFixed(2),
              activeColor: Colors.orangeAccent,
              inactiveColor: Colors.green.withAlpha(99),
              onChanged: (value) {
                setState(() {
                  progress = value;
                });
              },
            ),
            Text(
              progress.toStringAsFixed(2),
              style: TextStyle(color: Color(0xFF12CDD9)),
            ),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: allItem,
              onChanged: (bool? value) {
                setState(() {
                  allItem = value!;
                });
              },
            ),
            Text("应用至所有配图"),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: !allItem,
              onChanged: (bool? value) {
                setState(() {
                  allItem = !value!;
                });
              },
            ),
            Text("应用至当前未修改初始值的配图"),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            widget.content,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.justify,
          ),
        )
      ],
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
              widget.onSubmit?.call(allItem,progress);
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
