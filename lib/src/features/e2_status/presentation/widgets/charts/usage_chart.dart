import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UsageChart extends StatelessWidget {
  const UsageChart({
    super.key,
    this.height = 200,
    required this.values,
    required this.maxValue,
    this.maxSamplesNo = 50,
    this.interval,
  });

  final double height;
  final List<double> values;
  final double maxValue;
  final double maxSamplesNo;
  final double? interval;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          maxY: maxValue,
          maxX: maxSamplesNo,
          minX: 0,
          minY: 0,
          lineTouchData: LineTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toString(),
                    style: const TextStyle(color: Colors.white),
                  );
                },
                showTitles: true,
                interval: interval,
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: values.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value);
              }).toList(),
              isCurved: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.cyanAccent]
                      .map((color) => color.withOpacity(0.3))
                      .toList(),
                ),
              ),
              color: Colors.blue,
              barWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
