part of hf_tree;

typedef NodeGetUuid<UuidType, ItemType> = UuidType Function(ItemType node);
typedef NodeGetChildren<ItemType> = Iterable<ItemType> Function(ItemType node);
typedef FilterResultSetNewChildren<T> = T Function(
    T oldNode, Iterable<T> newChildren);
typedef FilterResultRemoveChildren<T> = T Function(T oldNode);

T? filterNode<T>(
  T node,
  NodeMatchCondition<T> condition,
  NodeGetChildren<T> getChildren,
  FilterResultSetNewChildren<T> setNewChildren,
) {
  if (condition(node)) {
    return node;
  }
  final List<T> filteredChildren = <T>[];
  final Iterable<T> children = getChildren(node);
  for (final T child in children) {
    final T? filteredChild =
        filterNode(child, condition, getChildren, setNewChildren);
    if (filteredChild != null) {
      filteredChildren.add(filteredChild);
    }
  }

  if (filteredChildren.isNotEmpty) {
    return setNewChildren(node, filteredChildren);
  } else {
    return null;
  }
}

List<T> filterTree<T>({
  required Iterable<T> roots,
  required NodeMatchCondition<T> condition,
  required NodeGetChildren<T> getChildren,
  required FilterResultSetNewChildren<T> setNewChildren,
  required FilterResultRemoveChildren<T> removeChildren,
  bool includeResultsChildren = true,
}) {
  final List<T> result = <T>[];
  for (final T root in roots) {
    final T? filteredRoot =
        filterNode(root, condition, getChildren, setNewChildren);
    if (filteredRoot != null) {
      final T filteredRootToReturn =
          includeResultsChildren ? filteredRoot : removeChildren(filteredRoot);
      result.add(filteredRootToReturn);
    }
  }
  return result;
}
