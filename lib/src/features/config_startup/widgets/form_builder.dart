import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:e2_explorer/src/widgets/custom_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';

class FormTextStyle extends StatelessWidget {
  final String text;
  const FormTextStyle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    List<String> texts = text.toUpperCase().split(".");
    List<Color> colors = [
      Colors.white,
      const Color(0xFFFFD600),
      const Color(0xFFFF2C78),
    ]; // Define colors

    List<InlineSpan> textSpans = [];

    for (int i = 0; i < texts.length; i++) {
      textSpans.add(
        TextSpan(
          text: texts[i],
          style: TextStyle(
            color: i == 0
                ? Colors.white
                : colors[(i - 1) % (colors.length - 1) + 1],
          ),
        ),
      );
      if (i != texts.length - 1) {
        textSpans.add(
          TextSpan(
            text: ".",
            style: TextStyle(
              color: i == 0
                  ? Colors.white
                  : colors[(i - 1) % (colors.length - 1) + 1],
            ),
          ),
        );
      }
    }
    return RichText(
      text: TextSpan(children: textSpans),
    );
  }
}

enum FormBuilderType {
  text,
  number,
  boolean,
  map,
  list;

  FormBuilderType get type => this;
  static FormBuilderType fromInstanceType(dynamic instanceType) {
    if (instanceType is String ||
        instanceType is DateTime ||
        instanceType is Duration ||
        instanceType == null) {
      if (bool.tryParse(instanceType) != null) {
        return FormBuilderType.boolean;
      }
      return FormBuilderType.text;
    }
    if (instanceType is int || instanceType is double || instanceType is num) {
      return FormBuilderType.number;
    } else if (instanceType is bool) {
      return FormBuilderType.boolean;
    } else if (instanceType is List) {
      return FormBuilderType.list;
    } else if (instanceType is Map<String, dynamic>) {
      return FormBuilderType.map;
    } else {
      throw Exception('Unsupported type');
    }
  }
}

class FormBuilder extends StatefulWidget {
  const FormBuilder({
    Key? key,
    required this.type,
    required this.label,
    this.initialValue,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  final FormBuilderType type;
  final String label;
  final dynamic initialValue;
  final String? Function(String?)? validator;
  final void Function(String value, FormBuilderType formType)? onChanged;

  @override
  State<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue?.toString());
    _controller.addListener(() {
      widget.onChanged?.call(_controller.text, widget.type);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        FormTextStyle(text: widget.label),
        const SizedBox(height: 10),
        if (widget.type == FormBuilderType.text)
          TextFormField(
            controller: _controller,
            validator: widget.validator,
          ),
        if (widget.type == FormBuilderType.number)
          TextFormField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: widget.validator,
            inputFormatters: <NumberTextInputFormatter>[
              NumberTextInputFormatter(
                integerDigits: 10,
                decimalDigits: 0,
                maxValue: '1000000000.00',
                decimalSeparator: '.',
                allowNegative: true,
                overrideDecimalPoint: true,
                insertDecimalPoint: false,
                insertDecimalDigits: true,
              ),
            ],
          ),
        if (widget.type == FormBuilderType.boolean)
          CustomDropDown<bool>(
            onChanged: (value) {},
            value: true,
            controller: _controller,
            hintText: "Select Option",
            dropDownItems: const [
              DropdownMenuItem(
                value: true,
                child: Text("True"),
              ),
              DropdownMenuItem(
                value: false,
                child: Text("False"),
              ),
            ],
          ),
      ],
    );
  }
}

class JsonFormBuilder extends StatefulWidget {
  final Map<String, dynamic> data;
  final void Function(Map<String, dynamic> newData)? onChanged;

  const JsonFormBuilder({super.key, required this.data, this.onChanged});

  @override
  State<JsonFormBuilder> createState() => _JsonFormBuilderState();
}

class _JsonFormBuilderState extends State<JsonFormBuilder> {
  late Map<String, dynamic> newData;

  @override
  void initState() {
    super.initState();
    newData = Map.from(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildFields(widget.data, ''),
    );
  }

  List<Widget> _buildFields(Map<String, dynamic> jsonData, String parentKey) {
    List<Widget> fields = [];

    jsonData.forEach((key, value) {
      String fieldKey = parentKey.isNotEmpty ? '$parentKey.$key' : key;
      if (value is Map) {
        fields.addAll(_buildFields(value as Map<String, dynamic>, fieldKey));
      } else if (value is List) {
        for (int i = 0; i < value.length; i++) {
          if (value[i] is Map) {
            fields.addAll(_buildFields(value[i], '$fieldKey[$i]'));
          } else {
            fields.add(
              FormBuilder(
                type: FormBuilderType.fromInstanceType(value[i]),
                label: '$fieldKey[$i]',
                initialValue: value[i],
                onChanged: (newValue, type) {
                  _updateData(fieldKey, i, newValue);
                },
              ),
            );
          }
        }
      } else {
        fields.add(
          FormBuilder(
            type: FormBuilderType.fromInstanceType(value),
            label: fieldKey,
            initialValue: value,
            onChanged: (newValue, type) {
              _updateData(fieldKey, null, newValue);
            },
          ),
        );
      }
    });

    return fields;
  }

  dynamic regenrateDataBasedonType(String value) {
    if (num.tryParse(value) != null) {
      return num.parse(value);
    }
    if (bool.tryParse(value) != null) {
      return bool.parse(value);
    }
    if (value == 'null') {
      return null;
    }
    return value;
  }

  void _updateData(String key, int? index, String value) {
    List<String> keys = key.split('.');
    dynamic currentData = newData;

    for (int i = 0; i < keys.length - 1; i++) {
      currentData = currentData[keys[i]];
    }
    var newValue = regenrateDataBasedonType(value);
    if (index != null) {
      currentData[keys.last][index] = newValue;
    } else {
      currentData[keys.last] = newValue;
    }

    widget.onChanged?.call(newData);
  }
}
