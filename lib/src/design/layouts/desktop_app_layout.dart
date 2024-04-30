import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/window_buttons.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

class DesktopAppLayout extends StatelessWidget {
  const DesktopAppLayout({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // height: 40,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 3.5,
          ),
          // color: Colors.red,
          child: WindowTitleBarBox(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: MoveWindow(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'AIXpand',
                          style: TextStyles.small14Strong(),
                        ),
                      ),
                    ),
                  ),
                ),
                const WindowButtons(),
              ],
            ),
          ),
        ),
        if (child != null) Expanded(child: child!),
      ],
    );
  }
}
