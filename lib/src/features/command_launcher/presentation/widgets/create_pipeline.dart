import 'package:e2_explorer/src/features/common_widgets/app_dialog_widget.dart';
import 'package:e2_explorer/src/features/common_widgets/layout/loading_parent_widget.dart';
import 'package:e2_explorer/src/features/config_startup/widgets/form_builder.dart';
import 'package:e2_explorer/src/features/node_dashboard/presentation/pages/pipeline/widgets/pipleline_tree/presentation/expandable_widget.dart';
import 'package:e2_explorer/src/utils/app_utils.dart';
import 'package:e2_explorer/src/widgets/transparent_inkwell_widget.dart';
import 'package:flutter/material.dart';

class CreatePipelineDialogUtils {
  static Future<void> showDialog(
    BuildContext context, {
    required String boxName,
  }) async {
    await showAppDialog(
      context: context,
      content: CreatePipelineDialog(
        boxName: boxName,
      ),
    );
  }
}

class CreatePipelineDialog extends StatefulWidget {
  final String boxName;
  const CreatePipelineDialog({super.key, required this.boxName});

  @override
  State<CreatePipelineDialog> createState() => _CreatePipelineDialogState();
}

class _CreatePipelineDialogState extends State<CreatePipelineDialog> {
  List<int> pluginsData = [0];
  Map<String, dynamic> data = {};
  @override
  void initState() {
    data = {
      "NAME": "",
      "TYPE": "",
      "URL": "",
      "PLUGINS": [
        {
          "SIGNATURE": "",
          "INSTANCES": [
            {"INSTANCE_ID": ""}
          ],
        },
      ]
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AppDialogWidget(
      appDialogType: AppDialogType.medium,
      positiveActionButtonText: "Save",
      negativeActionButtonText: "Close",
      positiveActionButtonAction: () {},
      title: "Create Pipeline for ${widget.boxName}",
      content: SizedBox(
        height: size.height * 0.8,
        width: size.width * 0.8,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // JsonFormBuilder(
                //   data: data,
                //   onChanged: (newData) {
                //     data = newData;
                //   },
                // ),
                FormBuilder(
                  type: FormBuilderType.text,
                  label: 'NAME',
                  initialValue: '',
                  onChanged: (newValue, type) {},
                ),
                FormBuilder(
                  type: FormBuilderType.text,
                  label: 'TYPE',
                  initialValue: '',
                  onChanged: (newValue, type) {},
                ),
                FormBuilder(
                  type: FormBuilderType.text,
                  label: 'URL',
                  initialValue: '',
                  onChanged: (newValue, type) {},
                ),
                FormBuilder(
                  type: FormBuilderType.text,
                  label: 'CAP_RESOLUTION',
                  initialValue: '',
                  onChanged: (newValue, type) {},
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    children: [
                      const Text("PLUGINS"),
                      const Spacer(),
                      TransparentInkwellWidget(
                        onTap: () {
                          setState(() {
                            pluginsData.add(pluginsData.length);
                          });
                        },
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                ...List.generate(
                  pluginsData.length,
                  (index) => CreatePluginWidget(
                    index: pluginsData[index],
                    onRemove: (a) {
                      if (pluginsData.length > 1) {
                        setState(() {
                          pluginsData.removeAt(index);
                        });
                      }
                    },
                  ),
                )

                // const CreatePluginWidget(index: 1),
                // const CreatePluginWidget(index: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CreatePluginWidget extends StatefulWidget {
  final int index;
  final Function(int) onRemove;
  const CreatePluginWidget(
      {super.key, required this.index, required this.onRemove});

  @override
  State<CreatePluginWidget> createState() => _CreatePluginWidgetState();
}

class _CreatePluginWidgetState extends State<CreatePluginWidget> {
  List<int> instanceData = [0];
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ExpandableWidget(
            onToggle: (s) {},
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormBuilder(
                    type: FormBuilderType.text,
                    label: 'SIGNATURE',
                    initialValue: '',
                    onChanged: (newValue, type) {},
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Row(
                      children: [
                        const Text("PLUGINS INSTANCE:"),
                        const Spacer(),
                        TransparentInkwellWidget(
                          onTap: () {
                            setState(() {
                              instanceData.add(instanceData.length);
                            });
                          },
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  ...List.generate(
                    instanceData.length,
                    (index) => CreateInstanceWidget(
                      index: instanceData[index],
                      onRemove: (a) {
                        if (instanceData.length > 1) {
                          setState(() {
                            instanceData.removeAt(index);
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
            header: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                children: [
                  Text("PLUGINS ${widget.index}: "),
                  const Spacer(),
                  TransparentInkwellWidget(
                    child: Icon(Icons.close),
                    onTap: () {
                      widget.onRemove(widget.index);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CreateInstanceWidget extends StatelessWidget {
  final int index;
  final Function(int) onRemove;
  const CreateInstanceWidget(
      {super.key, required this.index, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ExpandableWidget(
            onToggle: (s) {},
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormBuilder(
                    type: FormBuilderType.text,
                    label: 'INSTANCE ID',
                    initialValue: '',
                    onChanged: (newValue, type) {},
                  ),
                ],
              ),
            ),
            header: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                children: [
                  Text("INSTANCE $index: "),
                  const Spacer(),
                  TransparentInkwellWidget(
                    child: Icon(Icons.close),
                    onTap: () {
                      onRemove(index);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
