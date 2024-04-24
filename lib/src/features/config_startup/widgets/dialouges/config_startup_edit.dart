import 'package:e2_explorer/dart_e2/commands/e2_commands.dart';
import 'package:e2_explorer/dart_e2/formatter/format_decoder.dart';
import 'package:e2_explorer/dart_e2/utils/xpand_utils.dart';
import 'package:e2_explorer/main.dart';
import 'package:e2_explorer/src/design/app_toast.dart';
import 'package:e2_explorer/src/features/common_widgets/app_dialog_widget.dart';
import 'package:e2_explorer/src/features/common_widgets/layout/loading_parent_widget.dart';
import 'package:e2_explorer/src/features/config_startup/widgets/form_builder.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/utils/app_utils.dart';

import 'package:flutter/material.dart';

const _name = 'admin_pipeline';
const _signature = 'UPDATE_MONITOR_01';
const _instanceId = 'UPDATE_MONITOR_01_INST';

class ConfigStartUpEditDialog {
  static viewConfigLog(BuildContext context, {required String targetId}) {
    E2Client().session.sendCommand(
          ActionCommands.updatePipelineInstance(
            targetId: targetId,
            payload: E2InstanceConfig(
              instanceConfig: {
                "INSTANCE_COMMAND": {"COMMAND": "GET_CONFIG"}
              },
              instanceId: _instanceId,
              name: _name,
              signature: _signature,
            ),
          ),
        );
    _showDialog(context, targetId: targetId);
  }

  static Future<void> _showDialog(
    BuildContext context, {
    required String targetId,
  }) async {
    await showAppDialog(
      context: context,
      content: ConfigStartUpEdit(
        targetId: targetId,
      ),
    );
  }
}

class ConfigStartUpEdit extends StatefulWidget {
  final String targetId;

  const ConfigStartUpEdit({
    super.key,
    required this.targetId,
  });

  @override
  State<ConfigStartUpEdit> createState() => _ConfigStartUpEditState();
}

class _ConfigStartUpEditState extends State<ConfigStartUpEdit> {
  bool isLoading = true;
  Map<String, dynamic> data = {};

  void save() {
    try {
      final base64Encoded = XpandUtils.encodeEncryptedGzipMessage(data);

      E2Client().session.sendCommand(
            ActionCommands.updatePipelineInstance(
              targetId: widget.targetId,
              payload: E2InstanceConfig(
                instanceConfig: {
                  "INSTANCE_COMMAND": {
                    "COMMAND": "SAVE_CONFIG",
                    "DATA": base64Encoded
                  },
                },
                instanceId: _instanceId,
                name: _name,
                signature: _signature,
              ),
              initiatorId: kAIXpWallet?.initiatorId,
            ),
          );
      debugPrint(' saved data: $base64Encoded');
      AppToast(
        message: 'Config Startup file saved successfully',
        type: ToastificationType.success,
      ).show(context);

      Navigator.of(context).pop();
    } catch (e) {
      // Handle errors, such as invalid JSON or encoding failures
      debugPrint('Error saving data: $e');
      AppToast(
        message: 'Failed to save Config Startup file',
        type: ToastificationType.error,
      ).show(context);
      // Optionally, you could show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return E2Listener(
      onPayload: (data) {
        final Map<String, dynamic> convertedMessage =
            MqttMessageEncoderDecoder.raw(data);
        final EE_PAYLOAD_PATH = (convertedMessage['EE_PAYLOAD_PATH'] as List)
            .map((e) => e as String?)
            .toList();
        if (EE_PAYLOAD_PATH.length == 4) {
          if (EE_PAYLOAD_PATH[0] == widget.targetId &&
              EE_PAYLOAD_PATH[1] == _name &&
              EE_PAYLOAD_PATH[2] == _signature &&
              EE_PAYLOAD_PATH[3] == _instanceId) {
            convertedMessage.removeWhere((key, value) => value == null);
            this.data = XpandUtils.decodeEncryptedGzipMessage(
              convertedMessage['CONFIG_STARTUP'],
            );
            isLoading = false;
            setState(() {});
          }
        }

        if (this.data.containsKey('CONFIG_STARTUP') &&
            this.data['CONFIG_STARTUP'] is String) {
          final decodedConfig = XpandUtils.decodeEncryptedGzipMessage(
            this.data['CONFIG_STARTUP'],
          );
          this.data.remove('CONFIG_STARTUP');
          this.data['CONFIG_STARTUP'] = decodedConfig;
          setState(() {});
        }
      },
      builder: (context) {
        return AppDialogWidget(
          appDialogType: AppDialogType.medium,
          positiveActionButtonText: "Save",
          negativeActionButtonText: "Close",
          positiveActionButtonAction: () {
            save();
          },
          title: "Config Startup file for ${widget.targetId}",
          content: SizedBox(
            height: size.height * 0.8,
            width: size.width * 0.8,
            child: LoadingParentWidget(
              isLoading: isLoading,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    JsonFormBuilder(
                      data: data,
                      onChanged: (newData) {
                        data = newData;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
