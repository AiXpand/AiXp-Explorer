import 'package:collection/collection.dart';
import 'package:e2_explorer/dart_e2/utils/xpand_utils.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/model/plugin_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

final nodePipelineProvider = StateNotifierProvider.family<NodePipelineProvider,
    List<DecodedPlugin>, String>((ref, String boxName) {
  return NodePipelineProvider(boxName, ref);
});

class NodePipelineProvider extends StateNotifier<List<DecodedPlugin>> {
  final String boxName;
  final Ref ref;

  NodePipelineProvider(this.boxName, this.ref) : super([]);

  updateState(List<DecodedPlugin> data) {
    state = [...data];
  }

  List<Map<String, dynamic>> getPluginList(
      {required String? selectedPipeline}) {
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

  List<Map<String, dynamic>> getInstanceConfig(
      {required String? selectedPipeline, required String? selectedPlugin}) {
    final pluginList = getPluginList(selectedPipeline: selectedPipeline);
    final instanceConfigData = pluginList
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
    ref
        .read(selectedPipelineItemProvider.notifier)
        .setSelectedPipeline(selectedPipeline);
    ref
        .read(selectedPipelineItemProvider.notifier)
        .setItemNull(PipelineItems.plugin);
  }

  setSelectedPlugin(String selectedPlugin) {
    ref
        .read(selectedPipelineItemProvider.notifier)
        .setSelectedPlugin(selectedPlugin);

    updateState(state);
  }

  resetSelectedState() {
    ref
        .read(selectedPipelineItemProvider.notifier)
        .setItemNull(PipelineItems.pipeline);
    ref
        .read(selectedPipelineItemProvider.notifier)
        .setItemNull(PipelineItems.plugin);
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

class SelectedPipleineItemProvider extends StateNotifier<SelectedItemState> {
  SelectedPipleineItemProvider() : super(SelectedItemState.initials());

  void setSelectedPlugin(String? selectedPlugin) {
    state = state.copyWith(selectedPlugin: selectedPlugin);
  }

  void setSelectedPipeline(String? selectedPipeline) {
    state = state.copyWith(selectedPipeline: selectedPipeline);
  }

  void setItemNull(PipelineItems item) {
    state = state.setItemNull(item);
  }
}

final selectedPipelineItemProvider =
    StateNotifierProvider<SelectedPipleineItemProvider, SelectedItemState>(
        (ref) {
  return SelectedPipleineItemProvider();
});

class SelectedItemState {
  final String? selectedPipeline;
  final String? selectedPlugin;

  SelectedItemState({this.selectedPipeline, this.selectedPlugin});

  SelectedItemState.initials()
      : selectedPipeline = null,
        selectedPlugin = null;

  SelectedItemState copyWith(
      {String? selectedPipeline, String? selectedPlugin}) {
    return SelectedItemState(
      selectedPipeline: selectedPipeline ?? this.selectedPipeline,
      selectedPlugin: selectedPlugin ?? this.selectedPlugin,
    );
  }

  SelectedItemState setItemNull(PipelineItems item) {
    return SelectedItemState(
      selectedPipeline:
          item == PipelineItems.pipeline ? null : selectedPipeline,
      selectedPlugin: item == PipelineItems.plugin ? null : selectedPlugin,
    );
  }
}

enum PipelineItems { pipeline, plugin }
