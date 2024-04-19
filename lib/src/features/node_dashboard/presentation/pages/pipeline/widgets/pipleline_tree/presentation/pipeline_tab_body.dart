import 'package:collection/collection.dart';
import 'package:e2_explorer/src/features/common_widgets/text_widget.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/provider/node_pipeline_provider.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        Expanded(
          flex: 5,
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.containerBgColor,
            ),
          ),
        ),
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
            return InkWell(
              onTap: () => notifier.setSelectedPipeline(mapData['NAME']),
              child: Text(mapData['NAME']),
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
            return InkWell(
              // onTap: () => notifier.setSelectedPipeline(mapData['NAME']),
              child: Text(mapData['SIGNATURE']),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: data.length,
        ),
      ),
    );
  }
}
