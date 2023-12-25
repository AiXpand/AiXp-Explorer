import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:flutter/material.dart';

class ConnectButton extends StatefulWidget {
  const ConnectButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  State<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton> {
  bool _isConnected = E2Client().isConnected;

  void onConnectionChange(bool isConnected) {
    _isConnected = isConnected;
    setState(() {});
  }

  @override
  void initState() {
    E2Client()
        .notifiers
        .connection
        .addListener((data) => true, (data) => onConnectionChange(data));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () async {
            final client = E2Client();
            if (!client.isConnected) {
              await client.connect();
            } else {
              client.disconnect();
            }
            widget.onTap?.call();
            setState(() {});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: !_isConnected ? Colors.green : Colors.redAccent,
            foregroundColor: Colors.white70,
          ),
          child: Text(!_isConnected ? 'Connect' : 'Disconnect'),
        ),
        Text(
          _isConnected ? 'Connected to mqtt' : 'Not connected to mqtt',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
