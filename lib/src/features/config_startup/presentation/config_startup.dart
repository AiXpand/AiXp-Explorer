import 'dart:convert';
import 'dart:io';
import 'package:e2_explorer/dart_e2/formatter/format_decoder.dart';
import 'package:e2_explorer/src/features/command_launcher/model/command_launcher_data.dart';
import 'package:e2_explorer/src/features/command_launcher/presentation/command_launcher_page.dart';
import 'package:e2_explorer/src/features/common_widgets/buttons/app_button_secondary.dart';
import 'package:e2_explorer/src/features/common_widgets/buttons/refresh_button_with_animation.dart';
import 'package:e2_explorer/src/features/common_widgets/table/flr_table.dart';
import 'package:e2_explorer/src/features/common_widgets/table/table_header_item_widget.dart';
import 'package:e2_explorer/src/features/common_widgets/text_widget.dart';
import 'package:e2_explorer/src/features/config_startup/widgets/dialouges/config_startup_edit.dart';
import 'package:e2_explorer/src/features/config_startup/widgets/dialouges/config_startup_view.dart';
import 'package:e2_explorer/src/features/dashboard/presentation/widget/dashboard_body_container.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/provider/network_provider.dart';
import 'package:e2_explorer/src/utils/dimens.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class ConfigStartUp extends StatefulWidget {
  const ConfigStartUp({super.key});

  @override
  State<ConfigStartUp> createState() => _ConfigStartUpState();
}

class _ConfigStartUpState extends State<ConfigStartUp> {
  final period = const Duration(seconds: 5);

  @override
  Widget build(BuildContext context) {
    FLRTableLabels flrTableLabels = FLRTableLabels(
      filters: (BuildContext context) => 'Filters',
      hideColumns: (BuildContext context) => 'Hide Columns',
      hiddenColumn: (BuildContext context) => 'Hidden Column',
      $1hiddenColumns: (BuildContext context) => 'Hidden columns',
      refreshButton: RefreshButtonWithAnimationLabels(
        refresh: (BuildContext context) => 'Refresh',
        loading: (BuildContext context) => 'Loading',
      ),
    );

    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(networkProvider);
      return E2Listener(
        onPayload: (message) {
          final Map<String, dynamic> convertedMessage =
              MqttMessageEncoderDecoder.raw(message);
          ref
              .read(networkProvider.notifier)
              .updateNetmonStatusList(convertedMessage: convertedMessage);
        },
        builder: (context) {
          return DashboardBodyContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 10),
                  child: TextWidget('Config Startup',
                      style: CustomTextStyles.text20_700),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: state.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : FLRTable<CommandLauncherData, CommandLauncherColumns>(
                          expandLastColumn: true,
                          columns: CommandLauncherColumns.values,
                          columnsLeft: const [],
                          columnsRight: const [],
                          visibleColumns: CommandLauncherColumns.values.toSet(),
                          sortingColumns: const {},
                          sortedColumn: null,
                          items: state.netmonStatusList
                              .map((e) => CommandLauncherData(
                                    edgeNode: e.boxId,
                                    configStartupFile: 'configStartupFile',
                                  ))
                              .toList(),
                          rowBuilder: (item, columns) {
                            return columns.map((column) {
                              return switch (column) {
                                CommandLauncherColumns.edgeNode => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 8),
                                    child: TextWidget(item.edgeNode,
                                        style: CustomTextStyles.text14_400),
                                  ),
                                CommandLauncherColumns.configStartupFile =>
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 8),
                                    child: Row(
                                      children: [
                                        AppButtonSecondary(
                                          onPressed: () {
                                            ConfigStartUpViewDialog
                                                .viewConfigLog(
                                              context,
                                              targetId: item.edgeNode,
                                            );
                                          },
                                          text: 'View',
                                          height: 30,
                                          minWidth: 100,
                                          icon: SvgPicture.asset(
                                            'assets/icons/svg/eye.svg',
                                            height: 14,
                                            width: 14,
                                            colorFilter: const ColorFilter.mode(
                                                Colors.white, BlendMode.srcIn),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        AppButtonSecondary(
                                          onPressed: () {
                                            ConfigStartUpEditDialog
                                                .viewConfigLog(
                                              context,
                                              targetId: item.edgeNode,
                                            );
                                            // editData(item: item);
                                          },
                                          text: 'Edit',
                                          height: 30,
                                          minWidth: 100,
                                          icon: SvgPicture.asset(
                                            'assets/icons/svg/edit.svg',
                                            height: 14,
                                            width: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              };
                            }).toList();
                          },
                          headerBuilder: (header) {
                            return TableHeaderItemWidget(
                              title: header.title,
                              showSort: header.canSortBy,
                              isSorted: header.isSortedBy,
                              sortIsAscending: true,
                            );
                          },
                          headerTitle: (columnType) {
                            return switch (columnType) {
                              CommandLauncherColumns.edgeNode => 'Edge Node',
                              CommandLauncherColumns.configStartupFile =>
                                'Config Startup File',
                            };
                          },
                          columnWidth: (columnType) {
                            final size = MediaQuery.of(context).size;
                            return switch (columnType) {
                              CommandLauncherColumns.edgeNode =>
                                size.width / 2.5,
                              CommandLauncherColumns.configStartupFile =>
                                size.width / 2.5,
                            };
                          },
                          onTap: (value) async {},
                          onRefresh: () {},
                          rowHeight: (_) => Dimens.tableBodyRowHeight + 10,
                          isLoading: false,
                          labels: flrTableLabels,
                        ),
                )

                /// Todo: Table here
                // Container(
                //   color: Colors.green,
                //   width: double.maxFinite,
                //   height: 500,
                // )
              ],
            ),
          );
        },
      );
    });
  }
}
