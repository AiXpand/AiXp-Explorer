import 'package:e2_explorer/src/features/unfeatured_yet/connection/data/mqtt_server_repository.dart';
import 'package:e2_explorer/src/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/app_utils.dart';
import '../../common_widgets/app_dialog_widget.dart';
import '../../e2_status/application/e2_client.dart';
import '../../unfeatured_yet/connection/domain/models/mqtt_server.dart';
import 'add_network_dialog_content.dart';
import 'networks_listing_widget.dart';
import '../../common_widgets/text_widget.dart';

class SelectNetworkDialog extends StatefulWidget {
  const SelectNetworkDialog({super.key});

  @override
  State<SelectNetworkDialog> createState() => _SelectNetworkDialogState();
}

class _SelectNetworkDialogState extends State<SelectNetworkDialog> {
  List<MqttServer> servers = [];
  String? selectedServerName;

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => fetchServersList());
    super.initState();
  }

  void fetchServersList() async {
    servers = await MqttServerRepository().getMqttServers();
    selectedServerName = await MqttServerRepository().getSelectedServerName();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogWidget(
      positiveActionButtonText: 'Add Network',
      negativeActionButtonText: 'Close',
      positiveActionButtonAction: () async {
        Navigator.of(context).pop();
        showAppDialog(
          context: context,
          content: const AddNetworkDialogContent(),
        );
      },
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget(
              'The default network for AiExpand transactions is Mainnet.',
              style: CustomTextStyles.text16_400_secondary,
            ),
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NetworksListingWidget(
                  title: 'Mainnet',
                  servers: servers,
                  selectedItem: selectedServerName,
                  onSelectionChanged: (MqttServer server) async {
                    E2Client.changeConnectionData(server);
                    final E2Client client = E2Client();
                    await client.connect();
                    if (client.isConnected) {
                      setState(() {
                        selectedServerName = server.name;
                      });
                      await MqttServerRepository()
                          .saveSelectedServerName(server.name);
                      if (!context.mounted) return;
                      context.goNamed(RouteNames.connection);
                    } else {}
                  },
                ),
                const NetworksListingWidget(
                  title: 'Testnet',
                  servers: [],
                ),
              ],
            ),
          ],
        ),
      ),
      title: 'Select title',
    );
  }
}
