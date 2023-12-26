class Cavi2Transformer {
  /// A method used to transform the cavi2 payload into a raw payload in order for use to be able to load it into our class models.
  static Map<String, dynamic> decodeCavi2(Map<String, dynamic> encodedToCavi2) {
    Map<String, dynamic> output = {};

    // Remove 'messageID' from encodedToCavi2
    // encodedToCavi2.remove('messageID');

    // String eventType = encodedToCavi2.remove('type');
    String eeEventType = encodedToCavi2['type'];

    // Determine EE_EVENT_TYPE based on event type
    if (eeEventType != 'notification' && eeEventType != 'heartbeat') {
      eeEventType = 'payload';
    }

    output['EE_EVENT_TYPE'] = eeEventType.toUpperCase();
    final data = encodedToCavi2['data'];
    final metadata = encodedToCavi2['metadata'];

    // Map<String, dynamic> data = encodedToCavi2.remove('data');
    // Map<String, dynamic> metadata = encodedToCavi2.remove('metadata');

    // Process 'sender' zone
    output['EE_ID'] = encodedToCavi2['sender']['hostId'];
    encodedToCavi2['sender'].remove('id');
    encodedToCavi2['sender'].remove('instanceId');
    encodedToCavi2.remove('sender');

    // Process 'time' zone
    output['EE_TIMESTAMP'] = encodedToCavi2['time']['hostTime'];
    encodedToCavi2['time'].remove('deviceTime');
    encodedToCavi2['time'].remove('internetTime');
    encodedToCavi2.remove('time');

    // Extract metadata values
    output['EE_TOTAL_MESSAGES'] = metadata['sbTotalMessages'];
    output['EE_MESSAGE_ID'] = metadata['sbCurrentMessage'];

    // Process additional data if not a 'notification' or 'heartbeat' event
    if (eeEventType.toLowerCase() != 'notification' &&
        eeEventType.toLowerCase() != 'heartbeat') {
      output['SIGNATURE'] = eeEventType;
      Map<String, dynamic> captureMetadata = metadata['captureMetadata'];
      Map<String, dynamic> pluginMetadata = metadata['pluginMetadata'];

      // Rename and add capture metadata
      final newCaptureMetadata = Map<String, dynamic>.from({});
      captureMetadata.forEach((k, v) {
        newCaptureMetadata['_C_$k'] = v;
      });
      captureMetadata.clear();
      captureMetadata.addAll(newCaptureMetadata);

      // Rename and add plugin metadata
      final newPluginMetadata = Map<String, dynamic>.from({});
      pluginMetadata.forEach((k, v) {
        newPluginMetadata['_P_$k'] = v;
      });
      pluginMetadata.clear();
      pluginMetadata.addAll(newPluginMetadata);

      // Process data values
      output['STREAM'] = data['identifiers']['streamId'];
      output['INITIATOR_ID'] = data['identifiers']['initiatorId'];
      output['INSTANCE_ID'] = data['identifiers']['instanceId'];
      output['SESSION_ID'] = data['identifiers']['sessionId'];
      output['ID'] = data['identifiers']['payloadId'];
      output['ID_TAGS'] = data['identifiers']['idTags'];
      // data.remove('identifiers');

      // Process data 'value' and 'specificValue'
      data['value'].forEach((k, v) {
        output[k.toUpperCase()] = v;
      });

      // data['value'].keys.toList().forEach((k) {
      //   data['value'].remove(k);
      // });

      data['specificValue'].forEach((k, v) {
        output[k.toUpperCase()] = v;
      });

      // data['specificValue'].keys.toList().forEach((k) {
      //   data['specificValue'].remove(k);
      // });

      // Process image data
      String? img = data['img']['id'];
      int? imgH = data['img']['height'];
      int? imgW = data['img']['width'];
      // data.remove('img');

      if (img != null) {
        output['IMG'] = img;
        output['IMG_HEIGHT'] = imgH;
        output['IMG_WIDTH'] = imgW;
      }

      output['TIMESTAMP_EXECUTION'] = data['time'];

      // Merge output with capture and plugin metadata
      output = {...output, ...captureMetadata, ...pluginMetadata};
    }

    // Process remaining metadata
    metadata.forEach((k, v) {
      output[k.toUpperCase()] = v;
    });

    // Remove additional keys
    encodedToCavi2.remove('category');
    encodedToCavi2.remove('version');
    encodedToCavi2.remove('demoMode');

    return output;
  }
}
