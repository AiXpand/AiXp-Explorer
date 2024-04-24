import 'package:collection/collection.dart';

import 'package:e2_explorer/dart_e2/utils/xpand_utils.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/provider/network_state.dart';

import 'package:riverpod/riverpod.dart';

final nodePipelineProvider = StateNotifierProvider.autoDispose
    .family<NodePipelineProvider, List<Map<String, dynamic>>, String>(
        (ref, String boxName) {
  return NodePipelineProvider(boxName);
});

class NodePipelineProvider extends StateNotifier<List<Map<String, dynamic>>> {
  final String boxName;

  String? selectedPipeline;
  String? selectedPlugin;

  NodePipelineProvider(this.boxName) : super([]);

  updateState(List data) {
    state = [...data.map((e) => e).toList()];
  }

  List<Map<String, dynamic>> get getPluginList {
    final pipelineData = state
        .firstWhereOrNull((element) => element['NAME'] == selectedPipeline);
    if (pipelineData != null) {
      var plugins = pipelineData['PLUGINS'] as List;
      return plugins
          .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
          .toList();
      // return plugins;
    }

    return [];
  }

  setSelectedPipeline(String selectedPipeline) {
    this.selectedPipeline = selectedPipeline;
    updateState(state);
  }

  setSelectedPlugin(String selectedPlugin) {
    this.selectedPlugin = selectedPlugin;
    updateState(state);
  }

  void updatePipelineList({required Map<String, dynamic> convertedMessage}) {
    final eePayloadPath = (convertedMessage['EE_PAYLOAD_PATH'] as List)
        .map((e) => e as String?)
        .toList();

    if (convertedMessage["EE_EVENT_TYPE"] == "HEARTBEAT" &&
        eePayloadPath[0] == boxName) {
      final bool isV2 = convertedMessage['HEARTBEAT_VERSION'] == 'v2';

      if (isV2) {
        final metadataEncoded = XpandUtils.decodeEncryptedGzipMessage(
            convertedMessage['ENCODED_DATA'])['CONFIG_STREAMS'] as List;
        updateState(metadataEncoded);
      }
    }
  }
}
