import 'package:expense_flutter_app/bar_graph/bar_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatelessWidget {
  final double? maxY;
  final double sunAmount;
  final double monAmount;
  final double tueAmount;
  final double wedAmount;
  final double thurAmount;
  final double friAmount;
  final double satAmount;

  const MyBarGraph(
      {super.key,
      required this.maxY,
      required this.sunAmount,
      required this.monAmount,
      required this.tueAmount,
      required this.wedAmount,
      required this.thurAmount,
      required this.friAmount,
      required this.satAmount});

  @override
  Widget build(BuildContext context) {
    // initialize the bar data
    BarData myBarData = BarData(
        sunAmount: sunAmount,
        monAmount: monAmount,
        tueAmount: tueAmount,
        wedAmount: wedAmount,
        thurAmount: thurAmount,
        friAmount: friAmount,
        satAmount: satAmount);
    myBarData.initializeBarData();

    return BarChart(BarChartData(
      
      maxY: maxY,
      minY: 0,
      titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getBottomTitles,
          ))),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: myBarData.barData
          .map((data) => BarChartGroupData(x: data.x, barRods: [
                BarChartRodData(
                  toY: data.y,
                  color: Color(0xFF3A86FF),
                  width: 25,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: Color(0xFFEEF0F4),
                  ),
                )
              ]))
          .toList(),
    ));
  }
}

Widget getBottomTitles(double value, TitleMeta meta) {
  const style =
      TextStyle(color: Color(0xFF8393A5), fontWeight: FontWeight.bold, fontSize: 14);
  Widget text;
  switch (value.toInt()) {
    case 0:
      text = const Text('Пн', style: style);
      break;
    case 1:
      text = const Text('Вт', style: style);
      break;
    case 2:
      text = const Text('Ср', style: style);
      break;
    case 3:
      text = const Text('Чт', style: style);
      break;
    case 4:
      text = const Text('Пт', style: style);
      break;
    case 5:
      text = const Text('Сб', style: style);
      break;
    case 6:
      text = const Text('Вс', style: style);
      break;
    default:
      text = const Text('', style: style);
      break;
  }
  return SideTitleWidget(child: text, axisSide: meta.axisSide);
}
