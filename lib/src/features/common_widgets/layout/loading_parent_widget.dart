import 'package:e2_explorer/src/features/common_widgets/text_widget.dart';
import 'package:flutter/material.dart';

class LoadingParentWidget extends StatelessWidget {
  const LoadingParentWidget(
      {super.key, required this.isLoading, required this.child, this.message});

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      if (message == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              TextWidget(
                message!,
                style: CustomTextStyles.text14_400_secondary,
              )
            ],
          ),
        );
      }
    } else {
      return child;
    }
  }
}
