import 'dart:convert';
import 'dart:io';

import 'package:e2_explorer/src/design/app_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';

class FileUtils {
  static Future<void> saveJSONToFile(BuildContext context,
      {required Map data, required String fileName}) async {
    // Convert data to JSON string
    String jsonString = jsonEncode(data);

    // Get directory where user wants to save the file
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      String filePath = '$directoryPath/$fileName.json';

      // Save JSON to a file
      File file = File(filePath);
      await file.writeAsString(jsonString);
      AppToast(message: "File saved Sucessfully")
          .show(context, type: ToastificationType.success);
    }
  }
}
