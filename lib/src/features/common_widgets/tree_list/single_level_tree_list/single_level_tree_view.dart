import 'package:e2_explorer/src/features/common_widgets/tree_list/tree_child_element.dart';
import 'package:e2_explorer/src/features/common_widgets/tree_list/tree_parent_element.dart';
import 'package:flutter/material.dart';

/// TODO: make a generic version of this!!!
class SingleLevelTreeView extends StatefulWidget {
  const SingleLevelTreeView({
    super.key,
    required this.pipelineMessages,
    required this.onPipelineSelected,
    required this.onPluginSelected,
  });

  final List<Map<String, dynamic>> pipelineMessages;
  final void Function(String pipelineName) onPipelineSelected;
  final void Function(String pluginName, String pipelineName) onPluginSelected;

  @override
  State<StatefulWidget> createState() => _TreeListViewState();
}

class _TreeListViewState extends State<SingleLevelTreeView> {
  late final ScrollController _controllerOne;
  String? selectedParentText;
  String? selectedChildText;

  @override
  void dispose() {
    _controllerOne.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controllerOne = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: _controllerOne,
      thumbVisibility: true,

      interactive: true,
      // radius: Radius.circular(2),
      thumbColor: const Color(0xff484B50),
      trackColor: const Color(0xff272727),
      trackBorderColor: const Color(0xff272727),
      mainAxisMargin: 4,
      trackVisibility: true,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, left: 8, bottom: 8),
        child: ListView.builder(
          controller: _controllerOne,
          shrinkWrap: true,
          // physics: NeverScrollableScrollPhysics(),
          itemCount: widget.pipelineMessages.length,
          itemBuilder: (BuildContext item, int index) {
            final childrenRaw =
                (widget.pipelineMessages[index]['PLUGINS'] as List)
                    .map((plugin) {
              final pluginMap = plugin as Map<String, dynamic>;
              final pluginInstances = pluginMap['INSTANCES'] as List;

              final List<Widget> children = [];

              for (final instance in pluginInstances) {
                final pluginInstance = instance as Map<String, dynamic>;
                children.add(
                  TreeChildElement(
                    text: pluginInstance['INSTANCE_ID'],
                    isSelected:
                        pluginInstance['INSTANCE_ID'] == selectedChildText &&
                            widget.pipelineMessages[index]['NAME'] ==
                                selectedParentText,
                    onTap: () {
                      widget.onPluginSelected.call(
                          pluginInstance['INSTANCE_ID'],
                          widget.pipelineMessages[index]['NAME']);
                      setState(() {
                        selectedParentText =
                            widget.pipelineMessages[index]['NAME'];
                        selectedChildText = pluginInstance['INSTANCE_ID'];
                      });
                    },
                  ),
                );
              }
              return children;
            }).toList();

            final children = <Widget>[];

            for (final child in childrenRaw) {
              children.addAll(child);
            }

            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TreeParentElement(
                isSelected: widget.pipelineMessages[index]['NAME'] ==
                    selectedParentText,
                isChildSelected: widget.pipelineMessages[index]['NAME'] ==
                        selectedParentText &&
                    selectedChildText != null,
                rightAlignedText: widget.pipelineMessages[index]['TYPE'],
                onTap: () {
                  widget.onPipelineSelected
                      .call(widget.pipelineMessages[index]['NAME']);
                  setState(() {
                    selectedParentText = widget.pipelineMessages[index]['NAME'];
                    selectedChildText = null;
                  });
                },
                text: widget.pipelineMessages[index]['NAME'],
                children: children,
                // categoryName: widget.pluginsByType.keys.toList()[index],
                // plugins: widget.pluginsByType.values.toList()[index],
                // pluginOnTap: widget.pluginOnTap,
                // onPluginDelete: widget.onPluginDelete,
                // selectedPluginUuid: widget.selectedPluginUuid,
              ),
            );
          },
        ),
      ),
    );
  }
}
