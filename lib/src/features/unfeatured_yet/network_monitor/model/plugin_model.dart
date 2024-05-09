class PluginModel {
  final String? eeFormatter;
  final String? eeSign;
  final String? eeSender;
  final String? eeHash;
  final List<dynamic>? eePayloadPath;
  final String? eeEventType;
  final String? eeId;
  final String? eeTimestamp;
  final int? eeTotalMessages;
  final String? eeMessageId;
  final int? eeMessageSeq;
  final String? eeTimezone;
  final String? eeTz;
  final String? encodedData;
  final String? heartbeatVersion;

  PluginModel({
    this.eeFormatter,
    this.eeSign,
    this.eeSender,
    this.eeHash,
    this.eePayloadPath,
    this.eeEventType,
    this.eeId,
    this.eeTimestamp,
    this.eeTotalMessages,
    this.eeMessageId,
    this.eeMessageSeq,
    this.eeTimezone,
    this.eeTz,
    this.encodedData,
    this.heartbeatVersion,
  });

  factory PluginModel.fromJson(Map<String, dynamic> json) {
    try {
      return PluginModel(
        eeFormatter: json['EE_FORMATTER'],
        eeSign: json['EE_SIGN'],
        eeSender: json['EE_SENDER'],
        eeHash: json['EE_HASH'],
        eePayloadPath: json['EE_PAYLOAD_PATH'],
        eeEventType: json['EE_EVENT_TYPE'],
        eeId: json['EE_ID'],
        eeTimestamp: json['EE_TIMESTAMP'],
        eeTotalMessages: json['EE_TOTAL_MESSAGES'],
        eeMessageId: json['EE_MESSAGE_ID'],
        eeMessageSeq: json['EE_MESSAGE_SEQ'],
        eeTimezone: json['EE_TIMEZONE'],
        eeTz: json['EE_TZ'],
        encodedData: json['ENCODED_DATA'],
        heartbeatVersion: json['HEARTBEAT_VERSION'],
      );
    } catch (e) {
      throw Exception('Error parsing PluginModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'eeFormatter': eeFormatter,
      'eeSign': eeSign,
      'eeSender': eeSender,
      'eeHash': eeHash,
      'eePayloadPath': eePayloadPath,
      'eeEventType': eeEventType,
      'eeId': eeId,
      'eeTimestamp': eeTimestamp,
      'eeTotalMessages': eeTotalMessages,
      'eeMessageId': eeMessageId,
      'eeMessageSeq': eeMessageSeq,
      'eeTimezone': eeTimezone,
      'eeTz': eeTz,
      'encodedData': encodedData,
      'HEARTBEAT_VERSION': heartbeatVersion,
    };
  }
}

class DecodedPlugin {
  String? reconnectable;
  String? url;
  bool? liveFeed;
  String name;
  List<Plugin?>? plugins;
  String? sessionId;
  String type;
  bool? validated;

  DecodedPlugin({
    required this.reconnectable,
    required this.url,
    required this.liveFeed,
    required this.name,
    required this.plugins,
    this.sessionId,
    required this.type,
    required this.validated,
  });

  factory DecodedPlugin.fromJson(Map<String, dynamic> json) {
    try {
      return DecodedPlugin(
        reconnectable: json['RECONNECTABLE'],
        url: json['URL'],
        liveFeed: json['LIVE_FEED'],
        name: json['NAME'],
        plugins: json['PLUGINS'] != null
            ? List<Plugin>.from(json['PLUGINS'].map((x) => Plugin.fromJson(x)))
            : [],
        sessionId: json['SESSION_ID'],
        type: json['TYPE'],
        validated: json['VALIDATED'],
      );
    } catch (e, _) {
      throw Exception('Error parsing DecodedPlugin: $e');
    }
  }

  Map<String, dynamic> toJsonUpdatePipeline() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['NAME'] = name;
    data['TYPE'] = type;
    data['URL'] = url;
    data['PLUGINS'] = plugins?.map((plugin) => plugin?.toJson()).toList();
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RECONNECTABLE'] = reconnectable;
    data['URL'] = url;
    data['LIVE_FEED'] = liveFeed;
    data['NAME'] = name;
    data['PLUGINS'] = plugins?.map((plugin) => plugin?.toJson()).toList();
    data['SESSION_ID'] = sessionId;
    data['TYPE'] = type;
    data['VALIDATED'] = validated;
    return data;
  }
}

class Plugin {
  List<Map<String, dynamic>?>? instances;
  String? signature;

  Plugin({
    this.instances,
    this.signature,
  });

  factory Plugin.fromJson(Map<String, dynamic> json) {
    return Plugin(
      // instances: List<Instance>.from(
      //   json['INSTANCES'].map(
      //     (x) => Instance.fromJson(x),
      //   ),
      // ),
      instances: json['INSTANCES'] != null
          ? List<Map<String, dynamic>>.from(json['INSTANCES'].map((x) => x))
          : null,
      signature: json['SIGNATURE'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['INSTANCES'] = instances?.map((instance) => instance).toList();
    data['SIGNATURE'] = signature;
    return data;
  }
}

class Instance {
  String? aiEngine;
  String? instanceId;
  StartupAiEngineParams? startupAiEngineParams;
  List<String>? objectType;
  int? witnessPeriod;
  String? command;
  String? data;
  String? instanceCommand;
  String? instanceCommandLast;
  String? modelTrtFilename;
  String? trtUrl;
  String? diskLowPrc;
  String? memLowPrc;
  String? processDelay;
  bool? allowEmptyInputs;
  bool? runWithoutImage;
  String? sendManifestEach;
  bool? supervisor;
  String? node;
  String? request;
  bool? restartOnBehind;
  String? versionToken;
  String? versionUrl;
  List<List<String>>? workingHours;
  String? deviceIp;
  bool? forcedPause;
  List<Relays>? relays;
  Map<String, dynamic>? moxaState;

  Instance({
    this.aiEngine,
    this.instanceId,
    this.startupAiEngineParams,
    this.objectType,
    this.witnessPeriod,
    this.command,
    this.data,
    this.instanceCommand,
    this.instanceCommandLast,
    this.modelTrtFilename,
    this.trtUrl,
    this.diskLowPrc,
    this.memLowPrc,
    this.processDelay,
    this.allowEmptyInputs,
    this.runWithoutImage,
    this.sendManifestEach,
    this.supervisor,
    this.node,
    this.request,
    this.restartOnBehind,
    this.versionToken,
    this.versionUrl,
    this.workingHours,
    this.deviceIp,
    this.forcedPause,
    this.relays,
    this.moxaState,
  });

  factory Instance.fromJson(Map<String, dynamic> json) {
    return Instance(
      aiEngine: json['AI_ENGINE'],
      instanceId: json['INSTANCE_ID'],
      startupAiEngineParams: json['STARTUP_AI_ENGINE_PARAMS'] != null
          ? StartupAiEngineParams.fromJson(json['STARTUP_AI_ENGINE_PARAMS'])
          : null,
      objectType: json['object_type'] != null
          ? List<String>.from(json['object_type'])
          : null,
      witnessPeriod: json['witness_period'],
      command: json['COMMAND'],
      data: json['DATA'],
      instanceCommand: json['INSTANCE_COMMAND'],
      instanceCommandLast: json['INSTANCE_COMMAND_LAST'],
      modelTrtFilename: json['MODEL_TRT_FILENAME'],
      trtUrl: json['TRT_URL'],
      diskLowPrc: json['DISK_LOW_PRC'],
      memLowPrc: json['MEM_LOW_PRC'],
      processDelay: json['PROCESS_DELAY'],
      allowEmptyInputs: json['ALLOW_EMPTY_INPUTS'],
      runWithoutImage: json['RUN_WITHOUT_IMAGE'],
      sendManifestEach: json['SEND_MANIFEST_EACH'],
      supervisor: json['SUPERVISOR'],
      node: json['node'],
      request: json['request'],
      restartOnBehind: json['RESTART_ON_BEHIND'],
      versionToken: json['VERSION_TOKEN'],
      versionUrl: json['VERSION_URL'],
      workingHours: json['WORKING_HOURS'] != null
          ? List<List<String>>.from(
              json['WORKING_HOURS'].map((x) => List<String>.from(x)))
          : null,
      deviceIp: json['DEVICE_IP'],
      forcedPause: json['FORCED_PAUSE'],
      relays: json['RELAYS'] != null
          ? List<Relays>.from(json['RELAYS'].map((x) => Relays.fromJson(x)))
          : null,
      moxaState: json['MOXA_STATE'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AI_ENGINE'] = aiEngine;
    data['INSTANCE_ID'] = instanceId;
    data['STARTUP_AI_ENGINE_PARAMS'] = startupAiEngineParams?.toJson();
    data['object_type'] = objectType;
    data['witness_period'] = witnessPeriod;
    data['COMMAND'] = command;
    data['DATA'] = this.data;
    data['INSTANCE_COMMAND'] = instanceCommand;
    data['INSTANCE_COMMAND_LAST'] = instanceCommandLast;
    data['MODEL_TRT_FILENAME'] = modelTrtFilename;
    data['TRT_URL'] = trtUrl;
    data['DISK_LOW_PRC'] = diskLowPrc;
    data['MEM_LOW_PRC'] = memLowPrc;
    data['PROCESS_DELAY'] = processDelay;
    data['ALLOW_EMPTY_INPUTS'] = allowEmptyInputs;
    data['RUN_WITHOUT_IMAGE'] = runWithoutImage;
    data['SEND_MANIFEST_EACH'] = sendManifestEach;
    data['SUPERVISOR'] = supervisor;
    data['node'] = node;
    data['request'] = request;
    data['RESTART_ON_BEHIND'] = restartOnBehind;
    data['VERSION_TOKEN'] = versionToken;
    data['VERSION_URL'] = versionUrl;
    data['WORKING_HOURS'] = workingHours;
    data['DEVICE_IP'] = deviceIp;
    data['FORCED_PAUSE'] = forcedPause;
    data['RELAYS'] = relays?.map((relay) => relay.toJson()).toList();
    data['MOXA_STATE'] = moxaState;
    return data;
  }
}

class Relays {
  int index;
  int value;

  Relays({
    required this.index,
    required this.value,
  });

  factory Relays.fromJson(Map<String, dynamic> json) {
    return Relays(
      index: json['index'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['index'] = index;
    data['value'] = value;
    return data;
  }
}

class StartupAiEngineParams {
  String modelTrtFilename;
  String trtUrl;

  StartupAiEngineParams({
    required this.modelTrtFilename,
    required this.trtUrl,
  });

  factory StartupAiEngineParams.fromJson(Map<String, dynamic> json) {
    return StartupAiEngineParams(
      modelTrtFilename: json['MODEL_TRT_FILENAME'],
      trtUrl: json['TRT_URL'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['MODEL_TRT_FILENAME'] = modelTrtFilename;
    data['TRT_URL'] = trtUrl;
    return data;
  }
}
