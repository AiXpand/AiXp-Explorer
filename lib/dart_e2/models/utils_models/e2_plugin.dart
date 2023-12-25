typedef PluginInstance = Map<String, dynamic>;

class E2Plugin {
  E2Plugin({
    required this.instances,
    required this.signature,
  });

  final List<PluginInstance> instances;
  final String signature;

  Map<String, dynamic> toMap() {
    return {
      'INSTANCES': instances,
      'SIGNATURE': signature,
    };
  }

  factory E2Plugin.fromMap(Map<String, dynamic> map) {
    return E2Plugin(
      instances:
          (map['INSTANCES'] as List).map((e) => e as PluginInstance).toList(),
      signature: map['SIGNATURE'] as String,
    );
  }

  static List<E2Plugin> fromList(List<dynamic> list) {
    final elements = <E2Plugin>[];
    for (final dynamic element in list) {
      elements.add(E2Plugin.fromMap(element as Map<String, dynamic>));
    }
    return elements;
  }

  static List<Map<String, dynamic>> toListMap(List<E2Plugin> list) {
    final elements = <Map<String, dynamic>>[];
    for (final E2Plugin element in list) {
      elements.add(element.toMap());
    }
    return elements;
  }
}
