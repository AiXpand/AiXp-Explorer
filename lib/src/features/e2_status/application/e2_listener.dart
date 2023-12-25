import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:flutter/material.dart';

typedef E2DataCallback = void Function(dynamic data);
typedef E2ConnectionCallback = void Function(dynamic isConnected);
typedef E2DataFilter = bool Function(dynamic data);

/// TODO: Add didUpdateWidget to support hot reload modification of listener callback
class E2Listener extends StatefulWidget {
  const E2Listener({
    super.key,
    required this.builder,
    this.onHeartbeat,
    this.onPayload,
    this.onNotification,
    this.onConnectionChanged,
    this.dataFilter,
  });

  /// ToDo: Change builder to child. Add builder to E2Builder
  final Widget Function(BuildContext context) builder;

  final E2ConnectionCallback? onConnectionChanged;

  /// Creates a listener on new heartbeat messages if the onHeartbeat parameter is not null.
  ///
  /// Otherwise, we won't have a listener onHeartbeat.
  final E2DataCallback? onHeartbeat;

  /// Creates a listener on new payload messages if the onPayload parameter is not null.
  ///
  /// Otherwise, we won't have a listener onPayload.
  final E2DataCallback? onPayload;

  /// Creates a listener on new notification messages if the onNotification parameter is not null.
  ///
  /// Otherwise, we won't have a listener onNotification.
  final E2DataCallback? onNotification;

  /// Defaults to () => true
  ///
  /// Will be applied to all listeners.
  /// Might change in the future to have one for each listener and maybe some
  /// standard filters.
  final E2DataFilter? dataFilter;

  @override
  State<E2Listener> createState() => _E2ListenerState();
}

class _E2ListenerState extends State<E2Listener> {
  late E2DataFilter dataFilter;
  // final List<int> _listenerIds = [];
  final E2Client _client = E2Client();
  late final _ListenerIds _listenerIds;

  @override
  void initState() {
    super.initState();
    dataFilter = widget.dataFilter ?? (data) => true;
    _listenerIds = _ListenerIds(client: _client);
    if (widget.onHeartbeat != null) {
      _listenerIds.addHeartbeatListenerId(
        _client.notifiers.heartbeats
            .addListener(dataFilter, widget.onHeartbeat!),
      );
    }

    if (widget.onNotification != null) {
      _listenerIds.addNotificationListenerId(
        _client.notifiers.notifications
            .addListener(dataFilter, widget.onNotification!),
      );
    }

    if (widget.onPayload != null) {
      _listenerIds.addPayloadListenerId(
        _client.notifiers.payloads.addListener(dataFilter, widget.onPayload!),
      );
    }

    if (widget.onConnectionChanged != null) {
      _listenerIds.addConnectionListener(
        _client.notifiers.connection
            .addListener(dataFilter, widget.onConnectionChanged!),
      );
    }
  }

  @override
  void dispose() {
    _listenerIds.removeAllListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder.call(context);
}

class _ListenerIds {
  _ListenerIds({required this.client});

  final E2Client client;

  final List<int> heartbeatListeners = [];
  final List<int> notificationListeners = [];
  final List<int> payloadListeners = [];
  final List<int> connectionListeners = [];

  void addHeartbeatListenerId(int id) {
    heartbeatListeners.add(id);
  }

  void addNotificationListenerId(int id) {
    notificationListeners.add(id);
  }

  void addPayloadListenerId(int id) {
    payloadListeners.add(id);
  }

  void addConnectionListener(int id) {
    connectionListeners.add(id);
  }

  void removeAllListeners() {
    removeHeartbeatListeners();
    removeNotificationListeners();
    removePayloadListeners();
  }

  void removeHeartbeatListeners() {
    for (final id in heartbeatListeners) {
      client.notifiers.heartbeats.removeListener(id);
    }
  }

  void removeNotificationListeners() {
    for (final id in notificationListeners) {
      client.notifiers.notifications.removeListener(id);
    }
  }

  void removePayloadListeners() {
    for (final id in payloadListeners) {
      client.notifiers.payloads.removeListener(id);
    }
  }

  void removeConnectionListeners() {
    for (final id in connectionListeners) {
      client.notifiers.connection.removeListener(id);
    }
  }
}
