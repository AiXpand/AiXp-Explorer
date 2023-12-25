import 'package:e2_explorer/dart_e2/models/utils_models/e2_plugin.dart';

import 'e2_pipeline.dart';

class E2MetaStream extends E2Pipeline {
  E2MetaStream({
    required this.collectedStreams,
    required this.streamConfigMetadata,
    required super.initiatorId,
    required super.name,
    required super.plugins,
    required super.type,
    required super.sessionId,
  });

  final List<String>? collectedStreams;
  final Map<String, dynamic>? streamConfigMetadata;

  factory E2MetaStream.fromMap(Map<String, dynamic> map) {
    return E2MetaStream(
      collectedStreams:
          (map['COLLECTED_STREAMS'] as List).map((e) => e as String).toList(),
      streamConfigMetadata:
          map['STREAM_CONFIG_METADATA'] as Map<String, dynamic>,
      initiatorId: map['INITIATOR_ID'] as String,
      name: map['NAME'] as String,
      plugins: E2Plugin.fromList(map['PLUGINS'] as List),
      type: map['TYPE'] as String,
      sessionId: map['SESSION_ID'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'COLLECTED_STREAMS': collectedStreams,
      'STREAM_CONFIG_METADATA': streamConfigMetadata,
    }..addAll(super.toMap());
  }
}
