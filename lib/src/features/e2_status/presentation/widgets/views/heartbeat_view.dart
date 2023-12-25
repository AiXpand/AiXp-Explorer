import 'package:e2_explorer/dart_e2/models/utils_models/e2_heartbeat.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener_filters.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/messages/heartbeat_message_viewer.dart';
import 'package:e2_explorer/src/features/e2_status/utils/box_messages.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

class HeartbeatView extends StatefulWidget {
  const HeartbeatView({
    super.key,
    // required this.messagesByPipelines,
    required this.boxName,
  });

  // final Map<String, List<Map<String, dynamic>>> messagesByPipelines;
  final String boxName;

  @override
  State<HeartbeatView> createState() => _HeartbeatViewState();
}

class _HeartbeatViewState extends State<HeartbeatView> {
  final E2Client _client = E2Client();
  Map<String, dynamic>? _selectedMessage;

  /// Used to represent v2 before decoding!
  Map<String, dynamic>? _selectedMessageRaw;
  List<E2Heartbeat> messages = [];
  List<Map<String, dynamic>> rawMessages = [];
  late HeartbeatVersion heartbeatVersion;

  void setSelectedMessage({
    required Map<String, dynamic> message,
    Map<String, dynamic>? rawMessage,
  }) {
    _selectedMessage = message;
    _selectedMessageRaw = rawMessage;
  }

  @override
  void initState() {
    super.initState();
    messages = _client.boxMessages[widget.boxName]?.heartbeatMessages ?? [];
    rawMessages =
        _client.boxMessages[widget.boxName]?.rawHeartbeatMessages ?? [];
    heartbeatVersion = _client.boxMessages[widget.boxName]?.heartbeatVersion ??
        HeartbeatVersion.unknown;
  }

  @override
  void didUpdateWidget(HeartbeatView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return E2Listener(
      onHeartbeat: (data) {
        // print('Hb received on hw info view');
        setState(() {
          messages =
              _client.boxMessages[widget.boxName]?.heartbeatMessages ?? [];
          heartbeatVersion =
              _client.boxMessages[widget.boxName]?.heartbeatVersion ??
                  HeartbeatVersion.unknown;
        });
        // print('Raw message');
        // print(rawMessages.lastOrNull);
      },
      dataFilter: E2ListenerFilters.filterByBox(widget.boxName),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Flexible(
                            child: Container(
                              child: Text(
                                'Functionality breaked during refactoring. Work in progress.',
                                style: TextStyles.body(),
                              ),
                            ),
                            // child: MessageList(
                            //     messages: messages,
                            //     selectedMessageId: _selectedMessage?['messageID'],
                            //     onTap: (int index, Map<String, dynamic> message) {
                            //       setState(() {
                            //         setSelectedMessage(
                            //           message: messages[index].messageBody ?? {},
                            //           rawMessage: heartbeatVersion == HeartbeatVersion.v2 ? rawMessages[index] : null,
                            //         );
                            //       });
                            //     }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: HeartbeatMessageViewer(
                  selectedMessage: _selectedMessage,
                  selectedRawMessage: _selectedMessageRaw,
                  isHeartbeatV2: heartbeatVersion == HeartbeatVersion.v2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
