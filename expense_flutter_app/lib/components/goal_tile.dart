import 'package:expense_flutter_app/components/goal_summary.dart';
import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/data/hive_goals.dart';
import 'package:expense_flutter_app/models/goal_item.dart';
import 'package:expense_flutter_app/pages/goal_history_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class GoalListItem extends StatelessWidget {
  final GoalItem goal;
  final TextEditingController _amountController =
      TextEditingController(); // Контроллер для управления текстовым полем

  GoalListItem({
    Key? key,
    required this.goal,
  }) : super(key: key);

  void _openAddAmountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Введите сумму'),
          content: TextField(
            controller:
                _amountController, // Привязываем контроллер к текстовому полю
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Сумма',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                double newAmount = double.tryParse(_amountController.text) ??
                    0.0; // Получаем значение суммы из контроллера
                // Выполняем необходимые действия с новой суммой
                if (newAmount > 0) {
                  Provider.of<ExpenseData>(context, listen: false)
                      .updateGoalAmountAndHistory(goal.name, newAmount);
                }
                Navigator.of(context).pop();
              },
              child: Text('Добавить'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Отмена'),
            ),
          ],
        );
      },
    );
  }

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

    return formattedValue;
  }

  @override
  Widget build(BuildContext context) {
    String currencySymbol = Provider.of<ExpenseData>(context).currencySymbol;
    ExpenseData expenseData = Provider.of<ExpenseData>(context);
    if (expenseData.selectedCurrency == 'RUB') {
      currencySymbol = '₽';
    } else if (expenseData.selectedCurrency == 'USD') {
      currencySymbol = '\$';
    } else if (expenseData.selectedCurrency == 'EUR') {
      currencySymbol = '€';
    }

    void _navigateToHistoryPage(BuildContext context) {
      final expenseData = Provider.of<ExpenseData>(context, listen: false);
      expenseData
          .setGoalForHistoryPage(goal); // Установка цели для страницы истории
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GoalHistoryPage(goal: goal)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEEF0F4),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              MyPercentIndicatorGoal(
                goalAmount: goal.goalAmount,
                savedAmount: goal.savedAmount,
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'Сумма накопления: ',
                    ),
                    TextSpan(
                      text: '${formatDouble(goal.goalAmount)} $currencySymbol',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: 'Накоплено: ',
                    ),
                    TextSpan(
                      text:
                          '${formatDouble(goal.savedAmount)} $currencySymbol ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text:
                          '(${((goal.savedAmount / goal.goalAmount) * 100).toStringAsFixed(2)}%)',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: goal.savedAmount / goal.goalAmount < 0.8
                            ? Color(
                                0xFF8393A5) // Если меньше 80%, то красный цвет
                            : Color(
                                0xFF3CB96A), // Если больше или равно 80%, то зеленый цвет
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                    ),
                    onPressed: () {
                      _openAddAmountDialog(context);
                    },
                    child: Row(
                      children: [
                        Text(
                          'Добавить сумму',
                          style: TextStyle(color: Color(0xFF3A86FF)),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Color(0xFF3A86FF),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                    ),
                    onPressed: () {
                      _navigateToHistoryPage(context);
                    },
                    child: Row(
                      children: [
                        Text(
                          'История',
                          style: TextStyle(color: Color(0xFF3A86FF)),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Icon(
                          Icons.history,
                          color: Color(0xFF3A86FF),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
