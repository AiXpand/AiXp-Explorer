import 'dart:math';

import 'package:e2_explorer/src/features/common_widgets/text_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../styles/color_styles.dart';

class LineChartWidget extends StatelessWidget {
  const LineChartWidget(
      {super.key,
      required this.borderColor,
      required this.gradient,
      required this.title,
      required this.data,
      required this.timestamps,
      this.maximumY});

  final Color borderColor;
  final Gradient? gradient;
  final String title;
  final List<double> data;
  final List<String> timestamps;
  final double? maximumY;

  LineChartBarData get finalData => LineChartBarData(
        isCurved: true,
        color: borderColor,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        showingIndicators: [0, 2, 3],
        belowBarData: BarAreaData(
          show: true,

          /// vertical line from top to bottom in each data points.
          // spotsLine: BarAreaSpotsLine(
          //   show: true,
          //   checkToShowSpotLine: (FlSpot spot) {
          //     var d = spot.x;
          //     print(d);
          //     return true;
          //   },
          //   flLineStyle: FlLine(
          //     color: const Color(0xFFBEC3E1).withOpacity(0.7),
          //     dashArray: [3, 3],
          //     strokeWidth: 0.9,
          //   ),
          // ),
          gradient: gradient,
        ),
        spots: data.asMap().entries.map((e) {
          int index = e.key;
          double value = e.value;
          return FlSpot(index.toDouble(), value.toDouble());
        }).toList(),
      );

  LineChartData get sampleData2 {
    double maxData =
        data.reduce((value, element) => value > element ? value : element);
    double averageChange = _calculateAverageChange(data);
    double minBufferMultiplier = 0.19; // Adjust this multiplier as needed
    double minBuffer = averageChange * minBufferMultiplier;
    double bufferPercentage = 0.15; // Adjust this buffer percentage as needed
    double buffer = max(maxData * bufferPercentage, minBuffer);
    double maxY = maxData + buffer;
    return LineChartData(
      backgroundColor: AppColors.containerBgColor,
      lineTouchData: lineTouchData2,
      gridData: gridData,
      titlesData: titlesData2,
      borderData: borderData,
      lineBarsData: lineBarsData2,
      minX: 0,
      maxX: (timestamps.length.toDouble() - 1),
      maxY: maximumY ?? maxY,
      minY: 0,
    );
  }

  LineTouchData get lineTouchData2 => const LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.white,
      ));

  FlGridData get gridData => const FlGridData(show: false);

  FlTitlesData get titlesData2 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles,
        ),
      );

  FlBorderData get borderData => FlBorderData(show: false);

  SideTitles get leftTitles => SideTitles(
        showTitles: true,
        reservedSize: 40,
        interval: 10,
        getTitlesWidget: (value, meta) {
          return TextWidget(value.toStringAsFixed(0),
              style: CustomTextStyles.text12_400_tertiary);
        },
      );

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: (value, meta) {
          int index = value.toInt();
          if (index >= 0 && index < timestamps.length) {
            return TextWidget(
              getTimeStamps(
                timestamps[index],
              ),
              style: CustomTextStyles.text12_400_tertiary,
            );
          } else {
            return InkWell(
                onTap: () => print("No data available"), child: const Text(""));
          }
        },
      );

  String getTimeStamps(String timeStamps) {
    String timestamp = timeStamps;
    DateTime parsedDateTime = DateTime.parse(timestamp);
    String timeString = DateFormat.Hm().format(parsedDateTime);
    return timeString;
  }

  double _calculateAverageChange(List<double> data) {
    double sum = 0;
    for (int i = 1; i < data.length; i++) {
      sum += (data[i] - data[i - 1]).abs();
    }
    return sum / (data.length - 1);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: Color(0xFFb6b6b6),
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('8:00', style: style);
        break;
      case 2:
        text = const Text('8:30', style: style);
        break;
      case 3:
        text = const Text('9:00', style: style);
        break;
      case 4:
        text = const Text('9:30', style: style);
        break;
      case 5:
        text = const Text('10:00', style: style);
        break;
      case 6:
        text = const Text('10:30', style: style);
        break;
      case 7:
        text = const Text('11:00', style: style);
        break;
      case 8:
        text = const Text('11:30', style: style);
        break;
      case 9:
        text = const Text('12:00', style: style);
        break;
      case 10:
        text = const Text('12:30', style: style);
        break;
      case 11:
        text = const Text('1:00', style: style);
        break;
      case 12:
        text = const Text('1:30', style: style);
        break;
      default:
        text = const Text('8:00', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: text,
    );
  }

  List<LineChartBarData> get lineBarsData2 => [
        finalData,
      ];

  @override
  Widget build(BuildContext context) {
    //if any value is in negative then it makes it 0

    return Container(
      // width: 570,
      // height: 315,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.containerBgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 18, right: 26, left: 26),
            child: TextWidget(
              title,
              style: CustomTextStyles.text16_600,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 1.87,
            // aspectRatio: 1.23,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: LineChart(
                sampleData2,
                duration: const Duration(milliseconds: 250),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
