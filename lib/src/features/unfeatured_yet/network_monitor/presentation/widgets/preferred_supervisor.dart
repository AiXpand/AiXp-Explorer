import 'package:carbon_icons/carbon_icons.dart';
import 'package:e2_explorer/src/features/common_widgets/buttons/clickable_button.dart';
import 'package:e2_explorer/src/features/common_widgets/hs_input_field.dart';
import 'package:e2_explorer/src/features/common_widgets/tooltip/icon_button_tooltip.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

class PreferredSupervisor extends StatefulWidget {
  const PreferredSupervisor({
    super.key,
    required this.onSupervisorChanged,
    required this.supervisorId,
  });

  final void Function(String?) onSupervisorChanged;
  final String? supervisorId;

  @override
  State<PreferredSupervisor> createState() => _PreferredSupervisorState();
}

class _PreferredSupervisorState extends State<PreferredSupervisor> {
  /// Flag that tells us if we are in standard mode or edit mode.
  bool isEdit = false;

  /// The completed supervisor id
  String? supervisorId;

  /// Text controller
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    supervisorId = widget.supervisorId;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Preferred supervisor:',
          style: TextStyles.body(),
        ),
        SizedBox(
          width: 8,
        ),
        Builder(
          builder: (context) {
            if (!isEdit) {
              if (supervisorId == null) {
                return ClickableButton(
                  text: ' Add supervisor ',
                  onTap: () {
                    setState(() {
                      isEdit = true;
                    });
                  },
                );
              } else {
                return Row(
                  children: [
                    Text(
                      supervisorId!,
                      style: TextStyles.body(),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    IconButtonWithTooltip(
                      onTap: () {
                        setState(() {
                          isEdit = true;
                        });
                      },
                      icon: CarbonIcons.edit,
                      tooltipMessage: 'Edit',
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    IconButtonWithTooltip(
                      onTap: () {
                        widget.onSupervisorChanged.call(null);
                        _controller.text = '';
                        setState(() {
                          supervisorId = null;
                        });
                      },
                      icon: CarbonIcons.delete,
                      tooltipMessage: 'Clear',
                    ),
                  ],
                );
              }
            } else {
              return Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: HSInputField(
                      inputFieldLabel: '',
                      hintText: 'Supervisor id',
                      textFieldController: _controller,
                      // onChanged: widget.onSupervisorChanged,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  IconButtonWithTooltip(
                    onTap: () {
                      final newSupervisor =
                          _controller.text.replaceAll(' ', '');
                      if (newSupervisor.isEmpty) {
                        widget.onSupervisorChanged.call(null);
                        setState(() {
                          isEdit = false;
                          supervisorId = null;
                        });
                      } else {
                        widget.onSupervisorChanged.call(_controller.text);
                        setState(() {
                          isEdit = false;
                          supervisorId = _controller.text;
                        });
                      }
                    },
                    icon: CarbonIcons.checkmark,
                    tooltipMessage: 'Accept',
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  IconButtonWithTooltip(
                    onTap: () {
                      setState(() {
                        isEdit = false;
                      });
                    },
                    icon: CarbonIcons.close,
                    tooltipMessage: 'Cancel',
                  ),
                ],
              );
            }
            return Container();
          },
        ),
      ],
    );
    if (!isEdit) {}
  }
}
