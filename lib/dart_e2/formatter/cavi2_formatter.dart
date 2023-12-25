import 'package:e2_explorer/dart_e2/formatter/models/cavi2_message.dart';
import 'package:e2_explorer/dart_e2/models/e2_message.dart';

class Cavi2Formatter {
  static E2Message cavi2ToRaw(Cavi2Message cavi2Message) {
    return E2Message(
      eventType: cavi2Message.type != null
          ? cavi2Message.type!.toUpperCase()
          : 'UNKNOWN_MESSAGE_TYPE',

      /// treat different if payload
      id: cavi2Message.sender.hostId!,
      eeTimestamp: cavi2Message.time.hostTime,
      totalMessages: cavi2Message.metadata.sbTotalMessages,
      messageId: cavi2Message.metadata.sbCurrentMessage,
      sbId: cavi2Message.metadata.sbId,
      sbEventType: cavi2Message.metadata.sbEventType,
      deviceStatus: cavi2Message.metadata.deviceStatus,
      machineIp: cavi2Message.metadata.machineIp,
      machineMemory: cavi2Message.metadata.machineMemory,
      availableMemory: cavi2Message.metadata.availableMemory,
      processMemory: cavi2Message.metadata.processMemory,
      cpuUsed: cavi2Message.metadata.cpuUsed,
      gpus: cavi2Message.metadata.gpus,
      gpuInfo: cavi2Message.metadata.gpuInfo,
      defaultCuda: cavi2Message.metadata.defaultCuda,
      cpu: cavi2Message.metadata.cpu,
      timestamp: cavi2Message.metadata.timestamp,
      currentTime: cavi2Message.metadata.currentTime,
      uptime: cavi2Message.metadata.uptime,
      version: cavi2Message.version,
      loggerVersion: cavi2Message.metadata.loggerVersion,
      totalDisk: cavi2Message.metadata.totalDisk,
      availableDisk: cavi2Message.metadata.availableDisk,
      activePlugins: cavi2Message.metadata.activePlugins,
      noInferences: cavi2Message.metadata.nrInferences,
      noPayloads: cavi2Message.metadata.nrPayloads,
      noStreamsData: cavi2Message.metadata.nrStreamsData,
      gitBranch: cavi2Message.metadata.gitBranch,
      condaEnv: cavi2Message.metadata.condaEnv,
      configPipelines: cavi2Message.metadata.configStreams,
      dctStats: cavi2Message.metadata.dctStats,
      commStats: cavi2Message.metadata.commStats,
      servingPids: cavi2Message.metadata.servingPids,
      loopsTimings: cavi2Message.metadata.loopsTimings,
      timers: cavi2Message.metadata.timers,
      deviceLog: cavi2Message.metadata.deviceLog,
      errorLog: cavi2Message.metadata.errorLog,
      initiatorId: cavi2Message.metadata.initiatorId,
      formatter: cavi2Message.eeFormatter,
    );
  }
}
