import 'package:e2_explorer/src/design/app_toast.dart';
import 'package:e2_explorer/src/features/common_widgets/app_dialog_widget.dart';
import 'package:e2_explorer/src/features/common_widgets/hs_input_field.dart';
import 'package:e2_explorer/src/features/common_widgets/text_widget.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/data/mqtt_server_repository.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/domain/models/mqtt_server.dart';
import 'package:e2_explorer/src/utils/form_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../common_widgets/buttons/app_button_primary.dart';
import '../../common_widgets/buttons/app_button_secondary.dart';

class AddNetworkDialogContent extends StatefulWidget {
  const AddNetworkDialogContent({super.key});

  @override
  State<AddNetworkDialogContent> createState() =>
      _AddNetworkDialogContentState();
}

class _AddNetworkDialogContentState extends State<AddNetworkDialogContent> {
  bool loading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _hostFocusNode = FocusNode();
  final FocusNode _portFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _userFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return AppDialogWidget(
      title: 'Add Network',
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget(
              'Add your network details to connect',
              style: CustomTextStyles.text16_400_secondary,
            ),
            const SizedBox(height: 27),
            TextInputFieldWidget(
              hintText: 'Name',
              controller: _nameController,
              focusNode: _nameFocusNode,
              validator: FormUtils.validateRequiredField,
            ),
            const SizedBox(height: 16),
            TextInputFieldWidget(
              hintText: 'Host',
              controller: _hostController,
              focusNode: _hostFocusNode,
              validator: FormUtils.validateRequiredField,
            ),
            const SizedBox(height: 16),
            TextInputFieldWidget(
              hintText: 'Port',
              controller: _portController,
              focusNode: _portFocusNode,
              validator: FormUtils.validateRequiredField,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            TextInputFieldWidget(
              hintText: 'User',
              controller: _userController,
              focusNode: _userFocusNode,
              validator: FormUtils.validateRequiredField,
            ),
            const SizedBox(height: 16),
            TextInputFieldWidget(
              hintText: 'Password',
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              validator: FormUtils.validatePassword,
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        AppButtonSecondary(
          minWidth: 134,
          height: 40,
          text: 'Close',
          onPressed: Navigator.of(context).pop,
        ),
        const SizedBox(width: 16),
        AppButtonPrimary(
          minWidth: 134,
          text: 'Add Network',
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              try {
                setState(() {
                  loading = true;
                });
                final MqttServer server = MqttServer(
                  name: _nameController.text.trim(),
                  host: _hostController.text.trim(),
                  port: int.parse(_portController.text.trim()),
                  username: _userController.text.trim(),
                  password: _passwordController.text.trim(),
                );
                await MqttServerRepository().addMqttServer(server);
                setState(() {
                  loading = false;
                });
                AppToast(
                        message: 'Network added successfully',
                        type: ToastificationType.success)
                    .show(context);
                Navigator.of(context).pop();
              } catch (e) {
                setState(() {
                  loading = false;
                });
                AppToast(
                        message: 'Failed to add network',
                        type: ToastificationType.error)
                    .show(context);
              }
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _passwordController.dispose();
    _userController.dispose();
    _nameFocusNode.dispose();
    _hostFocusNode.dispose();
    _portFocusNode.dispose();
    _passwordFocusNode.dispose();
    _userFocusNode.dispose();
    super.dispose();
  }
}
