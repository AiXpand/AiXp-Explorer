import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/dropdown_search_item.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/hf_dropdown.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_tree/index.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/message_filter.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/payload_filters/box_filter.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/payload_filters/pipeline_filter.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/payload_filters/plugin_instance_filter.dart';
import 'package:e2_explorer/src/features/e2_status/application/filters/payload_filters/plugin_type_filter.dart';
import 'package:e2_explorer/src/features/payload_viewer/presentation/widgets/filter_dropdown/filter_tree_controller.dart';
import 'package:e2_explorer/src/features/payload_viewer/presentation/widgets/filter_dropdown/filter_tree_view.dart';
import 'package:flutter/material.dart';

class FilterDropdown extends StatefulWidget {
  const FilterDropdown({
    super.key,
    required this.filters,
    this.onCheckedItemsChanged,
  });

  final List<MessageFilter> filters;
  final void Function(List<MessageFilter> checkedItems)? onCheckedItemsChanged;

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  late final OverlayController overlayController =
      OverlayController('filter dropdown');
  late final FilterTreeController treeController = FilterTreeController(
    filters: widget.filters,
    onCheckedItemsChanged: widget.onCheckedItemsChanged,
  );

  String _currentSearchQuery = '';

  @override
  void didUpdateWidget(FilterDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters != widget.filters) {
      //debugPrint('new filters for dropdown: ${widget.filters}');
      if (overlayController.isVisible) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          overlayController.rebuild();
        });
        // overlayController.rebuild();
        // treeController.rebuild();
      }
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
    return HFDropdown(
      contentWidth: 300,
      overlayController: overlayController,
      buttonBuilder: (BuildContext context, DropdownButtonOnTap onButtonTap) =>
          ElevatedButton(
        onPressed: onButtonTap,
        // icon: CarbonIcons.location,
        // buttonColor: Colors.transparent,
        // color: ColorStyles.light100,
        child: Text(
          'Filters',
          style: TextStyle(color: Colors.white),
        ),
      ),
      maxContentHeight: 400,
      onClose: (result) {
        treeController.clearExpandedItems();
      },
      contentShellBuilder: (BuildContext context, Widget content) => Container(
        decoration: BoxDecoration(
          color: const Color(0xff2b2b2b),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: const Color(0xff454545)),
        ),
        clipBehavior: Clip.hardEdge,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: content,
        ),
      ),
      contentBuilder: (BuildContext context, OverlayController overlay) {
        return Material(
          color: const Color(0xff2b2b2b),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
              const Divider(
                color: Color(0xff454545),
                height: 1,
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: FilterTreeView(
                    treeController: treeController,
                    onItemChecked: widget.onCheckedItemsChanged,
                    // showCheckboxes: true,
                    // controller: treeController,
                    // onCheckedItemsChanged: (Iterable<Location> items) {
                    //   setState(
                    //     () {
                    //       _checkedItems = items;
                    //     },
                    //   );
                    //   widget.onCheckedItemsChanged?.call(items);
                    // },
                    // emptyStateBuilder: (_) {
                    //   return Padding(
                    //     padding: const EdgeInsets.all(8),
                    //     child: Text(
                    //       'No location: $_currentSearchQuery',
                    //       overflow: TextOverflow.ellipsis,
                    //       maxLines: 1,
                    //       style: TextStyles.small14regular(color: ColorStyles.lightGrey),
                    //     ),
                    //   );
                    // },
                    filters: widget.filters,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
