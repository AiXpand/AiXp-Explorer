import 'package:e2_explorer/dart_e2/formatter/models/cavi2_metadata.dart';

import 'cavi2_data.dart';
import 'cavi2_sender.dart';
import 'cavi2_time.dart';

class Cavi2Message {
  final String? messageId;
  final String? type;
  final String category;
  final String version;
  final Cavi2Data data;
  final Cavi2Metadata metadata;
  final Cavi2Time time;
  final Cavi2Sender sender;
  final bool demoMode;
  final String eeFormatter;
  final String sbImplementation;
  final List<String?> eePayloadPath;

  Cavi2Message({
    required this.messageId,
    required this.type,
    required this.category,
    required this.version,
    required this.data,
    required this.metadata,
    required this.time,
    required this.sender,
    required this.demoMode,
    required this.eeFormatter,
    required this.sbImplementation,
    required this.eePayloadPath,
  });

  factory Cavi2Message.fromMap(Map<String, dynamic> json) => Cavi2Message(
        messageId: json["messageID"],
        type: json["type"],
        category: json["category"],
        version: json["version"],
        data: Cavi2Data.fromMap(json["data"]),
        metadata: Cavi2Metadata.fromMap(json["metadata"]),
        time: Cavi2Time.fromMap(json["time"]),
        sender: Cavi2Sender.fromMap(json["sender"]),
        demoMode: json["demoMode"],
        eeFormatter: json["EE_FORMATTER"],
        sbImplementation: json["SB_IMPLEMENTATION"],
        eePayloadPath:
            List<String?>.from(json["EE_PAYLOAD_PATH"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "messageID": messageId,
        "type": type,
        "category": category,
        "version": version,
        "data": data.toMap(),
        "metadata": metadata.toMap(),
        "time": time.toMap(),
        "sender": sender.toMap(),
        "demoMode": demoMode,
        "EE_FORMATTER": eeFormatter,
        "SB_IMPLEMENTATION": sbImplementation,
        "EE_PAYLOAD_PATH": List<dynamic>.from(eePayloadPath.map((x) => x)),
      };

  @override
  String toString() {
    return 'Cavi2Message{messageId: $messageId, type: $type, category: $category, version: $version, data: $data, metadata: $metadata, time: $time, sender: $sender, demoMode: $demoMode, eeFormatter: $eeFormatter, sbImplementation: $sbImplementation, eePayloadPath: $eePayloadPath}';
  }
}
