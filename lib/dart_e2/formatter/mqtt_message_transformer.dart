import 'package:e2_explorer/dart_e2/formatter/cavi2_transformer.dart';

class MqttMessageTransformer {
  static Map<String, dynamic> formatToRaw(Map<String, dynamic> message) {
    final String? format = message['EE_FORMATTER'];
    if (format == 'cavi2') {
      return Cavi2Transformer.decodeCavi2(message);
    } else if (format == null || format == 'raw') {
      return message;
    } else {
      /// This is an unknown format. Message should be dropped.
      throw FormatException(
          'EE_FORMATTER is invalid for the message with path: ${message['EE_PAYLOAD_PATH']}');
    }
  }
}
