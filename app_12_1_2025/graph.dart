import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SuccessRateGraph extends StatelessWidget {
  final List<double> successRates;

  SuccessRateGraph({required this.successRates});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Success Rate Graph'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, interval: 0.1),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Test ${value.toInt()}'),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: successRates
                    .asMap()
                    .entries
                    .map((entry) => FlSpot(entry.key.toDouble() + 1, entry.value))
                    .toList(),
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                belowBarData: BarAreaData(show: false),
                dotData: FlDotData(show: true),
              ),
            ],
            minX: 1,
            maxX: successRates.length.toDouble(),
            minY: 0,
            maxY: 1,
          ),
        ),
      ),
    );
  }
}
