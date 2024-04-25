import 'package:collection/collection.dart';
import 'package:e2_explorer/src/features/common_widgets/text_widget.dart';
import 'package:e2_explorer/src/features/node_dashboard/presentation/pages/pipeline/widgets/pipleline_tree/presentation/expandable_widget.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/provider/node_pipeline_provider.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/widgets/transparent_inkwell_widget.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_data_explorer/json_data_explorer.dart';
import 'package:provider/provider.dart' as p;
import 'package:json_data_explorer/json_data_explorer.dart';
import 'package:provider/provider.dart' as p;

class PipelineTabBodyWidget extends ConsumerStatefulWidget {
  final String boxName;
  const PipelineTabBodyWidget({
    super.key,
    required this.boxName,
  });

  @override
  ConsumerState<PipelineTabBodyWidget> createState() =>
      _PipelineTabBodyWidgetState();
}

class _PipelineTabBodyWidgetState extends ConsumerState<PipelineTabBodyWidget> {
  final DataExplorerStore store = DataExplorerStore();
  @override
  Widget build(BuildContext context) {
    return p.ChangeNotifierProvider.value(
      value: store,
      child: p.Consumer<DataExplorerStore>(
        builder: (context, value, child) {
          return Row(
            children: [
              PipelineListWidget(boxName: widget.boxName),
              const SizedBox(width: 20),
              PluginListWidget(
                boxName: widget.boxName,
                onPluginSelected: (plugin) {
                  final notifier =
                      ref.read(nodePipelineProvider(widget.boxName).notifier);
                  final data = notifier.getPluginList;
                  final pluginData = data.firstWhereOrNull(
                    (element) => element['SIGNATURE'] == plugin,
                  );
                  value.buildNodes(pluginData, areAllCollapsed: false);
                },
              ),
              const SizedBox(width: 20),
              PipelineJsonData(
                boxName: widget.boxName,
                value: value,
              )
            ],
          );
        },
      ),
    );
  }
}

class PipelineListWidget extends ConsumerWidget {
  final String boxName;
  const PipelineListWidget({
    super.key,
    required this.boxName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(nodePipelineProvider(boxName));
    final notifier = ref.read(nodePipelineProvider(boxName).notifier);
    return Expanded(
      flex: 4,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.containerBgColor,
        ),
        child: ListView.builder(
          itemBuilder: (context, index) {
            var mapData = data[index];
            bool isSelected = mapData['NAME'] == notifier.selectedPipeline;
            return InkWell(
              onTap: () => notifier.setSelectedPipeline(mapData['NAME']),
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected
                        ? const Color(0xFF2E2C6A)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Text(mapData['NAME']),
                      const Spacer(),
                      Visibility(
                          visible: isSelected,
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ))
                    ],
                  )),
            );
          },
          // separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: data.length,
        ),
      ),
    );
  }
}

class PipelineItemWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic> mapData;
  final String boxName;
  const PipelineItemWidget({
    super.key,
    required this.mapData,
    required this.boxName,
  });

  @override
  ConsumerState<PipelineItemWidget> createState() => _PipelineItemWidgetState();
}

class _PipelineItemWidgetState extends ConsumerState<PipelineItemWidget> {
  final DataExplorerStore store = DataExplorerStore();

  @override
  void initState() {
    store.buildNodes(widget.mapData, areAllCollapsed: true);
    super.initState();
  }

  var keys = ["TYPE", "VALIDATED", 'SESSION', 'LIVE_FEED'];

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(nodePipelineProvider(widget.boxName).notifier);
    var entries = widget.mapData.entries
        .where((entry) => keys.contains(entry.key.toUpperCase()))
        .toList();
    var finalData = {};
    finalData.addEntries(entries);
    final currentPipelinName = widget.mapData['NAME'];
    return Container(
      color: notifier.selectedPipeline == currentPipelinName
          ? const Color(0xff2E2C6A)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: ExpandableWidget(
        header: TransparentInkwellWidget(
          onTap: () {
            notifier.setSelectedPipeline(currentPipelinName);
          },
          child: TextWidget(
            currentPipelinName.toUpperCase(),
            style: CustomTextStyles.text16_400,
          ),
        ),
        onToggle: (a) {},
        headerTitle: currentPipelinName,
        body: Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                // ...finalData.keys
                //     .map(
                //       (key) => PiplineDetailWidget(
                //         title: key,
                //         value: "${finalData[key]}",
                //       ),
                //     )
                //     .toList(),
              ],
            )),
      ),
    );
  }
}

class PluginListWidget extends ConsumerWidget {
  final String boxName;
  final Function(String plugin) onPluginSelected;
  const PluginListWidget(
      {super.key, required this.boxName, required this.onPluginSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(nodePipelineProvider(boxName));
    final notifier = ref.read(nodePipelineProvider(boxName).notifier);
    final data = notifier.getPluginList;

    return Expanded(
      flex: 5,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.containerBgColor,
        ),
        child: ListView.separated(
          itemBuilder: (context, index) {
            var mapData = data[index];
            bool isSelected = mapData['SIGNATURE'] == notifier.selectedPlugin;
            return InkWell(
              onTap: () {
                notifier.setSelectedPlugin(mapData['SIGNATURE']);
                onPluginSelected(mapData['SIGNATURE']);
              },
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected
                        ? const Color(0xFF2E2C6A)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Text(mapData['SIGNATURE']),
                      const Spacer(),
                      Visibility(
                          visible: isSelected,
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ))
                    ],
                  )),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: data.length,
        ),
      ),
    );
  }
}

class PipelineJsonData extends ConsumerStatefulWidget {
  const PipelineJsonData(
      {super.key, required this.boxName, required this.value});
  final String boxName;
  final DataExplorerStore value;

  @override
  ConsumerState<PipelineJsonData> createState() => _PipelineJsonDataState();
}

class _PipelineJsonDataState extends ConsumerState<PipelineJsonData> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.containerBgColor,
        ),
        child: ReusableJsonDataExplorer(
          value: widget.value,
          nodes: widget.value.displayNodes,
        ),
      ),
    );
  }
}
