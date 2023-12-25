part of hf_tree;

class TreeDataSource<TreeItemDataType, UniqueIDType> {
  TreeDataSource({required this.roots});

  final Iterable<TreeItemDataType> roots;

  @mustBeOverridden
  Iterable<TreeItemDataType> getChildren(TreeItemDataType item) {
    throw UnimplementedError();
  }

  @mustBeOverridden
  TreeItemDataType? getParent(TreeItemDataType item) {
    throw UnimplementedError();
  }

  @mustBeOverridden
  UniqueIDType getUniqueID(TreeItemDataType item) {
    throw UnimplementedError();
  }

  @mustBeOverridden
  bool hasChildren(TreeItemDataType item) {
    throw UnimplementedError();
  }

  void filter({
    required NodeMatchCondition<TreeItemDataType> condition,
    required FilterResultSetNewChildren<TreeItemDataType> setNewChildren,
    required FilterResultRemoveChildren<TreeItemDataType> removeChildren,
  }) {
    final List<TreeItemDataType> filteredTree = filterTree<TreeItemDataType>(
      roots: roots,
      condition: condition,
      getChildren: getChildren,
      setNewChildren: setNewChildren,
      removeChildren: removeChildren,
    );
    _filteredDataSource =
        TreeDataSource<TreeItemDataType, UniqueIDType>(roots: filteredTree);
  }

  bool get isFiltered => filteredData != null;

  /// Returns the filteredRoots if a filter is set
  /// or the tree roots otherwise
  Iterable<TreeItemDataType> get currentRoots =>
      isFiltered ? filteredData!.roots : this.roots;

  TreeDataSource<TreeItemDataType, UniqueIDType>? get filteredData =>
      _filteredDataSource;
  void clearFilter() {
    _filteredDataSource = null;
  }

  TreeDataSource<TreeItemDataType, UniqueIDType>? _filteredDataSource;

  void visitTreeWithAction(
      {required TreeItemDataType startingNode,
      required Visitor<TreeItemDataType> action}) {
    action(startingNode);
    final Iterable<TreeItemDataType> children = getChildren(startingNode);
    for (final TreeItemDataType child in children) {
      visitTreeWithAction(startingNode: child, action: action);
    }
  }

  void visitChildrenWithAction({
    required TreeItemDataType startingNode,
    Visitor<TreeItemDataType>? actionBeforeVisit,
    Visitor<TreeItemDataType>? actionAfterVisit,
  }) {
    assert(
      actionBeforeVisit != null || actionAfterVisit != null,
      'Please provide at least one action: before or after',
    );
    final Iterable<TreeItemDataType> children = getChildren(startingNode);
    for (final TreeItemDataType child in children) {
      actionBeforeVisit?.call(child);
      visitChildrenWithAction(
        startingNode: child,
        actionBeforeVisit: actionBeforeVisit,
        actionAfterVisit: actionAfterVisit,
      );
      actionAfterVisit?.call(child);
    }
  }

  void visitParentsWithAction(
      {required TreeItemDataType startingNode,
      required Visitor<TreeItemDataType> action}) {
    TreeItemDataType? currentParent = getParent(startingNode);
    while (currentParent != null) {
      action(currentParent);
      currentParent = getParent(currentParent);
    }
  }
}

class TreeMap<UuidType, ItemType> {
  TreeMap({required this.items, required this.parents});
  final Map<UuidType, ItemType> items;
  final Map<UuidType, ItemType?> parents;
}

TreeMap<UuidType, ItemType> createTreeMap<UuidType, ItemType>({
  required Iterable<ItemType> roots,
  required NodeGetUuid<UuidType, ItemType> getUuid,
  required NodeGetChildren<ItemType> getChildren,
}) {
  final Map<UuidType, ItemType> uuidMap = <UuidType, ItemType>{};
  final Map<UuidType, ItemType?> parentsMap = <UuidType, ItemType?>{};

  void traverseTree(ItemType node, ItemType? parent) {
    final UuidType uuid = getUuid(node);
    uuidMap[uuid] = node;
    if (parent != null) {
      parentsMap[uuid] = parent;
    }

    final Iterable<ItemType> nodeChildren = getChildren(node);
    if (nodeChildren.isNotEmpty) {
      for (final ItemType child in nodeChildren) {
        traverseTree(child, node);
      }
    }
  }

  for (final ItemType root in roots) {
    final UuidType currentRootUuid = getUuid(root);
    traverseTree(root, null);
    parentsMap[currentRootUuid] = null;
  }
  return TreeMap<UuidType, ItemType>(items: uuidMap, parents: parentsMap);
}
