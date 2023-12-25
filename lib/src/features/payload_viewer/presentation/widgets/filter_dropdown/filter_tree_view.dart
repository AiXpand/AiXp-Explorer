import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/dropdown_search_item.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_tree/index.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/message_filter.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/payload_filters/box_filter.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/payload_filters/pipeline_filter.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/payload_filters/plugin_instance_filter.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/payload_filters/plugin_type_filter.dart';
import 'package:e2_explorer/src/features/payload_viewer/presentation/widgets/filter_dropdown/filter_tree_controller.dart';
import 'package:e2_explorer/src/features/payload_viewer/presentation/widgets/filter_dropdown/items/filter_tree_item.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

class FilterTreeView extends StatefulWidget {
  const FilterTreeView({
    super.key,
    required this.filters,
    this.onItemChecked,
    this.treeController,
  });

  final List<MessageFilter> filters;
  final void Function(List<MessageFilter> checkedItems)? onItemChecked;
  final FilterTreeController? treeController;

  @override
  State<FilterTreeView> createState() => _FilterTreeViewState();
}

class _FilterTreeViewState extends State<FilterTreeView> {
  late final FilterTreeController treeController;
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    treeController = widget.treeController ??
        FilterTreeController(
          filters: widget.filters,
          onCheckedItemsChanged: widget.onItemChecked,
        );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(FilterTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters != widget.filters) {
      treeController.setFilters(widget.filters);
    }
  }

  void filterTree(String searchQuery, {bool shouldRebuild = true}) {
    treeController
      ..filter(
          shouldRebuild: shouldRebuild,
          condition: (MessageFilter messageFilter) {
            return messageFilter.name.toLowerCase().contains(searchQuery);
          },
          setNewChildren:
              (MessageFilter oldNode, Iterable<MessageFilter> newChildren) {
            switch (oldNode.type) {
              case FilterType.pipelineFilter:
                return (oldNode as PipelineFilter).copyWith(
                    children: newChildren
                        .toList()
                        .map((e) => e as PluginTypeFilter)
                        .toList());
              case FilterType.pluginTypeFilter:
                return (oldNode as PluginTypeFilter).copyWith(
                    children: newChildren
                        .toList()
                        .map((e) => e as PluginInstanceFilter)
                        .toList());
              case FilterType.pluginInstanceFilter:
                return oldNode;
              case FilterType.boxFilter:
                return (oldNode as BoxFilter).copyWith(
                    children: newChildren
                        .toList()
                        .map((e) => e as PipelineFilter)
                        .toList());
            }
          },
          removeChildren: (MessageFilter oldNode) {
            switch (oldNode.type) {
              case FilterType.pipelineFilter:
                return (oldNode as PipelineFilter).copyWith(children: []);
              case FilterType.pluginTypeFilter:
                return (oldNode as PluginTypeFilter).copyWith(children: []);
              case FilterType.pluginInstanceFilter:
                return oldNode;
              case FilterType.boxFilter:
                return (oldNode as BoxFilter).copyWith(children: []);
            }
          })
      ..expandMatchingNodes(
        (TreeNode<MessageFilter> node) =>
            node.data.name.toLowerCase().contains(searchQuery),
        shouldRebuild: shouldRebuild,
      );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownSearchItem(
          onChanged: (String searchQuery) {
            _currentSearchQuery = searchQuery.toLowerCase();
            if (searchQuery.isEmpty) {
              treeController.clearFilter();
              return;
            }
            filterTree(_currentSearchQuery);
          },
        ),
        const SizedBox(height: 8),
        TreeView<MessageFilter, String>(
          shrinkWrap: true,
          treeController: treeController,
          nodeBuilder: (context, node) {
            bool isExpanded = treeController.isItemExpanded(node.data);
            bool? isChecked = treeController.getCheckboxValue(node.data);
            bool hasChildren =
                treeController.dataSource.getChildren(node.data).isNotEmpty;

            return FilterTreeItem(
              onTap: () {
                isExpanded
                    ? treeController.collapse(node.data)
                    : treeController.expand(node.data);
              },
              onCheckboxPressed: () {
                // Set true if it is indeterminate or the opposite if not indeterminate
                treeController.setItemCheckboxValue(node.data,
                    value: isChecked == null ? true : !isChecked);
              },
              title: node.data.name,
              isChecked: isChecked,
              isExpanded: isExpanded,
              hasChildren: hasChildren,
              depth: node.level,
            );
            return Padding(
              padding: EdgeInsets.only(left: node.level * 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (treeController.dataSource.hasChildren(node.data))
                    InkWell(
                      onTap: () {
                        isExpanded
                            ? treeController.collapse(node.data)
                            : treeController.expand(node.data);
                      },
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Icon(
                          isExpanded ? CarbonIcons.subtract : CarbonIcons.add,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    SizedBox(width: 24, height: 24, child: Container()),
                  const SizedBox(
                    width: 4,
                  ),
                  InkWell(
                    onTap: () {
                      // Set true if it is indeterminate or the opposite if not indeterminate
                      treeController.setItemCheckboxValue(node.data,
                          value: isChecked == null ? true : !isChecked);
                    },
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        isChecked == null
                            ? CarbonIcons.checkbox_indeterminate_filled
                            : isChecked == true
                                ? CarbonIcons.checkbox_checked_filled
                                : CarbonIcons.checkbox,
                        color: isChecked != false ? Colors.blue : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Flexible(
                    child: Text(
                      node.data.name,
                      style: TextStyles.small14(
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
          emptyStateBuilder: (context) {
            return Text(
              'No filters available',
              style: TextStyles.small14(
                color: Colors.white,
              ),
            );
          },
        ),
      ],
    );
  }
}
