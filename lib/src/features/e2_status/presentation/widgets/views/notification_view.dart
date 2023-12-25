import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener_filters.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/messages/message_list.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/messages/simple_message_viewer.dart';
import 'package:flutter/material.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({
    super.key,
    // required this.messagesByPipelines,
    required this.boxName,
  });

  // final Map<String, List<Map<String, dynamic>>> messagesByPipelines;
  final String boxName;

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final E2Client _client = E2Client();
  Map<String, dynamic>? _selectedMessage;
  List<Map<String, dynamic>> messages = [];

  void setSelectedMessage(Map<String, dynamic> message) {
    _selectedMessage = message;
  }

  @override
  void initState() {
    super.initState();
    messages = _client.boxMessages[widget.boxName]?.notificationMessages ?? [];
  }

  @override
  void didUpdateWidget(NotificationView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return E2Listener(
      onNotification: (data) {
        // print('Hb received on hw info view');
        setState(() {
          messages =
              _client.boxMessages[widget.boxName]?.notificationMessages ?? [];
        });
      },
      dataFilter: E2ListenerFilters.filterByBox(widget.boxName),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Flexible(
                            child: MessageList(
                                messages: messages,
                                selectedMessageId:
                                    _selectedMessage?['messageID'],
                                onTap:
                                    (int index, Map<String, dynamic> message) {
                                  setState(() {
                                    setSelectedMessage(messages[index]);
                                  });
                                }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SimpleMessageViewer(
                  message: _selectedMessage,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
