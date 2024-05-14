import 'package:e2_explorer/dart_e2/models/payload/netmon/netmon_box_details.dart';

class NetworkState {
  final Map<String, dynamic>? serverData;
  final bool isLoading;
  final String? currentSupervisor;
  final List<NetmonBox> netmonStatusList;
  final Map<String, NetmonBoxDetails> netmonStatus;
  final List<String> supervisorIds;
  final bool refreshReady;

  List<NetmonBox> get onlineNetmon {
    return netmonStatusList
        .where((e) => e.details.working.toLowerCase() != 'lost status')
        .toList();
  }

  NetworkState({
    required this.serverData,
    required this.isLoading,
    required this.currentSupervisor,
    required this.netmonStatusList,
    required this.netmonStatus,
    required this.supervisorIds,
    required this.refreshReady,
  });

  factory NetworkState.initial() {
    return NetworkState(
      serverData: null,
      isLoading: true,
      currentSupervisor: null,
      netmonStatusList: [],
      netmonStatus: {},
      supervisorIds: [],
      refreshReady: true,
    );
  }

  NetworkState copyWith({
    Map<String, dynamic>? serverData,
    bool? isLoading,
    String? currentSupervisor,
    List<NetmonBox>? netmonStatusList,
    Map<String, NetmonBoxDetails>? netmonStatus,
    List<String>? supervisorIds,
    bool? refreshReady,
  }) {
    return NetworkState(
      serverData: serverData ?? this.serverData,
      isLoading: isLoading ?? this.isLoading,
      currentSupervisor: currentSupervisor ?? this.currentSupervisor,
      netmonStatusList: netmonStatusList ?? this.netmonStatusList,
      netmonStatus: netmonStatus ?? this.netmonStatus,
      supervisorIds: supervisorIds ?? this.supervisorIds,
      refreshReady: refreshReady ?? this.refreshReady,
    );
  }
}
