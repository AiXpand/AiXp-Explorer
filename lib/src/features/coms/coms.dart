import 'dart:convert';

import 'package:e2_explorer/src/features/common_widgets/json_viewer/json_viewer.dart';
import 'package:e2_explorer/src/features/coms/provider/filter_provider.dart';
import 'package:e2_explorer/src/features/coms/widget/payload_image_viewer.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/common/tab_display.dart';
import 'package:e2_explorer/src/features/e2_status/presentation/widgets/views/full_payload_view.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:json_data_explorer/json_data_explorer.dart';
import 'package:provider/provider.dart' as p;

class Comms extends StatefulWidget {
  const Comms({super.key, required this.boxName});

  final String boxName;

  @override
  State<Comms> createState() => _CommsState();
}

class _CommsState extends State<Comms> {
  get itemBuilder => null;
  bool copied = false;
  List<String> base64Images = [];
  bool hasImages = false;

  int selectedIndex = 0;
  NotificationData? _selectedNotificationData;
  void changeImdex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final DataExplorerStore store = DataExplorerStore();

  @override
  Widget build(BuildContext context) {
    return p.ChangeNotifierProvider.value(
      value: store,
      child: p.Consumer<DataExplorerStore>(
          builder: (context, DataExplorerStore value, child) {
        return Row(
          children: [
            Expanded(
              flex: 1,
              child: NotificationAndPayloadList(
                boxName: widget.boxName,
                onChange: (a) {
                  setState(() {
                    final imgField = a.data['data']['img']["id"];
                    if (imgField != null) {
                      if (imgField is List) {
                        // base64Images = imgField.map((e) => (e as Map<String, dynamic>)['id'] as String).toList();
                        base64Images =
                            imgField.map((e) => e as String).toList();
                        hasImages = true;
                      } else if (imgField is String) {
                        base64Images = [imgField];
                        hasImages = true;
                      } else {
                        hasImages = false;
                      }
                    } else {
                      hasImages = false;
                    }

                    _selectedNotificationData = a;
                    value.buildNodes(a.data);
                  });
                },
                selectedNotificationData: _selectedNotificationData,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.containerBgColor,
                ),
                child: TabDisplay(
                  tabNames: const <String>['Body', 'Images'],
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.containerBgColor,
                      ),
                      child: _selectedNotificationData != null
                          ? ReusableJsonDataExplorer(
                              nodes: value.displayNodes,
                              value: value,
                            )
                          : Container(
                              height: double.infinity,
                              width: double.infinity,
                              color: AppColors.containerBgColor,
                              child: Center(
                                child: Text(
                                    'Select a notification to view its payload',
                                    style: TextStyles.small14regular(
                                      color: const Color(0xFFDFDFDF),
                                    )),
                              ),
                            ),
                    ),
                    PayloadImageViwer(
                      base64Images: base64Images,
                      hasImages: hasImages,
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class NotificationAndPayloadList extends ConsumerStatefulWidget {
  final String boxName;
  final NotificationData? selectedNotificationData;
  final Function(NotificationData) onChange;
  const NotificationAndPayloadList({
    super.key,
    required this.boxName,
    this.selectedNotificationData,
    required this.onChange,
  });

  @override
  ConsumerState<NotificationAndPayloadList> createState() =>
      _NotificationAndPayloadListState();
}

class _NotificationAndPayloadListState
    extends ConsumerState<NotificationAndPayloadList> {
  late List<NotificationData> notficationDatas;
  @override
  Widget build(BuildContext context) {
    final e2Client = E2Client();
    final data = e2Client.boxMessages[widget.boxName];

    final state = ref.watch(filterProvider);

    notficationDatas = [
      ...(data?.notificationMessages ?? []).map(
        (e) => NotificationData(
          id: e.payload['EE_HASH'],
          data: e.payload,
          dateTime: e.localTimestamp,
          notificationType: NotificationType.Notification,
        ),
      ),
      ...(data?.payloadMessages ?? []).map(
        (e) => NotificationData(
          id: e.payload.hash ?? '',
          data: e.payload.messageBody ?? {},
          dateTime: e.localTimestamp,
          notificationType: NotificationType.Payload,
        ),
      ),
    ].where((notificationData) {
      // Apply filtering based on provider settings
      if (!state.isNotification && !state.isPayload) {
        return true; // Show both notifications and payloads
      } else if (state.isNotification && state.isPayload) {
        return true; // Show all notifications and payloads
      } else if (state.isNotification) {
        return notificationData.notificationType ==
            NotificationType.Notification;
      } else if (state.isPayload) {
        return notificationData.notificationType == NotificationType.Payload;
      }
      return false; // Default to not showing anything
    }).toList();
    notficationDatas.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return E2Listener(
      onPayload: (a) {
        setState(() {});
      },
      onNotification: (a) {
        setState(() {});
      },
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.containerBgColor,
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final notifcationData = notficationDatas[index];
                    return InkWell(
                      onTap: () => widget.onChange(notifcationData),
                      child: _NotificationListItem(
                        notificationData: notifcationData,
                        isSelected: widget.selectedNotificationData?.id ==
                            notifcationData.id,
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: notficationDatas.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationListItem extends StatelessWidget {
  final NotificationData notificationData;
  final bool isSelected;
  const _NotificationListItem({
    super.key,
    required this.notificationData,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2E2C6A) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            notificationData.notificationType.name,
            style: TextStyles.small14regular(color: const Color(0xFFDFDFDF)),
          ),
          Text(
            DateFormat('HH:mm:ss').format(notificationData.dateTime),
            style: TextStyles.small14regular(color: const Color(0xFFDFDFDF)),
          ),
        ],
      ),
    );
  }
}

enum NotificationType { Payload, Notification }

class NotificationData {
  final NotificationType notificationType;
  final Map<String, dynamic> data;
  final DateTime dateTime;
  final String id;

  NotificationData({
    required this.id,
    required this.notificationType,
    required this.data,
    required this.dateTime,
  });
}

Future<void> _copyNode(NodeViewModelState node, BuildContext context) async {
  String text;
  if (node.isRoot) {
    final value = node.isClass ? 'class' : 'array';
    debugPrint('key and value is ${node.key}: ${value}');
    text = '${node.key}: ${node.value}';
  } else {
    text = '${node.key}: ${node.value}';
  }
  await Clipboard.setData(ClipboardData(text: text));
}
