import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MyPieChart extends StatelessWidget {
  final Map<String, double> categoryExpenses;
  final List<Color> colors;

  const MyPieChart({
    Key? key,
    required this.categoryExpenses,
    required this.colors,
  }) : super(key: key);

  String formatDouble(double value) {
    String formattedValue = value.toString();

    // Проверяем, если значение является целым числом
    if (value == value.toInt()) {
      formattedValue =
          value.toInt().toString(); // Преобразуем в строку без дробной части
    } else {
      formattedValue =
          formattedValue.replaceAll(RegExp(r'(?<=\.\d*?)0*?$'), '');
    }

    return '$formattedValue';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150, // задаем ширину
      height: 150, // задаем высоту
      child: Stack(
        children: [
          Transform.scale(
            scale: 0.70,
            child: PieChart(
              PieChartData(
                sectionsSpace: 8,
                sections: _buildPieChartSections(),
              ),
            ),
          ),
          Positioned(
            right: 0, // Располагаем в левом углу
            bottom: 4, // Располагаем внизу
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _buildLegend(),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    List<PieChartSectionData> sections = [];
    int colorIndex = 0;

    categoryExpenses.forEach((category, expense) {
      sections.add(
        PieChartSectionData(
          showTitle: true,
          value: expense,
          title: formatDouble(expense), // Используем форматированное значение
          color: colors[colorIndex],
          radius: 30, // Радиус секции
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
      colorIndex = (colorIndex + 1) % colors.length; // Переходим к следующему цвету
    });

    return sections;
  }

  List<Widget> _buildLegend() {
    List<Widget> legendWidgets = [];
    int colorIndex = 0;
    categoryExpenses.forEach((category, _) {
      legendWidgets.add(
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors[colorIndex],
                  borderRadius: BorderRadius.circular(6)
                ),
              ),
              SizedBox(width: 4),
              Text(
                category,
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
        ),
      );
      legendWidgets.add(SizedBox(height: 4));
      colorIndex = (colorIndex + 1) % colors.length;
    });
    return legendWidgets;
  }
}
