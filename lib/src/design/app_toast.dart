import 'package:e2_explorer/src/features/common_widgets/text_widget.dart';
import 'package:e2_explorer/src/routes/routes.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

export 'package:toastification/toastification.dart';

class AppToast {
  final String message;
  final String? description;
  final ToastificationType type;
  final ToastificationStyle style;

  AppToast({
    required this.message,
    this.description,
    this.type = ToastificationType.info,
    this.style = ToastificationStyle.flatColored,
  });

  void show(
    BuildContext context, {
    ToastificationType type = ToastificationType.info,
  }) {
    toastification.show(
      context: context,
      dragToClose: true,
      autoCloseDuration: const Duration(seconds: 5),
      icon: Icon(
        type == ToastificationType.error
            ? Icons.error
            : type == ToastificationType.success
                ? Icons.check_circle
                : Icons.info,
        color: AppColors.textPrimaryColor,
      ),
      title: Text(
        message,
        style: TextStyle(
          color: AppColors.textPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      description: description != null
          ? Text(
              description!,
              style: TextStyle(
                color: AppColors.textSecondaryColor,
              ),
            )
          : null,
      type: type,
      style: style,
      borderRadius: BorderRadius.circular(8),
      boxShadow: highModeShadow,
      alignment: Alignment.topRight,
      foregroundColor: Colors.white,
      showProgressBar: false,
      backgroundColor: AppColors.buttonSecondaryBgColor,
    );
  }
}
