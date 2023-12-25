import 'package:e2_explorer/dart_e2/models/utils_models/e2_plugin.dart';
import 'package:e2_explorer/dart_e2/models/utils_models/pipelines/e2_meta_stream.dart';

class E2SingleCropMetaStream extends E2MetaStream {
  E2SingleCropMetaStream({
    required this.cropLeft,
    required this.cropRight,
    required this.cropTop,
    required this.cropBottom,
    required super.collectedStreams,
    required super.streamConfigMetadata,
    required super.initiatorId,
    required super.name,
    required super.plugins,
    required super.type,
    required super.sessionId,
  });

  final int cropLeft;
  final int cropRight;
  final int cropTop;
  final int cropBottom;

  factory E2SingleCropMetaStream.fromMap(Map<String, dynamic> map) {
    return E2SingleCropMetaStream(
      cropLeft: map['CROP_LEFT'] as int,
      cropRight: map['CROP_RIGHT'] as int,
      cropTop: map['CROP_TOP'] as int,
      cropBottom: map['CROP_BOTTOM'] as int,
      collectedStreams:
          (map['COLLECTED_STREAMS'] as List).map((e) => e as String).toList(),
      streamConfigMetadata:
          map['STREAM_CONFIG_METADATA'] as Map<String, dynamic>?,
      initiatorId: map['INITIATOR_ID'] as String?,
      name: map['NAME'] as String,
      plugins: E2Plugin.fromList(map['PLUGINS'] as List),
      type: map['TYPE'] as String,
      sessionId: map['SESSION_ID'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'CROP_LEFT': cropLeft,
      'CROP_RIGHT': cropRight,
      'CROP_TOP': cropTop,
      'CROP_BOTTOM': cropBottom,
    }..addAll(super.toMap());
  }
}
