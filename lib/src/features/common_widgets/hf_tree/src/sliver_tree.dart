part of hf_tree;

typedef TreeNodeHeaderBuilder<TreeItemDataType extends Object, UniqueIDType>
    = Widget Function(
  BuildContext context,
  TreeNode<TreeItemDataType> node,
);

class SliverTree<TreeItemDataType extends Object, UniqueIDType>
    extends StatefulWidget {
  const SliverTree({
    super.key,
    required this.controller,
    required this.nodeBuilder,
    required this.emptyStateBuilder,
  });

  final TreeController<TreeItemDataType, UniqueIDType> controller;
  final TreeNodeHeaderBuilder<TreeItemDataType, UniqueIDType> nodeBuilder;
  final Widget Function(BuildContext context) emptyStateBuilder;

  @override
  State<SliverTree<TreeItemDataType, UniqueIDType>> createState() =>
      _SliverTreeState<TreeItemDataType, UniqueIDType>();
}

class _SliverTreeState<TreeItemDataType extends Object, UniqueIDType>
    extends State<SliverTree<TreeItemDataType, UniqueIDType>> {
  /// A list containing all the expanded items and their children
  List<TreeNode<TreeItemDataType>> _displayedNodesList =
      <TreeNode<TreeItemDataType>>[];

  void _updateDisplayedNodesList() {
    final List<TreeNode<TreeItemDataType>> displayedNodesList =
        <TreeNode<TreeItemDataType>>[];
    widget.controller.visitNodes(onVisit: displayedNodesList.add);
    _displayedNodesList = displayedNodesList;
  }

  void _rebuild() => setState(_updateDisplayedNodesList);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    _updateDisplayedNodesList();
  }

  @override
  void didUpdateWidget(
      covariant SliverTree<TreeItemDataType, UniqueIDType> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
      _updateDisplayedNodesList();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _displayedNodesList = <TreeNode<TreeItemDataType>>[];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: _displayedNodesList.length,
        (BuildContext context, int index) {
          return widget.nodeBuilder(context, _displayedNodesList[index]);
        },
      ),
    );
  }
}
