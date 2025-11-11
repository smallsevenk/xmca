import 'package:flutter/material.dart';

class ScrollButton extends StatefulWidget {
  final VoidCallback? onTap;
  const ScrollButton({super.key, this.onTap});

  @override
  ScrollButtonState createState() => ScrollButtonState();
}

class ScrollButtonState extends State<ScrollButton> {
  void handleTap() {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: handleTap, child: SizedBox.shrink());
  }
}
