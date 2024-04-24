import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/hf_dropdown.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/overlay_parent.dart';
import 'package:e2_explorer/src/features/common_widgets/text_widget.dart';
import 'package:e2_explorer/src/features/network/widgets/network_info_dialog.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/domain/models/mqtt_server.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/widgets/transparent_inkwell_widget.dart';
import 'package:flutter/material.dart';

class NetworksListingWidget extends StatelessWidget {
  const NetworksListingWidget({
    super.key,
    required this.title,
    required this.servers,
    this.selectedItem,
    this.enabled = true,
    this.onSelectionChanged,
  });

  final List<MqttServer> servers;
  final String title;
  final String? selectedItem;
  final bool enabled;
  final Function(MqttServer)? onSelectionChanged;

  bool get isActive =>
      selectedItem != null &&
      servers.map((e) => e.name).toList().contains(selectedItem);

  @override
  Widget build(BuildContext context) {
    return OverlayParent(
      overlayController: OverlayController('NetworksListingWidget'),
      builder: (context, overlay) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ActiveStatusDot(isActive: isActive),
              const SizedBox(width: 6),
              TextWidget(title, style: CustomTextStyles.text16_600),
            ],
          ),
          const SizedBox(height: 14),
          for (MqttServer item in servers) ...[
            TransparentInkwellWidget(
              onTap: () {
                if (item.name.toLowerCase() != selectedItem?.toLowerCase()) {
                  onSelectionChanged?.call(item);
                }
              },
              onHover: (value) {
                if (value) {
                  overlay.showOverlay(
                    context: context,
                    width: 300,
                    maxWidth: 600,
                    followerAnchor: Alignment.centerRight,
                    shellBuilder: (context, child) => Container(
                      decoration: BoxDecoration(
                        color: ColorStyles.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    contentBuilder: (context, _) {
                      return NetworkInfoDialog(server: item);
                    },
                  );
                } else {
                  overlay.closeWithResult(true);
                }
              },
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  Container(
                    width: 30,
                    alignment: Alignment.topLeft,
                    child: itemSelected(item.name)
                        ? const Icon(Icons.check_rounded,
                            color: Color(0xFF49D688))
                        : const SizedBox(),
                  ),
                  TextWidget(
                    item.name,
                    style: itemSelected(item.name)
                        ? CustomTextStyles.text16_600
                        : CustomTextStyles.text16_400_secondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  bool itemSelected(String item) =>
      selectedItem != null && selectedItem == item;
}

class ActiveStatusDot extends StatelessWidget {
  const ActiveStatusDot({
    super.key,
    required this.isActive,
    this.size = 9,
  });

  final bool isActive;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF49D688) : const Color(0xFFFF384E),
      ),
    );
  }
}
