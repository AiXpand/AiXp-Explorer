import 'package:e2_explorer/dart_e2/formatter/format_decoder.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/features/node_dashboard/presentation/pages/resources/provider/resource_provider.dart';
import 'package:e2_explorer/src/widgets/chats_widgets/bar_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../styles/color_styles.dart';
import '../../../../../widgets/chats_widgets/line_chart_widget.dart';

class ResourcesTab extends ConsumerStatefulWidget {
  const ResourcesTab({
    super.key,
    required this.boxName,
  });
  final String boxName;
  static getResourceTab() {}
  @override
  ConsumerState<ResourcesTab> createState() => _ResourcesTabState();
}

class _ResourcesTabState extends ConsumerState<ResourcesTab> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref
          .read(resourceProvider.notifier)
          .nodeHistoryCommand(node: widget.boxName);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resourceProvider);
    print("${state.isLoading} ${state.nodeHistoryModel}");
    return E2Listener(
      onPayload: (payload) {
        final Map<String, dynamic> convertedMessage =
            MqttMessageEncoderDecoder.raw(payload);

        ref.read(resourceProvider.notifier).getResources(
              convertedMessage: convertedMessage,
              boxName: widget.boxName,
            );
      },
      builder: (context) {
        return state.isLoading || state.nodeHistoryModel == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: LineChartWidget(
                              data: state
                                  .nodeHistoryModel!.nodeHistory.gpuLoadHist
                                  .map((e) => e.toDouble())
                                  .toList(),
                              timestamps: state.nodeHistoryModel!.nodeHistory
                                  .convertedTimeStamps,
                              title: 'GPU Load',
                              borderColor: AppColors.lineChartGreenBorderColor,
                              gradient: AppColors.lineChartGreenGradient,
                            ),
                          ),
                          const SizedBox(width: 34),
                          Expanded(
                            child: LineChartWidget(
                              timestamps: state.nodeHistoryModel!.nodeHistory
                                  .convertedTimeStamps,
                              data: state.nodeHistoryModel!.nodeHistory.cpuHist
                                  .map((e) => e.toDouble())
                                  .toList(),
                              title: 'CPU',
                              borderColor:
                                  AppColors.lineChartMagentaBorderColor,
                              gradient: AppColors.lineChartMagentaGradient,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 34),
                      Row(
                        children: [
                          Expanded(
                            child: LineChartWidget(
                              timestamps: state.nodeHistoryModel!.nodeHistory
                                  .convertedTimeStamps,
                              data: state
                                  .nodeHistoryModel!.nodeHistory.gpuMemAvailHist
                                  .map((e) => e.toDouble())
                                  .toList(),
                              title: 'GPU Memory',
                              borderColor: AppColors.lineChartPinkBorderColor,
                              gradient: AppColors.lineChartPinkGradient,
                            ),
                          ),
                          const SizedBox(width: 34),
                          Expanded(
                            child: LineChartWidget(
                              data: state
                                  .nodeHistoryModel!.nodeHistory.memAvailHist
                                  .map((e) => e.toDouble())
                                  .toList(),
                              timestamps: state.nodeHistoryModel!.nodeHistory
                                  .convertedTimeStamps,
                              title: 'RAM',
                              borderColor: AppColors.lineChartGreenBorderColor,
                              gradient: AppColors.lineChartGreenGradient,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 34),
                      Row(
                        children: [
                          Expanded(
                              child: BarChartWidget(
                            title: "Disk",
                            totalDiskSize: state
                                .nodeHistoryModel!.nodeHistory.totalDisk
                                .toDouble(),
                            totalMemorySize: state
                                .nodeHistoryModel!.nodeHistory.totalMem
                                .toDouble(),
                          )),
                          const SizedBox(width: 34),
                          const Expanded(
                            child: SizedBox(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
