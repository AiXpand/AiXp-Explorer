import 'package:e2_explorer/dart_e2/commands/e2_commands.dart';
import 'package:e2_explorer/main.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/model/node_history_model.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/provider/network_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final resourceProvider = StateNotifierProvider<ResourceProvider, ResourceState>(
    (ref) => ResourceProvider(ref));

class ResourceState {
  final bool isLoading;
  final NodeHistoryModel? nodeHistoryModel;
  final bool isError;

  ResourceState({
    required this.isLoading,
    this.nodeHistoryModel,
    this.isError = false,
  });

  ResourceState copyWith({
    bool? isLoading,
    NodeHistoryModel? nodeHistoryModel,
    bool? isError,
  }) {
    return ResourceState(
      isLoading: isLoading ?? this.isLoading,
      nodeHistoryModel: nodeHistoryModel ?? this.nodeHistoryModel,
      isError: isError ?? this.isError,
    );
  }
}

class ResourceProvider extends StateNotifier<ResourceState> {
  final Ref ref;
  final _signature = 'NET_MON_01';
  final _name = "admin_pipeline";
  final _instanceId = "NET_MON_01_INST";
  final E2Client _client = E2Client();
  final int steps = 100;

  // NetworkProvider() : super(NetworkState.initial());

  ResourceProvider(this.ref) : super(ResourceState(isLoading: false));

  void toggleLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  void nodeHistoryCommand({required String node}) {
    toggleLoading(true);

    final provider = ref.read(networkProvider);
    _client.session.sendCommand(
      ActionCommands.updatePipelineInstance(
        targetId: provider.supervisorIds.isNotEmpty
            ? provider.supervisorIds.first
            : node,
        payload: E2InstanceConfig(
          name: 'admin_pipeline',
          signature: 'NET_MON_01',
          instanceId: 'NET_MON_01_INST',
          instanceConfig: {
            "INSTANCE_COMMAND": {
              "node": node,
              "request": "history",
              "options": {"steps": steps}
            }
          },
        ),
        initiatorId: kAIXpWallet?.initiatorId,
      ),
    );
  }

  Future<void> checkNotifications({
    required Map<String, dynamic> convertedMessage,
    required String boxName,
  }) async {
    final eePayloadPath = (convertedMessage['EE_PAYLOAD_PATH'] as List)
        .map((e) => e as String?)
        .toList();

    if (eePayloadPath[0] == ref.read(networkProvider).supervisorIds.first &&
        eePayloadPath[1] == "admin_pipeline" &&
        eePayloadPath[2] == "NET_MON_01" &&
        eePayloadPath[3] == "NET_MON_01_INST") {
      debugPrint(convertedMessage["NOTIFICATION"]);
      if (convertedMessage["NOTIFICATION"] ==
          "Command {'node': '$boxName', 'options': {'steps': $steps}, 'request': 'history'} failed.") {
        debugPrint(convertedMessage["NOTIFICATION"]);
        ("Errror gettig  node histrory");
        state = state.copyWith(isError: true);
        toggleLoading(false);
      }
    }
  }

  Future<void> getResources({
    required Map<String, dynamic> convertedMessage,
    required String boxName,
  }) async {
    final eePayloadPath = (convertedMessage['EE_PAYLOAD_PATH'] as List)
        .map((e) => e as String?)
        .toList();

    if (convertedMessage['E2_TARGET_ID'] == boxName &&
        eePayloadPath[1] == _name &&
        eePayloadPath[2] == _signature &&
        eePayloadPath[3] == _instanceId &&
        convertedMessage.containsKey('NODE_HISTORY')) {
      toggleLoading(true);
      print(convertedMessage['INITIATOR_ID']);

      convertedMessage.removeWhere((key, value) => value == null);
      final nodeHistoryModel = NodeHistoryModel.fromJson(convertedMessage);
      state = state.copyWith(
        isLoading: false,
        nodeHistoryModel: nodeHistoryModel,
      );
    }
  }
}
