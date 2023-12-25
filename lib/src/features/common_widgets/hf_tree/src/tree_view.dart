part of hf_tree;

typedef TreeItemCheckedCallback<TreeItemDataType extends Object> = void
    Function(TreeItemDataType item, {bool checked});

class TreeView<TreeItemDataType extends Object, UniqueIDType>
    extends BoxScrollView {
  const TreeView({
    super.key,
    required this.treeController,
    required this.nodeBuilder,
    required this.emptyStateBuilder,
    //this.transitionBuilder = defaultTreeTransitionBuilder,
    this.transitionBuilder = fadeSizeTransitionBuilder,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.linear,
    this.onItemCheckedChange,
    super.padding,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  });

  final TreeController<TreeItemDataType, UniqueIDType> treeController;

  final TreeNodeHeaderBuilder<TreeItemDataType, UniqueIDType> nodeBuilder;
  final Widget Function(BuildContext context) emptyStateBuilder;

  final TreeTransitionBuilder transitionBuilder;
  final TreeItemCheckedCallback<TreeItemDataType>? onItemCheckedChange;

  final Duration duration;

  final Curve curve;
  @override
  Widget buildChildLayout(BuildContext context) {
    return SliverListTreeAnimated<TreeItemDataType, UniqueIDType>(
      controller: treeController,
      nodeBuilder: nodeBuilder,
      emptyStateBuilder: emptyStateBuilder,
      transitionBuilder: transitionBuilder,
      duration: duration,
      curve: curve,
      onItemCheckedChange: onItemCheckedChange,
    );
  }
}
