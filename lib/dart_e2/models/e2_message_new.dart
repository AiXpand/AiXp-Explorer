/// This is the base message form in the AiXpand ecosystem.
/// EE_FORMATTER, EE_PAYLOAD_PATH, EE_SIGN, EE_SENDER, EE_HASH must be present in all valid messages.
/// Any class used to represent a message from this ecosystem should extends the [E2Message] class.
class E2Message {
  E2Message({
    required this.payloadPath,
    required this.formatter,
    required this.sign,
    required this.sender,
    required this.hash,
    this.messageBody,
  })  : boxId = payloadPath.isNotEmpty ? payloadPath[0]! : null,
        pipelineName = payloadPath.isNotEmpty ? payloadPath[1] : null,
        pluginSignature = payloadPath.isNotEmpty ? payloadPath[2] : null,
        pluginInstanceName = payloadPath.isNotEmpty ? payloadPath[3] : null;

  /// Should be a list, containing 4 elements with the following structure: [boxID, pipelineName,
  /// pluginSignature, pluginInstanceName]
  /// Only the first one is required (non-nullable)
  final List<String?> payloadPath;

  /// Extracted from payloadPath[0], represents the execution engine id.
  final String? boxId;

  /// Extracted from payloadPath[1], represents the running pipeline. Can be null.
  final String? pipelineName;

  /// Extracted from payloadPath[2], represents the signature of our running plugin. Can be null.
  final String? pluginSignature;

  /// Extracted from payloadPath[3], represents the instance name of our running plugin. Can be null.
  final String? pluginInstanceName;

  /// The formatter used to encode the message. A null value represents the RAW format, used by execution engine and its corresponding sdks.
  final String? formatter;

  /// Represents the signature used to validate the message.
  final String? sign;

  /// Represents the sender unique id. Used to validate the message.
  final String? sender;

  /// Represents the hash??
  final String? hash;

  /// The unmodified message as it was received on MQTT. If the message was created manually, this field is going to be null.
  final Map<String, dynamic>? messageBody;

  Map<String, dynamic> toMap() {
    return {
      'EE_PAYLOAD_PATH': payloadPath,
      'EE_FORMATTER': formatter,
      'EE_SIGN': sign,
      'EE_SENDER': sender,
      'EE_HASH': hash,
    };
  }

  factory E2Message.fromMap(
    Map<String, dynamic> map, {
    Map<String, dynamic>? originalMap,
  }) {
    return E2Message(
      payloadPath:
          (map['EE_PAYLOAD_PATH'] as List).map((e) => e as String).toList(),
      formatter: map['EE_FORMATTER'] as String?,
      sign: map['EE_SIGN'] as String,
      sender: map['EE_SENDER'] as String,
      hash: map['EE_HASH'] as String,
      messageBody: originalMap,
    );
  }
}
