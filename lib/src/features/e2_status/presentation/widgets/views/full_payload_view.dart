import 'package:e2_explorer/dart_e2/formatter/mqtt_message_transformer.dart';
import 'package:e2_explorer/dart_e2/models/payload/e2_payload.dart';
import 'package:e2_explorer/src/features/e2_status/application/client_messages/payload_message.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener_filters.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/message_filter.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/messages/payload_message_list.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/views/payload_message_view.dart';
import 'package:e2_explorer/src/features/payload_viewer/presentation/widgets/filter_dropdown/filter_dropdown.dart';
import 'package:flutter/material.dart';

class FullPayloadView extends StatefulWidget {
  const FullPayloadView({
    super.key,
    // required this.messagesByPipelines,
    required this.boxName,
  });

  // final Map<String, List<Map<String, dynamic>>> messagesByPipelines;
  final String boxName;

  @override
  State<FullPayloadView> createState() => _FullPayloadViewState();
}

class _FullPayloadViewState extends State<FullPayloadView> {
  final E2Client _client = E2Client();
  String? selectedPipelineName;
  PayloadMessage? _selectedMessage;

  // Map<String, List<Map<String, dynamic>>> messagesByPipelines = {};

  // final List<Map<String, dynamic>> filteredPipeline;

  List<String> pipelineFilter = [];
  List<String> pluginFilter = [];
  List<PayloadMessage> messages = [];
  List<MessageFilter> filters = [];

  final ScrollController _scrollController = ScrollController();

  void setSelectedMessage(PayloadMessage message) {
    _selectedMessage = message;
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

  //
  // bool applyFilterToMessage(MessageFilter filter, PayloadMessage message) {
  //
  //   switch(filter.type) {
  //     case FilterType.pipelineFilter:
  //       return message.pipelineName == filter.name && appl;
  //     case FilterType.pluginTypeFilter:
  //       // TODO: Handle this case.
  //       break;
  //     case FilterType.pluginInstanceFilter:
  //       // TODO: Handle this case.
  //       break;
  //     case FilterType.boxFilter:
  //       // TODO: Handle this case.
  //       break;
  //   }
  // }

  bool Function(PayloadMessage) filterMessagesByMessageFilters(
      List<MessageFilter> filters) {
    return (PayloadMessage message) {
      bool filterPass = false;
      for (final filter in filters) {
        // switch(filter.type) {
        //
        //   case FilterType.pipelineFilter:
        //     return message.pipelineName == filter.name;
        //   case FilterType.pluginTypeFilter:
        //     return message.pluginSignature == filter.name;
        //   case FilterType.pluginInstanceFilter:
        //     return message.pluginInstanceName == filter.name;
        //   case FilterType.boxFilter:
        //     return
        // }
        filterPass = filterPass || message.filteringId.startsWith(filter.id);
        if (filterPass) {
          break;
        }
      }
      return filterPass;
    };
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

    messages.sort(
      (a, b) => a.localTimestamp.compareTo(b.localTimestamp),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(FullPayloadView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatefulBuilder(builder: (context, setStateBuilder) {
            return E2Listener(
              onPayload: (message) {
                // if (messages.isEmpty) {
                //   final box = _client.selectBoxByName(widget.boxName);
                //   messages = box?.payloadMessages ?? [];
                // }
                // print('EEEEEE');
                // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);

                /// ToDo:  find  a way to optimize and insert the element in the sorted list
                final Map<String, dynamic> convertedMessage =
                    MqttMessageTransformer.formatToRaw(message);
                final E2Payload payloadObject = E2Payload.fromMap(
                  convertedMessage,
                  originalMap: message,
                );
                messages.add(PayloadMessage.fromE2Payload(payloadObject));
                messages.sort(
                  (a, b) => a.localTimestamp.compareTo(b.localTimestamp),
                );
                setStateBuilder(() {});
              },
              dataFilter: E2ListenerFilters.acceptAll(),
              builder: (context) {
                return Expanded(
                  flex: 2,
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
                      FilterDropdown(
                        filters: _client.boxFilters.values.toList(),
                        onCheckedItemsChanged:
                            (List<MessageFilter> checkedItems) {
                          debugPrint('Checked filters: $checkedItems');
                          setStateBuilder(() {
                            filters = checkedItems;
                          });
                        },
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Flexible(
                              /// ToDO: Replace message list with a widget that can be further parametrized
                              child: PayloadMessageList(
                                  // messages: messagesByPipelines[selectedPipelineName] ?? [],
                                  messages: filters.isEmpty
                                      ? messages
                                      : messages
                                          .where(filterMessagesByMessageFilters(
                                              filters))
                                          .toList(),
                                  selectedMessageId:
                                      _selectedMessage?.payload.hash,
                                  scrollController: _scrollController,
                                  onTap: (int index, PayloadMessage message) {
                                    setState(() {
                                      // setSelectedMessage(messagesByPipelines[selectedPipelineName]![index]);
                                      setSelectedMessage(message);
                                    });
                                  }),
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
                );
              },
            );
          }),
          Expanded(
            flex: 5,
            child: PayloadMessageView(
              // key: ValueKey(_selectedMessage?['messageID']),
              selectedMessage: _selectedMessage,
            ),
          ),
        ],
      ),
    );
  }
}
