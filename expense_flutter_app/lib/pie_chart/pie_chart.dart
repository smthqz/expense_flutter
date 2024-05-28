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

    if (value == value.toInt()) {
      formattedValue = value.toInt().toString();
    } else {
      formattedValue = formattedValue.replaceAll(RegExp(r'(?<=\.\d*?)0*?$'), '');
    }

    return '$formattedValue';
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> legendItems = _buildLegendItems();

    List<Widget> firstRowItems = legendItems.length > 3 ? legendItems.sublist(0, 3) : legendItems; // первый ряд
    List<Widget> secondRowItems = legendItems.length > 3 ? legendItems.sublist(3) : []; // второй ряд

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 70,
              sections: _buildPieChartSections(),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < firstRowItems.length; i++)
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: firstRowItems[i],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 6),
                if (legendItems.length > 3)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < secondRowItems.length; i++)
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: secondRowItems[i],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLegendItems() {
    List<Widget> items = [];

    categoryExpenses.forEach((category, expense) {
      Color color = colors[items.length % colors.length];
      items.add(_buildLegendItem(category, expense, color));
    });

    return items;
  }

  Widget _buildLegendItem(String category, double expense, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$category ${formatDouble(expense)} ₽',
        style: TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    List<PieChartSectionData> sections = [];
    int colorIndex = 0;

    categoryExpenses.forEach((category, expense) {
      sections.add(
        PieChartSectionData(
          showTitle: false,
          value: expense,
          color: colors[colorIndex],
          radius: 15,
        ),
      );
      colorIndex = (colorIndex + 1) % colors.length;
    });

    return sections;
  }
}
