import 'dart:async';

import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/dart_e2/models/payload/netmon/netmon_box_details.dart';
import 'package:e2_explorer/dart_e2/utils/xpand_utils.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/overlay_utils.dart';
import 'package:e2_explorer/src/features/common_widgets/tooltip/icon_button_tooltip.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/presentation/table_elements/netmon_table.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/presentation/widgets/preferred_supervisor_menu.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

class NetworkStatusPage extends StatefulWidget {
  const NetworkStatusPage({
    super.key,
    required this.onBoxSelected,
  });

  final void Function(String boxName) onBoxSelected;

  @override
  State<NetworkStatusPage> createState() => _NetworkStatusPageState();
}

class _NetworkStatusPageState extends State<NetworkStatusPage> {
  final period = const Duration(seconds: 5);
  Map<String, NetmonBoxDetails> netmonStatus = {};
  List<NetmonBox> netmonStatusList = [];
  List<String> supervisorIds = [];
  bool refreshReady = true;
  final OverlayController _settingsOverlayController =
      OverlayController('Preferred supervisor');

  // String? preferredSupervisor;
  String? currentSupervisor;
  late final Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        const Duration(seconds: 5), (timer) => refreshReady = true);
  }

  @override
  void dispose() {
    // timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return E2Listener(
      onPayload: (data) {
        final dataMap = data as Map<String, dynamic>;
        if (dataMap['data']?['specificValue']?['is_supervisor'] == true &&
            dataMap['data']?['specificValue']?['current_network'] != null) {
          final currentNetwork = dataMap['data']?['specificValue']
              ?['current_network'] as Map<String, dynamic>;
          final currentNetworkMap = <String, NetmonBoxDetails>{};
          currentNetwork.forEach((key, value) {
            currentNetworkMap[key] =
                NetmonBoxDetails.fromMap(value as Map<String, dynamic>);
          });
          if (currentNetworkMap.length > 1) {
            setState(() {
              currentSupervisor = dataMap['EE_PAYLOAD_PATH']?[0];
              refreshReady = false;
              netmonStatus = currentNetworkMap;
              netmonStatusList = netmonStatus.entries
                  .map((entry) =>
                      NetmonBox(boxId: entry.key, details: entry.value))
                  .toList();
              supervisorIds = netmonStatusList
                  .where((element) =>
                      element.details.isSupervisor &&
                      element.details.working == 'ONLINE')
                  .map((e) => e.boxId)
                  .toList();
            });
          }
        } else {}
      },
      // dataFilter: E2ListenerFilters.acceptAll(),
      dataFilter: (data) {
        // return true;
        /// ToDO: Refactor when only supervisor nodes are sending netmon
        final dataMap = data as Map<String, dynamic>;
        // if (dataMap?['EE_FORMATTER'] != "cavi2") {
        //   return false;
        // }

        /// Added a change to accept only preferredSupervisor
        if (currentSupervisor != null &&
            dataMap['EE_PAYLOAD_PATH']?[0] != currentSupervisor) {
          return false;
        }
        // final dataField = dataMap?['data'] as Map<String, dynamic>;
        // final specificValueField = dataField?['specificValue'] as Map<String, dynamic>;
        // final isSupervisor = specificValueField?['is_supervisor'] as bool?;
        return true;
      },
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Network status',
                  style: TextStyles.h2(),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      currentSupervisor != null
                          ? 'Current supervisor: $currentSupervisor'
                          : 'No supervisor',
                      style: TextStyles.body(),
                    ),
                    const SizedBox(width: 8),
                    OverlayTarget(
                      targetKey: _settingsOverlayController.targetKey,
                      layerLink: _settingsOverlayController.layerLink,
                      groupID: _settingsOverlayController.tapRegionGroupID,
                      child: IconButtonWithTooltip(
                        onTap: currentSupervisor == null
                            ? null
                            : () async {
                                if (!_settingsOverlayController.canOpen) {
                                  _settingsOverlayController
                                      .closeWithResult(null);
                                  return;
                                }
                                const Alignment targetAnchor =
                                    Alignment.bottomRight;
                                const Alignment followerAnchor =
                                    Alignment.bottomLeft;

                                final dynamic returnedValue =
                                    await _settingsOverlayController
                                        .showOverlay(
                                  context: context,
                                  isModal: false,
                                  targetAnchor: targetAnchor,
                                  followerAnchor: followerAnchor,
                                  contentOffset: const Offset(15, 175),
                                  width: 250,
                                  maxHeight: 200,

                                  // maxWidth: widget.maxContentWidth,
                                  // maxHeight: widget.maxContentHeight,
                                  shellBuilder: (context, content) => content,
                                  contentBuilder: (context, controller) {
                                    return PreferredSupervisorMenu(
                                      overlayController:
                                          _settingsOverlayController,
                                      supervisors: supervisorIds,
                                      selectedSupervisor: currentSupervisor!,
                                    );
                                  },
                                  // onTapOutside: widget.onTapOutside,
                                );
                                if (returnedValue != null) {
                                  currentSupervisor = returnedValue as String;
                                }
                              },
                        icon: CarbonIcons.settings,
                        tooltipMessage: 'Set preferred supervisor',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Expanded(
                child: NetmonTable(
                  boxStatusList: netmonStatusList,
                  onBoxSelected: widget.onBoxSelected,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> decodeData(String encodedData) {
    return XpandUtils.decodeEncryptedGzipMessage(encodedData);
  }
}
