import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:e2_explorer/src/features/common_widgets/layout/loading_parent_widget.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/data/mqtt_server_repository.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/domain/models/mqtt_server.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/presentation/widgets/dropdown/server_selection_dropdown.dart';
import 'package:e2_explorer/src/routes/routes.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/connection_button.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  E2Client client = E2Client();

  late MqttServer selectedServer;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_getSelectedServer);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getSelectedServer(Duration duration) async {
    selectedServer = (await MqttServerRepository().getSelectedMqttServer()) ??
        MqttServer.defaultServer;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyles.dark800,
      body: Center(
        child: LoadingParentWidget(
          isLoading: isLoading,
          child: isLoading
              ? Container()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 80.0, bottom: 150),
                      child: Text(
                        'E2 Explorer',
                        textAlign: TextAlign.start,
                        style: GoogleFonts.martianMono(
                          color: ColorStyles.viridianGreen,
                          fontSize: 38,
                        ),
                      ),
                    ),
                    Text(
                      'Connect to ${selectedServer.host}',
                      style: TextStyles.h4(),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: ServerSelectionDropdown(
                        onClose: (serverNullable) {
                          if (serverNullable != null) {
                            final server = serverNullable.value;
                            setState(() {
                              selectedServer =
                                  server ?? MqttServer.defaultServer;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: ConnectionButton(
                        onTap: () async {
                          // E2Client.clearClientData();
                          E2Client.changeConnectionData(selectedServer);
                          client = E2Client();
                          await client.connect();
                          if (client.isConnected) {
                            /// ToDO set on page render

                            if (!Platform.isMacOS) appWindow.hide();
                            const newSize = Size(1400, 800);
                            appWindow.minSize = newSize;
                            appWindow.size = newSize;
                            if (!Platform.isMacOS) appWindow.show();
                            if (context.mounted) {
                              context.goNamed(RouteNames.dashboard);
                            }
                          } else {
                            await _showConnectionFailedDialog();
                            print('failed to connect');
                          }
                        },
                      ),
                    ),
                    // UpdatWidget(
                    //   currentVersion: "1.0.0",
                    //   getLatestVersion: () async {
                    //     // Here you should fetch the latest version. It must be semantic versioning for update detection to work properly.
                    //     return "1.0.1";
                    //   },
                    //   getBinaryUrl: (latestVersion) async {
                    //     // Here you provide the link to the binary the user should download. Make sure it is the correct one for the platform!
                    //     return "https://github.com/latest/release/bin.exe";
                    //   },
                    //   // Lastly, enter your app name so we know what to call your files.
                    //   appName: "Updat Example",
                    // ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _showConnectionFailedDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connection failed'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Could not connect to ${selectedServer.host}.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
