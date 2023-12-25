import 'package:data_table_2/data_table_2.dart';
import 'package:e2_explorer/dart_e2/models/payload/netmon/netmon_box_details.dart';
import 'package:e2_explorer/src/features/unfeatured_yet/network_monitor/presentation/table_elements/netmon_table_row.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:e2_explorer/src/styles/text_styles.dart';
import 'package:flutter/material.dart';

class NetmonTable extends StatefulWidget {
  const NetmonTable({
    super.key,
    required this.boxStatusList,
    this.onBoxSelected,
  });

  final List<NetmonBox> boxStatusList;
  final void Function(String)? onBoxSelected;

  @override
  State<NetmonTable> createState() => _NetmonTableState();
}

class _NetmonTableState extends State<NetmonTable> {
  @override
  void didUpdateWidget(NetmonTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      /// Update the table data if a new message is identified
      tableData = widget.boxStatusList;

      /// Update the sorted table data by applying necessary sort on the tableData
      sortedTableData = List<NetmonBox>.from(tableData);
      if (sortColumnIndex != null) {
        sortOnDependencyChange(sortColumnIndex!);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('Netmon table dependencies');
    setState(() {
      /// Update the table data if a new message is identified
      tableData = widget.boxStatusList;

      /// Update the sorted table data by applying necessary sort on the tableData
      sortedTableData = List<NetmonBox>.from(tableData);
      if (sortColumnIndex != null) {
        onColumnSort(sortColumnIndex!);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    tableData = widget.boxStatusList;

    /// Update the sorted table data by applying necessary sort on the tableData
    sortedTableData = List<NetmonBox>.from(tableData);
    if (sortColumnIndex != null) {
      sortOnDependencyChange(sortColumnIndex!);
    }
  }

  late List<NetmonBox> tableData;
  late List<NetmonBox> sortedTableData;
  bool sortAscending = true;
  int? sortColumnIndex = 2;

  void sortOnDependencyChange(int columnIndex) {
    sortedTableData.sort(_netmonTableColumnsData[columnIndex].sortingFunction);
    if (sortAscending == false) {
      sortedTableData = sortedTableData.reversed.toList();
    }
    setState(() {
      sortColumnIndex = columnIndex;
    });
  }

  void onColumnSort(int columnIndex) {
    sortedTableData.sort(_netmonTableColumnsData[columnIndex].sortingFunction);
    sortAscending = sortColumnIndex != columnIndex ? true : !sortAscending;
    if (sortAscending == false) {
      sortedTableData = sortedTableData.reversed.toList();
    }
    setState(() {
      sortColumnIndex = columnIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (tableData.isEmpty) {
      return Center(
        child: Text(
          'Netmon not received yet!',
          style: TextStyles.body(),
        ),
      );
    } else {
      final theme = Theme.of(context);
      return Theme(
        data: theme.copyWith(
            iconTheme: theme.iconTheme.copyWith(color: ColorStyles.light200)),
        child: Container(
          decoration: const BoxDecoration(
            color: ColorStyles.dark900,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: DataTable2(
            columnSpacing: 12,
            sortAscending: sortAscending,
            sortColumnIndex: sortColumnIndex,
            headingRowColor:
                MaterialStateColor.resolveWith((states) => ColorStyles.dark700),
            border: TableBorder.all(
              width: 2,
              color: ColorStyles.dark600,

              // borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            columns: _netmonTableColumnsData
                .map((data) => _getNetmonDataColumn(
                      data: data,
                      onSort: onColumnSort,
                    ))
                .toList(),
            // rows: [],
            rows: sortedTableData
                .map((data) => createNetmonTableDataRow(
                    data.boxId, data.details,
                    onBoxClicked: widget.onBoxSelected))
                .toList(),
          ),
        ),
      );
    }
  }
}

DataColumn _getNetmonDataColumn({
  required NetmonTableHeaderData data,
  void Function(int columnIndex)? onSort,
}) {
  return DataColumn2(
    size: ColumnSize.L,
    label: Text(
      data.title,
      style: TextStyles.body(),
      textAlign: TextAlign.left,
    ),
    onSort: (columnIndex, ascending) {
      onSort?.call(columnIndex);
    },
    // onSort: data.onSort,
  );
}

class NetmonTableHeaderData {
  final String title;
  final int Function(NetmonBox box1, NetmonBox box2)? sortingFunction;

  const NetmonTableHeaderData({
    required this.title,
    this.sortingFunction,
  });
}

final _netmonTableColumnsData = [
  NetmonTableHeaderData(
    title: 'Box ID',
    sortingFunction: (box1, box2) =>
        box1.boxId.toLowerCase().compareTo(box2.boxId.toLowerCase()),
  ),
  NetmonTableHeaderData(
    title: 'Working',
    sortingFunction: (box1, box2) => box1.details.working
        .toLowerCase()
        .compareTo(box2.details.working.toLowerCase()),
  ),
  NetmonTableHeaderData(
    title: 'Trust',
    sortingFunction: (box1, box2) =>
        box1.details.trust.compareTo(box2.details.trust),
  ),
  NetmonTableHeaderData(
    title: 'Score',
    sortingFunction: (box1, box2) =>
        box1.details.score.compareTo(box2.details.score),
  ),
  NetmonTableHeaderData(
    title: 'Disk',
    sortingFunction: (box1, box2) =>
        box1.details.availDisk.compareTo(box2.details.availDisk),
  ),
  NetmonTableHeaderData(
    title: 'Mem',
    sortingFunction: (box1, box2) =>
        box1.details.availMem.compareTo(box2.details.availMem),
  ),
  NetmonTableHeaderData(
    title: 'CPU Load',
    sortingFunction: (box1, box2) =>
        box1.details.cpuPast1h.compareTo(box2.details.cpuPast1h),
  ),
  NetmonTableHeaderData(
    title: 'GPU Load',
    sortingFunction: (box1, box2) =>
        box1.details.gpuLoadPast1h.compareTo(box2.details.gpuLoadPast1h),
  ),
  NetmonTableHeaderData(
    title: 'GPU Mem',
    sortingFunction: (box1, box2) =>
        box1.details.gpuLoadPast1h.compareTo(box2.details.gpuLoadPast1h),
  ),
  NetmonTableHeaderData(
    title: 'Last seen',
    sortingFunction: (box1, box2) =>
        box1.details.lastSeenSec.compareTo(box2.details.lastSeenSec),
  ),
  NetmonTableHeaderData(
    title: 'Version',
    sortingFunction: (box1, box2) =>
        box1.details.version.compareTo(box2.details.version),
  ),
];
