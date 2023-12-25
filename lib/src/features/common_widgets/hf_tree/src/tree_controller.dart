// ignore_for_file: public_member_api_docs, sort_constructors_first
part of hf_tree;

const int treeRootLevel = 0;

typedef Visitor<T> = void Function(T node);
typedef NodeMatchCondition<T> = bool Function(T node);

class TreeControllerEvent extends ChangeNotifier {
  void handle() {
    if (super.hasListeners) {
      super.notifyListeners();
    }
  }
}

class TreeController<TreeItemDataType extends Object, UniqueIDType>
    with ChangeNotifier {
  TreeController({
    required this.dataSource,
    this.syncChildCheckboxWithParent = true,
  });

  final TreeControllerEvent onFilterUpdate = TreeControllerEvent();
  TreeDataSource<TreeItemDataType, UniqueIDType> dataSource;

  NodeMatchCondition<TreeItemDataType>? _filterCondition;
  FilterResultSetNewChildren<TreeItemDataType>? _setNewChildren;
  FilterResultRemoveChildren<TreeItemDataType>? _removeChildren;

  void filter({
    required NodeMatchCondition<TreeItemDataType> condition,
    required FilterResultSetNewChildren<TreeItemDataType> setNewChildren,
    required FilterResultRemoveChildren<TreeItemDataType> removeChildren,
    bool shouldRebuild = true,
  }) {
    if (!dataSource.isFiltered) {
      // Save expanded items before applying first filter
      _expandedItemsBeforeFilter = Set<UniqueIDType>.from(_expandedItems);
    }
    clearExpandedItems();
    _filterCondition = condition;
    _setNewChildren = setNewChildren;
    _removeChildren = removeChildren;
    applyFilter();

    handleFilterUpdate(shouldRebuild: shouldRebuild);
  }

  void applyFilter() {
    if (_filterCondition == null ||
        _setNewChildren == null ||
        _removeChildren == null) {
      debugPrint('No filter to apply');
      return;
    }
    dataSource.filter(
      condition: _filterCondition!,
      setNewChildren: _setNewChildren!,
      removeChildren: _removeChildren!,
    );
  }

  void clearFilter() {
    _filterCondition = null;
    _setNewChildren = null;
    _removeChildren = null;
    dataSource.clearFilter();
    // Restore expanded items before filter
    _expandedItems = Set<UniqueIDType>.from(_expandedItemsBeforeFilter);
    handleFilterUpdate();
  }

  void setDataSource(
      TreeDataSource<TreeItemDataType, UniqueIDType> dataSource) {
    final bool previousDataSourceWasFiltered = this.dataSource.isFiltered;
    this.dataSource = dataSource;
    if (previousDataSourceWasFiltered) {
      applyFilter();
    }
    this.rebuild();
  }

  bool get animateExpandCollapse => _animateExpandCollapse;
  bool _animateExpandCollapse = true;

  /// Returns the filteredRoots if a filter is set
  /// or the tree roots otherwise
  Iterable<TreeItemDataType> get displayedTree => dataSource.currentRoots;

  void handleFilterUpdate({bool shouldRebuild = true}) {
    onFilterUpdate.handle();
    if (shouldRebuild) {
      rebuild(animate: false);
    }
  }

  Set<UniqueIDType> _expandedItems = <UniqueIDType>{};
  Set<UniqueIDType> _expandedItemsBeforeFilter = <UniqueIDType>{};

  bool isItemExpanded(TreeItemDataType item) {
    return _expandedItems.contains(dataSource.getUniqueID(item));
  }

  void setItemExpanded(TreeItemDataType item, {required bool expanded}) {
    final UniqueIDType id = dataSource.getUniqueID(item);
    expanded ? _expandedItems.add(id) : _expandedItems.remove(id);
  }

  void toggleItemExpanded(TreeItemDataType item) {
    setItemExpanded(item, expanded: !isItemExpanded(item));
    rebuild();
  }

  void clearExpandedItems() {
    _expandedItems.clear();
  }

  final Set<UniqueIDType> _checkedItemsIds = <UniqueIDType>{};
  final Set<UniqueIDType> _indeterminateItemsIds = <UniqueIDType>{};

  bool? getCheckboxValueForId(UniqueIDType id) {
    // Check in checked items list
    if (_checkedItemsIds.contains(id)) {
      return true;
    }
    // Check in indeterminate items list
    if (_indeterminateItemsIds.contains(id)) {
      return null;
    }
    // If not found in the two sets, then it must be unchecked
    return false;
  }

  bool? getCheckboxValue(TreeItemDataType item) {
    final UniqueIDType id = dataSource.getUniqueID(item);
    return getCheckboxValueForId(id);
  }

  void setCheckboxValueForId(UniqueIDType id, {required bool? value}) {
    switch (value) {
      case true:
        _checkedItemsIds.add(id);
        _indeterminateItemsIds.remove(id);
        break;
      case null:
        _checkedItemsIds.remove(id);
        _indeterminateItemsIds.add(id);
        break;
      case false:
        _checkedItemsIds.remove(id);
        _indeterminateItemsIds.remove(id);
    }
  }

  void updateAncestorsCheckboxesToReflectChildren(TreeItemDataType item) {
    final TreeItemDataType? parent = dataSource.getParent(item);
    if (parent == null) {
      return;
    }
    updateItemCheckboxToReflectChildren(parent);
    updateAncestorsCheckboxesToReflectChildren(parent);
  }

  void updateItemCheckboxToReflectChildren(TreeItemDataType item) {
    final UniqueIDType itemID = dataSource.getUniqueID(item);

    bool? newCheckedState;
    final Iterable<TreeItemDataType> children = dataSource.getChildren(item);

    // In case we don't have any children, do it for the parent
    if (children.isEmpty) {
      updateAncestorsCheckboxesToReflectChildren(item);
      return;
    }

    for (final TreeItemDataType currentChild in children) {
      final UniqueIDType id = dataSource.getUniqueID(currentChild);
      final bool? siblingCheckedState = getCheckboxValueForId(id);
      if (siblingCheckedState == null) {
        // If the current child sibling is indeterminate then the
        // item is indeterminate
        newCheckedState = null;
        break;
      } else
      // The current child sibling checked state is true or false
      // Check if the newCheckedState state is null/indeterminate
      if (newCheckedState == null) {
        // If it is indeterminate then set it
        // to the current sibling checked state (true or false)
        if (syncChildCheckboxWithParent) {
          newCheckedState = siblingCheckedState;
        }
      } else
      // If new checked state is not indeterminate then
      // compare it to current child sibling checked state and see if it is
      // different. If different, then the new item checked state
      // should be indeterminate (null)
      if (newCheckedState != siblingCheckedState) {
        newCheckedState = null;
        break;
      }
    }

    final bool? currentCheckedState = getCheckboxValueForId(itemID);
    if (currentCheckedState != newCheckedState) {
      setCheckboxValueForId(itemID, value: newCheckedState);
      // Also do it for the parent
      updateAncestorsCheckboxesToReflectChildren(item);
    }
  }

  void updateAncestorsIndeterminateStateToReflectChildren(
      TreeItemDataType item) {
    final TreeItemDataType? parent = dataSource.getParent(item);
    if (parent == null) {
      return;
    }
    updateIndeterminateStateToReflectChildren(parent);
    // Do it for the other parents
    updateAncestorsIndeterminateStateToReflectChildren(parent);
  }

  void updateIndeterminateStateToReflectChildren(TreeItemDataType item) {
    final UniqueIDType itemID = dataSource.getUniqueID(item);
    final Iterable<TreeItemDataType> children = dataSource.getChildren(item);

    // In case we don't have any children, return
    if (children.isEmpty) {
      return;
    }

    final bool? prevCheckboxValue = getCheckboxValueForId(itemID);
    // If the item is checked then there is no need to set is as indeterminate
    if (prevCheckboxValue ?? false) {
      return;
    }

    bool hasAtLeastOneCheckedOrIndeterminate = false;

    for (final TreeItemDataType currentChild in children) {
      final bool? checkboxValue = getCheckboxValue(currentChild);
      // Check if it is true or indeterminate
      if (checkboxValue ?? true) {
        hasAtLeastOneCheckedOrIndeterminate = true;
        break;
      }
    }
    if (hasAtLeastOneCheckedOrIndeterminate == true) {
      // Set is as indeterminate
      setCheckboxValueForId(itemID, value: null);
    } else {
      // Otherwise set it as unchecked if it is not checked already
      if (getCheckboxValueForId(itemID) != true) {
        setCheckboxValueForId(itemID, value: false);
      }
    }
  }

  bool syncChildCheckboxWithParent = true;

  void setItemCheckboxValue(TreeItemDataType item,
      {required bool value, bool includeChildren = false}) {
    final UniqueIDType id = dataSource.getUniqueID(item);
    final Iterable<TreeItemDataType> children = dataSource.getChildren(item);

    // Update item
    setCheckboxValueForId(id, value: value);

    // Update children
    if (children.isNotEmpty) {
      if (includeChildren) {
        dataSource.visitChildrenWithAction(
          startingNode: item,
          actionBeforeVisit: (TreeItemDataType currentChild) {
            final UniqueIDType currentChildID =
                dataSource.getUniqueID(currentChild);
            setCheckboxValueForId(currentChildID, value: value);
          },
        );
      } else {
        if (value == false) {
          updateIndeterminateStateToReflectChildren(item);
        }
      }
    }

    // Update parent
    if (syncChildCheckboxWithParent) {
      updateAncestorsCheckboxesToReflectChildren(item);
    } else {
      updateAncestorsIndeterminateStateToReflectChildren(item);
    }

    rebuild();
  }

  void toggleItemCheckbox(TreeItemDataType item) {
    final bool? currentValue = getCheckboxValue(item);
    setItemCheckboxValue(item, value: currentValue == null || !currentValue);
    rebuild();
  }

  /// Override this to enable multiple selection support
  bool isMultiSelectEnabled() {
    return false;
  }

  final Set<UniqueIDType> _selectedItems = <UniqueIDType>{};

  void selectItem(TreeItemDataType item) => setItemSelected(item, value: true);
  void deselectItem(TreeItemDataType item) =>
      setItemSelected(item, value: false);

  bool isItemSelected(TreeItemDataType item) {
    final UniqueIDType id = dataSource.getUniqueID(item);
    return _selectedItems.contains(id);
  }

  void setItemSelected(TreeItemDataType item, {required bool value}) {
    final UniqueIDType id = dataSource.getUniqueID(item);
    // Clear the selected items if only multi-selection is not supported
    if (!isMultiSelectEnabled()) {
      _selectedItems.clear();
    }
    value ? _selectedItems.add(id) : _selectedItems.remove(id);
  }

  /// Notify listeners that the tree structure changed
  void rebuild({bool animate = true}) {
    // Temporarily disable/enable expand/collapse animation
    final bool previousValue = animateExpandCollapse;
    _animateExpandCollapse = animate;
    notifyListeners();
    _animateExpandCollapse = previousValue;
  }

  void _collapse(TreeItemDataType item) =>
      setItemExpanded(item, expanded: false);
  void _expand(TreeItemDataType item) => setItemExpanded(item, expanded: true);

  void expandMatchingNodes(
      NodeMatchCondition<TreeNode<TreeItemDataType>> matchCondition,
      {bool shouldRebuild = true}) {
    visitNodes(
      matchCondition: (TreeNode<TreeItemDataType> node) {
        return dataSource.hasChildren(node.data);
      },
      onVisit: (TreeNode<TreeItemDataType> node) {
        if (matchCondition(node)) {
          TreeNode<TreeItemDataType>? currentNode = node;
          while (currentNode != null) {
            setItemExpanded(currentNode.data, expanded: true);
            currentNode = currentNode.parent;
          }
        }
      },
    );
    if (shouldRebuild) {
      rebuild(animate: false);
    }
  }

  void expand(TreeItemDataType item) {
    if (isItemExpanded(item)) {
      return;
    }
    _expand(item);
    rebuild();
  }

  void expandItems(Iterable<TreeItemDataType> items) {
    bool shouldRebuild = false;
    for (final TreeItemDataType element in items) {
      if (!isItemExpanded(element)) {
        shouldRebuild = true;
        _expand(element);
      }
    }
    if (shouldRebuild) {
      rebuild(animate: false);
    }
  }

  void collapse(TreeItemDataType item) {
    if (!isItemExpanded(item)) {
      return;
    }
    _collapse(item);
    rebuild();
  }

  void _applyCascadingAction(
      Iterable<TreeItemDataType> items, Visitor<TreeItemDataType> action) {
    for (final TreeItemDataType item in items) {
      action(item);
      _applyCascadingAction(dataSource.getChildren(item), action);
    }
  }

  void expandCascading(Iterable<TreeItemDataType> items) {
    if (items.isEmpty) {
      return;
    }
    _applyCascadingAction(items, _expand);
    rebuild();
  }

  void collapseCascading(Iterable<TreeItemDataType> nodes) {
    if (nodes.isEmpty) {
      return;
    }
    _applyCascadingAction(nodes, _collapse);
    rebuild();
  }

  void expandAll() => expandCascading(displayedTree);

  void collapseAll() => collapseCascading(displayedTree);

  bool isNodeExpandedCondition(TreeNode<TreeItemDataType> node) =>
      isItemExpanded(node.data);

  /// Visit nodes matching a specific condition.
  ///
  /// Visits nodes that are expanded if no condition is specified.
  void visitNodes({
    required Visitor<TreeNode<TreeItemDataType>> onVisit,
    NodeMatchCondition<TreeNode<TreeItemDataType>>? matchCondition,
    TreeNode<TreeItemDataType>? startingNode,
  }) {
    final NodeMatchCondition<TreeNode<TreeItemDataType>> visitChildren =
        matchCondition ?? isNodeExpandedCondition;

    void createTreeNodesForItems({
      required TreeNode<TreeItemDataType>? parent,
      required Iterable<TreeItemDataType> items,
      required int level,
    }) {
      TreeNode<TreeItemDataType>? node;

      for (final TreeItemDataType item in items) {
        final bool itemHasChildren = dataSource.hasChildren(item);
        node = TreeNode<TreeItemDataType>(
          parent: parent,
          data: item,
          level: level,
        );

        onVisit(node);

        if (itemHasChildren && visitChildren(node)) {
          final Iterable<TreeItemDataType> children =
              dataSource.getChildren(item);
          createTreeNodesForItems(
            parent: node,
            items: children,
            level: level + 1,
          );
        }
      }
    }

    if (startingNode != null) {
      createTreeNodesForItems(
        parent: startingNode,
        items: dataSource.getChildren(startingNode.data),
        level: startingNode.level + 1,
      );
    } else {
      createTreeNodesForItems(
        parent: null,
        items: displayedTree,
        level: treeRootLevel,
      );
    }
  }

  @override
  void dispose() {
    clearExpandedItems();
    onFilterUpdate.dispose();
    super.dispose();
  }
}

/// Every data object we want to display in a tree must have a TreeNode
/// that points to its parent node and level
class TreeNode<TreeItemDataType extends Object> {
  TreeNode({
    required this.parent,
    required this.data,
    required this.level,
  });

  final TreeNode<TreeItemDataType>? parent;
  final TreeItemDataType data;
  final int level;
}
