class Cavi2Transformer {
  /// A method used to transform the cavi2 payload into a raw payload in order for use to be able to load it into our class models.
  static Map<String, dynamic> decodeCavi2(Map<String, dynamic> encodedOutput) {
    // return cavi2Decoder(encodedOutput);
    // Remove specific keys if they exist
    if (encodedOutput.containsKey('SB_IMPLEMENTATION')) {
      encodedOutput.remove('SB_IMPLEMENTATION');
    }
    if (encodedOutput.containsKey('EE_FORMATTER')) {
      encodedOutput.remove('EE_FORMATTER');
    }

    Map<String, dynamic> output = {};

    // Remove 'messageID' from encodedOutput
    encodedOutput.remove('messageID');

    String eventType = encodedOutput.remove('type');
    String eeEventType = eventType;

    // Determine EE_EVENT_TYPE based on event type
    if (eventType != 'notification' && eventType != 'heartbeat') {
      eeEventType = 'payload';
    }
    output['EE_EVENT_TYPE'] = eeEventType.toUpperCase();

    Map<String, dynamic> data = encodedOutput.remove('data');
    Map<String, dynamic> metadata = encodedOutput.remove('metadata');

    // Process 'sender' zone
    output['EE_ID'] = encodedOutput['sender']['hostId'];
    encodedOutput['sender'].remove('id');
    encodedOutput['sender'].remove('instanceId');
    encodedOutput.remove('sender');

    // Process 'time' zone
    output['EE_TIMESTAMP'] = encodedOutput['time']['hostTime'];
    encodedOutput['time'].remove('deviceTime');
    encodedOutput['time'].remove('internetTime');
    encodedOutput.remove('time');

    // Extract metadata values
    output['EE_TOTAL_MESSAGES'] = metadata['sbTotalMessages'];
    output['EE_MESSAGE_ID'] = metadata['sbCurrentMessage'];

    // Process additional data if not a 'notification' or 'heartbeat' event
    if (eventType != 'notification' && eventType != 'heartbeat') {
      output['SIGNATURE'] = eventType.toUpperCase();
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
      data.remove('identifiers');

      // Process data 'value' and 'specificValue'
      data['value'].forEach((k, v) {
        output[k.toUpperCase()] = v;
      });
      data['value'].keys.toList().forEach((k) {
        data['value'].remove(k);
      });
      data['specificValue'].forEach((k, v) {
        output[k.toUpperCase()] = v;
      });
      data['specificValue'].keys.toList().forEach((k) {
        data['specificValue'].remove(k);
      });

      // Process image data
      String? img = data['img']['id'];
      int? imgH = data['img']['height'];
      int? imgW = data['img']['width'];
      data.remove('img');

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
    encodedOutput.remove('category');
    encodedOutput.remove('version');
    encodedOutput.remove('demoMode');

    return output;
  }
}
