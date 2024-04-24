import 'package:collection/collection.dart';
import 'package:e2_explorer/src/features/common_widgets/json_viewer/json_viewer.dart';
import 'package:e2_explorer/src/features/common_widgets/text_widget.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/provider/node_pipeline_provider.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PipelineListWidget(boxName: widget.boxName),
        const SizedBox(width: 20),
        PluginListWidget(boxName: widget.boxName),
        const SizedBox(width: 20),
        PipelineJsonData(
          boxName: widget.boxName,
        )
      ],
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
      flex: 3,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.containerBgColor,
        ),
        child: ListView.separated(
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
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: data.length,
        ),
      ),
    );
  }
}

class PluginListWidget extends ConsumerWidget {
  final String boxName;
  const PluginListWidget({
    super.key,
    required this.boxName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(nodePipelineProvider(boxName));
    final notifier = ref.read(nodePipelineProvider(boxName).notifier);
    final data = notifier.getPluginList;
    return Expanded(
      flex: 4,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.containerBgColor,
        ),
        child: ListView.separated(
          itemBuilder: (context, index) {
            var mapData = data[index];
            bool isSelected = mapData['SIGNATURE'] == notifier.selectedPlugin;
            return InkWell(
              onTap: () => notifier.setSelectedPlugin(mapData['SIGNATURE']),
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
  const PipelineJsonData({super.key, required this.boxName});
  final String boxName;

  @override
  ConsumerState<PipelineJsonData> createState() => _PipelineJsonDataState();
}

class _PipelineJsonDataState extends ConsumerState<PipelineJsonData> {
  final DataExplorerStore store = DataExplorerStore();

  @override
  Widget build(BuildContext context) {
    return p.ChangeNotifierProvider.value(
      value: store,
      child: p.Consumer<DataExplorerStore>(
        builder: (context, value, child) {
          final notifier =
              ref.read(nodePipelineProvider(widget.boxName).notifier);
          final data = notifier.getPluginList;
          final selectedData = data.firstWhereOrNull(
              (element) => element['SIGNATURE'] == notifier.selectedPlugin);
          value.buildNodes(selectedData);
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
                value: value,
                nodes: value.displayNodes,
              ),
            ),
          );
        },
      ),
    );
  }
}
