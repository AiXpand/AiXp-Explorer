import 'package:collection/collection.dart';
import 'package:e2_explorer/dart_e2/utils/xpand_utils.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/model/plugin_model.dart';
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

final nodePipelineProvider = StateNotifierProvider.family<NodePipelineProvider,
    List<DecodedPlugin>, String>((ref, String boxName) {
  return NodePipelineProvider(boxName);
});

class NodePipelineProvider extends StateNotifier<List<DecodedPlugin>> {
  final String boxName;

  String? selectedPipeline;

  String? selectedPlugin;

  NodePipelineProvider(this.boxName) : super([]);

  updateState(List<DecodedPlugin> data) {
    state = [...data];
  }

  List<Map<String, dynamic>> get getPluginList {
    final pluginData =
        state.firstWhereOrNull((element) => element.name == selectedPipeline);
    if (pluginData != null) {
      var plugins = pluginData.plugins;
      return plugins
              ?.map<Map<String, dynamic>>((e) => e?.toJson() ?? {})
              .toList() ??
          [];
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

  resetSelectedState() {
    selectedPipeline = null;
    selectedPlugin = null;
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
        print(metadataEncoded);
        try {
          updateState(
            metadataEncoded
                .map<DecodedPlugin>((e) => DecodedPlugin.fromJson(e))
                .toList(),
          );
        } catch (e, _) {
          print(e);
        }
      }
    }
  }
}
