import 'package:e2_explorer/src/features/e2_status/application/client_messages/payload_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PayloadMessageList extends StatefulWidget {
  const PayloadMessageList({
    super.key,
    required this.messages,
    this.onTap,
    this.selectedMessageId,
    required this.scrollController,
  });

  final List<PayloadMessage> messages;
  final void Function(int index, PayloadMessage tappedMessage)? onTap;
  final String? selectedMessageId;
  final ScrollController scrollController;

  @override
  State<PayloadMessageList> createState() => _PayloadMessageListState();
}

class _PayloadMessageListState extends State<PayloadMessageList> {
  bool autoScrollUp = true;

  final _defaultColor = const Color(0xff161616);

  @override
  void didUpdateWidget(PayloadMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // print(oldWidget.messages.lastOrNull);
    // print(widget.messages.lastOrNull);
    // print('\n');
    // if (oldWidget.messages.lastOrNull != widget.messages.lastOrNull) {
    //   print('Scroll up');
    //   if (autoScrollUp == true) {
    //     widget.scrollController.jumpTo(widget.scrollController.position.minScrollExtent);
    //   }
    // }
  }

  @override
  void initState() {
    super.initState();
    // _scrollController = ScrollController();
    // _scrollController.addListener(() {
    //   // if (autoScrollUp) {
    //   //   print('go up');
    //   //   // && _scrollController.offset != _scrollController.position.minScrollExtent) {
    //   //   _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    //   // }
    // });
  }

  @override
  void dispose() {
    super.dispose();
    // _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      trackVisibility: true,
      controller: widget.scrollController,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: NotificationListener<ScrollNotification>(
          // onNotification: (scrollNotification) {
          //   // if (scrollNotification is ScrollStartNotification) {
          //   //   _onStartScroll(scrollNotification.metrics);
          //   // } else if (scrollNotification is ScrollUpdateNotification) {
          //   //   _onUpdateScroll(scrollNotification.metrics);
          //   // } else
          //
          //   // if (scrollNotification is ScrollEndNotification) {
          //   //   if (scrollNotification.metrics.atEdge &&
          //   //       _scrollController.position.userScrollDirection == ScrollDirection.reverse) {
          //   //     autoScrollUp = true;
          //   //     print('scrolled up');
          //   //   } else {
          //   //     autoScrollUp = false;
          //   //   }
          //   // }
          //
          //   /// what?
          //   return false;
          // },
          child: ListView.builder(
            shrinkWrap: true,
            reverse: true,
            controller: widget.scrollController,
            itemBuilder: (context, index) {
              final message = widget.messages[index].payload;
              return InkWell(
                // key: message['messageId'],
                key: ValueKey(widget.messages[index].payload.hash),
                onTap: () {
                  widget.onTap?.call(index, widget.messages[index]);
                },
                child: Container(
                  color: widget.selectedMessageId == message.hash
                      ? const Color(0xff2A3A6F)
                      : _defaultColor,
                  height: 30,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${message.boxId} -> ${message.pluginSignature}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white38,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            DateFormat('HH:mm:ss')
                                .format(widget.messages[index].localTimestamp),
                            style: const TextStyle(
                              color: Colors.white38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            /*separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 4,
                          );
                        },*/
            itemCount: widget.messages.length,
          ),
        ),
      ),
    );
  }
}
