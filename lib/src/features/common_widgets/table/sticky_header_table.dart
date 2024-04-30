// ignore_for_file: avoid_redundant_argument_values

import 'dart:math';

import 'package:e2_explorer/src/features/common_widgets/table/sync_scroll_controller.dart';
import 'package:e2_explorer/src/features/common_widgets/text_widget.dart';
import 'package:e2_explorer/src/styles/color_styles.dart';
import 'package:flutter/material.dart';

/// Table with sticky headers. Whenever you scroll content horizontally
/// or vertically - top and left headers always stay.
class StickyHeadersTable extends StatefulWidget {
  const StickyHeadersTable({
    super.key,

    /// Fixed columns numbers, default: first one and last one
    int fixedLeft = 1,
    int fixedRight = 1,

    /// Sync controllers for rows and columns
    this.verticalSyncController,
    this.horizontalSyncController,

    /// Number of Headers
    required this.headersLength,

    /// Header height
    required this.headerHeight,

    /// Callback function for column width
    required this.columnWidth,

    /// Callback function for row height
    required this.rowHeight,

    /// Number of Rows
    required this.rowsLength,

    /// Builder for column titles. Takes index of content column as parameter
    /// and returns String for column title
    required this.headersBuilder,

    /// Builder for content cell. Takes index for content column first,
    /// index for content row second and returns String for cell
    required this.rowsBuilder,

    /// Callback function for on row tap
    required this.onRowTap,
    //
    required this.onRowHover,

    /// Callback to determine if row is selected
    required this.isRowSelected,
    required this.isLoading,
  })  : assert(
          fixedLeft >= 0 && fixedRight >= 0,
          'Fixed columns numbers should not be negative',
        ),

        /// NOTE: if all columns are fixed => all columns are flexible
        fixedLeft = (fixedLeft + fixedRight >= headersLength) ? 0 : fixedLeft,
        fixedRight = (fixedLeft + fixedRight >= headersLength) ? 0 : fixedRight;

  final bool isLoading;

  final SyncScrollController? verticalSyncController;
  final SyncScrollController? horizontalSyncController;
  final int headersLength;
  final double headerHeight;
  final double Function(int columnIndex) columnWidth;
  final double Function(int rowIndex) rowHeight;
  final int fixedLeft;
  final int fixedRight;
  final int rowsLength;
  final Widget Function(int columnIndex) headersBuilder;
  final Widget Function(int columnIndex, int rowIndex) rowsBuilder;
  final void Function(int rowIndex) onRowTap;
  final bool Function(int rowIndex) isRowSelected;
  final void Function(bool value, int index) onRowHover;

  @override
  State<StickyHeadersTable> createState() => _StickyHeadersTableState();
}

class _StickyHeadersTableState extends State<StickyHeadersTable> {
  late final SyncScrollController _horizontalSyncController;
  late final SyncScrollController _verticalSyncController;

  @override
  void initState() {
    super.initState();
    // Create controllers internally if not given by widget.
    _verticalSyncController =
        widget.verticalSyncController ?? SyncScrollController();
    _horizontalSyncController =
        widget.horizontalSyncController ?? SyncScrollController();
  }

  @override
  void dispose() {
    // Only dispose controllers if created internally.
    if (widget.verticalSyncController == null) {
      _verticalSyncController.dispose();
    }
    if (widget.horizontalSyncController == null) {
      _horizontalSyncController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int flexibleLength =
        widget.headersLength - (widget.fixedLeft + widget.fixedRight);

    double leftWidth = 0;
    double rightWidth = 0;
    double middleWidth = 0;
    const double borderWidth = 1;
    for (int i = 0; i < widget.fixedLeft; i++) {
      leftWidth += widget.columnWidth(i);
    }
    for (int i = 0; i < widget.fixedRight; i++) {
      rightWidth += widget.columnWidth(widget.headersLength - i - 1);
    }
    for (int i = widget.fixedLeft;
        i < widget.headersLength - widget.fixedRight;
        i++) {
      middleWidth += widget.columnWidth(i);
    }
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: widget.headerHeight,
            child: Row(
              children: <Widget>[
                /// STICKY LEFT HEADER
                Container(
                  width: leftWidth + borderWidth,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: AppColors.tableBorderColor,
                        width: borderWidth,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List<Widget>.generate(
                      widget.fixedLeft,
                      (int index) {
                        return widget.headersBuilder(index);
                      },
                    ),
                  ),
                ),

                /// STICKY-FLEXIBLE HEADER
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      if (notification.metrics.axis == Axis.horizontal) {
                        return _horizontalSyncController.onNotification(
                          notification,
                          _horizontalSyncController.leadingController,
                        );
                      }

                      return false;
                    },
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        final double headerWidth =
                            max(constraints.maxWidth, middleWidth);

                        return SizedBox(
                          width: headerWidth,
                          child: CustomScrollView(
                            scrollDirection: Axis.horizontal,
                            controller:
                                _horizontalSyncController.leadingController,
                            physics: const ClampingScrollPhysics(),
                            slivers: <Widget>[
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return widget.headersBuilder(
                                      index + widget.fixedLeft,
                                    );
                                  },
                                  childCount: flexibleLength,
                                ),
                              ),
                              SliverFillRemaining(
                                hasScrollBody: false,
                                fillOverscroll: true,
                                child: Container(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                /// STICKY RIGHT HEADER
                Container(
                  width: rightWidth + 1,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: AppColors.tableBorderColor,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List<Widget>.generate(
                      widget.fixedRight,
                      (int index) {
                        return widget.headersBuilder(
                          index + widget.fixedLeft + flexibleLength,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.rowsLength > 0
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      /// STICKY LEFT COLUMNS
                      NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          if (notification.metrics.axis == Axis.vertical) {
                            return _verticalSyncController.onNotification(
                              notification,
                              _verticalSyncController.leadingController,
                            );
                          }

                          return false;
                        },
                        child: SizedBox(
                          width: leftWidth + 1,
                          // decoration: BoxDecoration(
                          //   border: Border(
                          //     right: BorderSide(
                          //       color: AppColors.tableBorderColor,
                          //     ),
                          //   ),
                          // ),
                          child: ListView.builder(
                            controller:
                                _verticalSyncController.leadingController,
                            itemCount: widget.rowsLength,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (BuildContext context, int rowIndex) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: widget.isRowSelected(rowIndex)
                                      ? AppColors.tableRowEvenIndexBgColor
                                      : null,
                                  border: rowIndex == widget.rowsLength - 1
                                      ? Border(
                                          bottom: BorderSide(
                                            color: AppColors.tableBorderColor,
                                          ),
                                        )
                                      : null,
                                ),
                                child: InkWell(
                                  onHover: (value) {
                                    widget.onRowHover(value, rowIndex);
                                  },
                                  onTap: () => widget.onRowTap(rowIndex),
                                  child: Row(
                                    children: List<Widget>.generate(
                                      widget.fixedLeft,
                                      (int colIndex) {
                                        return widget.rowsBuilder(
                                          colIndex,
                                          rowIndex,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      /// FLEXIBLE CONTENT
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification notification) {
                            switch (notification.metrics.axis) {
                              case Axis.vertical:
                                return _verticalSyncController.onNotification(
                                  notification,
                                  _verticalSyncController.bodyController,
                                );
                              case Axis.horizontal:
                                return _horizontalSyncController.onNotification(
                                  notification,
                                  _horizontalSyncController.bodyController,
                                );
                            }
                          },
                          child: LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              final double contentWidth =
                                  max(middleWidth, constraints.maxWidth);
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller:
                                    _horizontalSyncController.bodyController,
                                physics: const ClampingScrollPhysics(),
                                child: SizedBox(
                                  width: contentWidth,
                                  child: SingleChildScrollView(
                                    controller:
                                        _verticalSyncController.bodyController,
                                    physics: const ClampingScrollPhysics(),
                                    child: Column(
                                      children: List<Widget>.generate(
                                        widget.rowsLength,
                                        (int rowIndex) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: widget
                                                      .isRowSelected(rowIndex)
                                                  ? AppColors
                                                      .tableRowEvenIndexBgColor
                                                  : null,
                                            ),
                                            height: widget.rowHeight(rowIndex),
                                            child: InkWell(
                                              onTap: () {
                                                widget.onRowTap(rowIndex);
                                              },
                                              child: CustomScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                slivers: <Widget>[
                                                  SliverList(
                                                    delegate:
                                                        SliverChildBuilderDelegate(
                                                      (
                                                        BuildContext context,
                                                        int columnIndex,
                                                      ) {
                                                        return widget
                                                            .rowsBuilder(
                                                          columnIndex +
                                                              widget.fixedLeft,
                                                          rowIndex,
                                                        );
                                                      },
                                                      childCount:
                                                          flexibleLength,
                                                    ),
                                                  ),
                                                  const SliverFillRemaining(
                                                    hasScrollBody: false,
                                                    fillOverscroll: true,
                                                    child: SizedBox(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      /// STICKY RIGHT COLUMNS
                      NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          if (notification.metrics.axis == Axis.vertical) {
                            return _verticalSyncController.onNotification(
                              notification,
                              _verticalSyncController.trailingController,
                            );
                          }

                          return false;
                        },
                        child: SizedBox(
                          width: rightWidth + borderWidth,
                          child: ListView.builder(
                            shrinkWrap: true,
                            controller:
                                _verticalSyncController.trailingController,
                            itemCount: widget.rowsLength,
                            itemBuilder: (context, int rowIndex) {
                              return Container(
                                color: widget.isRowSelected(rowIndex)
                                    ? AppColors.tableRowEvenIndexBgColor
                                    : null,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: rowIndex == widget.rowsLength - 1
                                        ? BorderSide(
                                            color: AppColors.tableBorderColor,
                                            width: borderWidth,
                                          )
                                        : BorderSide.none,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => widget.onRowTap(rowIndex),
                                  child: Row(
                                    children: List<Widget>.generate(
                                      widget.fixedRight,
                                      (int colIndex) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: colIndex == 0
                                                  ? BorderSide(
                                                      color: AppColors
                                                          .tableBorderColor,
                                                      width: borderWidth,
                                                    )
                                                  : BorderSide.none,
                                            ),
                                          ),
                                          child: widget.rowsBuilder(
                                            colIndex +
                                                widget.fixedLeft +
                                                flexibleLength,
                                            rowIndex,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : widget.isLoading
                    ? Container()
                    : Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: TextWidget(
                            'No items',
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
