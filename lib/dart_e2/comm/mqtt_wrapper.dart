import 'dart:async';
import 'dart:convert';

import 'package:e2_explorer/dart_e2/const/mqtt_config.dart';
import 'package:e2_explorer/dart_e2/utils/xpand_utils.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/domain/models/mqtt_server.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

/// Move to another file? Is this method good?

class MqttWrapper {
  MqttWrapper({
    this.sendChannelName,
    required this.receiveChannelName,
    this.communicationType = '',
    required this.server,
    this.onMessage,

    /// maybe remove?
    // required this.receiveStream,
    int maxRetries = 5,
    this.onConnectionStatusChanged,
  }) {
    final String randomIdentifier = 'EE_ID_${XpandUtils.getRandomString(8)}';
    _client = MqttServerClient.withPort(
      server.host,
      randomIdentifier,
      server.port,
      maxConnectionAttempts: maxRetries,
    )
      ..logging(on: false)
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected
      ..onSubscribed = _onSubscribed
      ..pongCallback = pong
      ..autoReconnect = true;

    /// also has a startClear, should we use this?
  }

  final String? sendChannelName;
  final String receiveChannelName;
  final MqttServer server;

  final void Function(Map<String, dynamic> message)? onMessage;

  /// ToDO: This should be deleted
  final void Function(bool connectionStatus)? onConnectionStatusChanged;

  /// Maybe this is not used anywhere
  final String communicationType;

  StreamController<Map<String, dynamic>>? _receiveStream;

  late final MqttServerClient _client;

  final List<MqttSubscription> _subscriptions = <MqttSubscription>[];

  bool get isConnected {
    final MqttConnectionState connectionStatus =
        _client.connectionStatus!.state;

    return connectionStatus == MqttConnectionState.connected;
  }

  Future<void> serverConnect(
      {StreamController<Map<String, dynamic>>? receiveStream}) async {
    try {
      await _client.connect(server.username, server.password);

      _receiveStream = receiveStream;

      /// Might not be the best place to put this listener
      /// What case can have the updates null?
      _client.updates.listen((event) {
        final MqttPublishMessage recMess =
            event[0].payload as MqttPublishMessage;
        final String pt =
            MqttUtilities.bytesToStringAsString(recMess.payload.message!);

        try {
          final Map<String, dynamic> decodedPayload = jsonDecode(pt);
          if (_receiveStream != null) {
            _receiveStream!.add(decodedPayload);
          }
          if (onMessage != null) {
            onMessage!.call(decodedPayload);
          }
        } catch (_) {
          // print(pt);
        }
      });
    } catch (_) {
      print('Mqtt conn failed: $_');
    }
  }

  void subscribe({int maxRetries = 5}) {
    /// Check if we have to treat the null case for connection status
    if (isConnected) {
      int retryNumber = 0;
      while (retryNumber < maxRetries) {
        /// Check if we have to use the atLeastOnce, or the config 0. Config 0 could be the first in the enum?
        final MqttSubscription? subscription =
            _client.subscribe(receiveChannelName, MqttConfig.qos);
        if (subscription != null) {
          /// Might not be necessary?
          _subscriptions.add(subscription);
          break;
        } else {
          print(
              'Trying to subscribe to topic: $receiveChannelName, retry number: ${retryNumber + 1}');
        }
        retryNumber++;
      }
    } else {
      print('Client ${_client.clientIdentifier} is not connected!');
    }
  }

  void send(String jsonBody) {
    if (isConnected && sendChannelName != null) {
      final builder = MqttPayloadBuilder();

      /// What values are we sending exactly? How?
      builder.addString(jsonBody);
      if (builder.payload != null) {
        final result = _client.publishMessage(
            sendChannelName!, MqttConfig.qos, builder.payload!);
      }
    }
  }

  void sendOnTopic(String jsonBody, String topicName) {
    if (isConnected) {
      final builder = MqttPayloadBuilder();

      /// What values are we sending exactly? How?
      builder.addString(jsonBody);
      if (builder.payload != null) {
        final result =
            _client.publishMessage(topicName, MqttConfig.qos, builder.payload!);
        print(result);
      }
    }
  }

  void disconnect() {
    /// This is a hard disconnect!
    _receiveStream = null;
    _client.unsubscribeStringTopic(receiveChannelName);
    _subscriptions.clear();
    _client.disconnect();
  }

  void _onConnected() {
    print('MQTT Connected');
    onConnectionStatusChanged?.call(true);
  }

  void _onDisconnected() {
    _receiveStream = null;
    // _client.unsubscribe(receiveChannelName);
    _subscriptions.clear();
    print('MQTT Disconnected');
    onConnectionStatusChanged?.call(false);
  }

  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
  }

  void _onSubscribed(MqttSubscription subscription) {
    print('Subscribed to: ${subscription.topic.rawTopic}');
  }
}
