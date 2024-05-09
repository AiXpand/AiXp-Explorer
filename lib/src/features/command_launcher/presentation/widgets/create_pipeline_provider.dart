import 'dart:convert';

import 'package:e2_explorer/src/models/create_pipeline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createPipelineProvider = StateNotifierProvider.family<
    CreatePipelineProvider, CreatePipeline, String>((ref, String boxName) {
  return CreatePipelineProvider(CreatePipeline.initialize(), boxName, ref);
});

class CreatePipelineProvider extends StateNotifier<CreatePipeline> {
  final String boxName;
  final Ref ref;
  CreatePipelineProvider(CreatePipeline data, this.boxName, this.ref)
      : super(data);

  initialize() {
    state = CreatePipeline.initialize();
  }

  List<String> get defaultKey {
    return ['name', 'type', 'url'];
  }

  List<String> get allKeys {
    return [...defaultKey, 'plugins', ...allCustomFieldsKey];
  }

  List<String> get allCustomFieldsKey {
    return state.customFields.map((e) => e.key).toList();
  }

  List<String> get allKeysWithoutPlugin {
    return [...defaultKey, ...allCustomFieldsKey];
  }

  List<dynamic> get allValues {
    return [
      state.name,
      state.type,
      state.url,
      ...state.customFields.map((e) => e.value)
    ];
  }

  updateState(CreatePipeline createPipeline) {
    state = createPipeline.copyWith();
  }

  updateDefaultValue(String key, String value) {
    if (defaultKey[0] == key) {
      updateState(state.copyWith(name: value));
    }
    if (defaultKey[1] == key) {
      updateState(state.copyWith(type: value));
    }
    if (defaultKey[2] == key) {
      updateState(state.copyWith(url: value));
    }
  }

  addCustomField() {
    if (state.isCustomFieldsValid) {
      updateState(
        state.copyWith(
          customFields: [...state.customFields, CustomField.initialize()],
        ),
      );
    }
  }

  updateCustomFieldKey(CustomField customField) {
    bool isKeyUnique = allKeysWithoutPlugin
        .where(
            (element) => element.toLowerCase() == customField.key.toLowerCase())
        .isEmpty;
    if (isKeyUnique) {
      updateCustomField(customField);
    }
  }

  updateCustomField(CustomField customField) {
    var customFields = state.customFields;
    int index =
        customFields.indexWhere((element) => element.id == customField.id);
    if (index > -1) {
      customFields[index] = customField;
      updateState(state.copyWith(customFields: [...customFields]));
    }
  }

  removeCustomField(CustomField customField) {
    var customFields = state.customFields;
    customFields.removeWhere((element) => element.id == customField.id);
    updateState(state.copyWith(customFields: [...customFields]));
  }

  addPlugin() {
    updateState(
      state.copyWith(plugins: [...state.plugins, Plugins.initialize()]),
    );
  }

  updatePlugin(Plugins plugin) {
    var plugins = state.plugins;
    int index = plugins.indexWhere((element) => element.id == plugin.id);
    if (index > -1) {
      plugins[index] = plugin;
      updateState(state.copyWith(plugins: [...plugins]));
    }
  }

  removePlugin(Plugins plugin) {
    var plugins = state.plugins;
    plugins.removeWhere((element) => element.id == plugin.id);
    updateState(
      state.copyWith(plugins: [...plugins]),
    );
  }

  addInstance(Plugins plugin) {
    updatePlugin(plugin.addInstance());
  }

  updateInstance(Plugins plugin, Instance instance) {
    var instances = plugin.instances;
    int index = instances.indexWhere((element) => element.id == instance.id);
    if (index > -1) {
      instances[index] = instance;
      plugin = plugin.copyWith(instances: [...instances]);
      updatePlugin(plugin);
    }
  }

  removeInstance(Plugins plugin, Instance instance) {
    var instances = plugin.instances;
    instances.removeWhere((element) => element.id == instance.id);
    plugin = plugin.copyWith(instances: [...instances]);
    updatePlugin(plugin);
  }

  addInstanceCustomField(Plugins plugin, Instance instance) {
    if (instance.isCustomFieldsValid) {
      instance = instance.copyWith(
        customFields: [...instance.customFields, CustomField.initialize()],
      );
      updateInstance(plugin, instance);
    }
  }

  updateInstanceCustomFieldKey(
    Plugins plugin,
    Instance instance,
    CustomField customField,
  ) {
    var uniqueKeyData = instance.allCustomFieldsKey.where(
      (element) => element.toLowerCase() == customField.key.toLowerCase(),
    );
    if (uniqueKeyData.isEmpty) {
      updateInstanceCustomFieldValue(plugin, instance, customField);
    }
  }

  updateInstanceCustomFieldValue(
    Plugins plugin,
    Instance instance,
    CustomField customField,
  ) {
    var customFields = instance.customFields;
    int index =
        customFields.indexWhere((element) => element.id == customField.id);
    if (index > -1) {
      customFields[index] = customField;
      instance = instance.copyWith(customFields: customFields);
      updateInstance(plugin, instance);
    }
  }

  removeInstanceCustomFieldValue(
    Plugins plugin,
    Instance instance,
    CustomField customField,
  ) {
    var customFields = instance.customFields;
    customFields.removeWhere((element) => element.id == customField.id);
    instance = instance.copyWith(customFields: customFields);
    updateInstance(plugin, instance);
  }

  save() {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(state.toJson());
    print(prettyprint);
  }
}
