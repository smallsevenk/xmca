import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:xkit/x_kit.dart';
import 'package:xmca/helper/ca_color.dart';
import 'package:xmca/pages/comm/widgets/ca_image.dart';

class InputToolbarItem {
  String title;
  String icon;

  InputToolbarItem({required this.title, required this.icon});
}

class CAInputToolbar extends StatelessWidget {
  final List<InputToolbarItem> items;
  final Function()? humanCsTap;
  const CAInputToolbar({super.key, required this.items, this.humanCsTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 96.w,
      padding: EdgeInsets.symmetric(vertical: 16.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            height: 64.w,
            width: 198.w,
            margin: EdgeInsets.only(left: 24.w),
            decoration: BoxDecoration(
              color: CAColor.cWhite,
              borderRadius: BorderRadius.circular(32.w),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CAImage('tool_${item.icon}', width: 32.w),
                Gap(6.w),
                Text(item.title, style: TextStyle(color: CAColor.c51565F)),
              ],
            ),
          ).onDbTap(humanCsTap);
        },
      ),
    );
  }
}
