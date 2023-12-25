import 'package:e2_explorer/dart_e2/models/payload/netmon/netmon_box_details.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

TableRow createNetmonTableRow(String boxName, NetmonBoxDetails details) {
  return TableRow(
    children: [
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            boxName,
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            '${details.working}',
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            '${details.trust}',
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            '${details.score}',
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            '${details.availDisk}',
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            '${details.availMem}',
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            '${details.isSupervisor}',
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            '${details.cpuPast1h}',
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            '${details.gpuLoadPast1h}',
            style: TextStyles.small14(),
          ),
        ),
      ),
    ],
  );
}

enum NetmonColumn {
  name(sortable: true),
  boxName(sortable: true),
  working(sortable: true),
  trust(sortable: true),
  score(sortable: true),
  availableDisk(sortable: true),
  availableMem(sortable: true),
  supervisor(sortable: true),
  cpuLoad(sortable: true),
  gpuLoad(sortable: true);

  const NetmonColumn({this.sortable = false});

  final bool sortable;
}

TableRow createNetmonHeader() {
  return TableRow(
    decoration: BoxDecoration(
      color: ColorStyles.dark600,
    ),
    children: [
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            'Box name',
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            'Working',
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            'Trust',
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            'Score',
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            'Available Disk',
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            'Available Mem',
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            'Supervisor',
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            'Cpu load past 1h',
            style: TextStyles.small14(),
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Center(
          child: Text(
            'Gpu load past 1h',
            style: TextStyles.small14(),
          ),
        ),
      ),
    ],
  );
}

DataRow createNetmonTableDataRow(String boxName, NetmonBoxDetails details,
    {void Function(String)? onBoxClicked}) {
  return DataRow(
    cells: [
      DataCell(
        Text(
          boxName,
          style: TextStyles.small14(),
        ),
        onTap: () {
          onBoxClicked?.call(boxName);
        },
      ),
      DataCell(
        Text(
          '${details.working}',
          style: TextStyles.small14(
            color: details.working == 'ONLINE'
                ? ColorStyles.green
                : ColorStyles.red,
          ),
        ),
      ),
      DataCell(
        Text(
          '${(details.trust * 100).toStringAsFixed(1)}%',
          style: TextStyles.small14(
            color: details.trust >= 0.75
                ? ColorStyles.green
                : details.trust >= 0.5
                    ? ColorStyles.yellow
                    : ColorStyles.red,
          ),
        ),
      ),
      DataCell(
        Text(
          '${details.score}',
          style: TextStyles.small14(),
        ),
      ),
      DataCell(
        Text(
          '${details.availDisk.toStringAsFixed(1)} GB',
          style: TextStyles.small14(),
        ),
      ),
      DataCell(
        Text(
          '${details.availMem.toStringAsFixed(1)} GB',
          style: TextStyles.small14(),
        ),
      ),
      // DataCell(
      //   Center(
      //     child: Text(
      //       '${details.isSupervisor}',
      //       style: TextStyles.small14(),
      //     ),
      //   ),
      // ),
      DataCell(
        Text(
          '${details.cpuPast1h != -1 ? '${details.cpuPast1h.toStringAsFixed(1)}%' : 'Not enough data'}',
          style: TextStyles.small14(),
        ),
      ),
      DataCell(
        Text(
          '${details.gpuLoadPast1h != -1 ? '${details.gpuLoadPast1h.toStringAsFixed(1)}%' : 'Not enough data'}',
          style: TextStyles.small14(),
        ),
      ),
      DataCell(
        Text(
          '${details.gpuMemPast1h != -1 ? '${details.gpuMemPast1h.toStringAsFixed(1)}%' : 'Not enough data'}',
          style: TextStyles.small14(),
        ),
      ),
      DataCell(
        Text(
          _formatSeconds(details.lastSeenSec.toInt()),
          style: TextStyles.small14(),
        ),
      ),
      DataCell(
        Text(
          details.version.split(' ')[0],
          style: TextStyles.small14(),
        ),
      ),
    ],
  );
}

String _formatSeconds(int seconds) {
  final duration = Duration(seconds: seconds);
  if (duration.inDays > 0) {
    return '${duration.inDays} days ago';
  }
  if (duration.inHours > 0) {
    return '${duration.inHours} hours ago';
  }
  if (duration.inMinutes > 0) {
    return '${duration.inMinutes} minutes ago';
  }
  return '$seconds sec ago';
}
