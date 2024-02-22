import 'package:e2_explorer/src/styles/text_styles.dart';

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';

class XMLViwer extends StatelessWidget {
  const XMLViwer({super.key, required this.xml});
  final String xml;

  @override
  Widget build(BuildContext context) {
    final Map<String, TextStyle> customTheme = {
      'root': const TextStyle(
        color: Colors.white, // Change text color to white
        backgroundColor:
            Colors.transparent, // Set background color to transparent
        fontSize: 16, // Adjust font size as needed
      ),
      // Define text styles for other syntax elements as needed
    };
    return HighlightView(xml,
        theme: customTheme,
        language: 'xml',
        padding: const EdgeInsets.all(12),
        textStyle: TextStyles.small14regular());
  }
}
