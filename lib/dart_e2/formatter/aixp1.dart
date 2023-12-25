Map<String, dynamic> decodeOutput(Map<String, dynamic> encodedOutput) {
  // Pop the unimportant stuff
  encodedOutput.remove('EE_FORMATTER');

  List<String?> eeIdPipelineSignatureInstanceId =
      encodedOutput.remove('EE_PAYLOAD_PATH') ?? [null, null, null, null];

  String? eeId = eeIdPipelineSignatureInstanceId[0];
  String? pipeline = eeIdPipelineSignatureInstanceId[1];
  String? signature = eeIdPipelineSignatureInstanceId[2];
  String? instanceId = eeIdPipelineSignatureInstanceId[3];

  encodedOutput['EE_ID'] = eeId;

  if (encodedOutput['EE_EVENT_TYPE'] != 'HEARTBEAT') {
    encodedOutput['STREAM_NAME'] = pipeline;
  }

  if (pipeline != null) {
    encodedOutput['SIGNATURE'] = signature;
  }

  if (instanceId != null) {
    encodedOutput['INSTANCE_ID'] = instanceId;
  }

  Map<String, dynamic> lvl1Dct = encodedOutput.remove('DATA');

  if (encodedOutput['EE_EVENT_TYPE'] == 'PAYLOAD') {
    encodedOutput['STREAM'] = pipeline;
    encodedOutput['PIPELINE'] = pipeline;

    // Plugin meta
    Map<String, dynamic> pluginMeta =
        (lvl1Dct['PLUGIN_META'] ?? {}) as Map<String, dynamic> ?? {};
    pluginMeta.forEach((k, v) {
      encodedOutput[k] = v;
    });

    // Pipeline meta
    Map<String, dynamic> pipelineMeta =
        (lvl1Dct['PIPELINE_META'] ?? {}) as Map<String, dynamic> ?? {};
    pipelineMeta.forEach((k, v) {
      encodedOutput[k] = v;
    });

    encodedOutput['PLUGIN_CATEGORY'] = 'general';
    int a = 1;
  }

  lvl1Dct.forEach((k, v) {
    encodedOutput[k] = v;
  });

  return encodedOutput;
}
