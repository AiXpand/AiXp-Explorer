import 'package:collection/collection.dart';
import 'package:e2_explorer/dart_e2/formatter/format_decoder.dart';
import 'package:e2_explorer/src/features/command_launcher/presentation/widgets/create_pipeline_provider.dart';
import 'package:e2_explorer/src/features/common_widgets/app_dialog_widget.dart';
import 'package:e2_explorer/src/features/common_widgets/json_viewer/json_viewer.dart';
import 'package:e2_explorer/src/features/common_widgets/text_widget.dart';
import 'package:e2_explorer/src/features/config_startup/widgets/form_builder.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/features/node_dashboard/presentation/pages/pipeline/widgets/pipleline_tree/presentation/expandable_widget.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/provider/node_pipeline_provider.dart';
import 'package:e2_explorer/src/models/create_pipeline.dart';
import 'package:e2_explorer/src/utils/app_utils.dart';
import 'package:e2_explorer/src/utils/form_utils.dart';
import 'package:e2_explorer/src/widgets/transparent_inkwell_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_data_explorer/json_data_explorer.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart' as p;
import '../../../common_widgets/buttons/app_button_primary.dart';

enum UiMode { Edit, View }

class CreatePipelineDialogUtils {
  static String boxName = '';
  static Future<void> showDialog(
    BuildContext context,
    WidgetRef ref, {
    required String boxName,
  }) async {
    ref.read(createPipelineProvider(boxName).notifier).initialize();
    await showAppDialog(
      context: context,
      content: CreatePipelineDialog(
        boxName: boxName,
      ),
    );
  }
}

class CreatePipelineDialog extends ConsumerStatefulWidget {
  final String boxName;
  const CreatePipelineDialog({super.key, required this.boxName});

  @override
  ConsumerState<CreatePipelineDialog> createState() =>
      _CreatePipelineDialogState();
}

class _CreatePipelineDialogState extends ConsumerState<CreatePipelineDialog> {
  final scrollController = ScrollController();

  final pageController = PageController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var state = ref.watch(createPipelineProvider(widget.boxName));
    final notifier = ref.read(createPipelineProvider(widget.boxName).notifier);

    return AppDialogWidget(
      appDialogType: AppDialogType.medium,
      positiveActionButtonText: "Save",
      negativeActionButtonText: "Close",
      positiveActionButtonAction: () {
        notifier.save();
      },
      appButtonStatusPositiveButton:
          state.isFormValid ? AppButtonStatus.normal : AppButtonStatus.disabled,
      title: "Create Pipeline for ${widget.boxName}",
      content: SizedBox(
        height: size.height * 0.9,
        width: size.width * 0.9,
        child: E2Listener(onHeartbeat: (payload) {
          final Map<String, dynamic> convertedMessage =
              MqttMessageEncoderDecoder.raw(payload);
          ref
              .read(nodePipelineProvider(widget.boxName).notifier)
              .updatePipelineList(convertedMessage: convertedMessage);
        }, builder: (a) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppButtonPrimary(
                text: pageController.page == 0 ? "View Mode" : 'Edit Mode',
                onPressed: () {
                  if (pageController.page == 0) {
                    pageController.jumpToPage(1);
                  } else {
                    pageController.jumpToPage(0);
                  }
                  setState(() {});
                },
              ),
              Expanded(
                child: PageView(
                  controller: pageController,
                  children: [
                    EditTestMode(
                      boxName: widget.boxName,
                    ),
                    _ViewMode(
                      boxName: widget.boxName,
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ViewMode extends ConsumerStatefulWidget {
  final String boxName;
  const _ViewMode({
    super.key,
    required this.boxName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => __ViewModeState();
}

class __ViewModeState extends ConsumerState<_ViewMode> {
  final DataExplorerStore store = DataExplorerStore();

  Map<String, dynamic> cleanedData(Map<String, dynamic> mapData) {
    var data = uppercaseKeysOfMap(mapData);
    var pluginData = List<Map<String, dynamic>>.from(data['PLUGINS']);

    return data;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var state = ref.read(createPipelineProvider(widget.boxName));
      // var stateCopy = Map.fromIterables(state.keys, state.values);
      store.buildNodes(state.toJson());
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(createPipelineProvider(widget.boxName), (p, s) {
      store.buildNodes(s.toJson());
    });
    return p.ChangeNotifierProvider.value(
      value: store,
      child: p.Consumer<DataExplorerStore>(
        builder: (context, DataExplorerStore value, child) {
          return ReusableJsonDataExplorer(
            nodes: value.displayNodes,
            value: value,
          );
        },
      ),
    );
  }
}

class EditTestMode extends ConsumerStatefulWidget {
  final String boxName;

  const EditTestMode({
    super.key,
    required this.boxName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditTestModeState();
}

class _EditTestModeState extends ConsumerState<EditTestMode>
    with AutomaticKeepAliveClientMixin<EditTestMode> {
  final scrollController = ScrollController();

  Widget get addCustomFieldBtn {
    return AppButtonPrimary(
      text: 'Add Custom Field',
      height: 36,
      appButtonStatus: state.isCustomFieldsValid
          ? AppButtonStatus.normal
          : AppButtonStatus.disabled,
      onPressed: () {
        notifier.addCustomField();
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  late CreatePipelineProvider notifier;
  late CreatePipeline state;

  @override
  Widget build(BuildContext context) {
    state = ref.watch(createPipelineProvider(widget.boxName));
    notifier = ref.read(createPipelineProvider(widget.boxName).notifier);
    var allPlugins = ref.watch(nodePipelineProvider(widget.boxName));
    var pluginsData = state.plugins;
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Spacer(),
                if (state.isCustomFieldsValid)
                  addCustomFieldBtn
                else
                  JustTheTooltip(
                    content: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextWidget(
                        "Make Sure Existing Custom Fields are valid",
                      ),
                    ),
                    child: addCustomFieldBtn,
                  ),
              ],
            ),
            ...notifier.defaultKey.mapIndexed(
              (i, e) {
                /// Needed for validation to make sure we don't have duplicate keys

                return FormBuilder(
                  type: FormBuilderType.text,
                  label: e,
                  initialValue: notifier.allValues[i],
                  validator: e.toLowerCase() == 'url'
                      ? (a) => FormUtils.validateCreatePipelineUrl(
                            context,
                            val: a,
                            existingUrl:
                                allPlugins.map((e) => e.url ?? '').toList(),
                          )
                      : null,
                  onChanged: (newValue, type) {
                    notifier.updateDefaultValue(e, newValue);
                  },
                );
              },
            ),
            ...state.customFields.mapIndexed(
              (index, element) {
                final existingKeys = notifier.allKeysWithoutPlugin
                    .where((a) => element.key.toLowerCase() != a.toLowerCase())
                    .map((e) => e.toLowerCase())
                    .toList();

                return KeyValueInputField(
                  key: ValueKey(element.id),
                  existingKeys: existingKeys,
                  onKeyChange: (p0) {
                    element = element.copyWith(key: p0);
                    notifier.updateCustomFieldKey(element);
                  },
                  onRemove: () {
                    notifier.removeCustomField(element);
                  },
                  onValueChange: (p0) {
                    element = element.copyWith(value: p0);
                    notifier.updateCustomField(element);
                  },
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Row(
                children: [
                  const Text("PLUGINS"),
                  const Spacer(),
                  if (state.isAllPluginValid)
                    AppButtonPrimary(
                      height: 36,
                      text: 'Add Plugin',
                      appButtonStatus: AppButtonStatus.normal,
                      onPressed: () {
                        notifier.addPlugin();
                        Future.delayed(const Duration(milliseconds: 200), () {
                          scrollController.jumpTo(
                            scrollController.position.maxScrollExtent,
                          );
                        });
                      },
                    )
                  else
                    JustTheTooltip(
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextWidget(
                          "Make Sure Existing Plugin Forms are valid",
                        ),
                      ),
                      child: AppButtonPrimary(
                        height: 36,
                        text: 'Add Plugin',
                        appButtonStatus: AppButtonStatus.disabled,
                        onPressed: () {
                          notifier.addPlugin();
                          Future.delayed(const Duration(milliseconds: 200), () {
                            scrollController.jumpTo(
                              scrollController.position.maxScrollExtent,
                            );
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
            ...List.generate(pluginsData.length, (index) {
              var plugin = pluginsData[index];
              return CreatePluginWidget(
                key: ValueKey(plugin.id),
                plugin: pluginsData[index],
                boxName: widget.boxName,
                onAddInstance: () {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    scrollController.jumpTo(
                      scrollController.position.maxScrollExtent,
                    );
                  });
                },
              );
            })
          ],
        ),
      ),
    );
  }
}

class CreatePluginWidget extends ConsumerWidget {
  final Plugins plugin;
  final Function onAddInstance;
  final String boxName;
  const CreatePluginWidget({
    super.key,
    required this.onAddInstance,
    required this.boxName,
    required this.plugin,
  });

  Widget addInstanceButton(notifier) {
    return AppButtonPrimary(
      text: 'Add Instance',
      height: 36,
      onPressed: () {
        notifier.addInstance(plugin);
        onAddInstance();
      },
      appButtonStatus: plugin.isAllInstanceValid
          ? AppButtonStatus.normal
          : AppButtonStatus.disabled,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(createPipelineProvider(boxName));
    final notifier = ref.read(createPipelineProvider(boxName).notifier);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ExpandableWidget(
        onToggle: (s) {},
        isExpanded: true,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormBuilder(
                type: FormBuilderType.text,
                label: 'SIGNATURE',
                initialValue: '',
                validator: (p0) => FormUtils.validateRequiredField(context, p0),
                onChanged: (newValue, type) {
                  notifier.updatePlugin(plugin.copyWith(signature: newValue));
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  children: [
                    const Text("PLUGINS INSTANCE:"),
                    const Spacer(),
                    if (plugin.isAllInstanceValid)
                      addInstanceButton(notifier)
                    else
                      JustTheTooltip(
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextWidget(
                            "Make Sure Existing Instance Forms are valid",
                          ),
                        ),
                        child: addInstanceButton(notifier),
                      ),
                  ],
                ),
              ),
              ...plugin.instances.mapIndexed((i, e) {
                return CreateInstanceWidget(
                  key: ValueKey(e.id),
                  index: i,
                  boxName: boxName,
                  instance: e,
                  plugin: plugin,
                );
              }),
            ],
          ),
        ),
        header: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Row(
            children: [
              Text("PLUGINS: "),
              const Spacer(),
              TransparentInkwellWidget(
                child: const Icon(
                  Icons.minimize_outlined,
                  color: Colors.red,
                ),
                onTap: () {
                  notifier.removePlugin(plugin);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateInstanceWidget extends ConsumerWidget {
  final String boxName;
  final int index;
  final Plugins plugin;
  final Instance instance;
  CreateInstanceWidget({
    super.key,
    required this.index,
    required this.boxName,
    required this.plugin,
    required this.instance,
  });

  Widget get addCustomFieldBtn {
    return AppButtonPrimary(
      text: 'Add Custom Field',
      height: 36,
      appButtonStatus: instance.isCustomFieldsValid
          ? AppButtonStatus.normal
          : AppButtonStatus.disabled,
      onPressed: () {
        notifier.addInstanceCustomField(plugin, instance);
      },
    );
  }

  late CreatePipelineProvider notifier;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    notifier = ref.read(createPipelineProvider(boxName).notifier);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ExpandableWidget(
        isExpanded: true,
        onToggle: (s) {},
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormBuilder(
                type: FormBuilderType.text,
                label: 'Instance Id',
                initialValue: '',
                onChanged: (newValue, type) {
                  notifier.updateInstance(
                    plugin,
                    instance.copyWith(instanceId: newValue),
                  );
                },
              ),
              ...instance.customFields.map(
                (element) {
                  var existingKeys = instance.allCustomFieldsKey;

                  /// Needed for validation to make sure we don't have duplicate keys

                  existingKeys = existingKeys
                      .where(
                          (a) => element.key.toLowerCase() != a.toLowerCase())
                      .toList();

                  return KeyValueInputField(
                    key: ValueKey(element.id),
                    onRemove: () {
                      notifier.removeInstanceCustomFieldValue(
                        plugin,
                        instance,
                        element,
                      );
                    },
                    existingKeys: existingKeys,
                    onKeyChange: (p0) {
                      element = element.copyWith(key: p0);
                      notifier.updateInstanceCustomFieldKey(
                        plugin,
                        instance,
                        element,
                      );
                    },
                    onValueChange: (p0) {
                      element = element.copyWith(value: p0);
                      notifier.updateInstanceCustomFieldValue(
                        plugin,
                        instance,
                        element,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
        header: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Row(
            children: [
              Text("INSTANCE $index:"),
              const Spacer(),
              if (instance.isCustomFieldsValid)
                addCustomFieldBtn
              else
                JustTheTooltip(
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextWidget(
                      "Make Sure Existing Custom Fields are valid",
                    ),
                  ),
                  child: addCustomFieldBtn,
                ),
              TransparentInkwellWidget(
                child: const Icon(
                  Icons.minimize_outlined,
                  color: Colors.red,
                ),
                onTap: () {
                  notifier.removeInstance(plugin, instance);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KeyValueInputField extends StatefulWidget {
  final Function(String) onKeyChange;
  final Function(String) onValueChange;
  final Function onRemove;
  final List<String> existingKeys;

  const KeyValueInputField({
    super.key,
    required this.onKeyChange,
    required this.onValueChange,
    required this.existingKeys,
    required this.onRemove,
  });

  @override
  State<KeyValueInputField> createState() => _KeyValueInputFieldState();
}

class _KeyValueInputFieldState extends State<KeyValueInputField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: FormBuilder(
            type: FormBuilderType.text,
            label: 'Key',
            initialValue: '',
            validator: (a) {
              return FormUtils.validateCreatePipelineKey(
                context,
                value: a,
                existingKeys: widget.existingKeys,
              );
            },
            onChanged: (newValue, type) {
              widget.onKeyChange(newValue);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 30.0),
          child: TextWidget(
            " : ",
            style: CustomTextStyles.text20_700,
          ),
        ),
        Expanded(
          flex: 3,
          child: FormBuilder(
            type: FormBuilderType.text,
            label: 'Value',
            initialValue: '',
            onChanged: (newValue, type) {
              widget.onValueChange(newValue);
            },
          ),
        ),
        TransparentInkwellWidget(
          child: const Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10),
            child: Icon(
              Icons.minimize_outlined,
              color: Colors.red,
            ),
          ),
          onTap: () {
            widget.onRemove();
            // onRemove(index);
          },
        ),
      ],
    );
  }
}
