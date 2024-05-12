import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/models/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyHeatMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime selectedMonth = Provider.of<ExpenseData>(context).selectedMonth;
    List<ExpenseItem> filteredExpenses = Provider.of<ExpenseData>(context)
        .getFilteredExpenseListByMonth(selectedMonth);

    return Container(
      child: HeatMap(
        datasets: generateExpenseDataMap(filteredExpenses),
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 20)),
        textColor: Colors.black,
        showColorTip: false,
        size: 30,
        defaultColor: Color(0xFFEEF0F4),
        colorMode: ColorMode.opacity,
        showText: false,
        scrollable: true,
        colorsets: generateColorPalette(filteredExpenses),
        onClick: (DateTime value) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(value);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Date: $formattedDate'),
            ),
          );
        },
      ),
    );
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

  Map<int, Color> generateColorPalette(List<ExpenseItem> expenses) {
    // Создаем цветовую палитру, где цвет зависит от суммы расходов за каждый день
    Map<int, Color> colorPalette = {};

    // Проходим по всем расходам
    for (ExpenseItem expense in expenses) {
      DateTime date = DateTime(
          expense.dateTime.year, expense.dateTime.month, expense.dateTime.day);

      // Получаем сумму расходов за текущий день
      int totalExpenseForDay = getTotalExpenseForDay(expenses, date);

      // Получаем цвет для текущей суммы расходов
      Color colorForDay = _getColorForAmount(totalExpenseForDay.toDouble());

      // Добавляем цвет в палитру для текущего дня
      colorPalette[date.day] = colorForDay;
    }

    return colorPalette;
  }

  int getTotalExpenseForDay(List<ExpenseItem> expenses, DateTime date) {
    int totalExpense = 0;
    for (ExpenseItem expense in expenses) {
      if (DateTime(expense.dateTime.year, expense.dateTime.month,
              expense.dateTime.day) ==
          date) {
        totalExpense += int.parse(expense.amount);
      }
    }
    return totalExpense;
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
}
