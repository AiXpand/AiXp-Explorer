import 'package:e2_explorer/dart_e2/models/payload/e2_payload.dart';
import 'package:e2_explorer/dart_e2/models/payload/netmon/netmon_box_details.dart';

class E2Netmon extends E2Payload {
  E2Netmon({
    required super.payloadPath,
    required super.formatter,
    required super.sign,
    required super.sender,
    required super.hash,
    required super.timestamp,
    required super.timezone,
    required super.content,
    required this.currentNetwork,
    required this.isSupervisor,
    super.messageBody,
  });

  final List<NetmonBox> currentNetwork;
  final bool isSupervisor;

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'CURRENT_NETWORK': currentNetwork,
      'IS_SUPERVISOR': isSupervisor,
    };
  }

  factory E2Netmon.fromMap(
    Map<String, dynamic> map, {
    Map<String, dynamic>? originalMap,
  }) {
    final currentNetwork = map['CURRENT_NETWORK'] as Map<String, dynamic>;
    final currentNetworkMap = <String, NetmonBoxDetails>{};
    currentNetwork.forEach((key, value) {
      currentNetworkMap[key] =
          NetmonBoxDetails.fromMap(value as Map<String, dynamic>);
    });
    final content = E2Payload.extractContent(map)..remove('CURRENT_NETWORK');
    return E2Netmon(
      payloadPath:
          (map['EE_PAYLOAD_PATH'] as List).map((e) => e as String).toList(),
      formatter: map['EE_FORMATTER'] as String?,
      sign: map['EE_SIGN'] as String,
      sender: map['EE_SENDER'] as String,
      hash: map['EE_HASH'] as String,
      timestamp: map['EE_TIMESTAMP'] as String,
      timezone: map['EE_TIMEZONE'] as String,
      currentNetwork: currentNetworkMap.entries
          .map((entry) => NetmonBox(boxId: entry.key, details: entry.value))
          .toList(),
      isSupervisor: map['IS_SUPERVISOR'] as bool,
      messageBody: originalMap,
      content: content,
    );
  }
}
