import 'package:e2_explorer/dart_e2/models/utils_models/e2_active_plugin.dart';
import 'package:e2_explorer/dart_e2/models/utils_models/e2_comm_stats.dart';
import 'package:e2_explorer/dart_e2/models/utils_models/e2_config_pipelines.dart';
import 'package:e2_explorer/dart_e2/models/utils_models/e2_dct_stats.dart';
import 'package:e2_explorer/dart_e2/models/utils_models/e2_gpu.dart';
import 'package:e2_explorer/dart_e2/models/utils_models/e2_loop_timing.dart';

class E2Message {
  final String eventType;
  final String id;
  final DateTime? eeTimestamp;
  final int totalMessages;
  final int messageId;
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
  final DateTime? currentTime;
  final double? uptime;
  final String version;
  final String loggerVersion;
  final double? totalDisk;
  final double? availableDisk;
  final List<E2ActivePlugin> activePlugins;
  final int noInferences;
  final int noPayloads;
  final int noStreamsData;
  final String gitBranch;
  final String condaEnv;
  final E2ConfigPipelines configPipelines;
  final E2DctStats dctStats;
  final E2CommStats commStats;
  final List<int> servingPids;
  final E2LoopTiming loopsTimings;
  final String timers;
  final String deviceLog;
  final String errorLog;
  final String? initiatorId;
  final String? formatter;

  E2Message({
    required this.eventType,
    required this.id,
    required this.eeTimestamp,
    required this.totalMessages,
    required this.messageId,
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
    required this.noInferences,
    required this.noPayloads,
    required this.noStreamsData,
    required this.gitBranch,
    required this.condaEnv,
    required this.configPipelines,
    required this.dctStats,
    required this.commStats,
    required this.servingPids,
    required this.loopsTimings,
    required this.timers,
    required this.deviceLog,
    required this.errorLog,
    required this.initiatorId,
    this.formatter,
  });

  Map<String, dynamic> toMap() {
    return {
      'EE_EVENT_TYPE': eventType,
      'EE_ID': id,
      'EE_TIMESTAMP': eeTimestamp?.toIso8601String(),
      'EE_TOTAL_MESSAGES': totalMessages,
      'EE_MESSAGE_ID': messageId,
      'SB_ID': sbId,
      'SB_EVENT_TYPE': sbEventType,
      'DEVICE_STATUS': deviceStatus,
      'MACHINE_IP': machineIp,
      'MACHINE_MEMORY': machineMemory,
      'AVAILABLE_MEMORY': availableMemory,
      'PROCESS_MEMORY': processMemory,
      'CPU_USED': cpuUsed,
      'GPUS': E2Gpu.toListMap(gpus),
      // 'GPUS': gpus,
      'GPU_INFO': gpuInfo,
      'DEFAULT_CUDA': defaultCuda,
      'CPU': cpu,
      'TIMESTAMP': timestamp,
      'CURRENT_TIME': currentTime?.toIso8601String(),
      'UPTIME': uptime,
      'VERSION': version,
      'LOGGER_VERSION': loggerVersion,
      'TOTAL_DISK': totalDisk,
      'AVAILABLE_DISK': availableDisk,
      'ACTIVE_PLUGINS': E2ActivePlugin.toListMap(activePlugins),
      'NR_INFERENCES': noInferences,
      'NR_PAYLOADS': noPayloads,
      'NR_STREAMS_DATA': noStreamsData,
      'GIT_BRANCH': gitBranch,
      'CONDA_ENV': condaEnv,
      'CONFIG_STREAMS': configPipelines.toListMap(),
      'DCT_STATS': dctStats.toMap(),
      'COMM_STATS': commStats.toMap(),
      'SERVING_PIDS': servingPids,
      'LOOPS_TIMINGS': loopsTimings.toMap(),
      'TIMERS': timers,
      'DEVICE_LOG': deviceLog,
      'ERROR_LOG': errorLog,
      'INITIATOR_ID': initiatorId,
      'EE_FORMATTER': formatter,
    };
  }

  factory E2Message.fromMap(Map<String, dynamic> map) {
    return E2Message(
      eventType: map['EE_EVENT_TYPE'] as String,
      id: map['EE_ID'] as String,
      eeTimestamp:
          (map['EE_TIMESTAMP'] as String).isEmpty || map["EE_TIMESTAMP"] == null
              ? null
              : DateTime.parse(map["EE_TIMESTAMP"]),
      totalMessages: map['EE_TOTAL_MESSAGES'] as int,
      messageId: map['EE_MESSAGE_ID'] as int,
      sbId: map['SB_ID'] as String,
      sbEventType: map['SB_EVENT_TYPE'] as String,
      deviceStatus: map['DEVICE_STATUS'] as String?,
      machineIp: map['MACHINE_IP'] as String?,
      machineMemory: map['MACHINE_MEMORY'] as double?,
      availableMemory: map['AVAILABLE_MEMORY'] as double?,
      processMemory: map['PROCESS_MEMORY'] as double,
      cpuUsed: map['CPU_USED'] as double,
      gpus: E2Gpu.fromList(map['GPUS'] as List),
      // gpus: map['GPUS'],
      gpuInfo: map['GPU_INFO'] as String,
      defaultCuda: map['DEFAULT_CUDA'] as String,
      cpu: map['CPU'] as String,
      timestamp: map['TIMESTAMP'] as String,
      currentTime:
          (map['CURRENT_TIME'] as String).isEmpty || map["CURRENT_TIME"] == null
              ? null
              : DateTime.parse(map["CURRENT_TIME"]),
      uptime: map['UPTIME'] as double,
      version: map['VERSION'] as String,
      loggerVersion: map['LOGGER_VERSION'] as String,
      totalDisk: map['TOTAL_DISK'] as double,
      availableDisk: map['AVAILABLE_DISK'] as double,
      activePlugins: E2ActivePlugin.fromList(map['ACTIVE_PLUGINS'] as List),
      noInferences: map['NR_INFERENCES'] as int,
      noPayloads: map['NR_PAYLOADS'] as int,
      noStreamsData: map['NR_STREAMS_DATA'] as int,
      gitBranch: map['GIT_BRANCH'] as String,
      condaEnv: map['CONDA_ENV'] as String,
      configPipelines:
          E2ConfigPipelines.fromList(map['CONFIG_STREAMS'] as List),
      dctStats: E2DctStats.fromMap(map['DCT_STATS']),
      commStats: E2CommStats.fromMap(map['COMM_STATS']),
      servingPids: map['SERVING_PIDS'] as List<int>,
      loopsTimings: E2LoopTiming.fromMap(map['LOOPS_TIMINGS']),
      timers: map['TIMERS'] as String,
      deviceLog: map['DEVICE_LOG'] as String,
      errorLog: map['ERROR_LOG'] as String,
      initiatorId: map['INITIATOR_ID'] as String?,
      formatter: map['EE_FORMATTER'] as String?,
    );
  }
}
