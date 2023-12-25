import 'package:flutter/material.dart';

enum BoxViewerTab {
  hardwareInfo,
  pipelines,
  payload,
  notification,
  heartbeat,
  fullPayload;

  static BoxViewerTab fromIndex(int index) {
    return BoxViewerTab.values[index];
  }
}

class BoxMessagesTabDisplay extends StatefulWidget {
  const BoxMessagesTabDisplay({
    super.key,
    required this.hardwareInfoView,
    required this.pipelinesView,
    required this.payloadView,
    required this.notificationView,
    required this.heartbeatView,
    required this.commandView,
    // required this.fullPayloadsView,
    this.onTabChanged,
  });

  final Widget hardwareInfoView;
  final Widget pipelinesView;
  final Widget payloadView;
  final Widget notificationView;
  final Widget heartbeatView;
  final Widget commandView;
  // final Widget fullPayloadsView;
  final void Function(BoxViewerTab tab)? onTabChanged;

  @override
  State<StatefulWidget> createState() => _BoxMessagesTabDisplayState();
}

class _BoxMessagesTabDisplayState extends State<BoxMessagesTabDisplay>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late int _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabIndex = _tabController.index;
    _tabController.addListener(() {
      if (_tabIndex != _tabController.index) {
        final tab = BoxViewerTab.fromIndex(_tabController.index);
        widget.onTabChanged?.call(tab);
        setState(() {
          _tabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Container(
                    color: const Color(0xff282828),
                    width: double.infinity,
                    height: 2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 3 / 3,
                    child: TabBar(
                      indicatorColor: const Color(0xff0073E6),
                      controller: _tabController,
                      tabs: const <Widget>[
                        Tab(text: 'Hardware info'),
                        Tab(text: 'Pipelines'),
                        Tab(text: 'Payload'),
                        Tab(text: 'Notification'),
                        Tab(text: 'Heartbeat'),
                        Tab(text: 'Commands'),
                        // Tab(text: 'Full payloads (EXP)'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _tabIndex,
            children: <Widget>[
              ColoredBox(
                color: const Color(0xff1F1F1F),
                child: widget.hardwareInfoView,
              ),
              ColoredBox(
                color: const Color(0xff1F1F1F),
                child: widget.pipelinesView,
              ),
              ColoredBox(
                color: const Color(0xff1F1F1F),
                child: widget.payloadView,
              ),
              ColoredBox(
                color: const Color(0xff1F1F1F),
                child: widget.notificationView,
              ),
              ColoredBox(
                color: const Color(0xff1F1F1F),
                child: widget.heartbeatView,
              ),
              ColoredBox(
                color: const Color(0xff1F1F1F),
                child: widget.commandView,
              ),
              // ColoredBox(
              //   color: const Color(0xff1F1F1F),
              //   child: widget.fullPayloadsView,
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
