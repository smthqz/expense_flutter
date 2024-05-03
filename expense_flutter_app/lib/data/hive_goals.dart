import 'package:expense_flutter_app/models/goal_item.dart';
import 'package:hive/hive.dart';

class HiveGoalDatabase {
  static Box? _goalBox;

  // Статический метод для получения бокса
  static Future<Box> getGoalBox() async {
    _goalBox ??= await Hive.openBox('goal_database');
    return _goalBox!;
  }

  // Регистрируем адаптер для класса AmountHistoryItem
  static void registerAdapters() {
    Hive.registerAdapter(AmountHistoryItemAdapter());
  }

  // Метод для сохранения данных цели
  static Future<void> saveGoalData(GoalItem goal) async {
    var box = await getGoalBox();
    // Преобразуем список AmountHistoryItem в список словарей с суммами и датами
    List<Map<String, dynamic>> amountHistoryData = goal.amountHistory
        .map((item) => item.toMap()) // Используем метод toMap из адаптера
        .toList();

    Map<String, dynamic> goalFormatted = {
      'name': goal.name,
      'amount': goal.goalAmount,
      'goalDate': goal.goalDate.toIso8601String(),
      'savedAmount': goal.savedAmount,
      'amountHistory': amountHistoryData,
    };
    List<dynamic> allGoals = box.get('GOALS', defaultValue: <dynamic>[]);
    allGoals.add(goalFormatted);
    await box.put('GOALS', allGoals);
  }

  // Метод для чтения данных цели
  static Future<List<GoalItem>> readGoalData() async {
    var box = await getGoalBox();
    List<dynamic> savedGoals = box.get('GOALS', defaultValue: []);
    return savedGoals.map<GoalItem>((goalData) {
      // Преобразуем список словарей в список AmountHistoryItem
      List<AmountHistoryItem> amountHistory = [];
      if (goalData['amountHistory'] != null &&
          goalData['amountHistory'] is List) {
        amountHistory = (goalData['amountHistory'] as List)
            .map<AmountHistoryItem>((historyItem) {
          // Создаем объект AmountHistoryItem из словаря
          return AmountHistoryItem(
            amount: historyItem['amount'] as double,
            date: DateTime.parse(historyItem['date'] as String),
          );
        }).toList();
      }

      return GoalItem(
        name: goalData['name'] as String,
        goalAmount: goalData['amount'] as double,
        savedAmount: goalData['savedAmount'] as double ?? 0.0,
        goalDate: DateTime.parse(goalData['goalDate'] as String),
        amountHistory: amountHistory,
      );
    }).toList();
  }

  // Удаление данных
  static Future<void> deleteGoalData(String goalName) async {
    var box = await getGoalBox();
    List<dynamic> savedGoals = box.get('GOALS', defaultValue: []);
    savedGoals.removeWhere((goalData) => goalData['name'] == goalName);
    await box.put('GOALS', savedGoals);
  }

  static Future<void> deleteAllGoalsData() async {
    var box = await getGoalBox();
    await box.clear(); // Очищаем бокс, удаляя все данные о целях
  }

  static Future<void> updateGoalAmount(
      String goalName, double newSavedAmount) async {
    var box = await getGoalBox();
    List<dynamic> savedGoals = box.get('GOALS', defaultValue: []);
    for (var goalData in savedGoals) {
      if (goalData['name'] == goalName) {
        // Обновляем значение savedAmount для цели
        goalData['savedAmount'] = newSavedAmount;
        break;
      }
    }
    await box.put('GOALS', savedGoals);
  }

  static Future<void> updateGoalHistory(
      String goalName, List<AmountHistoryItem> newHistory) async {
    var box = await getGoalBox();
    List<dynamic> savedGoals = box.get('GOALS', defaultValue: []);
    for (var goalData in savedGoals) {
      if (goalData['name'] == goalName) {
        // Преобразуем список AmountHistoryItem в список словарей
        List<Map<String, dynamic>> formattedHistory = newHistory
            .map((item) => item.toMap()) // Используем метод toMap из адаптера
            .toList();
        goalData['amountHistory'] = formattedHistory;
        break;
      }
    }
    await box.put('GOALS', savedGoals);
  }

  // Метод для получения истории сумм для выбранной цели
  static Future<List<double>> getAmountHistoryForGoal(String goalName) async {
    var box = await getGoalBox();
    List<dynamic> savedGoals = box.get('GOALS', defaultValue: []);
    for (var goalData in savedGoals) {
      if (goalData['name'] == goalName) {
        // Если найдена цель с указанным именем, возвращаем её историю сумм
        List<dynamic> amountHistory = goalData['amountHistory'] ?? [];
        return List<double>.from(amountHistory);
      }
    }
    // Если цель не найдена, возвращаем пустой список
    return [];
  }

  Future<void> addAmountToHistory(String goalName, double amount) async {
    // Создаем объект AmountHistoryItem с данными о сумме и дате
    AmountHistoryItem newAmountItem = AmountHistoryItem(
      amount: amount,
      date: DateTime.now(),
    );

    // Обновляем историю сумм в базе данных
    await updateGoalHistory(goalName, [newAmountItem]);
  }

  // Метод для обновления данных цели в базе данных
  static Future<void> updateGoalData(GoalItem goal) async {
    var box = await getGoalBox();
    List<dynamic> savedGoals = box.get('GOALS', defaultValue: []);
    for (var i = 0; i < savedGoals.length; i++) {
      if (savedGoals[i]['name'] == goal.name) {
        // Обновляем данные цели в списке
        savedGoals[i] = {
          'name': goal.name,
          'amount': goal.goalAmount,
          'goalDate': goal.goalDate.toIso8601String(),
          'savedAmount': goal.savedAmount,
          'amountHistory': goal.amountHistory
              .map((item) => item.toMap())
              .toList(), // Обновляем историю сумм
        };
        break;
      }
    }
    await box.put('GOALS', savedGoals); // Обновляем данные в базе данных
  }
}
