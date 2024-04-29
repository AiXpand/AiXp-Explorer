import 'package:flutter/material.dart';

class ExpandableWidget extends StatefulWidget {
  ///A widget whose body section expands and collapses alternately on clicking
  ///on its header widget.
  const ExpandableWidget({
    Key? key,
    this.isExpanded = false,
    this.header,
    this.headerTitle,
    this.headerSubTitle,
    this.onToggle,
    this.iconColor,
    required this.body,
    this.contentPadding,
    this.headerContentPadding,
    this.enableToggle = true,
    this.enableContainerToggle = true,
  }) : super(key: key);
  final bool isExpanded;

  final Widget? header;
  final String? headerTitle;
  final String? headerSubTitle;

  final Function(bool)? onToggle;
  final Color? iconColor;
  final Widget body;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? headerContentPadding;
  final bool enableToggle;
  final bool enableContainerToggle;

  @override
  State<ExpandableWidget> createState() => _ExpandableWidgetState();
}

class _ExpandableWidgetState extends State<ExpandableWidget>
    with TickerProviderStateMixin {
  bool _isExpanded = false;

  ///for animating expand and collapse of container
  late AnimationController _controller;
  late Animation<double> _animation;

  double _dropdownIconTurns = 0;

  Color backgroundColor = Colors.transparent;

  @override
  void initState() {
    _isExpanded = widget.isExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
    if (widget.isExpanded) {
      _controller.duration = const Duration(milliseconds: 0);
      _controller.forward();
      _controller.duration = const Duration(milliseconds: 200);
    }
    super.initState();
  }

  void _toggleExpandableContainer() {
    if (_animation.status != AnimationStatus.completed) {
      _controller.forward();
    } else {
      _controller.animateBack(0, duration: const Duration(milliseconds: 200));
    }
  }

  void _onContainerToggle(bool expanded) {
    if (widget.enableContainerToggle) {
      _toggleExpandableContainer();
    }

    widget.onToggle?.call(expanded);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.header != null || widget.headerTitle != null,
      'Either header title or header widget must be provided!',
    );
    assert(
      widget.enableToggle == false || widget.onToggle != null,
      'Provide onToggle callback when toggle is enabled!',
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                  animation: _animation,
                  builder: (context, snapshot) {
                    return InkWell(
                      onHover: (value) {
                        setState(() {
                          backgroundColor = value
                              ? Colors.grey.withOpacity(0.2)
                              : Colors.transparent;
                        });
                      },
                      onTap: () {
                        _toggleExpandableContainer();
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        color: backgroundColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: AnimatedRotation(
                          turns: _isExpanded ? 0.25 : 0.75,
                          // turns: _isExpanded ? 1 : 0.5,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            size: 15,
                          ),
                        ),
                      ),
                    );
                  }),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: widget.header,
              ),
            ],
          ),
          SizeTransition(
            sizeFactor: _animation,
            axis: Axis.vertical,
            child: Container(
              decoration: const BoxDecoration(),
              child: widget.body,
            ),
          ),
        ],
      ),
    );
  }
}
