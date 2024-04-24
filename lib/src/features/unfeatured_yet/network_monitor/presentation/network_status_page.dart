import 'dart:async';

import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/dart_e2/formatter/format_decoder.dart';
import 'package:e2_explorer/dart_e2/models/payload/netmon/netmon_box_details.dart';
import 'package:e2_explorer/dart_e2/utils/xpand_utils.dart';
import 'package:e2_explorer/src/features/common_widgets/buttons/app_button_primary.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/overlay_utils.dart';
import 'package:e2_explorer/src/features/common_widgets/text_widget.dart';
import 'package:e2_explorer/src/features/common_widgets/tooltip/icon_button_tooltip.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/presentation/table_elements/netmon_table.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/presentation/table_elements/netmon_table_new.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/presentation/widgets/preferred_supervisor_menu.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/presentation/widgets/single_node_page.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/provider/network_provider.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:provider/provider.dart';

class NetworkStatusPage extends ConsumerStatefulWidget {
  const NetworkStatusPage({
    super.key,
    required this.onBoxSelected,
  });

  final void Function(NetmonBox) onBoxSelected;

  @override
  ConsumerState<NetworkStatusPage> createState() => _NetworkStatusPageState();
}

class _NetworkStatusPageState extends ConsumerState<NetworkStatusPage> {
  bool refreshReady = true;
  final OverlayController _settingsOverlayController =
      OverlayController('Preferred supervisor');

  // String? preferredSupervisor;
  String? currentSupervisor;
  late final Timer timer;
  bool isSingleNodeManager = false;

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
    final provider = ref.watch(networkProvider);
    return E2Listener(
      onPayload: (message) {
        final Map<String, dynamic> convertedMessage =
            MqttMessageEncoderDecoder.raw(message);
        ref
            .read(networkProvider.notifier)
            .updateNetmonStatusList(convertedMessage: convertedMessage);
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
        var d = Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: !isSingleNodeManager
                ? AppColors.containerBgColor
                : AppColors.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        top: 10, left: 16, right: 10, bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.containerBgColor,
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          topLeft: Radius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        TextWidget('Node Dashboard',
                            style: CustomTextStyles.text20_700),
                        const SizedBox(width: 10),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            // Checkbox(
                            //     value: isSingleNodeManager,
                            //     onChanged: (value) {
                            //       setState(() {
                            //         isSingleNodeManager = value!;
                            //       });
                            //     }),
                            // const Text("Single node manager"),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Network by ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textPrimaryColor,
                                ),
                                children: [
                                  TextSpan(
                                    text: provider.supervisorIds.isNotEmpty
                                        ? provider.supervisorIds[0]
                                        : '...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimaryColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            TextWidget(
                              provider.netmonStatusList
                                      .where((element) =>
                                          element.details.isSupervisor)
                                      .isNotEmpty
                                  ? ' ${provider.netmonStatusList.where((element) => element.boxId == provider.supervisorIds[0]).first.details.lastRemoteTime}'
                                  : '',
                              style: CustomTextStyles.text14_700,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!provider.isLoading &&
                      isSingleNodeManager &&
                      provider.netmonStatusList.isNotEmpty)
                    SizedBox(
                        height: 80,
                        child: NetmonTableNew(
                          netmonBoxes: [provider.netmonStatusList[0]],
                        )),
                ],
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : isSingleNodeManager
                        ? Container()
                        : NetmonTableNew(
                            netmonBoxes: provider.netmonStatusList,
                            onBoxSelected: widget.onBoxSelected,
                          ),
              ),

              /// Todo: Table here
              // Container(
              //   color: Colors.green,
              //   width: double.maxFinite,
              //   height: 500,
              // )
            ],
          ),
        );
        return d;
      },
    );
  }

  Map<String, dynamic> decodeData(String encodedData) {
    return XpandUtils.decodeEncryptedGzipMessage(encodedData);
  }
}
