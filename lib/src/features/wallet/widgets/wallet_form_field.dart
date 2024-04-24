import 'package:e2_explorer/src/utils/asset_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WalletFormFieldWidget extends StatefulWidget {
  final TextEditingController? controller;

  /// Handles text changes
  final void Function(String text)? onChanged;

  /// Handles text changes
  final void Function(String text)? onFieldSubmitted;

  /// Handles validations errors
  final String? Function(String?)? validator;

  final bool obscureText;

  final String hintText;

  final AutovalidateMode autovalidateMode;

  final int? maxLines;

  const WalletFormFieldWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.obscureText = false,
    this.hintText = '',
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.maxLines,
  });

  @override
  State<WalletFormFieldWidget> createState() => _WalletFormFieldWidgetState();
}

class _WalletFormFieldWidgetState extends State<WalletFormFieldWidget> {
  bool _obscureText = false;

  @override
  void initState() {
    _obscureText = widget.obscureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: widget.obscureText
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: SvgPicture.asset(
                    AssetUtils.getSvgIconPath(
                      _obscureText ? "eye-off" : "eye",
                    ),
                    height: 16,
                    fit: BoxFit.fill,
                  ),
                ),
              )
            : null,
        hintText: widget.hintText,
      ),
    );
  }
}
