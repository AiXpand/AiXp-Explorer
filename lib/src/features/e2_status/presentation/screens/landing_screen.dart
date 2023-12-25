// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:e2_explorer/src/features/box_viewer/presentation/box_viewer.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/connect_button.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/window_buttons.dart';
import 'package:e2_explorer/src/features/payload_viewer/presentation/payload_viewer.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  final E2Client client = E2Client();
  late TabController _tabController;
  late int _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabIndex = _tabController.index;
    _tabController.addListener(() {
      if (_tabIndex != _tabController.index) {
        setState(() {
          _tabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WindowTitleBarBox(
          child: Row(
            children: <Widget>[
              Expanded(child: MoveWindow()),
              const WindowButtons(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ConnectButton(
                onTap: () {
                  setState(() {});
                },
              ),
              const SizedBox(
                width: 16,
              ),
              if (client.isConnected || client.boxMessages.isNotEmpty)
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Boxes'),
                        Tab(text: 'Payloads'),
                      ],
                    ),
                  ),
                ),
              const Spacer(
                flex: 3,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IndexedStack(
              index: _tabIndex,
              children: <Widget>[
                BoxViewer(),
                PayloadViewer(boxName: ''),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
