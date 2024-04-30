import 'package:e2_explorer/src/features/common_widgets/table/sticky_header_table.dart';
import 'package:e2_explorer/src/features/common_widgets/table/sync_scroll_controller.dart';
import 'package:e2_explorer/src/utils/dimens.dart';
import 'package:e2_explorer/src/widgets/transparent_inkwell_widget.dart';
import 'package:flutter/material.dart';

import '../../../styles/color_styles.dart';
import '../buttons/refresh_button_with_animation.dart';
import 'flr_table_types.dart';

typedef TranslateCallback = String Function(BuildContext context);

class FLRTableLabels {
  final TranslateCallback filters;
  final TranslateCallback hideColumns;
  final TranslateCallback hiddenColumn;
  final TranslateCallback $1hiddenColumns;

  final RefreshButtonWithAnimationLabels refreshButton;

  FLRTableLabels({
    required this.filters, //AppStrings.filters.translated,
    required this.hideColumns, //AppStrings.hideColumns.translate(context)
    required this.hiddenColumn, //AppStrings.hiddenColumn.translate(context)
    required this.$1hiddenColumns, //AppStrings.$1hiddenColumns.translate(context)
    required this.refreshButton,
  });
}

class FLRTable<ItemType, ColumnType extends Enum> extends StatefulWidget {
  const FLRTable({
    super.key,
    this.verticalSyncController,
    this.horizontalSyncController,
    required this.columns,
    required this.columnsLeft,
    required this.columnsRight,
    required this.visibleColumns,
    required this.sortingColumns,
    required this.sortedColumn,
    required this.items,
    required this.rowBuilder,
    required this.headerBuilder,
    required this.headerTitle,
    required this.columnWidth,
    required this.onTap,
    required this.onRefresh,
    required this.rowHeight,
    this.headerHeight = Dimens.tableHeaderRowHeight,
    required this.isLoading,
    required this.labels,
    this.filtersContent,
    this.selectedRowIndex = -1,
    this.selectRowOnClick = true,
    this.refreshEnabled = true,
    this.selectColumnsMenuEnabled = true,
    this.tableActionsLeft = const <Widget>[],
    this.tableActionsRight = const <Widget>[],
    this.expandLastColumn = false,
  });

  final FLRTableLabels labels;

  final SyncScrollController? verticalSyncController;
  final SyncScrollController? horizontalSyncController;
  final List<ColumnType> columns;
  final List<ColumnType> columnsLeft;
  final List<ColumnType> columnsRight;
  final Set<ColumnType> visibleColumns;
  final Set<ColumnType> sortingColumns;
  final ColumnType? sortedColumn;
  final List<ItemType> items;
  final FLRTableRowBuilder<ItemType, ColumnType> rowBuilder;
  final FLRTableHeaderBuilder<ColumnType> headerBuilder;
  final FLRTableHeaderTitle<ColumnType> headerTitle;
  final FLRTableColumnWidth<ColumnType> columnWidth;
  final Future<void> Function(int) onTap;
  final void Function() onRefresh;
  final double headerHeight;
  final FLRTableRowHeightCallback<ItemType> rowHeight;
  final bool isLoading;
  final bool selectRowOnClick;
  final Widget? filtersContent;
  final int selectedRowIndex;
  final bool refreshEnabled;
  final bool selectColumnsMenuEnabled;
  final List<Widget> tableActionsLeft;
  final List<Widget> tableActionsRight;
  final bool expandLastColumn;

  @override
  State<FLRTable<ItemType, ColumnType>> createState() =>
      _FLRTableState<ItemType, ColumnType>();
}

class _FLRTableState<ItemType, ColumnType extends Enum>
    extends State<FLRTable<ItemType, ColumnType>> {
  final Set<ColumnType> _visibleColumns = <ColumnType>{};
  final List<ColumnType> _columns = <ColumnType>[];
  bool _filtersExpanded = false;

  @override
  void initState() {
    super.initState();

    _columns.addAll(widget.columns);

    if (!_checkLeftColumns() || !_checkRightColumns()) {
      throw StateError('Fixed columns should respect columns order.');
    }

    _visibleColumns.addAll(widget.visibleColumns);
  }

  bool _checkLeftColumns() {
    for (int index = 0; index < widget.columnsLeft.length; index++) {
      if (_columns[index] != widget.columnsLeft[index]) {
        return false;
      }
    }

    return true;
  }

  bool _checkRightColumns() {
    final List<ColumnType> reversedColumns = _columns.reversed.toList();
    final List<ColumnType> reversedColumnsRight =
        widget.columnsRight.reversed.toList();
    for (int index = 0; index < reversedColumnsRight.length; index++) {
      if (reversedColumns[index] != reversedColumnsRight[index]) {
        return false;
      }
    }

    return true;
  }

  List<ColumnType> get getColumnsToBuild {
    return _columns.where(_visibleColumns.contains).toList();
  }

  List<ColumnType> get getFixedLeft {
    return widget.columnsLeft.where(_visibleColumns.contains).toList();
  }

  List<ColumnType> get getFixedRight {
    return widget.columnsRight.where(_visibleColumns.contains).toList();
  }

  void _reorderColumns(int oldIndex, int newIndex) {
    int index = newIndex;
    if (oldIndex < index) {
      index--;
    }

    setState(() {
      final ColumnType oldColumn = _columns.removeAt(oldIndex);
      _columns.insert(index, oldColumn);
    });
  }

  void _onHideShowColumn(ColumnType column) {
    final Set<ColumnType> newVisibleColumns = <ColumnType>{};

    if (_visibleColumns.contains(column)) {
      newVisibleColumns.addAll(
        <ColumnType>{..._visibleColumns}..remove(column),
      );
    } else {
      newVisibleColumns.addAll(
        <ColumnType>{..._visibleColumns, column},
      );
    }

    setState(() {
      _visibleColumns
        ..clear()
        ..addAll(newVisibleColumns);
    });
  }

  bool isHovered = false;
  int hoveredIndex = -1;

  Color getContainerColor(int index) {
    return index.isEven
        ? getHovered(index)
            ? AppColors.sideNavSelectedTileBgColor
            : AppColors.tableRowEvenIndexBgColor
        : getHovered(index)
            ? AppColors.sideNavSelectedTileBgColor
            : AppColors.alertDialogBgColor;
  }

  void changeHovered(bool value, int index) {
    setState(() {
      isHovered = value;
      hoveredIndex = index;
    });
  }

  bool getHovered(int index) {
    return isHovered && hoveredIndex == index;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        /// TABLE CONTENT
        Expanded(
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(0),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: StickyHeadersTable(
                    isLoading: widget.isLoading,
                    verticalSyncController: widget.verticalSyncController,
                    horizontalSyncController: widget.horizontalSyncController,
                    fixedLeft: getFixedLeft.length,
                    fixedRight: getFixedRight.length,
                    headersLength: getColumnsToBuild.length,
                    headerHeight: widget.headerHeight,
                    columnWidth: (int columnIndex) {
                      final ColumnType columnType =
                          getColumnsToBuild[columnIndex];
                      return widget.columnWidth(columnType);
                    },
                    rowsLength: widget.items.length,
                    headersBuilder: (int index) {
                      final ColumnType column = getColumnsToBuild[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            // top: BorderSide(
                            //   color: AppColors.tableBorderColor,
                            // ),
                            left: BorderSide(
                              color: AppColors.tableBorderColor,
                            ),
                            bottom: BorderSide(
                              color: AppColors.tableBorderColor,
                            ),
                          ),
                          color: AppColors.tableHeaderBgColor,
                        ),
                        width: widget.columnWidth(column),
                        height: widget.headerHeight,
                        child: widget.headerBuilder(
                          FLRHeaderInfo<ColumnType>(
                            columnType: getColumnsToBuild[index],
                            title: widget.headerTitle(column),
                            canSortBy: widget.sortingColumns.contains(column),
                            isSortedBy: widget.sortedColumn == column,
                          ),
                        ),
                      );
                    },
                    rowsBuilder: (int colIndex, int rowIndex) {
                      final ColumnType header = getColumnsToBuild[colIndex];
                      final double width = widget.columnWidth(header);
                      final ItemType item = widget.items[rowIndex];
                      final List<Widget> row = widget.rowBuilder(
                        item,
                        getColumnsToBuild,
                      );
                      final double height = widget.rowHeight(item);
                      return Container(
                        width: width,
                        height: height,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: getContainerColor(
                            rowIndex,
                          ),
                          border: Border(
                            right: BorderSide(
                              color: AppColors.tableBorderColor,
                            ),
                            bottom: rowIndex == widget.items.length - 1
                                ? BorderSide(
                                    color: AppColors.tableBorderColor,
                                  )
                                : BorderSide.none,
                          ),
                        ),
                        child: row[colIndex],
                      );
                    },
                    onRowTap: (int index) {
                      /*if (widget.selectRowOnClick) {
                        setState(() {
                          _selectedRow = index;
                        });
                      }*/
                      widget.onTap(index);
                    },
                    onRowHover: (value, index) {
                      changeHovered(value, index);
                    },
                    isRowSelected: (int rowIndex) {
                      return widget.selectRowOnClick &&
                          widget.selectedRowIndex == rowIndex;
                    },
                    rowHeight: (int rowIndex) {
                      final ItemType item = widget.items[rowIndex];
                      return widget.rowHeight(item);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
