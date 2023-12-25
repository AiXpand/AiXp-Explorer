import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageList extends StatefulWidget {
  const MessageList({
    super.key,
    required this.messages,
    this.onTap,
    this.selectedMessageId,
  });

  final List<Map<String, dynamic>> messages;
  final void Function(int index, Map<String, dynamic> tappedMessage)? onTap;
  final String? selectedMessageId;

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  late final ScrollController _scrollController;
  // bool autoScrollUp = true;

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (oldWidget.messages.lastOrNull != widget.messages.lastOrNull) {
    //   print('Scroll up');
    //   if (autoScrollUp == true) {
    //     _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    //   }
    // }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      // if (autoScrollUp) {
      //   print('go up');
      //   // && _scrollController.offset != _scrollController.position.minScrollExtent) {
      //   _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      // }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      trackVisibility: true,
      controller: _scrollController,
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
            controller: _scrollController,
            itemBuilder: (context, index) {
              final message = widget.messages[index];
              return InkWell(
                // key: message['messageId'],
                key: ValueKey(widget.messages[index]['messageID']),
                onTap: () {
                  widget.onTap?.call(index, widget.messages[index]);
                },
                child: Container(
                  color: widget.selectedMessageId == message['messageID']
                      ? const Color(0xff2A3A6F)
                      : ColorStyles.dark800,
                  height: 30,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${message['type']}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white38,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            DateFormat('hh:mm:ss').format(
                                DateTime.parse(message['time']?['hostTime'])
                                    .toLocal()),
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
