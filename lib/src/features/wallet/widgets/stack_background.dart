import 'package:e2_explorer/src/design/layouts/desktop_app_layout.dart';
import 'package:e2_explorer/src/utils/asset_utils.dart';
import 'package:flutter/material.dart';

class StackWalletBackground extends StatelessWidget {
  const StackWalletBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: DesktopAppLayout(
        child: Stack(
          children: [
            Positioned(
                left: 0,
                child: Image.asset(
                  AssetUtils.getPngIconPath("stack_image_left"),
                  fit: BoxFit.contain,
                  height: deviceHeight,
                )),
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(AssetUtils.getPngIconPath("stack_image_top")),
            ),
            Positioned(
                right: 0,
                child: Image.asset(
                  AssetUtils.getPngIconPath("stack_image_right"),
                  fit: BoxFit.contain,
                  height: deviceHeight,
                )),
            child
          ],
        ),
      ),
    );
  }
}
