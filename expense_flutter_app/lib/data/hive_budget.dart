import 'package:hive/hive.dart';
import 'package:expense_flutter_app/models/budget_item.dart';

class HiveDataBase {
  static Box? _myBox;

  // Статический метод для получения бокса
  static Future<Box> getBox() async {
    _myBox ??= await Hive.openBox('budget_database');
    return _myBox!;
  }

  // Запись данных
  static Future<void> saveBudgetData(BudgetItem budget) async {
    var box = await getBox();
    Map<String, dynamic> budgetFormatted = {
      'amount': budget.amount,
      'startDate': budget.startDate.toIso8601String(),
      'endDate': budget.endDate.toIso8601String()
    };
    List<dynamic> allBudgets = box.get('BUDGETS', defaultValue: <dynamic>[]);
    allBudgets.add(budgetFormatted);
    await box.put('BUDGETS', allBudgets);
  }

  // Чтение данных
  static Future<List<BudgetItem>> readBudgetData() async {
    var box = await getBox();
    List<dynamic> savedBudgets = box.get('BUDGETS', defaultValue: []);
    return savedBudgets.map<BudgetItem>((budgetData) {
      return BudgetItem(
        amount: budgetData['amount'],
        startDate: DateTime.parse(budgetData['startDate']),  // Если даты сохранены как строки
        endDate: DateTime.parse(budgetData['endDate']),
        originalAmount: budgetData['amount']
      );
    }).toList();
}

  // Удаление данных
  static Future<void> deleteBudgetData() async {
    var box = await getBox();
    await box.clear(); // Очистка бокса, удаляет все данные внутри бокса.
  }
}
