import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:json_data_explorer/json_data_explorer.dart';

class ReusableJsonDataExplorer extends StatefulWidget {
  final List<NodeViewModelState> nodes;
  final DataExplorerStore value;

  const ReusableJsonDataExplorer({
    Key? key,
    required this.nodes,
    required this.value,
  }) : super(key: key);

  @override
  State<ReusableJsonDataExplorer> createState() =>
      _ReusableJsonDataExplorerState();
}

class _ReusableJsonDataExplorerState extends State<ReusableJsonDataExplorer> {
  bool copied = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (search) {
            widget.value.search(search);
          },
        ),
        const SizedBox(height: 10),
        Expanded(
          child: JsonDataExplorer(
            valueFormatter: (value) {
              var newValue = value.toString();

              /// Temporary to ignore the big image field

              if (newValue.length > 500) {
                return newValue.replaceRange(10, newValue.length, '...');
              }
              return newValue;
            },
            itemSpacing: 10,
            nodes: widget.nodes,
            trailingBuilder: (context, node) {
              return !(node.isRoot) && node.isFocused
                  ? Padding(
                      padding: const EdgeInsets.only(
                        right: 20,
                        top: 6,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(maxHeight: 20),
                          icon: Icon(
                            copied ? Icons.check : Icons.copy,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              copied = true;
                            });
                            _copyNode(node, context);
                            Future.delayed(
                              const Duration(seconds: 1),
                              () {
                                setState(() {
                                  copied = false;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    )
                  : const SizedBox();
            },
            theme: DataExplorerTheme(
              rootKeyTextStyle: const TextStyle(
                color: ColorStyles.light100,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              propertyKeyTextStyle: const TextStyle(
                color: ColorStyles.light100,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              valueTextStyle: const TextStyle(
                color: ColorStyles.yellow,
                fontSize: 16,
              ),
              highlightColor: ColorStyles.primaryColor.withOpacity(.5),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _copyNode(NodeViewModelState node, BuildContext context) async {
    String text;
    if (node.isRoot) {
      final value = node.isClass ? 'class' : 'array';
      debugPrint('key and value is ${node.key}: ${value}');
      text = '${node.key}: ${node.value}';
    } else {
      text = '${node.key}: ${node.value}';
    }
    await Clipboard.setData(ClipboardData(text: text));
  }
}
