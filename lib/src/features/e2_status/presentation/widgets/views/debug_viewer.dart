import 'package:e2_explorer/src/features/coms/coms.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/box_messages_tab_display.dart';
import 'package:e2_explorer/src/features/node_dashboard/presentation/pages/pipeline/pipeline_screen.dart';
import 'package:e2_explorer/src/features/node_dashboard/presentation/pages/resources/resources_tab.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/provider/node_pipeline_provider.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugViewer extends ConsumerWidget {
  const DebugViewer({super.key, required this.boxName, this.onTabChanged});

  final String? boxName;
  final Function(int a)? onTabChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (boxName == null) {
      return Container(
        color: const Color(0xff161616),
        height: double.infinity,
        child: Center(
          child: Text(
            'Box not available!',
            style: TextStyles.body(),
          ),
        ),
      );
    }
    return SizedBox(
        height: double.infinity,
        child: BoxMessagesTabDisplay(
          resourcesView: ResourcesTab(
            key: ValueKey('${boxName ?? ''}1'),
            boxName: boxName!,
          ),
          pipelinesView: PipeLine(
            key: ValueKey('${boxName ?? ''}2'),
            boxName: boxName!,
          ),
          commsView: Comms(
            boxName: boxName!,
          ),

          // Comms(
          //   key: ValueKey('${boxName ?? ''}3'),
          //   boxName: boxName!,
          // ),
          onTabChanged: (tab) {
            onTabChanged?.call(tab.index);
            ref
                .read(nodePipelineProvider(boxName!).notifier)
                .resetSelectedState();
          },
        ));
  }
}
