import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SuccessRateGraph extends StatelessWidget {
  final List<double> successRates;
  final double max_y;
  final double healthy_baseline;
  final Color colorgraph;
  final List<String> times;
  final List<int> levels;

  SuccessRateGraph({
    required this.successRates,
    required this.max_y,
    required this.healthy_baseline,
    required this.colorgraph,
    required this.times,
    required this.levels,

  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                           //   child: Text('Test ${value.toInt()}'),
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
                            .map((entry) => FlSpot(entry.key.toDouble() + 1,  entry.value >= max_y ? max_y : entry.value,))
                            .toList(),
                        isCurved: false,
                        color: colorgraph,
                        barWidth: 3,
                        belowBarData: BarAreaData(show: false),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 6,
                            color: colorgraph,
                            strokeWidth: 1.5,
                            strokeColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: healthy_baseline,
                          color: Colors.red,
                          strokeWidth: 2,
                          dashArray: [10, 5], // Dashed line pattern
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.centerRight,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                            labelResolver: (line) =>
                            'Healthy Baseline: ${healthy_baseline.toStringAsFixed(1)}',
                          ),
                        ),
                      ],
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Colors.black87,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              'Test ${spot.x.toInt()}\n'
                                  'Value: ${spot.y.toStringAsFixed(1)}\n'
                                  'Time: ${times[spot.x.toInt() - 1]}\n'
                                  'level: ${levels[spot.x.toInt() - 1]}',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        },

                      ),
                      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                        if (touchResponse != null &&
                            touchResponse.lineBarSpots != null &&
                            event is FlTapUpEvent) {
                          final spot = touchResponse.lineBarSpots!.first;
                          _showDetails(context, spot.x.toInt(), spot.y,);
                        }
                      },
                      handleBuiltInTouches: true,  // Enables touch interaction
                    ),
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

  void _showDetails(BuildContext context, int testNumber, double value) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Test $testNumber Details'),
          content: Text(
            'Success rate: ${value.toStringAsFixed(1)}%\n'
                'Time: ${times[testNumber - 1]}\n'
              'level: ${levels[testNumber - 1]}',// Get the corresponding time
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

}
