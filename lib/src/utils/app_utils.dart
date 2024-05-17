import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<dynamic> showAppDialog({
  required BuildContext context,
  required Widget content,
}) async {
  return await showDialog(context: context, builder: (_) => content);
}

Map<String, dynamic> uppercaseKeysOfMap(Map<String, dynamic> data) {
  var keys = data.keys;
  keys = keys.map((e) => e.toUpperCase());
  var values = data.values.toList();
  return Map.fromIterables(keys, values);
}

String timeAgoString(int seconds) {
  final duration = Duration(seconds: seconds);
  if (duration.inDays > 0) {
    return '${duration.inDays} days ago';
  }
  if (duration.inHours > 0) {
    return '${duration.inHours} hours ago';
  }
  if (duration.inMinutes > 0) {
    return '${duration.inMinutes} minutes ago';
  }
  return '$seconds sec ago';
}

String formatDateFileName(DateTime date) {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('dd-MM-yyyy-HH:mm:ss');
  String formattedDate = formatter.format(now);

  return formattedDate;
}
