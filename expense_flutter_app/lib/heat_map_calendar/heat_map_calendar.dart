import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/models/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:provider/provider.dart';

class MyHeatMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Получите текущий выбранный месяц из провайдера
    DateTime selectedMonth = Provider.of<ExpenseData>(context).selectedMonth;

// Получите отфильтрованный список расходов для текущего месяца
    List<ExpenseItem> filteredExpenses =
        Provider.of<ExpenseData>(context).getAllExpenseList(selectedMonth);
    return Consumer<ExpenseData>(
      builder: (context, expenseData, _) {
        Map<DateTime, Color> colorPalette =
            generateColorPalette(expenseData.getFilteredExpenseListByMonth(selectedMonth));
        Map<int, Color> convertedColorPalette =
            convertColorPalette(colorPalette);

        return Container(
          child: HeatMap(
            datasets: generateExpenseDataMap(expenseData.getFilteredExpenseListByMonth(selectedMonth)),
            startDate: DateTime.now(),
            endDate: DateTime.now().add(Duration(days: 20)),
            textColor: Colors.black,
            showColorTip: false,
            size: 30,
            defaultColor: Color(0xFFEEF0F4),
            colorMode: ColorMode.opacity,
            showText: false,
            scrollable: true,
            colorsets: convertedColorPalette,
            onClick: (value) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(value.toString())));
            },
          ),
        );
      },
    );
  }

  Map<DateTime, Color> generateColorPalette(List<ExpenseItem> expenses) {
    Map<DateTime, Color> colorPalette = {};

    for (ExpenseItem expense in expenses) {
      DateTime date = DateTime(
          expense.dateTime.year, expense.dateTime.month, expense.dateTime.day);
      double totalExpenseForDay = getTotalExpenseForDay(expenses, date);
      colorPalette[date] = _getColorForAmount(totalExpenseForDay);
    }

    return colorPalette;
  }

  double getTotalExpenseForDay(List<ExpenseItem> expenses, DateTime date) {
    double totalExpense = 0;
    for (ExpenseItem expense in expenses) {
      if (DateTime(expense.dateTime.year, expense.dateTime.month,
              expense.dateTime.day) ==
          date) {
        totalExpense += double.parse(expense.amount);
      }
    }
    return totalExpense;
  }

  Map<DateTime, int> generateExpenseDataMap(List<ExpenseItem> expenses) {
    Map<DateTime, int> expenseDataMap = {};

    for (ExpenseItem expense in expenses) {
      DateTime date = DateTime(
          expense.dateTime.year, expense.dateTime.month, expense.dateTime.day);
      expenseDataMap[date] =
          (expenseDataMap[date] ?? 0) + int.parse(expense.amount);
    }

    return expenseDataMap;
  }

  Color _getColorForAmount(double totalExpense) {
    if (totalExpense <= 100) {
      return Color.fromARGB(255, 255, 150, 150); // Light red
    } else if (totalExpense <= 500) {
      return Color.fromARGB(255, 255, 84, 84); // Medium red
    } else if (totalExpense <= 1000) {
      return Color.fromARGB(255, 209, 30, 30); // Dark red
    } else {
      return Color.fromARGB(255, 140, 25, 25); // Very dark red
    }
  }

  Map<int, Color> convertColorPalette(Map<DateTime, Color> colorPalette) {
    Map<int, Color> convertedPalette = {};
    int index = 1;
    colorPalette.forEach((date, color) {
      convertedPalette[index] = color;
      index++;
    });
    return convertedPalette;
  }
}
