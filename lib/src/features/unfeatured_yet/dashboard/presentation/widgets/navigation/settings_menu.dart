import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:e2_explorer/dart_e2/const/mqtt_config.dart';
import 'package:e2_explorer/src/features/common_widgets/buttons/clickable_button.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/hf_dropdown.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/routes/routes.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({
    super.key,
    this.height = 200,
    this.width = 300,
    required this.overlayController,
  });

  final double height;
  final double width;
  final OverlayController overlayController;

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  bool isConnected = E2Client().isConnected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: ColorStyles.dark630,
          border:
              Border.all(color: ColorStyles.selectedHoverButtonBlue, width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        height: widget.height,
        width: widget.width,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: E2Listener(onConnectionChanged: (connectionStatus) {
            // setState(() {
            isConnected = connectionStatus as bool;
            // });
            widget.overlayController.rebuild();
          }, builder: (context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MqttConfig.host,
                      style: TextStyles.small14(),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      isConnected
                          ? 'Status: Connected'
                          : 'Status: Disconnected',
                      style: TextStyles.caption(
                        color:
                            isConnected ? ColorStyles.green : ColorStyles.red,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ClickableButton(
                        onTap: () {
                          if (isConnected) {
                            E2Client().disconnect();
                          } else {
                            E2Client().connect();
                          }
                        },
                        height: 25,
                        text: isConnected ? 'Disconnect' : 'Connect',
                        textColor: isConnected
                            ? ColorStyles.light100
                            : ColorStyles.dark600,
                        hoveredTextColor: isConnected
                            ? ColorStyles.light100
                            : ColorStyles.dark600,
                        fontSize: 12,
                        backgroundColor:
                            isConnected ? ColorStyles.red : ColorStyles.green,
                        hoverColor: isConnected
                            ? ColorStyles.red.withOpacity(0.8)
                            : ColorStyles.green.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ClickableButton(
                        onTap: () {
                          E2Client.clearClientData();
                          const newSize = Size(500, 700);
                          appWindow.minSize = newSize;
                          appWindow.size = newSize;
                          if (context.mounted) {
                            context.goNamed(RouteNames.connection);
                          }
                        },
                        height: 25,
                        text: 'Close session',
                        fontSize: 12,
                        hoverColor: ColorStyles.dark700.withOpacity(0.8),
                      ),
                    ),
                  ],
                )
              ],
            );
          }),
        ),
      ),
    );
  }
}
