import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class CreatePipeline {
  final String name;
  final String? url;
  final String type;
  final List<Plugins> plugins;
  final List<CustomField> customFields;

  CreatePipeline({
    required this.name,
    required this.url,
    required this.type,
    this.plugins = const [],
    this.customFields = const [],
  });

  Map<String, dynamic> get customFieldsJson {
    return Map.fromEntries(customFields.map(
      (innerMap) => MapEntry(innerMap.key, innerMap.value),
    ));
  }

  bool get isCustomFieldsValid {
    var data = customFields.where((e) => !e.isValid).toList();
    return data.isEmpty;
  }

  bool get isAllPluginValid {
    var data = plugins.where((e) => !e.isPluginValid).toList();
    return data.isEmpty;
  }

  factory CreatePipeline.initialize() {
    return CreatePipeline(
      name: '',
      type: '',
      url: '',
      customFields: [],
      plugins: [Plugins.initialize()],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'url': url,
      ...customFieldsJson,
      "plugins": plugins.map((e) => e.toJson()).toList(),
    };
  }

  CreatePipeline copyWith(
      {String? name,
      String? url,
      String? type,
      List<Plugins>? plugins,
      List<CustomField>? customFields}) {
    return CreatePipeline(
      name: name ?? this.name,
      type: type ?? this.type,
      url: url ?? this.url,
      customFields: customFields ?? this.customFields,
      plugins: plugins ?? this.plugins,
    );
  }
}

class Plugins {
  final String id;
  final String signature;
  final List<Instance> instances;

  Plugins({
    required this.id,
    required this.signature,
    required this.instances,
  });

  factory Plugins.initialize() {
    return Plugins(
      id: uuid.v4(),
      instances: [Instance.initialize()],
      signature: '',
    );
  }

  bool get isAllInstanceValid {
    var data = instances.where((e) => !e.isInstanceValid).toList();
    return data.isEmpty;
  }

  bool get isPluginValid {
    return isAllInstanceValid && signature.isNotEmpty;
  }

  Plugins addInstance() {
    return copyWith(
      instances: [...instances, Instance.initialize()],
    );
  }

  Plugins copyWith({
    String? signature,
    List<Instance>? instances,
  }) {
    return Plugins(
      id: id,
      signature: signature ?? this.signature,
      instances: instances ?? this.instances,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'signature': signature,
      "insatnces": instances.map((e) => e.toJson()).toList(),
    };
  }
}

class Instance {
  final String instanceId;
  final String id;
  final List<CustomField> customFields;

  Instance({
    required this.instanceId,
    required this.id,
    this.customFields = const [],
  });

  List<String> get allCustomFieldsKey {
    return customFields.map((e) => e.key).toList();
  }

  factory Instance.initialize() {
    return Instance(
      id: uuid.v4(),
      instanceId: '',
      customFields: [],
    );
  }

  Instance copyWith({
    String? instanceId,
    List<CustomField>? customFields,
  }) {
    return Instance(
      id: id,
      instanceId: instanceId ?? this.instanceId,
      customFields: customFields ?? this.customFields,
    );
  }

  bool get isCustomFieldsValid {
    var data = customFields.where((e) => !e.isValid).toList();
    return data.isEmpty;
  }

  bool get isInstanceValid {
    return isCustomFieldsValid && instanceId.isNotEmpty;
  }

  Map<String, dynamic> get customFieldsJson {
    return Map.fromEntries(customFields.map(
      (innerMap) => MapEntry(innerMap.key, innerMap.value),
    ));
  }

  Map<String, dynamic> toJson() {
    return {
      'instance_id': instanceId,
      ...customFieldsJson,
    };
  }
}

class CustomField {
  final String key;
  final String value;
  final String id;

  CustomField({
    required this.id,
    required this.key,
    required this.value,
  });

  bool get isValid {
    if (key.isNotEmpty && value.isNotEmpty) {
      return true;
    }
    return false;
  }

  factory CustomField.initialize() {
    return CustomField(
      id: uuid.v4(),
      key: '',
      value: '',
    );
  }

  CustomField copyWith({
    String? key,
    String? value,
  }) {
    return CustomField(
      id: id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toJson() {
    return {key: value};
  }
}
