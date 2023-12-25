import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/dropdown_item_utils.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/dropdown_label_item.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/dropdown_search_item.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/hf_dropdown.dart';
import 'package:e2_explorer/src/features/common_widgets/hf_dropdown/hf_dropdown_button.dart';
import 'package:e2_explorer/src/features/common_widgets/options_menu/options_menu.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/data/mqtt_server_repository.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/domain/models/mqtt_server.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/presentation/widgets/add_connection/add_connection_dialog.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/connection/presentation/widgets/dropdown/server_dropdown_item.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/utils/nullable_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ServerSelectionDropdown extends StatefulWidget {
  const ServerSelectionDropdown({
    super.key,
    this.onItemChanged,
    // this.initialSelectedName,
    this.onClose,
    this.onInitDone,
    // required this.onItemAdd,
  });

  final DropdownItemChanged<MqttServer?>? onItemChanged;

  // final String? initialSelectedName;
  final void Function(Nullable<MqttServer>? mqttNullable)? onClose;
  final void Function(MqttServer? selectedSchedule)? onInitDone;

  @override
  State<ServerSelectionDropdown> createState() =>
      _ServerSelectionDropdownState();
}

class _ServerSelectionDropdownState extends State<ServerSelectionDropdown> {
  List<MqttServer> servers = <MqttServer>[];
  final ScrollController scrollController = ScrollController();
  late final OverlayController overlayController;
  int? selectedIndex;
  late bool isLoading;
  String searchQuery = '';
  bool closeOnTapOutside = true;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    overlayController = OverlayController('Server dropdown');
    WidgetsBinding.instance.addPostFrameCallback(_fetchServers);
  }

  Future<void> _fetchServers(Duration duration) async {
    servers = await MqttServerRepository().getMqttServers();
    final initialSelectedName =
        await MqttServerRepository().getSelectedServerName();
    selectedIndex =
        servers.indexWhere((element) => element.name == initialSelectedName);
    if (selectedIndex == -1) {
      selectedIndex = null;
    }
    // servers = [MqttServer.defaultServer];
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HFDropdown(
      onTapOutside: (OverlayController controller) {
        return closeOnTapOutside;
      },
      overlayController: overlayController,
      maxContentHeight: 250,
      buttonBuilder: (BuildContext context, VoidCallback onButtonTap) =>
          HFDropdownButton(
        height: 50,
        isExpanded: overlayController.isVisible,
        onTap: () {
          setState(() {
            searchQuery = '';
          });
          onButtonTap.call();
        },
        displayValue: isLoading
            ? 'Loading...'
            : selectedIndex == null
                ? '${MqttServer.defaultServer.name}\n${MqttServer.defaultServer.host}'
                : '${servers[selectedIndex!].name}\n${servers[selectedIndex!].host}',
      ),
      onClose: (dynamic value) {
        setState(() {});
        try {
          final Nullable<MqttServer>? castedValue =
              value as Nullable<MqttServer>?;
          widget.onClose?.call(castedValue);
        } catch (_) {
          if (kDebugMode) {
            print('Can not cast $value as a Nullable<MqttServer> object!');
          }
        }
      },
      contentShellBuilder: (BuildContext context, Widget content) => Container(
        decoration: BoxDecoration(
          color: const Color(0xff2b2b2b),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: const Color(0xff454545)),
        ),
        clipBehavior: Clip.hardEdge,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: content,
        ),
      ),
      contentBuilder: (BuildContext context, OverlayController overlay) {
        final List<MqttServer> displayedServers = servers
            .where((MqttServer element) => element.name
                .toLowerCase()
                .startsWith(searchQuery.toLowerCase()))
            .toList();
        return Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownItemUtils(
                hasDivider: true,
                child: DropdownLabelItem(
                  label: 'Add new server',
                  onAdd: () async {
                    closeOnTapOutside = false;
                    final result = await showDialog(
                      context: context,
                      builder: (_) => AddConnectionDialog(),
                    );
                    if (result != null) {
                      final newServer = result as MqttServer;
                      await MqttServerRepository()
                          .saveSelectedServerName(newServer.name);
                      setState(() async {
                        servers = await MqttServerRepository().getMqttServers();
                        selectedIndex = servers.indexWhere(
                            (element) => element.name == newServer.name);
                      });
                      overlay.closeWithResult(
                          Nullable<MqttServer>.value(newServer));
                      // overlayController.rebuild();
                    }

                    closeOnTapOutside = true;
                  },
                ),
              ),
              DropdownItemUtils(
                hasDivider: true,
                isVisible: servers.isNotEmpty,
                child: DropdownSearchItem(
                  onClear: () {
                    setState(() {
                      searchQuery = '';
                    });
                    overlay.rebuild();
                  },
                  onChanged: (String value) {
                    setState(() {
                      searchQuery = value;
                    });
                    overlay.rebuild();
                  },
                ),
              ),
              if (displayedServers.isNotEmpty)
                Flexible(
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          DropdownItemUtils(
                            hasDivider: false,
                            isVisible: searchQuery.isEmpty,
                            child: ServerDropdownItem(
                              server: MqttServer.defaultServer,
                              selected: selectedIndex == null,
                              onTap: (bool isSelected) async {
                                setState(() {
                                  selectedIndex = null;
                                });
                                // widget.onItemChanged?.call(null, true);
                                await MqttServerRepository()
                                    .saveSelectedServerName(null);
                                overlay.closeWithResult(
                                    Nullable<MqttServer>.value(
                                        MqttServer.defaultServer));
                              },
                            ),
                          ),
                          ListView.builder(
                            controller: scrollController,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayedServers.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return ServerDropdownItem(
                                menuItems: [
                                  MenuOptionItem(
                                    child: const Text('Delete'),
                                    onTap: () async {
                                      await MqttServerRepository()
                                          .removeMqttServer(servers[index]);
                                      // setState(() async {
                                      servers = await MqttServerRepository()
                                          .getMqttServers();
                                      // });
                                      overlay.rebuild();
                                    },
                                  )
                                ],
                                onMenuClose: () {},
                                selected: selectedIndex != null &&
                                    displayedServers[index] ==
                                        servers[selectedIndex!],
                                //selectedIndex == index,
                                server: displayedServers[index],
                                onTap: (bool isSelected) async {
                                  if (!isSelected) {
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                    await MqttServerRepository()
                                        .saveSelectedServerName(
                                            displayedServers[index].name);
                                    overlay.closeWithResult(
                                        Nullable<MqttServer>.value(
                                            displayedServers[index]));
                                  } else {
                                    overlay.closeWithResult(null);
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (searchQuery.isNotEmpty)
                ListTile(
                  tileColor: const Color(0xff2b2b2b), //.dark750,
                  hoverColor: ColorStyles.dark600,
                  title: !isLoading
                      ? Text(
                          'No servers found for: $searchQuery',
                          style: const TextStyle(color: ColorStyles.light100),
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: ColorStyles.light100,
                          ),
                        ),
                  // onTap: () => overlay.closeWithResult(null),
                ),
            ],
          ),
        );
      },
    );
  }
}
