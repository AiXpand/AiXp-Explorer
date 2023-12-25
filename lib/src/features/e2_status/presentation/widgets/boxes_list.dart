// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/e2_boxes/e2_box_item.dart';
import 'package:flutter/material.dart';

class BoxesList extends StatefulWidget {
  const BoxesList({
    Key? key,
    this.onBoxSelected,
  }) : super(key: key);

  @override
  State<BoxesList> createState() => _BoxesListState();
  final void Function(String boxName)? onBoxSelected;
}

class BoxInfo {
  final String name;
  int totalMessageCount;
  DateTime? lastMessageTime;
  BoxInfo({
    required this.name,
    this.totalMessageCount = 0,
    this.lastMessageTime,
  });
}

class _BoxesListState extends State<BoxesList> {
  String? _selectedBox;
  final client = E2Client();
  final Map<String, BoxInfo> _boxes = {};
  List<String> _boxNames = [];
  int? _listenerID;

  void boxMessageListener(dynamic data) {
    final message = data as Map<String, dynamic>;
    final boxName = E2Client.getBoxName(message);
    final isNewBox = !_boxes.containsKey(boxName);
    if (isNewBox) {
      _boxes[boxName] = BoxInfo(name: boxName);
    }
    final currentBox = _boxes[boxName]!;
    currentBox.lastMessageTime = DateTime.now();
    currentBox.totalMessageCount++;
    if (isNewBox) {
      _boxNames = _boxes.keys.toList()..sort((s1, s2) => s1.compareTo(s2));
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _listenerID =
        client.notifiers.all.addListener((data) => true, boxMessageListener);
    // _listenerID = client.notifiers.heartbeats.addListener((data) => true, boxMessageListener);
    // _listenerID = client.notifiers.notifications.addListener((data) => true, boxMessageListener);
    // _listenerID = client.notifiers.payloads.addListener((data) => true, boxMessageListener);
  }

  @override
  void dispose() {
    if (_listenerID != null) {
      client.notifiers.heartbeats.removeListener(_listenerID!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xff161616),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            final currentBox = _boxes[_boxNames[index]];
            final messageCount =
                client.boxMessages[currentBox?.name]?.totalMessageCount ?? 0;
            return E2BoxItem(
              key: ValueKey(currentBox!.name),
              messageCount: messageCount,
              boxName: currentBox.name,
              isSelected: currentBox.name == _selectedBox,
              onTap: () {
                if (_selectedBox == currentBox.name) {
                  return;
                }
                setState(() {
                  _selectedBox = currentBox.name;
                  widget.onBoxSelected?.call(_selectedBox!);
                });
              },
            );
          },
          separatorBuilder: (context, index) => const SizedBox(
            height: 4,
          ),
          itemCount: _boxNames.length,
        ),
      ),
    );
  }
}
