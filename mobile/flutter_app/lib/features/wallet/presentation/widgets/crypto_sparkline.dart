import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CryptoSparkline extends StatelessWidget {
  final List<double> prices;
  final bool isPositive;

  const CryptoSparkline({
    super.key,
    required this.prices,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? Colors.greenAccent : Colors.redAccent;

    return SizedBox(
      height: 60,
      width: 100,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (prices.length - 1).toDouble(),
          minY: prices.reduce((a, b) => a < b ? a : b) * 0.9,
          maxY: prices.reduce((a, b) => a > b ? a : b) * 1.1,
          lineBarsData: [
            LineChartBarData(
              spots: prices.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value);
              }).toList(),
              isCurved: true,
              color: color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.2),
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
