import 'package:e2_explorer/src/features/command_launcher/model/command_launcher_data.dart';
import 'package:e2_explorer/src/features/common_widgets/buttons/app_button_secondary.dart';
import 'package:e2_explorer/src/features/common_widgets/buttons/refresh_button_with_animation.dart';
import 'package:e2_explorer/src/features/common_widgets/table/ai_table.dart';
import 'package:e2_explorer/src/features/common_widgets/table/flr_table.dart';
import 'package:e2_explorer/src/features/common_widgets/table/table_header_item_widget.dart';
import 'package:e2_explorer/src/features/common_widgets/text_widget.dart';
import 'package:e2_explorer/src/features/dashboard/presentation/widget/dashboard_body_container.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:e2_explorer/src/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommandLauncherPage extends StatelessWidget {
  const CommandLauncherPage({Key? key}) : super(key: key);

  static FLRTableLabels flrTableLabels = FLRTableLabels(
    filters: (BuildContext context) => 'Filters',
    hideColumns: (BuildContext context) => 'Hide Columns',
    hiddenColumn: (BuildContext context) => 'Hidden Column',
    $1hiddenColumns: (BuildContext context) => 'Hidden columns',
    refreshButton: RefreshButtonWithAnimationLabels(
      refresh: (BuildContext context) => 'Refresh',
      loading: (BuildContext context) => 'Loading',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DashboardBodyContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 10),
              child: Row(
                children: [
                  TextWidget('Command Launcher',
                      style: CustomTextStyles.text20_700),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: FLRTable<CommandLauncherData, CommandLauncherColumns>(
                columns: CommandLauncherColumns.values,
                columnsLeft: const [],
                columnsRight: const [],
                visibleColumns: CommandLauncherColumns.values.toSet(),
                sortingColumns: const {},
                sortedColumn: null,
                items: [
                  CommandLauncherData(
                    edgeNode: 'Goliath',
                    configStartupFile: 'configStartupFile',
                  ),
                  CommandLauncherData(
                    edgeNode: 'gts-test 1',
                    configStartupFile: 'configStartupFile',
                  ),
                  CommandLauncherData(
                    edgeNode: 'gts-staging',
                    configStartupFile: 'configStartupFile',
                  ),
                ],
                rowBuilder: (item, columns) {
                  return columns.map((column) {
                    return switch (column) {
                      CommandLauncherColumns.edgeNode => Padding(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: TextWidget(item.edgeNode,
                              style: CustomTextStyles.text14_400),
                        ),
                      CommandLauncherColumns.configStartupFile => Padding(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: Row(
                            children: [
                              AppButtonSecondary(
                                text: 'Restart',
                                height: 30,
                                minWidth: 100,
                                icon: SvgPicture.asset(
                                  'assets/icons/svg/restart.svg',
                                  height: 14,
                                  width: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AppButtonSecondary(
                                text: 'Get Logs',
                                height: 30,
                                minWidth: 100,
                                icon: SvgPicture.asset(
                                  'assets/icons/svg/log.svg',
                                  height: 14,
                                  width: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AppButtonSecondary(
                                height: 30,
                                minWidth: 100,
                                text: 'Create Pipeline',
                                icon: SvgPicture.asset(
                                  'assets/icons/svg/plus_circle.svg',
                                  height: 14,
                                  width: 14,
                                ),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.more_vert),
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
                    CommandLauncherColumns.edgeNode => size.width / 2.5,
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
          ],
        ),
      ),
    );
  }
}

enum CommandLauncherColumns {
  edgeNode,
  configStartupFile,
}
