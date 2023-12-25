// const mandatoryKeys = ['EE_SIGN', 'EE_SENDER', 'EE_HASH', 'EE_PAYLOAD_PATH'];
//
// Map<String, dynamic> cavi2Decoder(Map<String, dynamic> message) {
//   if (message.containsKey('messageID')) {
//     message.remove('messageID');
//   }
//   if (message.containsKey('SB_IMPLEMENTATION')) {
//     message.remove('SB_IMPLEMENTATION');
//   }
//   if (message.containsKey('EE_FORMATTER')) {
//     message.remove('EE_FORMATTER');
//   }
//
//   Map<String, dynamic> transformed = {
//     'EE_FORMATTER': null,
//   };
//
//   for (var mandatoryKey in mandatoryKeys) {
//     transformed[mandatoryKey] = message[mandatoryKey];
//     message.remove(mandatoryKey);
//   }
//
//   String eventType = message['type'];
//   message.remove('type');
//
//   String eeEventType = eventType;
//   if (!['notification', 'heartbeat'].contains(eventType)) {
//     eeEventType = 'payload';
//   }
//
//   transformed['EE_EVENT_TYPE'] = eeEventType.toUpperCase();
//
//   Map<String, dynamic> data = {...message['data']};
//   message.remove('data');
//   Map<String, dynamic> metadata = {...message['metadata']};
//   message.remove('metadata');
//
//   transformed['EE_ID'] = message['sender']['hostId'];
//   message.remove('sender');
//
//   transformed['EE_TIMESTAMP'] = message['time']['hostTime'];
//   message.remove('time');
//
//   transformed['EE_TOTAL_MESSAGES'] = metadata['sbTotalMessages'];
//   metadata.remove('sbTotalMessages');
//
//   transformed['EE_MESSAGE_ID'] = metadata['sbCurrentMessage'];
//   metadata.remove('sbCurrentMessage');
//
//   if (eeEventType == 'payload') {
//     transformed['SIGNATURE'] = eventType.toUpperCase();
//
//     Map<String, dynamic> captureMetadata = metadata['captureMetadata'];
//     metadata.remove('captureMetadata');
//     Map<String, dynamic> pluginMetadata = metadata['pluginMetadata'];
//     metadata.remove('pluginMetadata');
//
//     for (var key in captureMetadata.keys) {
//       transformed['_C_${key.toUpperCase()}'] = captureMetadata[key];
//       // captureMetadata.remove(key);
//     }
//
//     for (var key in pluginMetadata.keys) {
//       transformed['_P_${key.toUpperCase()}'] = pluginMetadata[key];
//       // pluginMetadata.remove(key);
//     }
//
//     transformed['STREAM'] = data['identifiers']['streamId'];
//     data['identifiers'].remove('streamId');
//     transformed['INSTANCE_ID'] = data['identifiers']['instanceId'];
//     data['identifiers'].remove('instanceId');
//     transformed['ID'] = data['identifiers']['payloadId'];
//     data['identifiers'].remove('payloadId');
//     transformed['ID_TAGS'] = data['identifiers']['idTags'];
//     data['identifiers'].remove('idTags');
//
//     if (data['identifiers'].containsKey('initiatorId')) {
//       transformed['INITIATOR_ID'] = data['identifiers']['initiatorId'];
//       data['identifiers'].remove('initiatorId');
//     } else {
//       transformed['INITIATOR_ID'] = null;
//     }
//
//     if (data['identifiers'].containsKey('sessionId')) {
//       transformed['SESSION_ID'] = data['identifiers']['sessionId'];
//       data['identifiers'].remove('sessionId');
//     } else {
//       transformed['SESSION_ID'] = null;
//     }
//
//     data.remove('identifiers');
//
//     Map<String, dynamic> value = {
//       ...data['value'],
//       ...data['specificValue'],
//     };
//     for (var key in value.keys) {
//       transformed[key.toUpperCase()] = value[key];
//       // value.remove(key);
//     }
//
//     data.remove('value');
//     data.remove('specificValue');
//
//     transformed['TIMESTAMP_EXECUTION'] = data['time'];
//     data.remove('time');
//
//     if (data.containsKey('img') && data['img'].containsKey('id')) {
//       transformed['IMG'] = data['img']['id'];
//       data['img'].remove('id');
//     }
//
//     if (data.containsKey('img') && data['img'].containsKey('height')) {
//       transformed['IMG_HEIGHT'] = data['img']['height'];
//       data['img'].remove('height');
//     }
//
//     if (data.containsKey('img') && data['img'].containsKey('width')) {
//       transformed['IMG_WIDTH'] = data['img']['width'];
//       data['img'].remove('width');
//     }
//   }
//
//   for (var key in metadata.keys) {
//     transformed[key.toUpperCase()] = metadata[key];
//     metadata.remove(key);
//   }
//
//   message.remove('category');
//   message.remove('version');
//   message.remove('demoMode');
//
//   return transformed;
// }
