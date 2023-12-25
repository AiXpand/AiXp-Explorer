import 'package:e2_explorer/dart_e2/base/generic_session.dart';
import 'package:e2_explorer/dart_e2/default/mqtt_session.dart';
import 'package:e2_explorer/dart_e2/models/utils_models/e2_heartbeat.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/message_filter.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/payload_filters/box_filter.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/payload_filters/pipeline_filter.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/payload_filters/plugin_instance_filter.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/payload_filters/plugin_type_filter.dart';
import 'package:e2_explorer/src/features/e2_status/utils/box_messages.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/domain/models/mqtt_server.dart';
import 'package:flutter/foundation.dart';

import 'events_notifier.dart';

class E2Notifiers {
  final EventsNotifier heartbeats = EventsNotifier();
  final EventsNotifier payloads = EventsNotifier();
  final EventsNotifier notifications = EventsNotifier();
  final EventsNotifier all = EventsNotifier();
  final EventsNotifier connection = EventsNotifier();
}

class E2Client {
  static E2Client _singleton = E2Client._internal();

  factory E2Client() {
    return _singleton;
  }

  /// Gives a new instance for our e2 client to remove all data
  static void clearClientData() {
    _singleton.disconnect();
    _singleton = E2Client._internal();
  }

  static void changeConnectionData(MqttServer connectionServer) {
    if (_singleton.isConnected) {
      _singleton.disconnect();
    }
    _singleton = E2Client._internal(server: connectionServer);
  }

  static String getBoxName(Map<String, dynamic> message) {
    try {
      final cavi2BoxName = message['sender']?['hostId'];
      final rawBoxName = message['EE_ID'];
      if (cavi2BoxName != null) {
        return cavi2BoxName;
      }
      if (rawBoxName == null) {
        debugPrint('Stop here');
      }
      return rawBoxName;
    } catch (_) {}
    return 'INVALID_BOX_NAME';
  }

  late MqttServer _server;

  MqttServer get server => _server;

  Map<String, BoxMessages> boxMessages = <String, BoxMessages>{};

  Map<String, MessageFilter> boxFilters = {};

  bool boxHasMessages(String boxName) => boxMessages.containsKey(boxName);

  BoxMessages? selectBoxByName(String boxName) => boxMessages[boxName];

  MessageFilter? selectBoxFiltersByName(String boxName) => boxFilters[boxName];

  String? selectedBoxName;
  late GenericSession session;

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  E2Notifiers notifiers = E2Notifiers();

  E2Client._internal({MqttServer? server}) {
    _server = server ?? MqttServer.defaultServer;
    session = MqttSession(
      server: _server,
      onHeartbeat: _onHeartbeat,
      onNotification: _onNotification,
      onPayload: _onPayload,
    );
  }

  Future<void> connect() async {
    await session.connect();
    _isConnected = session.isConnected;
    notifiers.connection.emit(true);
  }

  void disconnect() {
    session.close();
    _isConnected = false;
    notifiers.connection.emit(false);
  }

  void loadFilters(String boxName, E2Heartbeat heartbeatMessage) {
    final List<PipelineFilter> pipelineFilters = [];
    for (final pipeline in heartbeatMessage.configPipelines.allPipelines) {
      final List<PluginTypeFilter> pluginTypeFilters = [];
      for (final plugin in pipeline.plugins) {
        final List<PluginInstanceFilter> instancesFilters = [];
        for (final instance in plugin.instances) {
          final pluginInstanceFilter = PluginInstanceFilter(
            name: instance['INSTANCE_ID'],
            type: FilterType.pluginInstanceFilter,
            id: '$boxName#${pipeline.name}#${plugin.signature.toUpperCase()}#${instance['INSTANCE_ID']}',
          );

          instancesFilters.add(pluginInstanceFilter);
        }

        final pluginTypeFilter = PluginTypeFilter(
          name: plugin.signature.toUpperCase(),
          type: FilterType.pluginTypeFilter,
          id: '$boxName#${pipeline.name}#${plugin.signature.toUpperCase()}',
          children: instancesFilters,
        );

        ///ToDO maybe do it before?

        for (final filter in pluginTypeFilter.children) {
          filter.setParent(pluginTypeFilter);
        }

        pluginTypeFilters.add(pluginTypeFilter);
      }

      final pipelineFilter = PipelineFilter(
        name: pipeline.name,
        type: FilterType.pipelineFilter,
        id: '$boxName#${pipeline.name}',
        children: pluginTypeFilters,
      );

      for (final filter in pipelineFilter.children) {
        filter.setParent(pipelineFilter);
      }

      pipelineFilters.add(pipelineFilter);
    }

    final boxFilter = BoxFilter(
      name: boxName,
      type: FilterType.boxFilter,
      id: boxName,
      children: pipelineFilters,
    );

    for (final filter in boxFilter.children) {
      filter.setParent(boxFilter);
    }

    boxFilters[boxName] = boxFilter;
  }

  void _onHeartbeat(Map<String, dynamic> message) {
    final boxName = getBoxName(message);
    final currentBox =
        boxMessages.putIfAbsent(boxName, () => BoxMessages(boxName: boxName));
    currentBox.addHeartbeat(message);
    loadFilters(boxName, currentBox.heartbeatMessages.last);

    notifiers.heartbeats.emit(message);
    notifiers.all.emit(message);
  }

  void _onNotification(Map<String, dynamic> message) {
    final boxName = getBoxName(message);
    final currentBox =
        boxMessages.putIfAbsent(boxName, () => BoxMessages(boxName: boxName));
    currentBox.addNotification(message);
    notifiers.notifications.emit(message);
    notifiers.all.emit(message);
  }

  void _onPayload(Map<String, dynamic> message) {
    // print(message);
    // final boxName = getBoxName(message);
    String boxName = '';
    try {
      boxName = message['EE_PAYLOAD_PATH'][0];
    } catch (_) {
      print('Error while accessing EE_PAYLOAD_PATH: $message');
      return;
    }

    final currentBox =
        boxMessages.putIfAbsent(boxName, () => BoxMessages(boxName: boxName));
    // print(currentBox);
    try {
      currentBox.addPayloadToPipeline(message['EE_PAYLOAD_PATH'][1], message);
      notifiers.payloads.emit(message);
      notifiers.all.emit(message);
    } catch (_, stackTrace) {
      if (kDebugMode) {
        print(
          'Problem with payload message. Can not access message.EE_PAYLOAD_PATH[1]\nMessage: ${message['messageId']}\n Error:$_',
        );
        print(_);
        print(stackTrace);
      }
    }
  }
}
