import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleMessageViewer extends StatelessWidget {
  const SimpleMessageViewer({
    super.key,
    this.message,
  });

  final Map<String, dynamic>? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const Center(
        child: Text(
          'No message selected',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    }
    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(
                text: const JsonEncoder.withIndent('    ').convert(message)));
            await ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to your clipboard !')));
          },
          child: const Text('Copy to clipboard'),
        ),
        Expanded(
          child: SelectableText(
            const JsonEncoder.withIndent('    ').convert(message),
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}
