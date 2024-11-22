import 'package:app/app.dart';
import 'package:flutter/material.dart';

class SimpleDeskTopBar extends StatelessWidget {
  final Widget? leading;
  final Widget? tail;
  final double height;

  const SimpleDeskTopBar({super.key, this.leading,this.tail,this.height=64});

  @override
  Widget build(BuildContext context) {
    return DragToMoveAreaNoDouble(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: height,
        color: Color(0xff2C3036),
        child: Row(
          children: [
            if (leading != null) leading!,
            const Spacer(),
            const SizedBox(
              width: 20,
            ),
            if(tail!=null) tail!,
            const WindowButtons(),
          ],
        ),
      ),
    );
  }
}
