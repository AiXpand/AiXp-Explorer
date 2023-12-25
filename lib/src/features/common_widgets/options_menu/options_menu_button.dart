part of 'options_menu.dart';

class OptionsMenuButton extends StatefulWidget {
  const OptionsMenuButton({
    super.key,
    required this.items,
    this.onOpenOptionBox,
    this.onCloseOptionBox,
    this.dismissable = true,
    this.targetAnchor,
    this.followerAnchor,
    this.iconButtonSize = 42,
    this.iconData = CarbonIcons.overflow_menu_horizontal,
    this.child,
    this.hoverColor,
    this.materialColor = ColorStyles.dark700,
    this.borderRadius,
    this.iconSize = 18,
  });

  final Widget? child;
  final List<BaseMenuItem> items;
  final Color materialColor;
  final Color? hoverColor;
  final IconData? iconData;
  final double iconSize;
  final double iconButtonSize;
  final BorderRadius? borderRadius;
  final VoidCallback? onOpenOptionBox;
  final VoidCallback? onCloseOptionBox;
  final Alignment? targetAnchor;
  final Alignment? followerAnchor;
  final bool dismissable;

  @override
  State<OptionsMenuButton> createState() => _OptionsMenuButtonState();
}

class _OptionsMenuButtonState extends State<OptionsMenuButton> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late OffsetDetectorController _offsetDetectorController;

  bool isOpened = false;
  Alignment screenRegion = Alignment.center;

  @override
  void initState() {
    super.initState();
    _offsetDetectorController = OffsetDetectorController();
    _offsetDetectorController.addListener(() {
      _onBoxOffsetChanged(
        _offsetDetectorController.size,
        _offsetDetectorController.offset,
        _offsetDetectorController.rootPadding,
      );
    });
  }

  @override
  void dispose() {
    _offsetDetectorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      key: _textFieldKey,
      link: _layerLink,
      child: OffsetDetector(
        controller: _offsetDetectorController,
        onChanged: _onBoxOffsetChanged,
        child: widget.child != null
            ? Material(
                color: widget.materialColor,
                borderRadius: widget.borderRadius,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  hoverColor: widget.hoverColor,
                  borderRadius: widget.borderRadius,
                  onTap: _openOptionBox,
                  child: widget.child,
                ),
              )
            : Material(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
                color: widget.materialColor,
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: widget.iconButtonSize,
                  height: widget.iconButtonSize,
                  child: InkWell(
                    onTap: _openOptionBox,
                    child: Icon(
                      widget.iconData,
                      color: ColorStyles.light100,
                      size: widget.iconSize,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  /// Creates the option menu overlay.
  OverlayEntry _createOverlayEntry() {
    _computeScreenRegion();
    return OverlayEntry(
      builder: (BuildContext context) {
        /// The left, top and center regions (x <= 0 && y <= 0) use the same preferred alignment
        /// where the overlay expands to the bottom-right.
        /// Otherwise, the alignment is chosen such that the overlay expands in the opposite direction
        /// of the closest screen corner.
        final Alignment naturalTargetAnchor = screenRegion.x <= 0
            ? screenRegion.y <= 0
                ? Alignment.bottomLeft
                : Alignment.topLeft
            : screenRegion.y <= 0
                ? Alignment.bottomRight
                : Alignment.topRight;
        final Alignment naturalFollowerAnchor = screenRegion.x <= 0
            ? screenRegion.y <= 0
                ? Alignment.topLeft
                : Alignment.bottomLeft
            : screenRegion.y <= 0
                ? Alignment.topRight
                : Alignment.bottomRight;
        final Alignment targetAnchor =
            widget.targetAnchor ?? naturalTargetAnchor;
        final Alignment followerAnchor =
            widget.followerAnchor ?? naturalFollowerAnchor;

        /// Offset is computed based on the target and follower anchors.
        /// If the anchor axis of the target and follower directly oppose, then an offset
        /// is needed on that axis to separate the menu from the button.
        final Offset offset = Offset(
          targetAnchor.x.sign == -followerAnchor.x.sign
              ? 8 * -followerAnchor.x.sign
              : 0,
          targetAnchor.y.sign == -followerAnchor.y.sign
              ? 8 * -followerAnchor.y.sign
              : 0,
        );

        return Stack(
          children: <Widget>[
            if (widget.dismissable)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeOptionBox,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: targetAnchor,
              followerAnchor: followerAnchor,
              offset: offset,
              child: OptionsMenu(
                items: widget.items,
                onItemTap: (BaseMenuItem item) => _closeOptionBox(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onBoxOffsetChanged(
      Size size, EdgeInsets offset, EdgeInsets rootPadding) {
    _computeScreenRegion();
    _updateOptionBox();
  }

  /// Computes the screen region of the options menu button.
  /// Screen regions are split similarly to 9-patch areas, with each region
  /// matching one of the predefined [Alignment] values (topLeft, centerRight, etc).
  /// The overlay is aligned to the parent based on this screen region.
  /// This method is called when the overlay is first build and again whenever the box offset changes.
  void _computeScreenRegion() {
    final RenderBox renderBox = context.findRenderObject()! as RenderBox;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Offset globalPosition = renderBox.localToGlobal(
      Offset(renderBox.size.width / 2, renderBox.size.height / 2),
    );
    setState(() {
      screenRegion = Alignment(
        (globalPosition.dx * 2 / mediaQuery.size.width - 1).roundToDouble(),
        (globalPosition.dy * 2 / mediaQuery.size.height - 1).roundToDouble(),
      );
    });
  }

  void _openOptionBox() {
    if (isOpened) {
      return;
    }
    if (widget.items.isEmpty) {
      return;
    }

    widget.onOpenOptionBox?.call();
    _overlayEntry ??= _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    isOpened = true;
    _offsetDetectorController.notifyStateChanged();
  }

  void _closeOptionBox() {
    if (!isOpened) {
      return;
    }
    widget.onCloseOptionBox?.call();
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    isOpened = false;
  }

  void _updateOptionBox() {
    if (!isOpened) {
      return;
    }
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }
}
