import 'package:expense_flutter_app/data/hive_database.dart';
import 'package:expense_flutter_app/data/hive_database.dart';
import 'package:expense_flutter_app/data/hive_database.dart';
import 'package:expense_flutter_app/data/hive_user.dart';
import 'package:expense_flutter_app/datetime/date_time_helper.dart';
import 'package:expense_flutter_app/models/account_item.dart';
import 'package:expense_flutter_app/models/budget_item.dart';
import 'package:expense_flutter_app/models/expense_item.dart';
import 'package:expense_flutter_app/models/goal_item.dart';
import 'package:flutter/material.dart';
import 'package:expense_flutter_app/data/hive_budget.dart' as bd;
import 'package:expense_flutter_app/data/hive_goals.dart' as gd;
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'hive_database.dart';

class ExpenseData extends ChangeNotifier {
  GoalItem? _goalForHistoryPage;
  String? userEmail;
  List<Account> _accountList = [];

  List<Account> get accountList => _accountList;
  GoalItem? get goalForHistoryPage => _goalForHistoryPage;
  String _selectedCurrency = 'RUB'; // Инициализируем текущую выбранную валюту

  String get selectedCurrency => _selectedCurrency;
  String _currencySymbol = '₽';
  String get currencySymbol => _currencySymbol;
  String russianMonthName = '';
  bool _isPrepareDataCalled = false; // Флаг для отслеживания вызова prepareData
  // Флаг, указывающий, были ли данные загружены ранее
  bool _isDataLoaded = false;
  late DateTime _selectedMonth;
  // Переменная для хранения информации о наличии расходов для выбранного месяца
  bool _hasExpensesForSelectedMonth = false;

  ExpenseData() {
    russianMonthName = getRussianMonthName(DateTime.now().month - 1);
    _selectedMonth = DateTime.now();
    _selectedCurrency = 'RUB';
    if (!_isPrepareDataCalled) {
      prepareData();
      _isPrepareDataCalled =
          true; // Устанавливаем флаг в true после вызова prepareData
    }
    loadAccounts();
    loadSelectedCurrency();
  }

  Future<void> loadAccounts() async {
    _accountList = await getAccounts();
    notifyListeners();
  }

  void updateCurrency(String currency) {
    // Устанавливаем символ валюты в соответствии с выбранной валютой
    if (currency == 'RUB') {
      _currencySymbol = '₽';
    } else if (currency == 'USD') {
      _currencySymbol = '\$';
    } else if (currency == 'EUR') {
      _currencySymbol = '€';
    }

    _selectedCurrency = currency;

    notifyListeners(); // Сообщаем виджетам, что состояние изменилось
  }

  bool get hasExpensesForSelectedMonth => _hasExpensesForSelectedMonth;

  set hasExpensesForSelectedMonth(bool value) {
    _hasExpensesForSelectedMonth = value;
    notifyListeners();
  }

  DateTime get selectedMonth => _selectedMonth;
  set selectedMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners(); // Уведомляем слушателей об изменении выбранного месяца
  }

  int _selectedMonthIndex = DateTime.now().month - 1;
  int get selectedMonthIndex => _selectedMonthIndex;
  void setSelectedMonthIndex(int index) {
    _selectedMonthIndex = index;
    notifyListeners(); // Сообщаем об изменениях провайдеру
  }

  // Метод для очистки всех данных из БД
  Future<void> clearAllData() async {
    deleteExpenses();
    deleteAllGoals();
    deleteBudget();
    deleteAllAccounts();
    notifyListeners(); // Очистить все данные из БД
  }

  void setUserEmail(String email) {
    userEmail = email;
    notifyListeners();
  }

  void clearUserEmail() {
    userEmail = null;
    notifyListeners();
  }

  void loadUserEmail() {
    userEmail = HiveUser.getUserEmail();
    notifyListeners();
  }

  // list of ALL expenses
  List<ExpenseItem> overallExpenseList = [];

  BudgetItem? currentBudget;
  final db2 = bd.HiveDataBase();
  // List of ALL goals
  List<GoalItem> goalList = [];
  final dbGoal = gd.HiveGoalDatabase(); // база данных для целей
  String _monthName = DateFormat.MMMM('ru').format(DateTime.now());
  String get monthName => _monthName; // Геттер для получения значения monthName

  // Сеттер для установки нового значения monthName и уведомления подписчиков
  set monthName(String value) {
    _monthName = value;
    notifyListeners(); // Уведомляем подписчиков об изменении
  }

  // Метод для установки нового значения русского падежа месяца
  void setRussianMonthName(String value) {
    russianMonthName = value;
    notifyListeners(); // Уведомляем подписчиков об изменении
  }

  // Метод для получения русского падежа месяца по индексу
  String getRussianMonthName(int monthIndex) {
    switch (monthIndex) {
      case 0:
        return 'январе';
      case 1:
        return 'феврале';
      case 2:
        return 'марте';
      case 3:
        return 'апреле';
      case 4:
        return 'мае';
      case 5:
        return 'июне';
      case 6:
        return 'июле';
      case 7:
        return 'августе';
      case 8:
        return 'сентябре';
      case 9:
        return 'октябре';
      case 10:
        return 'ноябре';
      case 11:
        return 'декабре';
      default:
        return '';
    }
  }

  List<ExpenseItem> getAllExpenseList(DateTime selectedMonth) {
    // все расходы
    List<ExpenseItem> allExpenses = overallExpenseList;

    // Фильтрация списка расходов по выбранному месяцу
    List<ExpenseItem> filteredExpenses = allExpenses
        .where((expense) =>
            expense.dateTime.month == selectedMonth.month &&
            expense.dateTime.year == selectedMonth.year)
        .toList();

    return filteredExpenses;
  }

  List<ExpenseItem> getFilteredExpenseListByMonth(DateTime selectedMonth) {
    // все расходы
    List<ExpenseItem> allExpenses = overallExpenseList;

    // список расходов по выбранному месяцу
    List<ExpenseItem> filteredExpenses = allExpenses
        .where((expense) =>
            expense.dateTime.month == selectedMonth.month &&
            expense.dateTime.year == selectedMonth.year)
        .toList();

    return filteredExpenses;
  }

  // Load initial data
  Future<void> loadData() async {
    // Load budgets
    var budgets = await bd.HiveDataBase.readBudgetData();
    if (budgets.isNotEmpty) {
      currentBudget = budgets.last;
      notifyListeners();
    }

    // Load goals
    var goals = await gd.HiveGoalDatabase.readGoalData();
    if (goals.isNotEmpty) {
      goalList = goals;
      notifyListeners();
    }
    if (!_isDataLoaded) {
      // Установка русского падежа месяца
      // _russianMonthName = getRussianMonthName(DateTime.now().month - 1); // Вычитаем 1, потому что месяцы в Dart нумеруются с 1 до 12
      // Устанавливаем флаг, указывающий на то, что данные были загружены
      _isDataLoaded = true;
      notifyListeners();
    }
  }

  void sortExpensesByDate() {
    overallExpenseList.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  void sortExpensesByAmount() {
    overallExpenseList.sort(
        (a, b) => -double.parse(a.amount).compareTo(double.parse(b.amount)));
  }

  void sortExpensesByCurrentSortOption() async {
    String? currentSortOption = await readSortOption();
    switch (currentSortOption) {
      case 'amount':
        sortExpensesByAmount();
        break;
      case 'date':
      default:
        sortExpensesByDate();
        break;
    }
  }

  void setFilteredExpenseList(List<ExpenseItem> filteredExpenses) {
    overallExpenseList = filteredExpenses;
  }

  void updateExpensesByMonth(int selectedMonthIndex) async {
    // Обновляем состояние, хранящее выбранный месяц
    setSelectedMonthIndex(selectedMonthIndex);

    // Загружаем или обновляем данные перед фильтрацией расходов
    prepareData();

    // Получаем выбранный месяц
    DateTime selectedMonth =
        DateTime(DateTime.now().year, selectedMonthIndex + 1);

    // Фильтруем расходы для выбранного месяца
    List<ExpenseItem> filteredExpenses = overallExpenseList
        .where((expense) =>
            expense.dateTime.month == selectedMonth.month &&
            expense.dateTime.year == selectedMonth.year)
        .toList();

    // Устанавливаем отфильтрованный список как новый список расходов
    setFilteredExpenseList(filteredExpenses);

    // Сортируем расходы по выбранному месяцу
    sortExpensesByMonth(selectedMonth);
    notifyListeners();
  }

  void updateExpensesForSelectedMonth(int selectedMonthIndex) {
    // Получаем выбранный месяц
    DateTime selectedMonth =
        DateTime(DateTime.now().year, selectedMonthIndex + 1);

    // Получаем все расходы
    List<ExpenseItem> allExpenses = overallExpenseList;

    // Фильтруем список расходов по выбранному месяцу
    List<ExpenseItem> filteredExpenses = allExpenses
        .where((expense) =>
            expense.dateTime.month == selectedMonth.month &&
            expense.dateTime.year == selectedMonth.year)
        .toList();

    // Устанавливаем отфильтрованный список как новый список расходов для отображения
    setFilteredExpenseList(filteredExpenses);

    // Уведомляем слушателей об изменении данных
    notifyListeners();
  }

  // Фильтрация списка расходов при выборе текущего месяца без его изменения
  void filterExpensesForCurrentMonth() {
    // Фильтруем список расходов по текущему месяцу
    List<ExpenseItem> filteredExpenses = overallExpenseList
        .where((expense) =>
            expense.dateTime.month == _selectedMonth.month &&
            expense.dateTime.year == _selectedMonth.year)
        .toList();

    // Устанавливаем отфильтрованный список как новый список расходов
    setFilteredExpenseList(filteredExpenses);

    // Уведомляем всех слушателей о изменениях
    notifyListeners();
  }

  void checkExpensesForSelectedMonth(int selectedMonthIndex) {
    // Получаем список расходов для выбранного месяца
    List<ExpenseItem> expensesForSelectedMonth = getFilteredExpenseListByMonth(
        DateTime(DateTime.now().year, selectedMonthIndex + 1,
            1)); // +1 потому что месяцы нумеруются с 1

    // Проверяем, есть ли расходы для выбранного месяца
    if (expensesForSelectedMonth.isNotEmpty) {
      // Если есть, устанавливаем флаг или переменную для отображения расходов

      hasExpensesForSelectedMonth = true;
    } else {
      // Если нет, устанавливаем флаг или переменную для скрытия расходов

      hasExpensesForSelectedMonth = false;
    }

    // Уведомляем слушателей об изменениях
    notifyListeners();
  }

  // Метод для добавления нового счета в БД
  Future<void> addAccount(Account account) async {
    final box = await Hive.openBox<Account>('accounts');
    await box.add(account);
    notifyListeners();
  }

  // Метод для получения списка всех счетов из БД
  Future<List<Account>> getAccounts() async {
    final box = await Hive.openBox<Account>('accounts');
    notifyListeners();
    return box.values.toList();
  }

  // Метод для обновления баланса счета при добавлении расхода
  void updateAccountBalanceByExpense(Account account, double expenseAmount) {
    account.balance -= expenseAmount;
    saveAccountListToDatabase();
    notifyListeners();
  }

  void saveAccountListToDatabase() async {
    // Открываем или создаем коробку (базу данных) для счетов
    var box = await Hive.openBox<Account>('accounts');
    // Находим каждый счет в базе данных и обновляем его баланс
    for (var account in accountList) {
      // Находим индекс счета в базе данных
      int index = box.values
          .toList()
          .indexWhere((element) => element.balance == account.balance);
      if (index != -1) {
        // Если счет найден в базе данных, обновляем его баланс
        await box.putAt(index, account);
      }
    }
  }

  void updateAccountBalance(String accountName, double newBalance) {
    // Найдите счет в списке счетов по имени
    Account accountToUpdate =
        accountList.firstWhere((account) => account.name == accountName);
    // Обновите баланс счета
    accountToUpdate.balance = newBalance;
    saveAccountListToDatabase();
    // Сохраните изменения в базе данных или в другом хранилище
    // Примерное название метода для сохранения списка счетов
    // Уведомите слушателей о изменении данных
    notifyListeners();
  }

  // Метод для обновления счета в БД по индексу
  Future<void> updateAccount(int index, Account updatedAccount) async {
    final box = await Hive.openBox<Account>('accounts');
    await box.putAt(index, updatedAccount);
    notifyListeners();
  }

  void updateAccountName(String oldName, String newName) {
    int index = accountList.indexWhere((account) => account.name == oldName);
    if (index != -1) {
      accountList[index].name = newName;
      saveAccountListToDatabase();
      notifyListeners();
    }
  }

  List<ExpenseItem> getExpensesForAccount(String accountName) {
    return overallExpenseList
        .where((expense) => expense.account?.name == accountName)
        .toList();
  }

  // Метод для удаления счета из БД по индексу
  Future<void> deleteAccount(int index) async {
    final box = await Hive.openBox<Account>('accounts');
    await box.deleteAt(index);
    notifyListeners();
  }

  void deleteAllAccounts() async {
    accountList.clear();
    notifyListeners();
    final box = await Hive.openBox<Account>('accounts');
    box.clear();
    // Уведомить слушателей после удаления всех счетов
  }

  // Manage goals
  List<GoalItem> getAllGoals() {
    return goalList;
  }

  // Метод для добавления суммы в историю для выбранной цели и обновления данных в БД
  Future<void> updateGoalAmountAndHistory(
      String goalName, double amount) async {
    // Находим цель по имени
    GoalItem goal = goalList.firstWhere((goal) => goal.name == goalName);
    // Обновляем сумму накоплений и добавляем сумму в историю
    goal.addSavedAmount(amount);
    // Сохраняем обновленные данные в БД
    await gd.HiveGoalDatabase.updateGoalData(goal);
    // Уведомляем слушателей об изменении данных
    notifyListeners();
  }

  // Метод для установки цели для страницы истории
  void setGoalForHistoryPage(GoalItem goal) {
    _goalForHistoryPage = goal;
    notifyListeners();
  }

  void addNewGoal(GoalItem newGoal) {
    gd.HiveGoalDatabase.saveGoalData(newGoal);
    goalList.add(newGoal);
    notifyListeners();
  }

  void deleteGoal(GoalItem goal) async {
    goalList.remove(goal); // Удаляем цель из списка
    notifyListeners();
    await gd.HiveGoalDatabase.deleteGoalData(
        goal.name); // Удаляем цель из базы данных
  }

  Future<void> addAmountToHistory(String goalName, double amount) async {
    // Получаем текущую историю сумм для цели
    List<AmountHistoryItem> currentHistory = getAmountHistoryForGoal(goalName);

    // Создаем экземпляр AmountHistoryItem для новой суммы и её даты
    AmountHistoryItem newAmount = AmountHistoryItem(
      amount: amount,
      date: DateTime.now(),
    );

    // Добавляем новую сумму в историю
    currentHistory.add(newAmount);

    // Обновляем историю сумм в базе данных
    await gd.HiveGoalDatabase.updateGoalHistory(goalName, currentHistory);

    // Уведомляем слушателей о изменениях данных
    notifyListeners();
  }

  void updateGoal(GoalItem updatedGoal) {
    // Find the goal in the list and update it
    for (int i = 0; i < goalList.length; i++) {
      if (goalList[i].name == updatedGoal.name) {
        goalList[i] = updatedGoal;
        break;
      }
    }
    notifyListeners();
    gd.HiveGoalDatabase.saveGoalData(updatedGoal);
  }

  void deleteAllGoals() async {
    goalList.clear(); // Очищаем список целей
    notifyListeners();
    await gd.HiveGoalDatabase
        .deleteAllGoalsData(); // Удаляем все цели из базы данных
  }

  // Обновление суммы накоплений цели и списка amountHistory
  void updateGoalAmount(String goalName, double additionalAmount) async {
    for (int i = 0; i < goalList.length; i++) {
      if (goalList[i].name == goalName) {
        goalList[i].savedAmount +=
            additionalAmount; // Обновляем сумму накоплений
        // Сохранение обновленных данных в базе данных
        await gd.HiveGoalDatabase.updateGoalAmount(
            goalName, goalList[i].savedAmount);

        notifyListeners();
        return;
      }
    }
  }

  List<AmountHistoryItem> getAmountHistoryForGoal(String goalName) {
    // Находим цель в списке по её имени
    GoalItem? selectedGoal = goalList.firstWhere(
      (goal) => goal.name == goalName,
      orElse: () => GoalItem(
          name: '',
          goalAmount: 0,
          savedAmount: 0,
          goalDate: DateTime.now()), // Возвращаем пустой экземпляр GoalItem
    );

    // Если цель найдена, возвращаем её историю сумм
    if (selectedGoal != null) {
      return selectedGoal.amountHistory;
    } else {
      // Если цель не найдена, возвращаем пустой список
      return [];
    }
  }

  // Управление бюджетом
  BudgetItem? getCurrentBudget() {
    return currentBudget;
  }

  void setBudget(BudgetItem newBudget) {
    currentBudget = newBudget;
    currentBudget?.originalAmount = newBudget.amount;
    bd.HiveDataBase.saveBudgetData(newBudget);
    notifyListeners();
  }

  void deleteBudget() {
    currentBudget = null; // Удаляем текущий бюджет
    bd.HiveDataBase.deleteBudgetData(); // Удаляем данные из базы данных
    notifyListeners(); // Уведомляем слушателей
  }

  void deleteExpenses() {
    overallExpenseList = [];
    db.clearAllData();
    notifyListeners();
  }

  //prepare data to display

  final db = HiveDataBase();
  void prepareData() {
    if (db.readData().isNotEmpty) {
      overallExpenseList = db.readData();
      notifyListeners();
    }
  }

  void updateExpenseName(int index, String newName) {
    // Получаем список всех расходов из базы данных Hive
    List<ExpenseItem> allExpenses = db.readData();

    // Проверяем, что индекс находится в допустимых пределах
    if (index >= 0 && index < allExpenses.length) {
      // Обновляем название расхода
      allExpenses[index].name = newName;

      // Сохраняем изменения в базе данных Hive
      db.saveData(allExpenses);
      prepareData();
      // Уведомляем слушателей об изменениях
      notifyListeners();
    } else {
      print('Ошибка: Недопустимый индекс');
    }
  }

  void updateExpenseAmount(int index, String newAmount) {
    // Получаем список всех расходов из базы данных Hive
    List<ExpenseItem> allExpenses = db.readData();

    // Проверяем, что индекс находится в допустимых пределах
    if (index >= 0 && index < allExpenses.length) {
      // Обновляем название расхода
      allExpenses[index].amount = newAmount;

      // Сохраняем изменения в базе данных Hive
      db.saveData(allExpenses);
      prepareData();
      // Уведомляем слушателей об изменениях
      notifyListeners();
    } else {
      print('Ошибка: Недопустимый индекс');
    }
  }

  void updateExpenseDate(int index, DateTime newDate) {
    // Получаем список всех расходов из базы данных Hive
    List<ExpenseItem> allExpenses = db.readData();

    // Проверяем, что индекс находится в допустимых пределах
    if (index >= 0 && index < allExpenses.length) {
      // Обновляем название расхода
      allExpenses[index].dateTime = newDate;

      // Сохраняем изменения в базе данных Hive
      db.saveData(allExpenses);
      prepareData();
      // Уведомляем слушателей об изменениях
      notifyListeners();
    } else {
      print('Ошибка: Недопустимый индекс');
    }
  }

  void updateExpenseCategory(int index, String newCategory) {
    // Получаем список всех расходов из базы данных Hive
    List<ExpenseItem> allExpenses = db.readData();

    // Проверяем, что индекс находится в допустимых пределах
    if (index >= 0 && index < allExpenses.length) {
      // Обновляем название расхода
      allExpenses[index].category = newCategory;

      // Сохраняем изменения в базе данных Hive
      db.saveData(allExpenses);
      prepareData();
      // Уведомляем слушателей об изменениях
      notifyListeners();
    } else {
      print('Ошибка: Недопустимый индекс');
    }
  }

  void updateExpenseAccount(int expenseIndex, Account newAccount) {
    List<ExpenseItem> allExpenses = db.readData();
    if (expenseIndex >= 0 && expenseIndex < allExpenses.length) {
      allExpenses[expenseIndex].account = newAccount;
      db.saveData(allExpenses);
      prepareData();
      notifyListeners();
    }
  }

  void sortExpensesByMonth(DateTime selectedMonth) {
    overallExpenseList.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    overallExpenseList = overallExpenseList
        .where((expense) =>
            expense.dateTime.month == selectedMonth.month &&
            expense.dateTime.year == selectedMonth.year)
        .toList();
  }

  // add new expense
  void addNewExpense(ExpenseItem newExpense) {
    double expenseAmount =
        double.parse(newExpense.amount); // Преобразуем строку в число
    if (currentBudget != null) {
      currentBudget!.amount -=
          expenseAmount; // Вычитаем сумму расхода из бюджета
      bd.HiveDataBase.saveBudgetData(
          currentBudget!); // Сохраняем обновленные данные бюджета
    }
    overallExpenseList.insert(0, newExpense);
    notifyListeners();
    db.saveData(overallExpenseList);
  }

  // delete expense
  void deleteExpense(ExpenseItem expense) {
    double expenseAmount = double.parse(expense.amount);
    Account? selectedAccount = expense.account;
    selectedAccount?.balance += expenseAmount;

    // Проверяем наличие текущего бюджета
    if (currentBudget != null) {
      // Учитываем только те расходы, которые созданы после создания бюджета
      if (expense.dateTime.isAfter(currentBudget!.startDate)) {
        currentBudget!.amount +=
            expenseAmount; // Возвращаем сумму обратно в бюджет при удалении расхода
        bd.HiveDataBase.saveBudgetData(currentBudget!);
      }
    }

    overallExpenseList.remove(expense);
    notifyListeners();
    db.saveData(overallExpenseList);
  }

  // get weekday from a dateTime object
  String getDayName(DateTime dateTime) {
    switch (dateTime.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thur';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  // get the date for the start of the week (monday)
  DateTime startOfWeekDate() {
    DateTime? startOfWeek;

    // get todays date
    DateTime today = DateTime.now();

    // go backwards from today to find sunday
    for (int i = 0; i < 7; i++) {
      if (getDayName(today.subtract(Duration(days: i))) == 'Mon') {
        startOfWeek = today.subtract(Duration(days: i));
      }
    }
    return startOfWeek!;
  }

  /*
  convert overall list of expenses into a daily expense summary

  overallExpenseList = [
    [food, 2024/01/30, $10], 
    [drinks, 2024/01/30, $2],
  ]

  ->
  DailyExpenseSummary = [
    [20240130: $12],
  ]
  */
  Map<String, double> calculateDailyExpenseSummary() {
    Map<String, double> dailyExpenseSummary = {
      // date (yyyymmdd) : amountTotalForDay
    };

    for (var expense in overallExpenseList) {
      String date = convertDateTimeToString(expense.dateTime);
      double amount = double.parse(expense.amount);

      if (dailyExpenseSummary.containsKey(date)) {
        double currentAmount = dailyExpenseSummary[date]!;
        currentAmount += amount;
        dailyExpenseSummary[date] = currentAmount;
      } else {
        dailyExpenseSummary.addAll({date: amount});
      }
    }
    return dailyExpenseSummary;
  }

  // Получить данные о расходах по категориям
  Map<String, double> getCategoryExpenses() {
    Map<String, double> categoryExpenses = {};

    for (var expense in overallExpenseList) {
      double amount = double.parse(expense.amount);
      if (categoryExpenses.containsKey(expense.category)) {
        categoryExpenses[expense.category] =
            categoryExpenses[expense.category]! + amount;
      } else {
        categoryExpenses[expense.category] = amount;
      }
    }

    return categoryExpenses;
  }

  double getTotalExpenses() {
    double totalAmount = 0.0;

    // Проходим по всем расходам
    for (ExpenseItem expense in overallExpenseList) {
      // Учитываем только те расходы, которые созданы после создания бюджета
      if (currentBudget != null &&
          expense.dateTime.isAfter(currentBudget!.startDate)) {
        totalAmount += double.parse(expense.amount);
      }
    }

    return totalAmount;
  }

  double getRemainingBudgetPercent() {
    if (currentBudget != null && currentBudget!.originalAmount > 0) {
      return currentBudget!.amount / currentBudget!.originalAmount;
    }
    return 1.0; // Если бюджет не установлен или originalAmount равен 0, возвращаем 1.0 (100%)
  }

  // Save sort option
  Future<void> saveSortOption(String sortOption) async {
    await db.saveSortOption(sortOption);
  }

  // Read sort option
  Future<String?> readSortOption() async {
    return await db.readSortOption();
  }

  // Метод для загрузки выбранной валюты из Hive при инициализации
  Future<String?> loadSelectedCurrency() async {
    String? currency = await db.loadSelectedCurrency();
    if (currency != null) {
      _selectedCurrency = currency;
      notifyListeners();
    }
  }

  // Метод для сохранения выбранной валюты в Hive
  Future<void> saveSelectedCurrency(String currency) async {
    _selectedCurrency = currency;
    await db.saveSelectedCurrency(currency);
    notifyListeners();
  }
}
