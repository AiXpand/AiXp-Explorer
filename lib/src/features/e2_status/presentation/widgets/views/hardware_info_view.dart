import 'package:e2_explorer/dart_e2/models/utils_models/e2_heartbeat.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener_filters.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/charts/usage_chart.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/common/info_card.dart';
import 'package:flutter/material.dart';

class HardwareInfoView extends StatefulWidget {
  const HardwareInfoView({
    super.key,
    required this.boxName,
  });

  final String boxName;

  @override
  State<HardwareInfoView> createState() => _HardwareInfoViewState();
}

class _HardwareInfoViewState extends State<HardwareInfoView> {
  final E2Client _client = E2Client();

  List<E2Heartbeat> heartbeatHistory = [];

  @override
  void initState() {
    super.initState();
    heartbeatHistory =
        _client.boxMessages[widget.boxName]?.heartbeatMessages ?? [];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return E2Listener(
      onHeartbeat: (data) {
        // print('Hb received on hw info view');
        setState(() {
          heartbeatHistory =
              _client.boxMessages[widget.boxName]?.heartbeatMessages ?? [];
        });
      },
      dataFilter: E2ListenerFilters.filterByBox(widget.boxName),
      builder: (BuildContext context) {
        // print(_client.boxMessages[widget.boxName]?.heartbeatDecodedMessages.length);
        if (heartbeatHistory.isEmpty) {
          return const Center(
            child: Text(
              'No hb received',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          );
        }
        final lastHeartbeat = heartbeatHistory.last;
        return Container(
          width: double.infinity,
          color: const Color(0xff161616),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: const Color(0xff282828),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Box version: ${lastHeartbeat.version}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const Divider(
                                  color: Colors.white,
                                ),
                                Text(
                                  'Box name: ${lastHeartbeat.boxId}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const Divider(
                                  color: Colors.white,
                                ),
                                Text(
                                  'IP: ${lastHeartbeat.machineIp}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const Divider(
                                  color: Colors.white,
                                ),
                                const Text(
                                  // 'Machine time: ${DateFormat('hh:mm a').format(lastHeartbeat.currentTime!)}',
                                  'Feature removed at the moment from explorer',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          InfoCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DISK: ${lastHeartbeat.availableDisk.toString()}GB free out of ${lastHeartbeat.totalDisk.toString()}GB',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (lastHeartbeat.totalDisk != null &&
                                    lastHeartbeat.availableDisk != null)
                                  LinearProgressIndicator(
                                    color: Colors.green,
                                    backgroundColor: Colors.teal,
                                    value: (lastHeartbeat.totalDisk! -
                                            lastHeartbeat.availableDisk!) /
                                        lastHeartbeat.totalDisk!,
                                  ),
                              ],
                            ),
                          ),
                          InfoCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lastHeartbeat.cpu ?? 'No cpu name available',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                UsageChart(
                                  values: heartbeatHistory
                                      .map((e) => e.cpuUsed ?? 0)
                                      .toList(),
                                  maxValue: 100,
                                  maxSamplesNo: 50,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          InfoCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Memory: ${lastHeartbeat.availableMemory.toString()}GB free out of ${lastHeartbeat.machineMemory.toString()}GB',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                UsageChart(
                                  values: heartbeatHistory
                                      .map((e) => ((e.machineMemory! -
                                          e.availableMemory!)))
                                      .toList(),
                                  maxValue: lastHeartbeat.machineMemory!
                                      .ceilToDouble(),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: InfoCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    'GPUS',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          ...lastHeartbeat.gpus
                                              .asMap()
                                              .entries
                                              .map(
                                                (gpu) => InfoCard(
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        gpu.value.name,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      UsageChart(
                                                        height: 100,
                                                        values: heartbeatHistory
                                                            .map((message) =>
                                                                message
                                                                    .gpus[
                                                                        gpu.key]
                                                                    .allocatedMem
                                                                    .toDouble())
                                                            .toList(),
                                                        maxValue: lastHeartbeat
                                                            .gpus[gpu.key]
                                                            .totalMem
                                                            .ceilToDouble(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
