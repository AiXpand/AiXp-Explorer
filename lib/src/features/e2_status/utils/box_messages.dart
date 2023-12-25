import 'package:e2_explorer/dart_e2/formatter/mqtt_message_transformer.dart';
import 'package:e2_explorer/dart_e2/models/e2_message.dart';
import 'package:e2_explorer/dart_e2/models/payload/e2_payload.dart';
import 'package:e2_explorer/dart_e2/models/utils_models/e2_heartbeat.dart';
import 'package:e2_explorer/src/features/e2_status/application/client_messages/payload_message.dart';
import 'package:e2_explorer/src/features/e2_status/utils/status/pipeline_status.dart';

enum HeartbeatVersion { v1, v2, unknown }

class BoxMessages {
  BoxMessages({
    required this.boxName,
    this.maxMessagesCount = 50,
  });

  final String boxName;
  final int maxMessagesCount;

  // final Map<String, List<Map<String, dynamic>>> payloadMessagesByPipelines = {};
  final List<PayloadMessage> payloadMessages = [];

  final List<Map<String, dynamic>> notificationMessages = [];
  final List<E2Heartbeat> heartbeatMessages = [];

  @override
  String toString() {
    return 'BoxMessages{boxName: $boxName, payloadMessages: ${payloadMessages.length}, notificationMessages: ${notificationMessages.length}, heartbeatMessages: ${heartbeatMessages.length}\n';
  }

  List<PipelineStatus> get pipelineStatuses => _pipelinesStatuses;

  final List<PipelineStatus> _pipelinesStatuses = [];

  /// This is temporary in order to better display v2 messages.
  /// If the hb is not v2, this list is going to be empty.
  /// All heartbeats are going to be inside heartbeatMessages in a form that the client can interpret
  final List<Map<String, dynamic>> rawHeartbeatMessages = [];

  final List<E2Message> heartbeatDecodedMessages = [];

  int _totalMessageCount = 0;

  int get totalMessageCount => _totalMessageCount;

  HeartbeatVersion get heartbeatVersion => heartbeatMessages.isEmpty
      ? HeartbeatVersion.unknown
      : heartbeatMessages.first.heartbeatVersion == 'v2'
          ? HeartbeatVersion.v2
          : HeartbeatVersion.v1;

  bool _isLimit(List list, {int? maxMessagesCount}) {
    final maxLength = maxMessagesCount ?? this.maxMessagesCount;
    return list.length == maxLength;
  }

  void addPayloadToPipeline(String pipelineName, Map<String, dynamic> payload) {
    final Map<String, dynamic> convertedMessage =
        MqttMessageTransformer.formatToRaw(payload);
    final E2Payload payloadObject = E2Payload.fromMap(
      convertedMessage,
      originalMap: payload,
    );
    if (_isLimit(payloadMessages, maxMessagesCount: 200)) {
      payloadMessages.removeAt(0);
    }
    payloadMessages.add(PayloadMessage.fromE2Payload(payloadObject));
    _totalMessageCount += 1;
  }

  void addNotification(Map<String, dynamic> notification) {
    if (_isLimit(notificationMessages)) {
      // notificationMessages.removeLast();
      notificationMessages.removeAt(0);
    }
    _totalMessageCount += 1;
    // notificationMessages.insert(0, notification);
    notificationMessages.add(notification);
  }

  void addHeartbeat(Map<String, dynamic> receivedHeartbeat) {
    // bool isV2 = false;
    // final Map<String, dynamic> heartbeat = Map<String, dynamic>.from(receivedHeartbeat);
    final Map<String, dynamic> convertedMessage =
        MqttMessageTransformer.formatToRaw(receivedHeartbeat);
    final E2Heartbeat heartbeatObject = E2Heartbeat.fromMap(
      convertedMessage,
      originalMap: receivedHeartbeat,
    );
    if (_isLimit(heartbeatMessages)) {
      heartbeatMessages.removeAt(0);
    }

    // isV2 = heartbeatObject.heartbeatVersion == 'v2';
    heartbeatMessages.add(heartbeatObject);
    _totalMessageCount += 1;

    // try {
    //   isV2 = heartbeat['metadata']['heartbeat_version'] == 'v2';
    // } catch (_) {
    //   debugPrint('Cannot access metadata -> heartbeat_version for message ${heartbeat['messageID']}');
    // }
    //
    // if (_isLimit(heartbeatMessages)) {
    //   // heartbeatMessages.removeLast();
    //   heartbeatMessages.removeAt(0);
    //   // heartbeatDecodedMessages.removeAt(0);
    //   heartbeatDecodedMessages.removeAt(0);
    //   if (isV2) {
    //     rawHeartbeatMessages.removeAt(0);
    //   }
    // }
    // _totalMessageCount += 1;
    //
    // // heartbeatMessages.insert(0, heartbeat);
    //
    // /// Add to rawHeartbeats and modify the heartbeat to contain the decoded data
    // /// Also, we have to convert the keys to lowercase to respect cavi2 format
    // if (isV2) {
    //   rawHeartbeatMessages.add(Map<String, dynamic>.from(heartbeat));
    //   final metadataEncoded = XpandUtils.decodeEncryptedGzipMessage(heartbeat['metadata']['encoded_data']);
    //
    //   /// Process to cavi2 format
    //   // heartbeat = Map<String, dynamic>.from(heartbeat);
    //   final processedMetadata = metadataEncoded.map((key, value) => MapEntry(key.toLowerCase(), value));
    //   final newMetadata = Map<String, dynamic>.from(heartbeat['metadata'] as Map<String, dynamic>);
    //   newMetadata.addAll(processedMetadata);
    //   newMetadata.remove('encoded_data');
    //   heartbeat['metadata'] = newMetadata;
    // }
    // heartbeatMessages.add(heartbeat);
    //
    // try {
    //   final decodedMessage = MqttMessageDecoder.decodeMqttMessage(heartbeat);
    //
    //   /// ToDo: don't reinitialize if its the same
    //   // _pipelinesStatuses = [];
    //   //
    //   // for (final pipeline in decodedMessage.configPipelines.allPipelines) {
    //   //   final List<PluginStatus> pluginsStatus = [];
    //   //   for (final plugin in pipeline.plugins) {
    //   //     final List<InstanceStatus> instancesStatus = [];
    //   //     for (final instance in plugin.instances) {
    //   //       instancesStatus.add(InstanceStatus(instanceName: instance['INSTANCE_ID']));
    //   //     }
    //   //     pluginsStatus.add(PluginStatus(pluginSignature: plugin.signature, instances: instancesStatus));
    //   //   }
    //   //
    //   //   final pipelineStatus = PipelineStatus(pipelineName: pipeline.name, plugins: pluginsStatus);
    //   //   _pipelinesStatuses.add(pipelineStatus);
    //   // }
    //   if (kDebugMode) {
    //     // print(_pipelinesStatuses);
    //   }
    //   heartbeatDecodedMessages.add(decodedMessage);
    // } catch (error, stackTrace) {
    //   if (kDebugMode) {
    //     print('Error in decoding a heartbeat message into a model: $error\n Stack trace: $stackTrace');
    //   }
    // }
    // // heartbeatMessages.add(heartbeat);
    // // heartbeatDecodedMessages.add(MqttMessageDecoder.decodeMqttMessage(heartbeat));
  }

// @override
// String toString() {
//   return '$boxName has:\n\tpayloadMessages: ${payloadMessages.length}\n\tnotificationMessages: ${notificationMessages.length}';
// }
}
