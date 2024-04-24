import 'package:e2_explorer/src/features/e2_status/presentation/widgets/boxes_list.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/views/debug_viewer.dart';
import 'package:flutter/material.dart';

class BoxViewer extends StatefulWidget {
  const BoxViewer({super.key});

  @override
  State<BoxViewer> createState() => _BoxViewerState();
}

class _BoxViewerState extends State<BoxViewer> {
  String? _selectedBox;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: <Widget>[
          BoxesList(onBoxSelected: (boxName) {
            setState(() {
              _selectedBox = boxName;
            });
          }),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: _selectedBox != null
                ? DebugViewer(
                    boxName: _selectedBox!,
                  )
                : const Center(
                    child: Text(
                      'Select a box to display',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
