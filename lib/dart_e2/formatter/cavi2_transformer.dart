const mandatoryKeys = ['EE_SIGN', 'EE_SENDER', 'EE_HASH', 'EE_PAYLOAD_PATH'];

class Cavi2Transformer {
  /// A method used to transform the cavi2 payload into a raw payload in order for use to be able to load it into our class models.
  static Map<String, dynamic> decodeCavi2(Map<String, dynamic> encodedCavi2) {
    print("decoding cavi2 of type ${encodedCavi2['type']}");
    try {
      Map<String, dynamic> transformed = {
        'EE_FORMATTER': null,
      };

      // handle mandatory keys
      for (final key in mandatoryKeys) {
        if (!encodedCavi2.containsKey(key)) {
          throw FormatException(
              'EE_FORMATTER is invalid for the message with path: ${encodedCavi2['EE_PAYLOAD_PATH']}');
        } else {
          transformed[key] = encodedCavi2[key];
        }
      }

      ///  handle event type
      String? eventType = encodedCavi2['type'];
      String? eEventType = encodedCavi2['type'];

      // if type is other than 'notification' or 'heartbeat' then it is a payload
      if (eventType != 'notification' && eventType != 'heartbeat') {
        eEventType = 'payload';
      }

      transformed['EE_EVENT_TYPE'] = eEventType?.toUpperCase();

      final encodedData = encodedCavi2['data'];
      final encodedMetadata = encodedCavi2['metadata'];

      // Process 'sender' zone
      transformed['EE_ID'] = encodedCavi2['sender']?['hostId'];

      // Process 'time' zone
      transformed['EE_TIMESTAMP'] = encodedCavi2['time']?['hostTime'];

      // Extract metadata values
      transformed['EE_TOTAL_MESSAGES'] = encodedMetadata['sbTotalMessages'];
      transformed['EE_MESSAGE_ID'] = encodedMetadata['sbCurrentMessage'];

      // Process additional data if not a 'notification' or 'heartbeat' event
      if (eEventType == 'payload') {
        transformed['SIGNATURE'] = eventType?.toUpperCase();

        // Rename and add capture metadata
        final decodedCaptureMetadata = Map<String, dynamic>.from({});
        encodedMetadata['captureMetadata']?.forEach((k, v) {
          decodedCaptureMetadata['_C_$k'] = v;
        });

        // Rename and add plugin metadata
        final decodedPluginMetadata = Map<String, dynamic>.from({});
        encodedMetadata['pluginMetadata']?.forEach((k, v) {
          decodedPluginMetadata['_P_$k'] = v;
        });

        // Process data values
        transformed['STREAM'] = encodedData['identifiers']['streamId'];
        transformed['INSTANCE_ID'] = encodedData['identifiers']['instanceId'];
        transformed['ID'] = encodedData['identifiers']['payloadId'];
        transformed['ID_TAGS'] = encodedData['identifiers']['idTags'];

        transformed['INITIATOR_ID'] = encodedData['identifiers']['initiatorId'];
        transformed['SESSION_ID'] = encodedData['identifiers']['sessionId'];

        // Process data 'value' and 'specificValue'
        encodedData['value'].forEach((k, v) {
          transformed[k.toUpperCase()] = v;
        });

        encodedData['specificValue'].forEach((k, v) {
          transformed[k.toUpperCase()] = v;
        });

        // process time data
        transformed['TIMESTAMP_EXECUTION'] = encodedData['time'];

        // Process image data
        String? img = encodedData['img']['id'];
        int? imgH = encodedData['img']['height'];
        int? imgW = encodedData['img']['width'];

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
      encodedMetadata.forEach((k, v) {
        transformed[k.toUpperCase()] = v;
      });

      return transformed;
    } catch (e, s) {
      print("Could not decode cavi2 ${encodedCavi2['type']}: $e $s");
      return {};
    }
  }
}
