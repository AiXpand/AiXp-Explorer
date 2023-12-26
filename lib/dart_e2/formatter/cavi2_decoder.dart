import 'format_decoder.dart';

class Cavi2MessageEncoderDecoder implements MqttMessageEncoderDecoder {
  final mandatoryKeys = ['EE_SIGN', 'EE_SENDER', 'EE_HASH', 'EE_PAYLOAD_PATH'];

  @override
  Map<String, dynamic> decode(Map<String, dynamic> encoded) {
    try {
      Map<String, dynamic> transformed = {
        'EE_FORMATTER': null,
      };

      // handle mandatory keys
      for (final key in mandatoryKeys) {
        if (!encoded.containsKey(key)) {
          throw FormatException(
              'EE_FORMATTER is invalid for the message with path: ${encoded['EE_PAYLOAD_PATH']}');
        } else {
          transformed[key] = encoded[key];
        }
      }

      ///  handle event type
      String? eventType = encoded['type'];
      String? eEventType = encoded['type'];

      // if type is other than 'notification' or 'heartbeat' then it is a payload
      if (eventType != 'notification' && eventType != 'heartbeat') {
        eEventType = 'payload';
      }

      transformed['EE_EVENT_TYPE'] = eEventType?.toUpperCase();

      final encodedData = encoded['data'];
      final encodedMetadata = encoded['metadata'];

      // Process 'sender' zone
      transformed['EE_ID'] = encoded['sender']?['hostId'];

      // Process 'time' zone
      transformed['EE_TIMESTAMP'] = encoded['time']?['hostTime'];

      // Extract metadata values
      transformed['EE_TOTAL_MESSAGES'] = encodedMetadata?['sbTotalMessages'];
      transformed['EE_MESSAGE_ID'] = encodedMetadata?['sbCurrentMessage'];

      // Process additional data if not a 'notification' or 'heartbeat' event
      if (eEventType == 'payload') {
        transformed['SIGNATURE'] = eventType?.toUpperCase();

        // Rename and add capture metadata
        final decodedCaptureMetadata = Map<String, dynamic>.from({});
        encodedMetadata?['captureMetadata']?.forEach((k, v) {
          decodedCaptureMetadata['_C_$k'] = v;
        });

        // Rename and add plugin metadata
        final decodedPluginMetadata = Map<String, dynamic>.from({});
        encodedMetadata?['pluginMetadata']?.forEach((k, v) {
          decodedPluginMetadata['_P_$k'] = v;
        });

        // Process data values
        transformed['STREAM'] = encodedData?['identifiers']?['streamId'];
        transformed['INSTANCE_ID'] = encodedData?['identifiers']?['instanceId'];
        transformed['ID'] = encodedData?['identifiers']?['payloadId'];
        transformed['ID_TAGS'] = encodedData?['identifiers']?['idTags'];

        transformed['INITIATOR_ID'] =
            encodedData?['identifiers']?['initiatorId'];
        transformed['SESSION_ID'] = encodedData?['identifiers']?['sessionId'];

        // Process data 'value' and 'specificValue'
        encodedData?['value']?.forEach((k, v) {
          transformed[k.toUpperCase()] = v;
        });

        encodedData?['specificValue'].forEach((k, v) {
          transformed[k.toUpperCase()] = v;
        });

        // process time data : // TODO: handle time when null
        transformed['TIMESTAMP_EXECUTION'] = encodedData?['time'];

        // Process image data
        String? img = encodedData?['img']?['id'];
        int? imgH = encodedData?['img']?['height'];
        int? imgW = encodedData?['img']?['width'];

        if (img != null) {
          transformed['IMG'] = img;
          transformed['IMG_HEIGHT'] = imgH;
          transformed['IMG_WIDTH'] = imgW;
        }

        // Merge transformed with capture and plugin metadata
        transformed = {
          ...transformed,
          ...decodedCaptureMetadata,
          ...decodedPluginMetadata
        };
      }

      // Process remaining metadata
      encodedMetadata?.forEach((k, v) {
        transformed[k.toUpperCase()] = v;
      });

      return transformed;
    } catch (e, s) {
      print("Could not decode cavi2 ${encoded['type']}: $e $s");
      return {};
    }
  }

  @override
  Map<String, dynamic> encoder(Map<String, dynamic> decoded) {
    throw UnimplementedError();
  }
}
