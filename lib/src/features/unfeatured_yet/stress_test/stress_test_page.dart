import 'dart:async';

import 'package:e2_explorer/dart_e2/comm/mqtt_wrapper.dart';
import 'package:e2_explorer/dart_e2/commands/e2_commands.dart';
import 'package:e2_explorer/dart_e2/const/mqtt_config.dart';
import 'package:e2_explorer/src/features/common_widgets/buttons/clickable_button.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/stress_test/stress_test_message.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

class StressTestPage extends StatefulWidget {
  const StressTestPage({super.key});

  @override
  State<StressTestPage> createState() => _StressTestPageState();
}

class _StressTestPageState extends State<StressTestPage> {
  double value = 1;
  bool testActive = false;
  late Timer timer;
  final period = const Duration(seconds: 5);
  late final MqttWrapper mqttObject;

  int sentMessages = 0;

  @override
  void initState() {
    super.initState();
    mqttObject = MqttWrapper(
      server: E2Client().server,
      receiveChannelName: MqttConfig.controlChannelTopic,
      sendChannelName: MqttConfig.controlChannelTopic,
    );
    mqttObject.serverConnect();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  max: 10000,
                  divisions: 10,
                  onChanged: (newValue) {
                    setState(() {
                      value = newValue;
                    });
                  },
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      value.toInt().toString(),
                      style: TextStyles.body(),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ClickableButton(
                      onTap: () async {
                        await _showSafetyDialog();
                        if (false) {
                          if (!testActive) {
                            print('Stress test has started');
                            timer = Timer.periodic(period, (arg) {
                              for (var i = 0; i < value.toInt(); i++) {
                                mqttObject.send(getMessage(i));
                                // print(utf8.encode(getMessage(i)));
                              }
                              setState(() {
                                sentMessages += value.toInt();
                              });
                              print('Sent ${value.toInt()} hbs');
                            });
                          } else {
                            timer.cancel();
                            print('Stress test stop');
                          }
                          setState(() {
                            testActive = !testActive;
                          });
                        }
                      },
                      width: 100,
                      height: 50,
                      text: testActive ? 'Stop test' : 'Start test',
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '$sentMessages messages sent',
                style: TextStyles.body(),
              ),
              SizedBox(
                width: 10,
              ),
              ClickableButton(
                onTap: () {
                  setState(() {
                    sentMessages = 0;
                  });
                },
                text: 'Reset',
                width: 50,
              ),
            ],
          ),
          ClickableButton(
            width: 500,
            onTap: () {
              E2Client().session.sendCommand(
                    ActionCommands.restart(
                        targetId: 'theo_dckr',
                        initiatorId: 'Explorer-Theo',
                        sessionId: 'Theo-Session-ID'),
                  );
            },
            text: 'Send shutdown command',
          ),
          // Expanded(child: StressTestCpuMonitor()),
        ],
      ),
    );
  }

  Future<void> _showSafetyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Functionality disabled for safety reasons!'),
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
