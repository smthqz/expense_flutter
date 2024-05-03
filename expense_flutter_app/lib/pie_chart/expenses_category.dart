// Модель данных для хранения информации о расходах по категориям
import 'package:flutter/material.dart';

class ExpensesModel extends ChangeNotifier {
  Map<String, double> categoryExpenses = {
    // Добавьте другие категории по мере необходимости
  };

  // Метод для обновления расходов по категориям
  void updateExpenses(Map<String, double> newExpenses) {
    categoryExpenses = newExpenses;
    notifyListeners(); // Сообщаем всем заинтересованным виджетам о изменениях в данных
  }
}