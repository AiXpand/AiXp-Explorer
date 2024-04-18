import 'dart:convert';

import 'package:e2_explorer/src/features/coms/provider/filter_provider.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_client.dart';
import 'package:e2_explorer/src/features/e2_status/application/e2_listener.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:e2_explorer/src/widgets/xml_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Comms extends StatefulWidget {
  const Comms({super.key, required this.boxName});

  final String boxName;

  @override
  State<Comms> createState() => _CommsState();
}

class _CommsState extends State<Comms> {
  get itemBuilder => null;

  int selectedIndex = 0;
  NotificationData? _selectedNotificationData;
  void changeImdex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = E2Client();

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: NotificationAndPayloadList(
            boxName: widget.boxName,
            onChange: (a) {
              setState(() {
                _selectedNotificationData = a;
              });
            },
            selectedNotificationData: _selectedNotificationData,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.containerBgColor,
            ),
            child: _selectedNotificationData != null
                ? SingleChildScrollView(
                    child: XMLViwer(
                      content: jsonEncode(_selectedNotificationData!.data),
                      type: "json",
                    ),
                  )
                : SizedBox(),
          ),
        ),
      ],
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
