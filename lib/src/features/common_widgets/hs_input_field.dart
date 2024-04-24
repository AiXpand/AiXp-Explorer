import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:e2_explorer/src/utils/asset_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// top left is occupied by field name
/// bottom right is occupied by character count
enum OptionalPositionedLabel {
  topRight,
  bottomLeft,
}

class HSInputField extends StatefulWidget {
  const HSInputField({
    super.key,
    required this.inputFieldLabel,
    required this.hintText,
    required this.textFieldController,
    this.onOptionIconTap,
    this.optionalWithIcon = false,
    this.optionalWithText = false,
    this.withFixedCharacterNumber = false,
    this.enabled = true,
    this.isDense = false,
    this.obscureText = false,
    this.isValid = true,
    this.inputBackgroundColor = ColorStyles.dark700,
    this.borderColor = ColorStyles.dark600,
    this.focusBorderColor = ColorStyles.blue,
    this.borderRadius,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.unspecified,
    this.inputFormatters,
    this.innerPadding,
    this.disabledColor,
    this.cornerRadius = 8.0,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.counterText,
    this.autofocus = false,
    this.focusNode,
    this.enableBorder = true,
  });

  /// Label above input field
  final String inputFieldLabel;

  /// Hint of input text
  final String? hintText;

  /// Handles optional question mark icon visibility
  final bool optionalWithIcon;

  /// Handles optional question mark press event
  final VoidCallback? onOptionIconTap;

  /// Handles 'Optional' text visibility
  final bool optionalWithText;

  /// If true, a different input field widget with a fixed character number will be displayed
  /// The max character number is 300
  final bool withFixedCharacterNumber;

  final TextEditingController? textFieldController;

  /// Handles editable state
  final bool enabled;

  /// Handles input field background color.
  /// Default Color is ColorStyles.dark700
  final Color inputBackgroundColor;

  final Color? disabledColor;

  /// Handles input field border color.
  /// Default Color is ColorStyles.dark600
  final Color borderColor;

  /// Handles input field focus border color.
  /// Default Color is ColorStyles.blue
  final Color focusBorderColor;

  /// Handles input field custom border radius
  final BorderRadius? borderRadius;

  /// Handles text changes
  final void Function(String text)? onChanged;

  /// Handles text changes
  final void Function(String text)? onFieldSubmitted;

  /// Handles validations errors
  final String? Function(String?)? validator;

  /// Handles field validation. Default mode is disabled
  final AutovalidateMode autoValidateMode;

  /// Both handles keyboard type & keyboard input
  /// Default keyboard type is text
  final TextInputType keyboardType;

  ///
  final TextInputAction textInputAction;

  final List<TextInputFormatter>? inputFormatters;

  /// Border only validator
  final bool isValid;

  final EdgeInsetsGeometry? innerPadding;

  final bool isDense;
  final bool obscureText;
  final int? maxLength;

  final double cornerRadius;

  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? counterText;

  final bool autofocus;
  final FocusNode? focusNode;
  final bool enableBorder;

  @override
  State<HSInputField> createState() => _HSInputFieldState();
}

class _HSInputFieldState extends State<HSInputField> {
  static const int maxCharacters = 300;
  late FocusNode _focusNode;
  int charactersLeft = maxCharacters;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    charactersLeft = maxCharacters - widget.textFieldController!.text.length;
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Visibility optionalTextWidget = Visibility(
      visible: widget.optionalWithText || widget.optionalWithIcon,
      child: widget.optionalWithText
          ? Text(
              'Optional',
              style: TextStyles.smallStrong(color: ColorStyles.light900),
            )
          : InkWell(
              onTap: widget.onOptionIconTap,
              child: const Padding(
                padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 5),
                child: Icon(
                  CarbonIcons.help,
                  color: ColorStyles.light900,
                  size: 14,
                ),
              ),
            ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.inputFieldLabel.isNotEmpty) ...<Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.inputFieldLabel,
                style: TextStyles.smallStrong(
                  color: widget.enabled
                      ? ColorStyles.light100
                      : ColorStyles.light900,
                ),
              ),
              optionalTextWidget
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (widget.withFixedCharacterNumber)
          _buildFixedCharacterNumberInputField()
        else
          TextFormField(
            controller: widget.textFieldController,
            textInputAction: widget.textInputAction,
            enabled: widget.enabled,
            style: TextStyles.small(
              color:
                  widget.enabled ? ColorStyles.light100 : ColorStyles.light900,
            ),
            autofocus: widget.autofocus,
            autovalidateMode: widget.autoValidateMode,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters ?? <TextInputFormatter>[],
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onFieldSubmitted,
            maxLength: widget.maxLength,
            obscureText: widget.obscureText,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyles.small(color: ColorStyles.light900),
              contentPadding: widget.innerPadding,
              filled: true,
              counterText: widget.counterText,
              isDense: widget.isDense,
              fillColor: widget.enabled
                  ? widget.inputBackgroundColor
                  : widget.disabledColor ?? ColorStyles.dark800,
              enabledBorder: OutlineInputBorder(
                borderRadius: widget.borderRadius ??
                    BorderRadius.all(Radius.circular(widget.cornerRadius)),
                borderSide: !widget.enableBorder
                    ? BorderSide.none
                    : BorderSide(
                        color: widget.isValid
                            ? widget.borderColor
                            : ColorStyles.red,
                        width: 2,
                      ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: widget.borderRadius ??
                    BorderRadius.all(Radius.circular(widget.cornerRadius)),
                borderSide: !widget.enableBorder
                    ? BorderSide.none
                    : const BorderSide(color: ColorStyles.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: widget.borderRadius ??
                    BorderRadius.all(Radius.circular(widget.cornerRadius)),
                borderSide: !widget.enableBorder
                    ? BorderSide.none
                    : const BorderSide(color: ColorStyles.red, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: widget.borderRadius ??
                    BorderRadius.all(Radius.circular(widget.cornerRadius)),
                borderSide: !widget.enableBorder
                    ? BorderSide.none
                    : BorderSide(
                        color: widget.focusBorderColor,
                        width: 2,
                      ),
              ),
              border: !widget.enableBorder ? InputBorder.none : null,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
            ),
          ),
        Visibility(
          visible: widget.withFixedCharacterNumber,
          child: Row(
            children: <Widget>[
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  // '$charactersLeft / $MAX_CHARACTERS char',
                  '$charactersLeft char left',
                  style: TextStyles.smallStrong(color: ColorStyles.light900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFixedCharacterNumberInputField() {
    return SizedBox(
      height: 132,
      child: TextFormField(
        focusNode: _focusNode,
        controller: widget.textFieldController,
        enabled: widget.enabled,
        keyboardType: TextInputType.multiline,
        maxLines: 10,
        maxLength: widget.maxLength ?? 300,
        autovalidateMode: widget.autoValidateMode,
        validator: widget.validator,
        onTap: () {
          setState(() {
            FocusScope.of(context).requestFocus(_focusNode);
          });
        },
        onChanged: (String text) {
          if (widget.onChanged != null) {
            widget.onChanged!.call(text);
          }
          setState(() {
            charactersLeft =
                maxCharacters - widget.textFieldController!.text.length;
          });
        },
        style: TextStyles.small(
          color: widget.enabled ? ColorStyles.light100 : ColorStyles.light900,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          counterText: '',
          hintStyle: TextStyles.small(color: ColorStyles.light900),
          border: !widget.enableBorder
              ? null
              : OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: widget.borderColor),
                ),
          enabledBorder: !widget.enableBorder
              ? null
              : OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: widget.borderColor),
                ),
          contentPadding: const EdgeInsets.all(12),
          suffixIcon: widget.suffixIcon,
        ),
      ),
    );
  }
}

class NumericalRangeFormatter extends TextInputFormatter {
  NumericalRangeFormatter({required this.min, required this.max});

  final double min;
  final double max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if ((newValue.text.length > 1 && newValue.text.length <= 3) &&
        newValue.text.split('').every((String element) => element == '0')) {
      return oldValue;
    }
    if (newValue.text == '') {
      return newValue;
    } else if (int.parse(newValue.text) < min) {
      return TextEditingValue(text: '$min');
    } else {
      return int.parse(newValue.text) > max ? oldValue : newValue;
    }
  }
}

//
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:e2_explorer/src/styles/color_styles.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import '../../styles/text_styles.dart';
//
// /// top left is occupied by field name
// /// bottom right is occupied by character count
// enum OptionalPositionedLabel {
//   topRight,
//   bottomLeft,
// }
//
// class HSInputField extends StatefulWidget {
//   HSInputField({
//     super.key,
//     required this.inputFieldLabel,
//     required this.hintText,
//     this.textFieldController,
//     this.initialValue,
//     this.onOptionIconTap,
//     this.optionalWithIcon = false,
//     this.optionalWithText = false,
//     this.withFixedCharacterNumber = false,
//     this.enabled = true,
//     this.isDense = false,
//     this.obscureText = false,
//     this.isValid = true,
//     Color? inputBackgroundColor,
//     Color? borderColor,
//     Color? focusBorderColor,
//     this.borderRadius,
//     this.onChanged,
//     this.onFieldSubmitted,
//     this.validator,
//     this.autoValidateMode = AutovalidateMode.disabled,
//     this.keyboardType = TextInputType.text,
//     this.textInputAction = TextInputAction.unspecified,
//     this.inputFormatters,
//     this.innerPadding,
//     this.disabledColor,
//     this.cornerRadius = Dimens.inputFieldBorderRadius,
//     this.maxLength,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.counterText,
//     this.autofocus = false,
//     this.focusNode,
//     this.enableBorder = true,
//     this.style,
//     this.autoFillHints,
//     this.autocorrect = false,
//     this.enableSuggestions = false,
//   })  : inputBackgroundColor =
//             inputBackgroundColor ?? AppColors.inputFieldFillColor,
//         borderColor = borderColor ?? AppColors.inputFieldDefaultBorderColor,
//         focusBorderColor =
//             focusBorderColor ?? AppColors.inputFieldFocusedBorderColor;
//
//   /// Initial value
//   final String? initialValue;
//
//   /// Label above input field
//   final String inputFieldLabel;
//
//   /// Hint of input text
//   final String? hintText;
//
//   /// Handles optional question mark icon visibility
//   final bool optionalWithIcon;
//
//   /// Handles optional question mark press event
//   final VoidCallback? onOptionIconTap;
//
//   /// Handles 'Optional' text visibility
//   final bool optionalWithText;
//
//   /// If true, a different input field widget with a fixed character number will be displayed
//   /// The max character number is 300
//   final bool withFixedCharacterNumber;
//
//   final TextEditingController? textFieldController;
//
//   /// Handles editable state
//   final bool enabled;
//
//   /// Handles input field background color.
//   /// Default Color is HFColors.dark700
//   final Color inputBackgroundColor;
//
//   final Color? disabledColor;
//
//   /// Handles input field border color.
//   /// Default Color is HFColors.dark600
//   final Color borderColor;
//
//   /// Handles input field focus border color.
//   /// Default Color is HFColors.blue
//   final Color focusBorderColor;
//
//   /// Handles input field custom border radius
//   final BorderRadius? borderRadius;
//
//   /// Handles text changes
//   final void Function(String text)? onChanged;
//
//   /// Handles text changes
//   final void Function(String text)? onFieldSubmitted;
//
//   /// Handles validations errors
//   final String? Function(String?)? validator;
//
//   /// Handles field validation. Default mode is disabled
//   final AutovalidateMode autoValidateMode;
//
//   /// Both handles keyboard type & keyboard input
//   /// Default keyboard type is text
//   final TextInputType keyboardType;
//
//   ///
//   final TextInputAction textInputAction;
//
//   final List<TextInputFormatter>? inputFormatters;
//
//   /// Border only validator
//   final bool isValid;
//
//   final EdgeInsetsGeometry? innerPadding;
//
//   final bool isDense;
//   final bool obscureText;
//   final int? maxLength;
//
//   final double cornerRadius;
//
//   final Widget? prefixIcon;
//   final Widget? suffixIcon;
//   final String? counterText;
//
//   final bool autofocus;
//   final FocusNode? focusNode;
//   final bool enableBorder;
//   final TextStyle? style;
//   final List<String>? autoFillHints;
//   final bool autocorrect;
//   final bool enableSuggestions;
//
//   @override
//   State<HSInputField> createState() => _HSInputFieldState();
// }
//
// class _HSInputFieldState extends State<HSInputField> {
//   static const int maxCharacters = 300;
//   late FocusNode _focusNode;
//   int charactersLeft = maxCharacters;
//   late final TextEditingController _controller =
//       widget.textFieldController ?? TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _focusNode = widget.focusNode ?? FocusNode();
//     charactersLeft = maxCharacters - _controller.text.length;
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _focusNode.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Visibility optionalTextWidget = Visibility(
//       visible: widget.optionalWithText || widget.optionalWithIcon,
//       child: widget.optionalWithText
//           ? Text(
//               'Optional',
//               style: TextStyles.smallStrong(
//                 color: AppColors.inputFieldLabelTextColor,
//               ),
//             )
//           : InkWell(
//               onTap: widget.onOptionIconTap,
//               child: Padding(
//                 padding: const EdgeInsets.only(
//                   top: 8,
//                   left: 8,
//                   right: 8,
//                   bottom: 5,
//                 ),
//                 child: Icon(
//                   CarbonIcons.help,
//                   color: AppColors.inputFieldLabelTextColor,
//                   size: 14,
//                 ),
//               ),
//             ),
//     );
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         if (widget.inputFieldLabel.isNotEmpty) ...<Widget>[
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Text(
//                 widget.inputFieldLabel,
//                 style: NewTextStyles.inputFieldLabel(
//                   color: widget.enabled
//                       ? AppColors.inputFieldLabelTextColor
//                       : AppColors.inputFieldLabelTextColor.darken(),
//                 ),
//               ),
//               optionalTextWidget
//             ],
//           ),
//           const SizedBox(height: 8),
//         ],
//         if (widget.withFixedCharacterNumber)
//           _buildFixedCharacterNumberInputField()
//         else
//           TextFormField(
//             enableSuggestions: widget.enableSuggestions,
//             autocorrect: widget.autocorrect,
//             initialValue: widget.initialValue,
//             controller: _controller,
//             textInputAction: widget.textInputAction,
//             enabled: widget.enabled,
//             autofillHints: widget.autoFillHints,
//             style: widget.style ??
//                 NewTextStyles.inputFieldInputText(enabled: widget.enabled),
//             autofocus: widget.autofocus,
//             autovalidateMode: widget.autoValidateMode,
//             keyboardType: widget.keyboardType,
//             inputFormatters: widget.inputFormatters ?? <TextInputFormatter>[],
//             validator: widget.validator,
//             onChanged: widget.onChanged,
//             onFieldSubmitted: widget.onFieldSubmitted,
//             maxLength: widget.maxLength,
//             obscureText: widget.obscureText,
//             cursorColor: AppColors.inputFieldCursorColor,
//             decoration: InputDecoration(
//               hoverColor: AppColors.inputFieldFillColor,
//               hintText: widget.hintText,
//               hintStyle: NewTextStyles.inputFieldHintText(),
//               contentPadding: widget.innerPadding,
//               filled: true,
//               counterText: widget.counterText,
//               isDense: widget.isDense,
//               fillColor: widget.enabled
//                   ? widget.inputBackgroundColor
//                   : widget.disabledColor,
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: widget.borderRadius ??
//                     BorderRadius.all(
//                       Radius.circular(widget.cornerRadius),
//                     ),
//                 borderSide: !widget.enableBorder
//                     ? BorderSide.none
//                     : BorderSide(
//                         color: widget.isValid
//                             ? widget.borderColor
//                             : AppColors.inputFieldErrorBorderColor,
//                         width: 1,
//                       ),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderRadius: widget.borderRadius ??
//                     BorderRadius.all(
//                       Radius.circular(widget.cornerRadius),
//                     ),
//                 borderSide: !widget.enableBorder
//                     ? BorderSide.none
//                     : BorderSide(
//                         color: AppColors.inputFieldErrorBorderColor,
//                         width: 1,
//                       ),
//               ),
//               focusedErrorBorder: OutlineInputBorder(
//                 borderRadius: widget.borderRadius ??
//                     BorderRadius.all(
//                       Radius.circular(widget.cornerRadius),
//                     ),
//                 borderSide: !widget.enableBorder
//                     ? BorderSide.none
//                     : BorderSide(
//                         color: AppColors.inputFieldErrorBorderColor,
//                         width: 1,
//                       ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: widget.borderRadius ??
//                     BorderRadius.all(
//                       Radius.circular(widget.cornerRadius),
//                     ),
//                 borderSide: !widget.enableBorder
//                     ? BorderSide.none
//                     : BorderSide(
//                         color: widget.focusBorderColor,
//                         width: 1,
//                       ),
//               ),
//               border: !widget.enableBorder ? InputBorder.none : null,
//               prefixIcon: widget.prefixIcon,
//               suffixIcon: widget.suffixIcon,
//             ),
//           ),
//         Visibility(
//           visible: widget.withFixedCharacterNumber,
//           child: Row(
//             children: <Widget>[
//               const Spacer(),
//               Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Text(
//                   // '$charactersLeft / $MAX_CHARACTERS char',
//                   '$charactersLeft char left',
//                   style: TextStyles.smallStrong(
//                     color: AppColors.textPrimaryColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFixedCharacterNumberInputField() {
//     return SizedBox(
//       height: 132,
//       child: TextFormField(
//         initialValue: widget.initialValue,
//         focusNode: _focusNode,
//         controller: _controller,
//         enabled: widget.enabled,
//         keyboardType: TextInputType.multiline,
//         maxLines: 10,
//         maxLength: widget.maxLength ?? 300,
//         autovalidateMode: widget.autoValidateMode,
//         validator: widget.validator,
//         onTap: () {
//           setState(() {
//             FocusScope.of(context).requestFocus(_focusNode);
//           });
//         },
//         onChanged: (String text) {
//           if (widget.onChanged != null) {
//             widget.onChanged!.call(text);
//           }
//           setState(() {
//             charactersLeft = maxCharacters - _controller.text.length;
//           });
//         },
//         style: NewTextStyles.inputFieldInputText(enabled: widget.enabled),
//         decoration: InputDecoration(
//           hoverColor: AppColors.inputFieldFillColor,
//           filled: true,
//           fillColor: widget.enabled
//               ? widget.inputBackgroundColor
//               : widget.disabledColor ?? AppColors.inputFieldDisabledFillColor,
//           hintText: widget.hintText,
//           counterText: '',
//           hintStyle: TextStyles.small(
//             color: AppColors.inputFieldTextInputColor.darken(),
//           ),
//           border: !widget.enableBorder
//               ? null
//               : OutlineInputBorder(
//                   borderSide: BorderSide(width: 1, color: widget.borderColor),
//                 ),
//           enabledBorder: !widget.enableBorder
//               ? null
//               : OutlineInputBorder(
//                   borderSide: BorderSide(width: 1, color: widget.borderColor),
//                 ),
//           contentPadding: const EdgeInsets.all(12),
//           suffixIcon: widget.suffixIcon,
//         ),
//       ),
//     );
//   }
// }
//
// class NumericalRangeFormatter extends TextInputFormatter {
//   NumericalRangeFormatter({required this.min, required this.max});
//
//   final double min;
//   final double max;
//
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     if ((newValue.text.length > 1 && newValue.text.length <= 3) &&
//         newValue.text.split('').every((String element) => element == '0')) {
//       return oldValue;
//     }
//     if (newValue.text == '') {
//       return newValue;
//     } else if (int.parse(newValue.text) < min) {
//       return TextEditingValue(text: '$min');
//     } else {
//       return int.parse(newValue.text) > max ? oldValue : newValue;
//     }
//   }
// }

class TextInputFieldWidget extends StatefulWidget {
  const TextInputFieldWidget({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.validator,
    this.inputFormatters,
    this.obscureText = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? Function(BuildContext, String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;

  @override
  State<TextInputFieldWidget> createState() => _TextInputFieldWidgetState();
}

class _TextInputFieldWidgetState extends State<TextInputFieldWidget> {
  TextEditingController? _controller;
  FocusNode? _focusNode;

  bool _obscureText = false;
  TextEditingController get controller => widget.controller ?? _controller!;

  FocusNode get focusNode => widget.focusNode ?? _focusNode!;

  @override
  void initState() {
    _obscureText = widget.obscureText;
    if (widget.controller == null) {
      _controller = TextEditingController();
    }
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      inputFormatters: widget.inputFormatters,
      obscureText: _obscureText,
      decoration: InputDecoration(
        hintText: widget.hintText,
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
        // contentPadding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20)
      ),
    );
  }

  String? validator(String? val) => widget.validator?.call(context, val);
}
