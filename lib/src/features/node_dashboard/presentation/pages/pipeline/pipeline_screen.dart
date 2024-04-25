import 'package:e2_explorer/dart_e2/commands/e2_commands.dart';
import 'package:e2_explorer/dart_e2/formatter/format_decoder.dart';
import 'package:e2_explorer/main.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/features/node_dashboard/presentation/pages/pipeline/widgets/pipleline_tree/presentation/pipeline_tab_body.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/provider/node_pipeline_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PipeLine extends ConsumerStatefulWidget {
  final String boxName;
  const PipeLine({super.key, required this.boxName});

  @override
  ConsumerState<PipeLine> createState() => _PipeLineState();
}

class _PipeLineState extends ConsumerState<PipeLine> {
  List<Map<String, dynamic>> pipelineConfigStream = [];

  bool isLoading = true;
  @override
  void initState() {
    E2Client().session.sendCommand(
          ActionCommands.fullHeartbeat(
            targetId: widget.boxName,
            initiatorId: kAIXpWallet?.initiatorId,
          ),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: E2Listener(
        onHeartbeat: (payload) {
          final Map<String, dynamic> convertedMessage =
              MqttMessageEncoderDecoder.raw(payload);
          ref
              .read(nodePipelineProvider(widget.boxName).notifier)
              .updatePipelineList(
                convertedMessage: convertedMessage,
              );
          setState(() {
            isLoading = false;
          });
        },
        builder: (a) {
          return LoadingParentWidget(
            isLoading: isLoading,
            child: PipelineTabBodyWidget(
              boxName: widget.boxName,
            ),
          );
        },
      ),
    );
  }
}
