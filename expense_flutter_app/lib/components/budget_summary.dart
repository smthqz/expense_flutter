import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MyPercentIndicator extends StatelessWidget {
  final double budgetAmount; // Общая сумма бюджета
  final double totalExpenses; // Сумма расходов

  const MyPercentIndicator({
    Key? key,
    required this.budgetAmount,
    required this.totalExpenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (budgetAmount == 0) {
      return const SizedBox(); // Если бюджет равен нулю, не отображаем индикатор
    }

    double spentPercent = (totalExpenses / (budgetAmount + totalExpenses))
        .clamp(0.0, 1.0); // Ограничиваем значения от 0 до 1

    // Логирование для отладки
    debugPrint('Spent percent: $spentPercent');
    debugPrint('Budget Amount: $budgetAmount');

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Center(
          child: LinearPercentIndicator(
            width: constraints.maxWidth, // Вычитаем 24 для отступов
            lineHeight: 16,
            animation: true,
            animateFromLastPercent: true,
            percent:
                spentPercent, // Отображаем сколько уже потрачено от бюджета
            backgroundColor:
                Color(0xFFD9D9D9)!, // Используем нейтральный цвет фона
            progressColor: spentPercent < 0.8
                ? const Color(0xFF3CB96A)
                : Colors.red, 
            barRadius: const Radius.circular(12),
          ),
        );
      },
    );
  }
}
