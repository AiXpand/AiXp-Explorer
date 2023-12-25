import 'package:e2_explorer/src/features/common_widgets/hf_tree/index.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/message_filter.dart';
import 'package:e2_explorer/src/features/payload_viewer/presentation/widgets/filter_dropdown/filter_tree_data_source.dart';

class FilterTreeController extends TreeController<MessageFilter, String> {
  List<MessageFilter> filters;
  void Function(List<MessageFilter> checkedItems)? onCheckedItemsChanged;

  FilterTreeController({
    required this.filters,
    this.onCheckedItemsChanged,
  }) : super(dataSource: FilterTreeDataSource(roots: filters));

  void setFilters(List<MessageFilter> filters) {
    this.filters = filters;
    super.setDataSource(FilterTreeDataSource(roots: filters));
  }

  @override
  void setItemCheckboxValue(MessageFilter item,
      {required bool value, bool includeChildren = true}) {
    super.setItemCheckboxValue(item,
        value: value, includeChildren: includeChildren);
    final newCheckedItems = getCheckedItems(dataSource.roots);
    onCheckedItemsChanged?.call(newCheckedItems);
  }

  List<MessageFilter> getCheckedItems(Iterable<MessageFilter> children) {
    List<MessageFilter> results = [];
    for (final node in children) {
      final checkboxState = getCheckboxValueForId(node.id);
      switch (checkboxState) {
        // Skip item if it is unchecked
        case false:
          continue;
        // add it to results if it is checked
        case true:
          results.add(node);
          break;
        // visit children if it is indetereminate
        case null:
          final nodeChildren = dataSource.getChildren(node);
          final checkedChildren = getCheckedItems(nodeChildren);
          results.addAll(checkedChildren);
      }
    }
    return results;
  }
}
