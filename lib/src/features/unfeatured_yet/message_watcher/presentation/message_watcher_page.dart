import 'package:e2_explorer/dart_e2/comm/mqtt_wrapper.dart';
import 'package:e2_explorer/dart_e2/const/mqtt_config.dart';
import 'package:e2_explorer/dart_e2/utils/xpand_utils.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/messages/simple_message_viewer.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/message_watcher/domain/topic_message.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

class MessageWatcherPage extends StatefulWidget {
  const MessageWatcherPage({super.key});

  @override
  State<MessageWatcherPage> createState() => _MessageWatcherPageState();
}

class _MessageWatcherPageState extends State<MessageWatcherPage> {
  double value = 1;
  bool testActive = false;

  final period = const Duration(seconds: 5);
  late final MqttWrapper mqttHbs;
  late final MqttWrapper mqttNotification;
  late final MqttWrapper mqttPayload;
  late final MqttWrapper mqttCommands;

  final List<TopicMessage> messages = [];
  Map<String, dynamic>? selectedContent;
  final int messageLengthLimit = 50;

  int sentMessages = 0;

  @override
  void initState() {
    super.initState();
    mqttHbs = MqttWrapper(
      server: E2Client().server,
      receiveChannelName: MqttConfig.controlChannelTopic,
      onMessage: (message) {
        print('Received message');
        setState(() {
          addToMessageList(TopicMessageType.heartbeat, message);
        });
      },
    );

    mqttNotification = MqttWrapper(
      server: E2Client().server,
      receiveChannelName: MqttConfig.notificationChannelTopic,
      onMessage: (message) {
        setState(() {
          addToMessageList(TopicMessageType.notification, message);
        });
      },
    );

    mqttPayload = MqttWrapper(
      server: E2Client().server,
      receiveChannelName: MqttConfig.payloadsChannelTopic,
      onMessage: (message) {
        setState(() {
          addToMessageList(TopicMessageType.payload, message);
        });
      },
    );

    mqttCommands = MqttWrapper(
      server: E2Client().server,
      receiveChannelName: 'lummetry/theo_dckr/config',
      onMessage: (message) {
        setState(() {
          addToMessageList(TopicMessageType.payload, message);
        });
      },
    );
    // mqttHbs.serverConnect().then((value) => mqttHbs.subscribe());
    // mqttPayload.serverConnect().then((value) => mqttPayload.subscribe());
    mqttNotification
        .serverConnect()
        .then((value) => mqttNotification.subscribe());
    // mqttNotification.serverConnect();
    // mqttPayload.serverConnect();
  }

  void addToMessageList(TopicMessageType type, Map<String, dynamic> message) {
    final TopicMessage topicMessage = TopicMessage(
      message: message,
      messageType: type,
    );
    if (messages.length == messageLengthLimit) {
      messages.removeAt(0);
    }
    messages.add(topicMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: double.infinity,
            color: ColorStyles.dark700,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: double.infinity,
                color: ColorStyles.dark800,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.separated(
                    reverse: true,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final message = messages[index].message;
                      String boxId = '';
                      if (message['EE_FORMATTER'] == 'cavi2') {
                        boxId = message['sender']['hostId'];
                      } else {
                        boxId = message['EE_ID'];
                        if (message['HEARTBEAT_VERSION'] == 'v2') {
                          final encodedData =
                              message['ENCODED_DATA'] as String?;
                          if (encodedData != null) {
                            final decodedData = decodeData(encodedData);
                            message.remove('ENCODED_DATA');
                            message.addAll(decodedData);
                          }
                        }
                      }
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedContent = message;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          color: ColorStyles.dark700,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              boxId,
                              style: TextStyles.body(),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        height: 8,
                      );
                    },
                    itemCount: messages.length,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
            child: SimpleMessageViewer(
          message: selectedContent,
        ))
      ],
    );
  }

  Map<String, dynamic> decodeData(String encodedData) {
    return XpandUtils.decodeEncryptedGzipMessage(encodedData);
  }
}
