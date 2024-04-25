import 'dart:math';
import 'package:collection/collection.dart';

import 'package:e2_explorer/dart_e2/utils/xpand_utils.dart';

import 'package:riverpod/riverpod.dart';

class NodePipelineState {
  final List<Map<String, dynamic>> data;
  final bool isLoading;

  NodePipelineState({
    required this.isLoading,
    required this.data,
  });

  NodePipelineState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? data,
  }) {
    return NodePipelineState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
    );
  }
}

class SelectedPipelinePluginState {}

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
    final pluginData = state
        .firstWhereOrNull((element) => element['NAME'] == selectedPipeline);
    if (pluginData != null) {
      var plugins = pluginData['PLUGINS'] as List;
      return plugins
          .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
          .toList();
    }

    return [];
  }

  List<Map<String, dynamic>> get getInstanceConfig {
    final instanceConfigData = getPluginList
        .firstWhereOrNull((element) => element['SIGNATURE'] == selectedPlugin);
    if (instanceConfigData != null) {
      var plugins = instanceConfigData['INSTANCES'] as List;
      return plugins
          .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
          .toList();
    }

    return [];
  }

  setSelectedPipeline(String selectedPipeline) {
    this.selectedPipeline = selectedPipeline;
    selectedPlugin = null;
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
        final decodedData = XpandUtils.decodeEncryptedGzipMessage(
            convertedMessage['ENCODED_DATA']);
        final metadataEncoded = decodedData['CONFIG_STREAMS'] as List;
        updateState(metadataEncoded);
      }
    }
  }
}
