import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/src/features/common_widgets/tooltip/icon_button_tooltip.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/views/debug_viewer.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/presentation/network_status_page.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  static const _networkPageIndex = 0;
  static const _boxDetailsPageIndex = 1;
  String? selectedBoxName;
  int _navIndex = _networkPageIndex;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _navIndex,
      children: [
        NetworkStatusPage(
          onBoxSelected: (boxName) async {
            if (E2Client().boxHasMessages(boxName)) {
              setState(() {
                selectedBoxName = boxName;
                _navIndex = _boxDetailsPageIndex;
              });
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButtonWithTooltip(
                    onTap: () {
                      setState(() {
                        _navIndex = _networkPageIndex;
                        selectedBoxName = null;
                      });
                    },
                    icon: CarbonIcons.chevron_left,
                    tooltipMessage: '',
                  ),
                  Text(
                    'Go back',
                    style: TextStyles.small14(),
                  ),
                ],
              ),
            ),
            selectedBoxName != null
                ? Expanded(child: DebugViewer(boxName: selectedBoxName))
                : Container(),
          ],
        )
      ],
    );
  }
}
