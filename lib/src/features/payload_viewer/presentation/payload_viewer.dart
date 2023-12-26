import 'package:e2_explorer/dart_e2/models/payload/e2_payload.dart';
import 'package:e2_explorer/src/features/common_widgets/tooltip/simple_tooltip.dart';
import 'package:e2_explorer/src/features/e2_status/application/client_messages/payload_message.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener_filters.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/message_filter.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/messages/payload_message_list.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/views/payload_message_view.dart';
import 'package:e2_explorer/src/features/payload_viewer/presentation/widgets/filter_dropdown/filter_tree_view.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

class PayloadViewer extends StatefulWidget {
  const PayloadViewer({
    super.key,
    // required this.messagesByPipelines,
    required this.boxName,
  });

  // final Map<String, List<Map<String, dynamic>>> messagesByPipelines;
  final String boxName;

  @override
  State<PayloadViewer> createState() => _PayloadViewerState();
}

class _PayloadViewerState extends State<PayloadViewer> {
  bool autoScroll = true;
  final E2Client _client = E2Client();
  String? selectedPipelineName;
  PayloadMessage? _selectedMessage;

  List<PayloadMessage> messages = [];
  List<MessageFilter> filters = [];
  late final ValueNotifier<List<MessageFilter>> filterNotifier =
      ValueNotifier<List<MessageFilter>>(filters);

  final ScrollController _scrollController = ScrollController();

  void setSelectedMessage(PayloadMessage message) {
    _selectedMessage = message;
    // _selectedMessageText = const JsonEncoder.withIndent('    ').convert(message);
  }

  bool Function(PayloadMessage) filterMessagesByPipeline(String pipelineName) {
    return (PayloadMessage message) {
      return pipelineName == message.payload.pipelineName;
    };
  }

  bool Function(PayloadMessage) filterMessagesByPipelines(
      List<String> pipelines) {
    return (PayloadMessage message) {
      return pipelines.contains(message.payload.pipelineName);
    };
  }

  bool Function(PayloadMessage) filterMessagesByMessageFilters(
      List<MessageFilter> filters) {
    return (PayloadMessage message) {
      bool filterPass = false;
      for (final filter in filters) {
        filterPass = filterPass || message.filteringId.startsWith(filter.id);
        if (filterPass) {
          break;
        }
      }
      return filterPass;
    };
  }

  bool filterSingleMessageByFilters(
      final PayloadMessage message, List<MessageFilter> filters) {
    bool filterPass = false;
    for (final filter in filters) {
      filterPass = filterPass || message.filteringId.startsWith(filter.id);
      if (filterPass) {
        break;
      }
    }
    return filterPass;
  }

  @override
  void initState() {
    super.initState();

    for (final boxMessages in _client.boxMessages.values) {
      messages.addAll(boxMessages.payloadMessages);
    }
    //
    // final box = _client.selectBoxByName(widget.boxName);
    // messages = box!.payloadMessages;

    // messages.sort(
    //   (a, b) => a.localTimestamp.compareTo(b.localTimestamp),
    // );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(PayloadViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: const Color(0xff161616),
                height: double.infinity,
                child: SingleChildScrollView(
                  child: StatefulBuilder(
                    builder: (context, setStateBuilder) {
                      return E2Listener(
                        onHeartbeat: (data) {
                          setStateBuilder(() {});
                        },
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FilterTreeView(
                              filters: _client.boxFilters.values.toList(),
                              onItemChecked: (checkedItems) {
                                filters = checkedItems;
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            StatefulBuilder(
              builder: (context, setStateBuilder) {
                return E2Listener(
                  onPayload: (message) {
                    print("E2Listener: $message");

                    if (message == null) return;
                    // if (messages.isEmpty) {
                    //   final box = _client.selectBoxByName(widget.boxName);
                    //   messages = box?.payloadMessages ?? [];
                    // }
                    // print('EEEEEE');
                    // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);

                    // /// ToDo:  find  a way to optimize and insert the element in the sorted list
                    // final Map<String, dynamic> convertedMessage =
                    //     MqttMessageTransformer.formatToRaw(message);
                    // final E2Payload payloadObject = E2Payload.fromMap(
                    //   convertedMessage,
                    //   originalMap: message,
                    // );
                    //

                    // final payloadMessage =
                    //     PayloadMessage.fromE2Payload(payloadObject);

                    final payloadMessage = PayloadMessage.fromE2Payload(
                      E2Payload.fromMap(
                        message,
                        originalMap: message,
                      ),
                    );

                    messages.add(payloadMessage);
                    // /// ToDo:  find  a way to optimize and insert the element in the sorted list
                    // final payloadMessage = PayloadMessage.fromMap(message);
                    // messages.add(payloadMessage);
                    if (autoScroll) {
                      if (filters.isNotEmpty) {
                        if (filterSingleMessageByFilters(
                            payloadMessage, filters)) {
                          _scrollController.jumpTo(
                              _scrollController.position.maxScrollExtent);
                        }
                      } else {
                        _scrollController
                            .jumpTo(_scrollController.position.maxScrollExtent);
                      }
                    }

                    // messages.sort(
                    //   (a, b) => a.localTimestamp.compareTo(b.localTimestamp),
                    // );
                    setStateBuilder(() {});
                  },
                  dataFilter: E2ListenerFilters.acceptAll(),
                  builder: (context) {
                    return Expanded(
                      flex: 3,
                      child: Container(
                        color: const Color(0xff161616),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // if (selectedPipelineName != null)
                            // SizedBox(
                            //   height: 600,
                            //   width: 700,
                            //   child: FilterTreeView(
                            //     filters: _client.boxFilters.values.toList(),
                            //   ),
                            // ),

                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    color: ColorStyles.dark700,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Message list header --> sort in future?',
                                              style: TextStyles.bodyStrong(),
                                            ),
                                            SimpleTooltip(
                                              message: 'Auto Scroll',
                                              child: Checkbox(
                                                value: autoScroll,
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    setState(() {
                                                      autoScroll = value;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    /// ToDO: Replace message list with a widget that can be further parametrized
                                    child: ValueListenableBuilder(
                                      valueListenable: filterNotifier,
                                      builder: (BuildContext context, value,
                                          Widget? child) {
                                        return PayloadMessageList(
                                          // messages: messagesByPipelines[selectedPipelineName] ?? [],
                                          messages: filters.isEmpty
                                              ? messages
                                              : messages
                                                  .where(
                                                      filterMessagesByMessageFilters(
                                                          filters))
                                                  .toList(),
                                          selectedMessageId:
                                              _selectedMessage?.payload.hash,
                                          scrollController: _scrollController,
                                          onTap: (int index,
                                              PayloadMessage message) {
                                            setState(() {
                                              // setSelectedMessage(messagesByPipelines[selectedPipelineName]![index]);
                                              setSelectedMessage(message);
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                            // else
                            //   const Center(
                            //     child: Text('No pipeline selected'),
                            //   ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Expanded(
              flex: 4,
              child: PayloadMessageView(
                // key: ValueKey(_selectedMessage?['messageID']),
                selectedMessage: _selectedMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
