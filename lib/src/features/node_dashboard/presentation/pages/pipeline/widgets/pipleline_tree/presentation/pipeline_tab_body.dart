import 'package:e2_explorer/src/features/common_widgets/json_viewer/json_viewer.dart';
import 'package:e2_explorer/src/features/common_widgets/text_widget.dart';
import 'package:e2_explorer/src/features/node_dashboard/presentation/pages/pipeline/widgets/pipleline_tree/presentation/expandable_widget.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/model/plugin_model.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/provider/node_pipeline_provider.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/widgets/transparent_inkwell_widget.dart';
import 'package:flutter/material.dart';
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
        InstanceConfigList(boxName: widget.boxName),
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
            return InkWell(
              onTap: () => notifier.setSelectedPipeline(mapData.name),
              child: PipelineItemWidget(
                mapData: mapData,
                boxName: boxName,
              ),
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
  final DecodedPlugin mapData;
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
    var entries = widget.mapData
        .toJson()
        .entries
        .where((element) => keys.contains(element.key))
        .toList();
    var finalData = {};
    finalData.addEntries(entries);
    final currentPipelinName = widget.mapData.name;
    return Container(
      color: ref.watch(selectedPipelineProvider) == currentPipelinName
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
                ...finalData.keys
                    .map(
                      (key) => PiplineDetailWidget(
                        title: key,
                        value: "${finalData[key]}",
                      ),
                    )
                    .toList(),
              ],
            )),
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
    final selectedPipeline = ref.watch(selectedPipelineProvider);
    final selectedPlugin = ref.watch(selectedPluginProvider);
    final data = notifier.getPluginList(selectedPipeline: selectedPipeline);

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
            final currentSignature = mapData['SIGNATURE'];
            return Container(
              color: selectedPlugin == currentSignature
                  ? const Color(0xff2E2C6A)
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              child: InkWell(
                onTap: () {
                  notifier.setSelectedPlugin(currentSignature);
                },
                child: Text(currentSignature),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: data.length,
        ),
      ),
    );
  }
}

class InstanceConfigList extends ConsumerWidget {
  final String boxName;
  InstanceConfigList({
    super.key,
    required this.boxName,
  });

  final DataExplorerStore store = DataExplorerStore();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(nodePipelineProvider(boxName));
    final notifier = ref.read(nodePipelineProvider(boxName).notifier);
    final selectedPipeline = ref.watch(selectedPipelineProvider);
    final selectedPlugin = ref.watch(selectedPluginProvider);
    final instanceConfig = notifier.getInstanceConfig(
        selectedPipeline: selectedPipeline, selectedPlugin: selectedPlugin);

    ref.listen(
      nodePipelineProvider(boxName),
      (previous, next) {
        final data = notifier.getInstanceConfig(
            selectedPipeline: selectedPipeline, selectedPlugin: selectedPlugin);
        if (data.isNotEmpty) {
          store.buildNodes(data);
        }
      },
    );

    return Expanded(
      flex: 6,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.containerBgColor,
        ),
        child: instanceConfig.isEmpty
            ? Container()
            : p.ChangeNotifierProvider.value(
                value: store,
                child: p.Consumer<DataExplorerStore>(
                  builder: (context, DataExplorerStore value, child) {
                    return ReusableJsonDataExplorer(
                      nodes: value.displayNodes,
                      value: value,
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class PiplineDetailWidget extends StatelessWidget {
  final String title;
  final String value;
  const PiplineDetailWidget({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextWidget(
              title,
              style: CustomTextStyles.text12_600,
            ),
          ),
          Expanded(
            child: TextWidget(
              value,
              style: CustomTextStyles.text12_600,
            ),
          ),
        ],
      ),
    );
  }
}
