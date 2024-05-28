import 'package:expense_flutter_app/models/account_item.dart';
import 'package:hive/hive.dart';

import '../models/expense_item.dart';

class HiveDataBase {
  // reference our box
  final _myBox = Hive.box('expense_database');
  
  // write data
  void saveData(List<ExpenseItem> allExpense) {
    /*
    Hive can only store string and dateTime, and not custom objects like ExpenseItem.
    So lets convert ExpenseItem objects into types that can be stored in our db

    allExpense = [
      ExpenseItem ( name / amount / dateTime )
      ..
    ]

    ->

    [
      [name, amount, datetime],
      ..
    ]
    */
    List<List<dynamic>> allExpensesFormatted = [];
    // convert each expenseItem into a list of storable types (strings, dateTime)
    for (var expense in allExpense) {
      List<dynamic> expenseFormatted = [
        expense.name,
        expense.amount,
        expense.dateTime,
        expense.category,
        expense?.account
        
      ];
      allExpensesFormatted.add(expenseFormatted);
    }
    // finally lets store in out database
    _myBox.put('EXPENSES', allExpensesFormatted);
  }

  // read data
  List<ExpenseItem> readData() {
    /*

    Data is stored in Hive as a list of strings + dateTime so lets convert our saved data into ExpenseItem objects

    savedData = [
      [name, amount, dateTime],
    ]
    ->
    [
      ExpenseItem(name / amount / dateTime)
    ]
    */

    List savedExpenses = _myBox.get('EXPENSES') ?? [];
    List<ExpenseItem> allExpenses = [];
    for (int i = 0; i < savedExpenses.length; i++) {
      // collect individual expense data
      String name = savedExpenses[i][0];
      String amount = savedExpenses[i][1];
      DateTime dateTime = savedExpenses[i][2];
      String category = savedExpenses[i][3];
      Account? account = savedExpenses[i][4];
      

      // create expense item
      ExpenseItem expense = ExpenseItem(
          name: name, amount: amount, dateTime: dateTime, category: category, account: account);
      // add expense to overall list of expenses
      allExpenses.add(expense);
    }
    return allExpenses;
  }




  // Save sort option
  Future<void> saveSortOption(String sortOption) async {
    await _myBox.put('SORT_OPTION', sortOption);
  }

  // Read sort option
  Future<String?> readSortOption() async {
    return _myBox.get('SORT_OPTION');
  }

  // Метод для сохранения выбранной валюты
  Future<void> saveSelectedCurrency(String currency) async {
    await _myBox.put('SELECTED_CURRENCY', currency);
  }

  // Метод для загрузки выбранной валюты
  Future<String?> loadSelectedCurrency() async {
    return _myBox.get('SELECTED_CURRENCY');
  }

  // Метод для очистки всех данных из БД
  Future<void> clearAllData() async {
    await _myBox.clear();
    // Очистить все данные из бокса
  }
}
