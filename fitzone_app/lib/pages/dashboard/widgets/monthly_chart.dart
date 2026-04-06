import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../utilities/constants/app_colors.dart';

class MonthlyRevenueChart extends StatelessWidget {
  final List<double> revenues; // 🔥 dynamic data
  final List<String> months;   // 🔥 optional labels

  const MonthlyRevenueChart({
    super.key,
    required this.revenues,
    required this.months,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Revenue (Last 6 Months)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white10,
                      strokeWidth: 1,
                    );
                  },
                ),

                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "₹${(value ~/ 1000)}k",
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()],
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),

                borderData: FlBorderData(show: false),

                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: false),

                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.2),
                    ),

                    spots: _generateSpots(), // 🔥 dynamic spots
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 Convert list → FlSpot
  List<FlSpot> _generateSpots() {
    return List.generate(
      revenues.length,
      (index) => FlSpot(index.toDouble(), revenues[index]),
    );
  }
}