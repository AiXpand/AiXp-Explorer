import 'package:e2_explorer/src/features/common_widgets/buttons/app_button_secondary.dart';
import 'package:e2_explorer/src/features/coms/provider/filter_provider.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:e2_explorer/src/utils/asset_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum BoxViewerTab {
  resources,
  pipelines,
  comms;

  static BoxViewerTab fromIndex(int index) {
    return BoxViewerTab.values[index];
  }
}

class BoxMessagesTabDisplay extends StatefulWidget {
  const BoxMessagesTabDisplay({
    super.key,
    required this.resourcesView,
    required this.pipelinesView,
    required this.commsView,
    this.onTabChanged,
  });

  final Widget resourcesView;
  final Widget pipelinesView;
  final Widget commsView;

  // final Widget fullPayloadsView;
  final void Function(BoxViewerTab tab)? onTabChanged;

  @override
  State<StatefulWidget> createState() => _BoxMessagesTabDisplayState();
}

class _BoxMessagesTabDisplayState extends State<BoxMessagesTabDisplay>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late int _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabIndex = _tabController.index;
    _tabController.addListener(() {
      if (_tabIndex != _tabController.index) {
        final tab = BoxViewerTab.fromIndex(_tabController.index);
        widget.onTabChanged?.call(tab);
        setState(() {
          _tabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 3 / 3,
                    child: TabBar(
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                      tabAlignment: TabAlignment.start,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.only(right: 24),
                      isScrollable: true,
                      dividerHeight: 0,
                      indicatorWeight: 4,
                      controller: _tabController,
                      indicator: ShapeDecoration(
                        shape: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 4.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                        gradient: AppColors.tabBarIndicatorGradient,
                      ),
                      indicatorPadding: const EdgeInsets.only(top: 20),
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryColor,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryColor,
                      ),
                      tabs: const [
                        Text('Resources'),
                        Text('Pipelines'),
                        Text('Comms'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                return Visibility(
                  visible: _tabIndex == 2,
                  child: AppButtonSecondary(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    text: 'Filter',
                    icon: Row(
                      children: [
                        if (ref.watch(filterProvider).isFilterApplied) ...[
                          const Icon(
                            Icons.fiber_manual_record,
                            size: 8,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                        ],
                        SvgPicture.asset(
                          AssetUtils.getSvgIconPath('sliders'),
                          color: AppColors.buttonSecondaryIconColor,
                        ),
                      ],
                    ),
                    borderColor: Colors.transparent,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const CustomPopup();
                        },
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              /// Resources tab
              widget.resourcesView,

              /// Pipelines tab
              widget.pipelinesView,

              /// Comms tab
              widget.commsView,
            ],
          ),
        )
      ],
    );
  }
}

class CustomPopup extends StatefulWidget {
  const CustomPopup({super.key});

  @override
  State<CustomPopup> createState() => _CustomPopupState();
}

class _CustomPopupState extends State<CustomPopup> {
  bool isNotiication = false;
  bool isPayload = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close the popup when tapped outside
        Navigator.of(context).pop();
      },
      child: Stack(
        children: [
          Container(
            color: Colors.black
                .withOpacity(0.5), // Semi-transparent black background
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom:
                MediaQuery.of(context).size.height * 0.55, // Adjust as needed
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                width: 180,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.alertDialogBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Consumer(builder: (context, ref, child) {
                  final state = ref.watch(filterProvider);
                  return Material(
                    child: Container(
                      color: AppColors.alertDialogBgColor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                  value: state.isNotification,
                                  onChanged: (value) {
                                    setState(() {
                                      ref
                                          .read(filterProvider.notifier)
                                          .changeFilter(isNotification: value);
                                    });
                                  }),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                "Notifications",
                                style: TextStyles.custom(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Checkbox(
                                  value: state.isPayload,
                                  onChanged: (value) {
                                    setState(() {
                                      ref
                                          .read(filterProvider.notifier)
                                          .changeFilter(isPayload: value);
                                    });
                                    Navigator.of(context).pop();
                                  }),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                "Payload",
                                style: TextStyles.custom(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
