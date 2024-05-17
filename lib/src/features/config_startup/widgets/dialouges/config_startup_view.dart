import 'package:e2_explorer/dart_e2/commands/e2_commands.dart';
import 'package:e2_explorer/dart_e2/formatter/format_decoder.dart';
import 'package:e2_explorer/dart_e2/utils/xpand_utils.dart';
import 'package:e2_explorer/src/design/app_toast.dart';
import 'package:e2_explorer/src/features/common_widgets/app_dialog_widget.dart';
import 'package:e2_explorer/src/features/common_widgets/json_viewer/json_viewer.dart';
import 'package:e2_explorer/src/features/common_widgets/layout/loading_parent_widget.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/utils/app_utils.dart';
import 'package:e2_explorer/src/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_data_explorer/json_data_explorer.dart';
import 'package:provider/provider.dart';

const _name = 'admin_pipeline';
const _signature = 'UPDATE_MONITOR_01';
const _instanceId = 'UPDATE_MONITOR_01_INST';

class ConfigStartUpViewDialog {
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
      content: ConfigStartUpView(
        targetId: targetId,
      ),
    );
  }
}

class ConfigStartUpView extends StatefulWidget {
  final String targetId;

  const ConfigStartUpView({
    super.key,
    required this.targetId,
  });

  @override
  State<ConfigStartUpView> createState() => _ConfigStartUpViewState();
}

class _ConfigStartUpViewState extends State<ConfigStartUpView> {
  bool isLoading = true;
  Map<String, dynamic> data = {};
  final DataExplorerStore store = DataExplorerStore();

  bool copied = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: store,
      child: Consumer<DataExplorerStore>(builder:
          (BuildContext context, DataExplorerStore value, Widget? child) {
        return E2Listener(
          onPayload: (data) {
            final Map<String, dynamic> convertedMessage =
                MqttMessageEncoderDecoder.raw(data);
            final EE_PAYLOAD_PATH =
                (convertedMessage['EE_PAYLOAD_PATH'] as List)
                    .map((e) => e as String?)
                    .toList();
            if (EE_PAYLOAD_PATH.length == 4) {
              if (EE_PAYLOAD_PATH[0] == widget.targetId &&
                  EE_PAYLOAD_PATH[1] == _name &&
                  EE_PAYLOAD_PATH[2] == _signature &&
                  EE_PAYLOAD_PATH[3] == _instanceId) {
                this.data = XpandUtils.decodeEncryptedGzipMessage(
                  convertedMessage['CONFIG_STARTUP'],
                );
                isLoading = false;
                value.buildNodes(this.data, areAllCollapsed: false);
                setState(() {});
              }
            }
          },
          onNotification: (data) {
            final eePayloadPath = data['EE_PAYLOAD_PATH'];
            if (eePayloadPath[0] == 'gts-test2' && eePayloadPath[1] == null) {
              print('Notification received: $data');
              final metadata = data['metadata'];

              if ((metadata["notification"] as String)
                  .contains("STARTUP_CONFIG")) {
                AppToast(
                  message: 'Command sent',
                  description: 'Command sent to ${eePayloadPath[0]}',
                ).show(context);
              }
            }
          },
          builder: (context) {
            return AppDialogWidget(
              appDialogType: AppDialogType.medium,
              isActionbuttonReversed: true,
              positiveActionButtonAction: () async {
                await FileUtils.saveJSONToFile(data);
              },
              positiveActionButtonText: "Download Json",
              negativeActionButtonText: "Close",
              title: "Config Startup file for ${widget.targetId}",
              content: SizedBox(
                child: LoadingParentWidget(
                  message:
                      "Config Startup file requested ${widget.targetId}. Please wait until file is received and displayed",
                  isLoading: isLoading,
                  child: SizedBox(
                    child: ReusableJsonDataExplorer(
                      value: value,
                      nodes: value.displayNodes,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Future<void> _copyNode(NodeViewModelState node, BuildContext context) async {
    String text;
    if (node.isRoot) {
      final value = node.isClass ? 'class' : 'array';
      debugPrint('key and value is ${node.key}: ${value}');
      text = '${node.key}: ${node.value}';
    } else {
      text = '${node.key}: ${node.value}';
    }
    await Clipboard.setData(ClipboardData(text: text));
  }
}
