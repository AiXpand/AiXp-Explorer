import 'package:e2_explorer/dart_e2/models/utils_models/e2_active_plugin.dart';
import 'package:e2_explorer/dart_e2/models/utils_models/e2_comm_stats.dart';
import 'package:e2_explorer/dart_e2/models/utils_models/e2_config_pipelines.dart';
import 'package:e2_explorer/dart_e2/models/utils_models/e2_dct_stats.dart';
import 'package:e2_explorer/dart_e2/models/utils_models/e2_gpu.dart';
import 'package:e2_explorer/dart_e2/models/utils_models/e2_loop_timing.dart';

class Cavi2Metadata {
  final int sbTotalMessages;
  final int sbCurrentMessage;
  final String sbId;
  final String sbEventType;
  final String? deviceStatus;
  final String? machineIp;
  final double? machineMemory;
  final double? availableMemory;
  final double? processMemory;
  final double? cpuUsed;
  final List<E2Gpu> gpus;
  // final dynamic gpus;
  final String gpuInfo;
  final String defaultCuda;
  final String? cpu;
  final String timestamp;
  final DateTime currentTime;
  final double? uptime;
  final String version;
  final String loggerVersion;
  final double? totalDisk;
  final double? availableDisk;
  final List<E2ActivePlugin> activePlugins;
  final int nrInferences;
  final int nrPayloads;
  final int nrStreamsData;
  final String gitBranch;
  final String condaEnv;
  final E2ConfigPipelines configStreams;
  final E2DctStats dctStats;
  final E2CommStats commStats;
  final List<int> servingPids;
  final E2LoopTiming loopsTimings;
  final String timers;
  final String deviceLog;
  final String errorLog;
  final String? initiatorId;

  Cavi2Metadata({
    required this.sbTotalMessages,
    required this.sbCurrentMessage,
    required this.sbId,
    required this.sbEventType,
    required this.deviceStatus,
    required this.machineIp,
    required this.machineMemory,
    required this.availableMemory,
    required this.processMemory,
    required this.cpuUsed,
    required this.gpus,
    required this.gpuInfo,
    required this.defaultCuda,
    required this.cpu,
    required this.timestamp,
    required this.currentTime,
    required this.uptime,
    required this.version,
    required this.loggerVersion,
    required this.totalDisk,
    required this.availableDisk,
    required this.activePlugins,
    required this.nrInferences,
    required this.nrPayloads,
    required this.nrStreamsData,
    required this.gitBranch,
    required this.condaEnv,
    required this.configStreams,
    required this.dctStats,
    required this.commStats,
    required this.servingPids,
    required this.loopsTimings,
    required this.timers,
    required this.deviceLog,
    required this.errorLog,
    this.initiatorId,
  });

  factory Cavi2Metadata.fromMap(Map<String, dynamic> json) {
    return Cavi2Metadata(
      sbTotalMessages: json["sbTotalMessages"],
      sbCurrentMessage: json["sbCurrentMessage"],
      sbId: json["sb_id"],
      sbEventType: json["sb_event_type"],
      deviceStatus: json["device_status"] as String?,
      machineIp: json["machine_ip"] as String?,
      machineMemory: json["machine_memory"]?.toDouble(),
      availableMemory: json["available_memory"]?.toDouble(),
      processMemory: json["process_memory"]?.toDouble(),
      cpuUsed: json["cpu_used"]?.toDouble(),
      gpus: E2Gpu.fromList(json["gpus"]),
      // gpus: json['gpus'],
      gpuInfo: json["gpu_info"],
      defaultCuda: json["default_cuda"],
      cpu: json["cpu"],
      timestamp: json["timestamp"],
      currentTime: DateTime.parse(json["current_time"]),
      uptime: json["uptime"]?.toDouble(),
      version: json["version"],
      loggerVersion: json["logger_version"],
      totalDisk: json["total_disk"]?.toDouble(),
      availableDisk: json["available_disk"]?.toDouble(),
      activePlugins: List<E2ActivePlugin>.from(
          json["active_plugins"].map((x) => E2ActivePlugin.fromMap(x))),
      nrInferences: json["nr_inferences"],
      nrPayloads: json["nr_payloads"],
      nrStreamsData: json["nr_streams_data"],
      gitBranch: json["git_branch"],
      condaEnv: json["conda_env"],
      configStreams: E2ConfigPipelines.fromList(json["config_streams"] as List),
      dctStats: E2DctStats.fromMap(json['dct_stats']),
      commStats: E2CommStats.fromMap(json['comm_stats']),
      servingPids: List<int>.from(json["serving_pids"].map((x) => x)),
      loopsTimings: E2LoopTiming.fromMap(json["loops_timings"]),
      timers: json["timers"],
      deviceLog: json["device_log"],
      errorLog: json["error_log"],
      initiatorId: json["initiator_id"] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        "sbTotalMessages": sbTotalMessages,
        "sbCurrentMessage": sbCurrentMessage,
        "sb_id": sbId,
        "sb_event_type": sbEventType,
        "device_status": deviceStatus,
        "machine_ip": machineIp,
        "machine_memory": machineMemory,
        "available_memory": availableMemory,
        "process_memory": processMemory,
        "cpu_used": cpuUsed,
        "gpus": List<dynamic>.from(gpus.map((x) => x.toMap())),
        // "gpus": gpus,
        "gpu_info": gpuInfo,
        "default_cuda": defaultCuda,
        "cpu": cpu,
        "timestamp": timestamp,
        "current_time": currentTime.toIso8601String(),
        "uptime": uptime,
        "version": version,
        "logger_version": loggerVersion,
        "total_disk": totalDisk,
        "available_disk": availableDisk,
        "active_plugins":
            List<dynamic>.from(activePlugins.map((x) => x.toMap())),
        "nr_inferences": nrInferences,
        "nr_payloads": nrPayloads,
        "nr_streams_data": nrStreamsData,
        "git_branch": gitBranch,
        "conda_env": condaEnv,
        "config_streams": configStreams.toListMap(),
        "dct_stats": dctStats.toMap(),
        "comm_stats": commStats.toMap(),
        "serving_pids": List<dynamic>.from(servingPids.map((x) => x)),
        "loops_timings": loopsTimings.toMap(),
        "timers": timers,
        "device_log": deviceLog,
        "error_log": errorLog,
        "initiator_id": initiatorId,
      };
}
