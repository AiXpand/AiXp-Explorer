import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener_filters.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

class StressTestCpuMonitor extends StatefulWidget {
  const StressTestCpuMonitor({super.key});

  @override
  State<StressTestCpuMonitor> createState() => _StressTestCpuMonitorState();
}

class _StressTestCpuMonitorState extends State<StressTestCpuMonitor> {
  final E2Client _client = E2Client();

  @override
  Widget build(BuildContext context) {
    return E2Listener(
      onHeartbeat: (data) {
        setState(() {});
      },
      dataFilter: E2ListenerFilters.excludeNameContains('stress_test_'),
      builder: (context) {
        return ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final boxName = _client.boxMessages.keys.toList()[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Builder(builder: (context) {
                final box = _client.boxMessages[boxName]!;
                final hb = box.heartbeatDecodedMessages.lastOrNull;
                final memoryUsed = hb == null
                    ? null
                    : (hb.machineMemory ?? 0) - (hb.availableMemory ?? 0);
                return Text(
                  'Box ${box.boxName} : CPU - ${box.heartbeatDecodedMessages.lastOrNull?.cpuUsed ?? 'N/A'} %, RAM - ${memoryUsed?.round()} GB used',
                  style: TextStyles.body(),
                );
              }),
            );
          },
          separatorBuilder: (context, index) {
            return Container();
          },
          itemCount: _client.boxMessages.keys.length,
        );
      },
    );
  }
}
