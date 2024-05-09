import 'package:flutter/cupertino.dart';

class FormUtils {
  static final RegExp _passwordRegex =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

  ///validate password
  static String? validatePassword(BuildContext context, String? value) {
    if (value == null || value == '') {
      return 'This field is required!';
      // return context.locale.this_field_is_required;
    }
    if (value.length < 6) {
      return 'Password must contain at least 6 characters!';
    }

    return null;
  }

  static bool isPasswordValid(String? value) {
    return value != null && _passwordRegex.hasMatch(value);
  }

  ///validate required field
  static String? validateRequiredField(BuildContext context, String? value) {
    if (!isRequiredFieldValid(value)) {
      return 'This field is required!';
    }
    return null;
  }

  static String? validateCreatePipelineUrl(
    BuildContext context, {
    String? val,
    List<String> existingUrl = const [],
  }) {
    // if (!isRequiredFieldValid(val)) {
    //   return 'This field is required!';
    // }
    // String pattern =
    //     r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    // RegExp regExp = RegExp(pattern);
    // if (!regExp.hasMatch(val ?? '')) {
    //   return 'Please enter valid url';
    // }
    final isNotEmpty = existingUrl
        .where((element) => element.toLowerCase() == val!.toLowerCase());

    if (isNotEmpty.isNotEmpty) {
      return 'Enter unique Url';
    }
    return null;
  }

  static String? validateUrl(BuildContext context, String? val) {
    String pattern =
        r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(val ?? '')) {
      return 'Please enter valid url';
    }
    return null;
  }

  static String? validateCreatePipelineKey(
    BuildContext context, {
    String? value,
    List<String> existingKeys = const [],
  }) {
    print(existingKeys);
    if (!isRequiredFieldValid(value)) {
      return 'This field is required!';
    }

    if (isNumericUsingRegularExpression(value!)) {
      return 'This field cannot have numberic value';
    }
    final isNotEmpty = existingKeys
        .where((element) => element.toLowerCase() == value.toLowerCase());

    if (isNotEmpty.isNotEmpty) {
      return 'Entered key matches with existing keys. Unique key required';
    }

    return null;
  }

  static bool isNumericUsingRegularExpression(String string) {
    final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

    return numericRegex.hasMatch(string);
  }

  static bool isRequiredFieldValid(String? value) {
    return value != null && value != '';
  }
}
