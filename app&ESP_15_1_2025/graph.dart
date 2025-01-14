import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SuccessRateGraph extends StatelessWidget {
  final List<double> successRates;
  final double max_y;
  final Color colorgraph;

  SuccessRateGraph({required this.successRates, required this.max_y,required this.colorgraph});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
           /*   child: Text(
                'Success Rate Graph',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),*/
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
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
                          reservedSize: 40, // Space for x-axis titles
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
                        color: colorgraph,
                        barWidth: 3,
                        belowBarData: BarAreaData(show: false),
                        dotData: FlDotData(show: true),
                      ),
                    ],
                    minX: 1,
                    maxX: successRates.length.toDouble(),
                    minY: 0,
                    maxY: max_y,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
