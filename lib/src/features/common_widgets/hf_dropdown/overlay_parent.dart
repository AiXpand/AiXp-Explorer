import 'package:flutter/material.dart';

import 'hf_dropdown.dart';

class OverlayParent extends StatefulWidget {
  const OverlayParent({
    super.key,
    required this.builder,
    this.overlayController,
    this.name,
  });

  final String? name;
  final Widget Function(BuildContext context, OverlayController overlay)
      builder;
  final OverlayController? overlayController;
  @override
  State<OverlayParent> createState() => _OverlayParentState();
}

class _OverlayParentState extends State<OverlayParent> {
  late OverlayController _controller;
  @override
  void initState() {
    super.initState();
    _controller = widget.overlayController ??
        OverlayController(widget.name ?? 'Unnamed overlayParent');
  }

  @override
  Widget build(BuildContext context) {
    return OverlayTarget(
      targetKey: _controller.targetKey,
      layerLink: _controller.layerLink,
      groupID: _controller.tapRegionGroupID,
      child: widget.builder(
        context,
        _controller,
      ),
    );
  }
}
