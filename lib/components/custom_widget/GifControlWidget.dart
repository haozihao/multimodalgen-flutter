                                                                          import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class GifControlWidget extends StatefulWidget {
  final Function(int select) selectCallBack;
  final String gifUrl;
  final int index;

  const GifControlWidget({
    super.key,
    required this.selectCallBack,
    required this.gifUrl, required this.index,
  });

  @override
  State<GifControlWidget> createState() => _GifControlWidgetState();
}

class _GifControlWidgetState extends State<GifControlWidget>
    with SingleTickerProviderStateMixin {
  late final GifController _gifController;

  @override
  void initState() {
    _gifController = GifController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _gifController.reset();
        _gifController.forward();
        widget.selectCallBack.call(widget.index);
      },
      child: Gif(
        image: NetworkImage(widget.gifUrl),
        controller: _gifController,
        // if duration and fps is null, original gif fps will be used.
        //fps: 30,
        //duration: const Duration(seconds: 3),
        autostart: Autostart.no,
        placeholder: (context) => const Text('Loading...'),
        onFetchCompleted: () {
          // _gifController.reset();
          // _gifController.forward();
        },
      ),
    );
  }
}
