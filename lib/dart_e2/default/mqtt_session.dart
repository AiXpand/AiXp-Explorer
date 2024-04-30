import 'dart:async';
import 'dart:convert';

import 'package:e2_explorer/dart_e2/base/generic_session.dart';
import 'package:e2_explorer/dart_e2/comm/mqtt_wrapper.dart';
import 'package:e2_explorer/dart_e2/commands/e2_commands.dart';
import 'package:e2_explorer/dart_e2/const/mqtt_config.dart';
import 'package:e2_explorer/dart_e2/ec_signature_verify/aixp_verifier.dart';
import 'package:e2_explorer/dart_e2/objects/e2_box.dart';
import 'package:flutter/foundation.dart';

class MqttSession extends GenericSession {
  /// Message Veirifer
  final aixpVerifier = AixpVerifier(isDebug: false);

  MqttSession({
    required super.server,
    void Function(Map<String, dynamic>)? onHeartbeat,
    void Function(Map<String, dynamic>)? onNotification,
    void Function(Map<String, dynamic>)? onPayload,

    /// This at is triggered for any of the 3 mqttWrappers objects
    /// Should be 3 different parameters?
    void Function(bool connectionStatus)? onConnectionStatusChanged,
    VoidCallback? onBoxConnected,
  }) : super(
          onHeartbeat: onHeartbeat ?? _defaultOnHeartbeat,
          onNotification: onNotification ?? _defaultOnNotification,
          onPayload: onPayload ?? _defaultOnPayload,
        ) {
    _payloadMqtt = MqttWrapper(
      server: server,
      receiveChannelName: MqttConfig.payloadsChannelTopic,
      sendChannelName: MqttConfig.configChannelTopic,
      onConnectionStatusChanged: onConnectionStatusChanged,
    );
    _heartbeatMqtt = MqttWrapper(
      server: server,
      receiveChannelName: MqttConfig.controlChannelTopic,
      onConnectionStatusChanged: onConnectionStatusChanged,
    );
    _notificationMqtt = MqttWrapper(
      server: server,
      receiveChannelName: MqttConfig.notificationChannelTopic,
      onConnectionStatusChanged: onConnectionStatusChanged,
    );
  }

  late final MqttWrapper _payloadMqtt;
  late final MqttWrapper _heartbeatMqtt;
  late final MqttWrapper _notificationMqtt;
  StreamController<Map<String, dynamic>>? _payloadReceiveStream;
  StreamController<Map<String, dynamic>>? _heartbeatReceiveStream;
  StreamController<Map<String, dynamic>>? _notificationReceiveStream;

  bool get isHeartbeatConnected => _heartbeatMqtt.isConnected;
  bool get isNotificationConnected => _notificationMqtt.isConnected;
  bool get isPayloadConnected => _payloadMqtt.isConnected;

  @override
  bool get isConnected =>
      isHeartbeatConnected && isNotificationConnected && isPayloadConnected;

  /// Sends a command to a specific box.
  @override
  void sendCommand(E2Command command) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(command.signedMap());
    print(prettyprint);
    print(
      'Sent command on lummetry/${command.targetId}/config: ${command.toJson()}',
    );

    _payloadMqtt.sendOnTopic(
      command.toJson(),
      'lummetry/${command.targetId}/config',
    );
  }

  @override
  Future<void> connect() async {
    /// Could abstract everything??
    /// Heartbeat connect
    _heartbeatReceiveStream = StreamController<Map<String, dynamic>>();
    _heartbeatReceiveStream?.stream.listen((message) {
      var messageVerifier = aixpVerifier.verifyMessage(message);
      final eePayloadPath = message['EE_PAYLOAD_PATH'];
      if (eePayloadPath[0] == 'gts-test2') {
        JsonEncoder encoder = const JsonEncoder.withIndent('  ');
        String prettyprint = encoder.convert(message);
        // print("$prettyprint");
      }
      if (messageVerifier) {
        _onHeartbeatInternal(message);
      }
    });
    await _heartbeatMqtt.serverConnect(receiveStream: _heartbeatReceiveStream);
    _heartbeatMqtt.subscribe();

    /// Notification connect
    _notificationReceiveStream = StreamController<Map<String, dynamic>>();
    _notificationReceiveStream?.stream.listen((message) {
      var messageVerifier = aixpVerifier.verifyMessage(message);
      final eePayloadPath = message['EE_PAYLOAD_PATH'];
      if (eePayloadPath[0] == 'gts-test2') {
        JsonEncoder encoder = const JsonEncoder.withIndent('  ');
        String prettyprint = encoder.convert(message);
        print("$prettyprint");
      }
      if (messageVerifier) {
        onNotification(message);
      }
    });
    await _notificationMqtt.serverConnect(
      receiveStream: _notificationReceiveStream,
    );
    _notificationMqtt.subscribe();

    /// Payload (Default communicator) connect
    _payloadReceiveStream = StreamController<Map<String, dynamic>>();
    _payloadReceiveStream?.stream.listen((message) {
      final eePayloadPath = message['EE_PAYLOAD_PATH'];
      var messageVerifier = aixpVerifier.verifyMessage(message);

      if ((eePayloadPath[0] == 'stg_k8s_super' ||
              eePayloadPath[0] == 'gts-test2') &&
          eePayloadPath[1] == 'admin_pipeline') {
        print("$eePayloadPath EE_PAYLOAD_PATH");
      }
      if (messageVerifier) {
        onPayload(message);
      }
    });
    await _payloadMqtt.serverConnect(receiveStream: _payloadReceiveStream);
    _payloadMqtt.subscribe();
  }

  @override
  Future<void> close() async {
    _heartbeatMqtt.disconnect();
    if (_heartbeatReceiveStream != null) {
      await _heartbeatReceiveStream!.close();
    }

    /// Notif close
    _notificationMqtt.disconnect();
    if (_notificationReceiveStream != null) {
      await _notificationReceiveStream!.close();
    }

    /// Payload close
    _payloadMqtt.disconnect();
    if (_payloadReceiveStream != null) {
      await _payloadReceiveStream!.close();
    }
  }

  void _onHeartbeatInternal(Map<String, dynamic> message) {
    try {
      final boxName = message['sender']?['hostId'];
      if (boxName == null) {
        debugPrint('stop here');
        return;
      }
      if ((boxName as String).startsWith('stress_test_')) {
        return;
      }

      final timeNow = DateTime.now();
      if (boxes.containsKey(boxName)) {
        boxes[boxName]!.isOnline = true;
        boxes[boxName]!.lastHbReceived = timeNow;
      } else {
        boxes[boxName] =
            E2Box(name: boxName, isOnline: true, lastHbReceived: timeNow);
      }
      onHeartbeat.call(message);
    } catch (_, s) {
      print('Invalid heartbeat received');
      // print(s);
    }
  }

  static void _defaultOnHeartbeat(Map<String, dynamic> message) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(message);

    print('Received heartbeat message: <--\n $prettyprint \n-->');
    print('');
  }

  static void _defaultOnNotification(Map<String, dynamic> message) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(message);

    print('Received notification message: <--\n $prettyprint \n-->');
    print('');
  }

  static void _defaultOnPayload(Map<String, dynamic> message) {
    print('Received payload message');
    // print(jsonEncode(message));
  }
}
