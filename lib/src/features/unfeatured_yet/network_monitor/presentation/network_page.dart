import 'package:e2_explorer/dart_e2/models/payload/netmon/netmon_box_details.dart';
import 'package:e2_explorer/src/features/common_widgets/buttons/app_button_primary.dart';
import 'package:e2_explorer/src/features/coms/provider/filter_provider.dart';
import 'package:e2_explorer/src/features/dashboard/presentation/widget/dashboard_body_container.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/views/debug_viewer.dart';
import 'package:e2_explorer/src/features/node_dashboard/presentation/pages/resources/provider/resource_provider.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/model/node_history_model.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/presentation/network_status_page.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/features/common_widgets/text_widget.dart';
import 'package:e2_explorer/src/widgets/transparent_inkwell_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

class NetworkPage extends ConsumerStatefulWidget {
  const NetworkPage({super.key});

  @override
  ConsumerState<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends ConsumerState<NetworkPage> {
  bool isSingleNodeManager = false;
  static const _networkPageIndex = 0;
  static const _boxDetailsPageIndex = 1;
  String? selectedBoxName;
  NetmonBox? selectedBox;
  int _navIndex = _networkPageIndex;
  late NodeHistoryModel nodeHistoryModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _navIndex,
      children: [
        NetworkStatusPage(
          onBoxSelected: (boxName) async {
            if (E2Client().boxHasMessages(boxName.boxId)) {
              setState(() {
                selectedBoxName = boxName.boxId;
                selectedBox = boxName;
                _navIndex = _boxDetailsPageIndex;
              });
              ref
                  .read(resourceProvider.notifier)
                  .nodeHistoryCommand(node: boxName.boxId);
            } else {
              await showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Warning'),
                    content: const Text(
                        'The selected box has no messages at the moment!'),
                    actions: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardBodyContainer(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
              child: Row(
                children: [
                  TransparentInkwellWidget(
                    onTap: () {
                      setState(() {
                        _navIndex = _networkPageIndex;
                        selectedBoxName = null;
                        ref.read(filterProvider.notifier).clearFilter();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back,
                          size: 24, color: AppColors.textPrimaryColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        TextWidget(
                          'Monitoring Edge Node ${selectedBoxName ?? ''}',
                          style: CustomTextStyles.text16_400,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  AppButtonPrimary(
                    onPressed: () {
                      ref
                          .read(resourceProvider.notifier)
                          .nodeHistoryCommand(node: selectedBoxName!);
                    },
                    text: 'Refresh',
                    height: 32,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            selectedBoxName != null
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DebugViewer(
                        boxName: selectedBoxName,
                      ),
                    ),
                  )
                : Container(),
          ],
        )
      ],
    );
  }
}
