import 'package:e2_explorer/src/features/common_widgets/buttons/clickable_button.dart';
import 'package:e2_explorer/src/features/common_widgets/hs_input_field.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/data/mqtt_server_repository.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/domain/models/mqtt_server.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddConnectionDialog extends StatefulWidget {
  const AddConnectionDialog({super.key});

  @override
  State<AddConnectionDialog> createState() => _AddConnectionDialogState();
}

class _AddConnectionDialogState extends State<AddConnectionDialog> {
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// Turn to true after first validation
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  /// Initialized on every Add pressed validation.
  late List<MqttServer> currentServers;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop(null);
            },
            child: const SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
            ),
          ),
          Center(
            child: FractionallySizedBox(
              heightFactor: 0.7,
              widthFactor: 0.6,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: ColorStyles.dark800,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add a new MQTT server',
                        style: TextStyles.body(),
                      ),
                      const SizedBox(height: 32),

                      /// ToDO: move form in different file
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    HSInputField(
                                      autoValidateMode: autoValidateMode,
                                      inputFieldLabel: 'Name',
                                      hintText: '',
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Name can not be empty!';
                                        }
                                        if (value == 'Default server' ||
                                            currentServers.any((element) =>
                                                element.name == value)) {
                                          return 'Name already exists!';
                                        }
                                        return null;
                                      },
                                      textFieldController: _nameController,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    HSInputField(
                                      autoValidateMode: autoValidateMode,
                                      inputFieldLabel: 'Host',
                                      hintText: '',
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Host can not be empty!';
                                        }
                                        return null;
                                      },
                                      textFieldController: _hostController,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    HSInputField(
                                      autoValidateMode: autoValidateMode,
                                      inputFieldLabel: 'Port',
                                      hintText: '',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Port can not be empty!';
                                        }
                                        final parsedValue = int.tryParse(value);
                                        if (parsedValue == null ||
                                            parsedValue > 65535 ||
                                            parsedValue < 0) {
                                          return 'Port value is invalid!';
                                        }
                                        return null;
                                      },
                                      textFieldController: _portController,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    HSInputField(
                                      autoValidateMode: autoValidateMode,
                                      inputFieldLabel: 'Username',
                                      hintText: '',
                                      validator: (value) {
                                        // if (value == null || value.isEmpty) {
                                        //   return 'Username can not be empty!';
                                        // }
                                        return null;
                                      },
                                      textFieldController: _usernameController,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    HSInputField(
                                      autoValidateMode: autoValidateMode,
                                      inputFieldLabel: 'Password',
                                      hintText: '',
                                      validator: (value) {
                                        // if (value == null || value.isEmpty) {
                                        //   return 'Password can not be empty!';
                                        // }
                                        return null;
                                      },
                                      textFieldController: _passwordController,
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ClickableButton(
                              text: 'Cancel',
                              onTap: () {
                                Navigator.of(context).pop(null);
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: ClickableButton(
                              text: 'Add',
                              backgroundColor: ColorStyles.blue,
                              hoverColor: ColorStyles.lightBlue,
                              onTap: () async {
                                currentServers = await MqttServerRepository()
                                    .getMqttServers();
                                if (_formKey.currentState!.validate()) {
                                  final newServer = MqttServer(
                                    name: _nameController.text,
                                    host: _hostController.text,
                                    port: int.parse(_portController.text),
                                    username: _usernameController.text,
                                    password: _passwordController.text,
                                  );
                                  await MqttServerRepository()
                                      .addMqttServer(newServer);
                                  if (context.mounted) {
                                    Navigator.of(context).pop(newServer);
                                  }
                                } else {
                                  setState(() {
                                    autoValidateMode = AutovalidateMode.always;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
