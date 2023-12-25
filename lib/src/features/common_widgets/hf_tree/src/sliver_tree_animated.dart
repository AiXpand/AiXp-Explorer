part of hf_tree;

typedef TreeTransitionBuilder = Widget Function(
  BuildContext context,
  Widget child,
  Animation<double> animation,
);

Widget defaultTreeTransitionBuilder(
  BuildContext context,
  Widget child,
  Animation<double> animation,
) {
  return SizeTransition(sizeFactor: animation, child: child);
}

Widget fadeSizeTransitionBuilder(
    BuildContext context, Widget child, Animation<double> animation) {
  return FadeTransition(
    opacity: animation,
    child: SizeTransition(
      sizeFactor: animation,
      child: child,
    ),
  );
}

class SliverListTreeAnimated<TreeItemDataType extends Object, UniqueIDType>
    extends SliverTree<TreeItemDataType, UniqueIDType> {
  const SliverListTreeAnimated({
    super.key,
    required super.controller,
    required super.nodeBuilder,
    required super.emptyStateBuilder,
    this.transitionBuilder = defaultTreeTransitionBuilder,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut, // Curves.linear
    this.onItemCheckedChange,
  });

  final TreeTransitionBuilder transitionBuilder;
  final Duration duration;
  final Curve curve;
  final TreeItemCheckedCallback<TreeItemDataType>? onItemCheckedChange;

  @override
  State<SliverListTreeAnimated<TreeItemDataType, UniqueIDType>> createState() =>
      _SliverListtreeAnimated<TreeItemDataType, UniqueIDType>();
}

class _SliverListtreeAnimated<TreeItemDataType extends Object, UniqueIDType>
    extends State<SliverListTreeAnimated<TreeItemDataType, UniqueIDType>> {
  Map<TreeItemDataType, bool> _expansionStatesMap = <TreeItemDataType, bool>{};

  // A list containing all the expanded items and their children
  List<TreeNode<TreeItemDataType>> _displayedNodesList =
      <TreeNode<TreeItemDataType>>[];

  void _onFilterUpdate() {
    // Clear expansion states cache
    _expansionStatesMap.clear();
  }

  void _updateDisplayedNodesList() {
    final Map<TreeItemDataType, bool> oldExpandedStateMap =
        Map<TreeItemDataType, bool>.of(_expansionStatesMap);

    final Map<TreeItemDataType, bool> currentExpandedStateMap =
        <TreeItemDataType, bool>{};
    final List<TreeNode<TreeItemDataType>> displayedNodesList =
        <TreeNode<TreeItemDataType>>[];

    final Visitor<TreeNode<TreeItemDataType>> onVisit;

    if (widget.duration == Duration.zero) {
      onVisit = (TreeNode<TreeItemDataType> node) {
        displayedNodesList.add(node);
        currentExpandedStateMap[node.data] =
            widget.controller.isItemExpanded(node.data);
      };
    } else {
      onVisit = (TreeNode<TreeItemDataType> node) {
        displayedNodesList.add(node);
        currentExpandedStateMap[node.data] =
            widget.controller.isItemExpanded(node.data);

        if (widget.controller.animateExpandCollapse == false) {
          return;
        }

        final bool? previousState = oldExpandedStateMap[node.data];
        if ((previousState != null) &&
            (previousState != widget.controller.isItemExpanded(node.data))) {
          _animatingItems.add(node.data);
        }
      };
    }

    widget.controller.visitNodes(
      onVisit: onVisit,
      matchCondition: (TreeNode<TreeItemDataType> node) {
        if (_animatingItems.contains(node.data)) {
          // Don't include animating (expanding/collapsing) items in the displayed nodes list
          return false;
        }
        return widget.controller.isItemExpanded(node.data);
      },
    );

    _displayedNodesList = displayedNodesList;
    _expansionStatesMap = currentExpandedStateMap;
  }

  void _rebuild() => setState(_updateDisplayedNodesList);

  final Set<TreeItemDataType> _animatingItems = <TreeItemDataType>{};

  void _onAnimationComplete(TreeItemDataType item) {
    _animatingItems.remove(item);
    _rebuild();
  }

  List<TreeNode<TreeItemDataType>> _buildSubtree(
      TreeNode<TreeItemDataType> node) {
    final List<TreeNode<TreeItemDataType>> displayedNodesSubtree =
        <TreeNode<TreeItemDataType>>[];
    widget.controller.visitNodes(
      startingNode: node,
      onVisit: displayedNodesSubtree.add,
    );
    return displayedNodesSubtree;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    widget.controller.onFilterUpdate.addListener(_onFilterUpdate);
    _updateDisplayedNodesList();
  }

  @override
  void didUpdateWidget(
      covariant SliverListTreeAnimated<TreeItemDataType, UniqueIDType>
          oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      oldWidget.controller.onFilterUpdate.removeListener(_onFilterUpdate);
      widget.controller.addListener(_rebuild);
      widget.controller.onFilterUpdate.addListener(_onFilterUpdate);
      _updateDisplayedNodesList();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _animatingItems.clear();
    _displayedNodesList = <TreeNode<TreeItemDataType>>[];
    _expansionStatesMap.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_displayedNodesList.isEmpty) {
      return SliverToBoxAdapter(child: widget.emptyStateBuilder(context));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: _displayedNodesList.length,
        (BuildContext context, int index) {
          final TreeNode<TreeItemDataType> node = _displayedNodesList[index];
          return _TreeNodeWidget<TreeItemDataType, UniqueIDType>(
            key: _TreeNodeKey(node.data),
            node: node,
            controller: widget.controller,
            headerBuilder: widget.nodeBuilder,
            contentBuilder: _buildSubtree,
            transitionBuilder: widget.transitionBuilder,
            onAnimationComplete: _onAnimationComplete,
            curve: widget.curve,
            duration: widget.duration,
            showSubtree: _animatingItems.contains(node.data),
          );
        },
      ),
    );
  }
}

class _TreeNodeKey extends GlobalObjectKey {
  const _TreeNodeKey(super.value);
}

typedef _TreeNodeContentBuilder<TreeItemDataType extends Object, UniqueIDType>
    = List<TreeNode<TreeItemDataType>> Function(
  TreeNode<TreeItemDataType> virtualRoot,
);

class _TreeNodeWidget<TreeItemDataType extends Object, UniqueIDType>
    extends StatefulWidget {
  const _TreeNodeWidget({
    super.key,
    required this.node,
    required this.headerBuilder,
    required this.contentBuilder,
    required this.transitionBuilder,
    required this.onAnimationComplete,
    required this.curve,
    required this.duration,
    required this.showSubtree,
    required this.controller,
  });

  final TreeNode<TreeItemDataType> node;
  final TreeController<TreeItemDataType, UniqueIDType> controller;
  final TreeNodeHeaderBuilder<TreeItemDataType, UniqueIDType> headerBuilder;
  final _TreeNodeContentBuilder<TreeItemDataType, UniqueIDType> contentBuilder;

  final TreeTransitionBuilder transitionBuilder;
  final ValueSetter<TreeItemDataType> onAnimationComplete;
  final Curve curve;
  final Duration duration;
  final bool showSubtree;

  @override
  State<_TreeNodeWidget<TreeItemDataType, UniqueIDType>> createState() =>
      _TreeNodeWidgetState<TreeItemDataType, UniqueIDType>();
}

class _TreeNodeWidgetState<TreeItemDataType extends Object, UniqueIDType>
    extends State<_TreeNodeWidget<TreeItemDataType, UniqueIDType>>
    with SingleTickerProviderStateMixin {
  //TreeNode<TreeItemDataType> get item => widget.node;
  //TreeItemDataType get nodeData => item.data;

  late final AnimationController animationController;
  late final CurveTween curveTween;

  bool _isExpandedInternal = false;

  void onAnimationComplete() {
    widget.onAnimationComplete(widget.node.data);
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void expand() {
    final double? from = animationController.value == 1.0 ? 0.0 : null;
    animationController.forward(from: from).whenComplete(onAnimationComplete);
  }

  void collapse() {
    final double? from = animationController.value == 0.0 ? 1.0 : null;
    animationController.reverse(from: from).whenComplete(onAnimationComplete);
  }

  @override
  void initState() {
    super.initState();
    _isExpandedInternal = widget.controller.isItemExpanded(widget.node.data);

    curveTween = CurveTween(curve: widget.curve);
    animationController = AnimationController(
      vsync: this,
      value: _isExpandedInternal ? 1.0 : 0.0,
      duration: widget.duration,
    );
  }

  @override
  void didUpdateWidget(
      covariant _TreeNodeWidget<TreeItemDataType, UniqueIDType> oldWidget) {
    super.didUpdateWidget(oldWidget);

    curveTween.curve = widget.curve;
    animationController.duration = widget.duration;

    final bool expansionState =
        widget.controller.isItemExpanded(widget.node.data);

    if (_isExpandedInternal != expansionState) {
      _isExpandedInternal = expansionState;

      if (widget.showSubtree) {
        _isExpandedInternal ? expand() : collapse();
      }
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget header = widget.headerBuilder(context, widget.node);

    late final Widget content =
        _TreeNodeContent<TreeItemDataType, UniqueIDType>(
      virtualRoot: widget.node,
      headerBuilder: widget.headerBuilder,
      contentBuilder: widget.contentBuilder,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        header,
        if (widget.showSubtree && animationController.isAnimating)
          widget.transitionBuilder(
            context,
            content,
            animationController.drive(curveTween),
          ),
      ],
    );
  }
}

class _TreeNodeContent<TreeItemDataType extends Object, UniqueIDType>
    extends StatefulWidget {
  const _TreeNodeContent({
    super.key,
    required this.virtualRoot,
    required this.headerBuilder,
    required this.contentBuilder,
  });

  final TreeNode<TreeItemDataType> virtualRoot;
  final TreeNodeHeaderBuilder<TreeItemDataType, UniqueIDType> headerBuilder;
  final _TreeNodeContentBuilder<TreeItemDataType, UniqueIDType> contentBuilder;

  @override
  State<_TreeNodeContent<TreeItemDataType, UniqueIDType>> createState() =>
      _TreeNodeContentState<TreeItemDataType, UniqueIDType>();
}

class _TreeNodeContentState<TreeItemDataType extends Object, UniqueIDType>
    extends State<_TreeNodeContent<TreeItemDataType, UniqueIDType>> {
  late List<TreeNode<TreeItemDataType>> virtualItems;

  @override
  void initState() {
    super.initState();
    virtualItems = widget.contentBuilder(widget.virtualRoot);
  }

  @override
  void dispose() {
    virtualItems = <TreeNode<TreeItemDataType>>[];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final TreeNode<TreeItemDataType> virtualItem in virtualItems)
            widget.headerBuilder(context, virtualItem),
        ],
      ),
    );
  }
}
