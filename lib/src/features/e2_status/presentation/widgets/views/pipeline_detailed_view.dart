import 'package:collection/collection.dart';
import 'package:e2_explorer/dart_e2/models/utils_models/e2_heartbeat.dart';
import 'package:e2_explorer/src/features/common_widgets/tree_list/single_level_tree_list/single_level_tree_view.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener_filters.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/views/widgets/pipeline_viewer.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/views/widgets/plugin_viewer.dart';
import 'package:flutter/material.dart';

class PipelineDetailedView extends StatefulWidget {
  const PipelineDetailedView({
    super.key,
    required this.boxName,
  });

  final String boxName;

  @override
  State<PipelineDetailedView> createState() => _PipelineDetailedViewState();
}

class _PipelineDetailedViewState extends State<PipelineDetailedView> {
  final E2Client _client = E2Client();

  String? selectedPipelineName;
  String? selectedPluginId;

  E2Heartbeat? currentHeartbeat;

  @override
  void initState() {
    super.initState();
    currentHeartbeat =
        _client.boxMessages[widget.boxName]?.heartbeatMessages.lastOrNull;
  }

  @override
  void didUpdateWidget(PipelineDetailedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (oldWidget.currentHeartbeatMap != widget.currentHeartbeatMap) {
    //   selectedPipelineName = null;
    //   selectedPipelineType = null;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return E2Listener(
      onHeartbeat: (data) {
        setState(() {
          currentHeartbeat =
              _client.boxMessages[widget.boxName]?.heartbeatMessages.lastOrNull;
        });
      },
      dataFilter: E2ListenerFilters.filterByBox(widget.boxName),
      builder: (context) {
        if (currentHeartbeat == null) {
          return const Center(
            child: Text(
              'No heartbeat received',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        // final pipelines = currentHeartbeat!.configPipelines.allPipelines;
        final pipelinesMapList = (currentHeartbeat!.configPipelines as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        return Container(
          width: double.infinity,
          color: const Color(0xff161616),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: SingleLevelTreeView(
                    pipelineMessages: pipelinesMapList,
                    onPipelineSelected: (pipelineName) {
                      setState(() {
                        selectedPipelineName = pipelineName;
                        selectedPluginId = null;
                      });
                    },
                    onPluginSelected: (pluginName, pipelineName) {
                      setState(() {
                        selectedPipelineName = pipelineName;
                        selectedPluginId = pluginName;
                      });
                    },
                  ),
                  // child: ListView.builder(
                  //   shrinkWrap: true,
                  //   itemBuilder: (context, index) {
                  //     return InkWell(
                  //       //key: ValueKey(message['messageID']),
                  //       onTap: () {
                  //         setState(() {
                  //           selectedPipelineName = pipelines[index].name;
                  //           selectedPipelineType = pipelines[index].type;
                  //         });
                  //       },
                  //       child: Container(
                  //         color: selectedPipelineName == pipelines[index].name &&
                  //                 selectedPipelineType == pipelines[index].type
                  //             ? const Color(0xff2A3A6F)
                  //             : ColorStyles.dark800,
                  //         height: 30,
                  //         child: Padding(
                  //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               Text(
                  //                 pipelines[index].name,
                  //                 style: const TextStyle(
                  //                   color: Colors.white38,
                  //                 ),
                  //               ),
                  //               Text(
                  //                 pipelines[index].type,
                  //                 style: const TextStyle(
                  //                   color: Colors.white38,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //   itemCount: pipelines.length,
                  // ),
                ),
                const VerticalDivider(
                  color: Colors.white10,
                ),
                Expanded(
                  flex: 2,
                  child: selectedPipelineName != null &&
                          selectedPluginId != null &&
                          currentHeartbeat != null
                      ? Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: const Color(0xff161616),
                          child: PluginViewer(
                            heartbeat: currentHeartbeat!,
                            selectedPlugin: selectedPluginId!,
                            selectedPipeline: selectedPipelineName!,
                          ),
                        )
                      : selectedPipelineName != null && currentHeartbeat != null
                          ? SizedBox(
                              width: double.infinity,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: PipelineViewer(
                                  pipelineBody: pipelinesMapList.firstWhere(
                                      (element) =>
                                          element['NAME'] ==
                                          selectedPipelineName),
                                ),
                              ),
                            )
                          : const Center(
                              child: Text(
                                'No pipeline selected',
                                style: TextStyle(
                                  color: Colors.white38,
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
