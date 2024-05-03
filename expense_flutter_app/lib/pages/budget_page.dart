import 'package:expense_flutter_app/components/budget_summary.dart';
import 'package:expense_flutter_app/components/goal_summary.dart';
import 'package:expense_flutter_app/components/goal_tile.dart';
import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/data/hive_goals.dart';
import 'package:expense_flutter_app/models/budget_item.dart';
import 'package:expense_flutter_app/models/goal_item.dart';
import 'package:expense_flutter_app/pages/add_budget_page.dart';
import 'package:expense_flutter_app/pages/add_goals_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({Key? key}) : super(key: key);

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late List<GoalItem> _goals = [];
  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseData>(context, listen: false).loadData();
    _loadSavedGoals();
    
  }

  // Метод для загрузки сохраненных целей
  Future<void> _loadSavedGoals() async {
    List<GoalItem> goals = await HiveGoalDatabase.readGoalData();
    setState(() {
      _goals = goals; // Обновляем состояние списка целей
    });
  }

  // Метод для удаления цели
  void _deleteGoal(int index) async {
    // Получаем цель для удаления
    GoalItem goalToRemove = _goals[index];

    // Удаляем цель из базы данных
    await HiveGoalDatabase.deleteGoalData(goalToRemove.name);

    // Удаляем цель из списка
    setState(() {
      _goals.removeAt(index);
    });
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
    final expenseData = Provider.of<ExpenseData>(context);
    final currentBudget = expenseData.getCurrentBudget();
    double spentAmount =
        expenseData.getTotalExpenses(); // Метод возвращает сумму всех расходов
    double remainingPercent = expenseData.getRemainingBudgetPercent();
    final goals = expenseData.getAllGoals();
    String currency = Provider.of<ExpenseData>(context).selectedCurrency;
    String currencySymbol = Provider.of<ExpenseData>(context).currencySymbol;
    if (expenseData.selectedCurrency == 'RUB') {
      currencySymbol = '₽';
    } else if (expenseData.selectedCurrency == 'USD') {
      currencySymbol = '\$';
    } else if (expenseData.selectedCurrency == 'EUR') {
      currencySymbol = '€';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Бюджет',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 10,
              ), // Добавляем немного пространства между текстом "Бюджет" и кнопкой/плашкой
              if (currentBudget != null) ...[
                // Плашка с информацией о бюджете
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF0F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Бюджет до ${currentBudget?.endDate.day}/${currentBudget?.endDate.month}/${currentBudget?.endDate.year}',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      MyPercentIndicator(
                        budgetAmount: currentBudget?.amount ?? 0,
                        totalExpenses: spentAmount,
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
                              text: 'Осталось из бюджета: ',
                            ),
                            TextSpan(
                              text: '${formatDouble(currentBudget.amount)} $currencySymbol',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ), // Добавляем немного пространства между плашкой и текстом "Общая сумма расходов"
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Общая сумма расходов за период: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight
                              .normal, // Здесь устанавливаем обычный вес шрифта
                        ),
                      ),
                      TextSpan(
                        //text: '$spentAmount',
                        text: '${formatDouble(spentAmount)} $currencySymbol',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight
                              .w700, // Здесь устанавливаем жирный вес шрифта
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                const Divider(
                  color: Color(0xFF8393A5),
                  thickness: 0.2,
                ), // Добавляем пространство между текстом и кнопкой
                TextButton(
                  onPressed: () {
                    // Действие при нажатии кнопки "Удалить бюджет"
                    Provider.of<ExpenseData>(context, listen: false)
                        .deleteBudget();
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        EdgeInsets.zero), // Убираем встроенные отступы
                  ),
                  child: const Text(
                    'Удалить бюджет',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(
                  color: Color(0xFF8393A5),
                  thickness: 0.2,
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    // Действие при нажатии кнопки
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddBudget()),
                    ).then((result) {
                      if (result != null) {
                        Provider.of<ExpenseData>(context, listen: false)
                            .setBudget(result);
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A86FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity,
                        50), // Ширина кнопки равна ширине родительского виджета
                  ),
                  child: const Text(
                    'Добавить бюджет',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
              const SizedBox(
                height: 20,
              ), // Добавляем немного пространства перед текстом "Цели"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Цели',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.w700),
                  ),
                  if (goals.isNotEmpty) ...[
                    IconButton(
                      onPressed: () async {
                        final newGoal = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddGoalsPage()),
                        );

                        if (newGoal != null) {
                          setState(() {
                            _goals.add(newGoal);
                          });
                        }
                      },
                      icon: Icon(Icons.add, color: Color(0xFF3A86FF)),
                      iconSize: 28,
                      color: Colors.black,
                    ),
                  ],
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // Вывод списка целей или кнопки "Добавить цель"
              if (goals.isEmpty) ...[
                ElevatedButton(
                  onPressed: () async {
                    final newGoal = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddGoalsPage()),
                    );

                    if (newGoal != null) {
                      // Обновляем список целей сразу после добавления новой цели
                      setState(() {
                        _goals.add(newGoal);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A86FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity,
                        50), // Ширина кнопки равна ширине родительского виджета
                  ),
                  child: const Text(
                    'Добавить цель',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ] else ...[
                // Вывод списка целей
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      goals.map((goal) => GoalListItem(goal: goal)).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
