import 'dart:collection';
import 'package:expense_flutter_app/components/expense_summary.dart';
import 'package:expense_flutter_app/components/expense_tile.dart';
import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/heat_map_calendar/heat_map_calendar.dart';
import 'package:expense_flutter_app/models/expense_item.dart';
import 'package:expense_flutter_app/pages/budget_page.dart';
import 'package:expense_flutter_app/pages/expense_detail.dart';
import 'package:expense_flutter_app/pages/settings_page.dart';
import 'package:expense_flutter_app/pie_chart/pie_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeWithBarApp extends StatelessWidget {
  const HomeWithBarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavigationBarExample(),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({Key? key}) : super(key: key);

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    BudgetPage(),
    SettingsPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8, top: 8),
        child: GNav(
          tabs: const [
            GButton(
              icon: Icons.home,
              iconColor: Color(0xFF8393A5),
              text: 'Главная',
            ),
            GButton(
              icon: Icons.dataset,
              iconColor: Color(0xFF8393A5),
              text: 'План',
            ),
            GButton(
              icon: Icons.settings,
              iconColor: Color(0xFF8393A5),
              text: 'Настройки',
            ),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: _onItemTapped,
          tabBackgroundColor: const Color(0xFF3A86FF),
          activeColor: Colors.white,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          gap: 8,
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text controllers
  final newExpenseNameController = TextEditingController();
  final newExpenseAmountController = TextEditingController();
  final _controller = PageController();
  String? selectedCategory;
  LinkedHashMap<String, double> categoryExpenses = LinkedHashMap();
  String? _currentSortOption;
  String? _selectedCurrency;
  DateTime selectedMonth = DateTime.now();

  List<String> categories = [
    'Еда',
    'Транспорт',
    'Жилье',
    'Развлечения',
    'Здоровье',
    'Без категории'
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseData>(context, listen: false)
        .loadSelectedCurrency()
        .then((currency) {
      if (currency != null) {
        // Если валюта была сохранена, обновите состояние вашего виджета
        setState(() {
          _selectedCurrency = currency;
        });
      }
    });

    Provider.of<ExpenseData>(context, listen: false)
        .readSortOption()
        .then((value) {
      setState(() {
        _currentSortOption = value;
        if (_currentSortOption != null) {
          if (_currentSortOption == 'date') {
            Provider.of<ExpenseData>(context, listen: false)
                .sortExpensesByDate();
          } else if (_currentSortOption == 'amount') {
            Provider.of<ExpenseData>(context, listen: false)
                .sortExpensesByAmount();
          }
        }
      });
    });

    // Вызовите sortExpensesByMonth с текущим выбранным месяцем
    Provider.of<ExpenseData>(context, listen: false)
        .sortExpensesByMonth(selectedMonth);
  }
  // Восстанавливаем состояние сортировки

  void addNewExpense() {
    String? selectedCategory;

    showBarModalBottomSheet(
      context: context,
      builder: (context) {
        // Получаем высоту экрана
        double screenHeight = MediaQuery.of(context).size.height;
        // Устанавливаем высоту в 90% от высоты экрана
        double height = screenHeight * 0.9;
        return SizedBox(
          height: height,
          child: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Container(
                  height: height,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Добавить новый расход',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Название расхода
                      TextField(
                        controller: newExpenseNameController,
                        decoration: InputDecoration(
                          hintText: 'Название расхода',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Color(0xFF8393A5)),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Сумма расхода
                      TextField(
                        controller: newExpenseAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Сумма',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Color(0xFF8393A5)),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Выбор категории
                      DropdownButton<String>(
                        value: selectedCategory,
                        onChanged: (String? value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                        hint: Text('Выберите категорию'),
                        isExpanded: true,
                        items: categories
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16),
                      // Добавленный отступ снизу
                      Spacer(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedCategory != null &&
                                newExpenseNameController.text.isNotEmpty &&
                                newExpenseAmountController.text.isNotEmpty) {
                              save(context, selectedCategory!);
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            backgroundColor: const Color(0xFF3A86FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Сохранить',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // delete expense
  void deleteExpense(ExpenseItem expense) {
    Provider.of<ExpenseData>(context, listen: false).deleteExpense(expense);
  }
  /*
  void editExpense(ExpenseItem expense) {
    Provider.of<ExpenseData>(context, listen: false).updateExpense(index, updatedExpense)
  }*/
  
  // save
  void save(BuildContext context, String selectedCategory) {
    if (newExpenseNameController.text.isNotEmpty &&
        newExpenseAmountController.text.isNotEmpty &&
        selectedCategory != null) {
      double expenseAmount = double.parse(newExpenseAmountController.text);
      if (categoryExpenses.containsKey(selectedCategory)) {
        categoryExpenses[selectedCategory] =
            (categoryExpenses[selectedCategory] ?? 0) + expenseAmount;
      } else {
        categoryExpenses[selectedCategory] = expenseAmount;
      }
      ExpenseItem newExpense = ExpenseItem(
        name: newExpenseNameController.text,
        amount: newExpenseAmountController.text,
        dateTime: DateTime.now(),
        category: selectedCategory,
      );
      // add the new expense
      Provider.of<ExpenseData>(context, listen: false)
          .addNewExpense(newExpense);
      // Применяем сортировку к списку
      Provider.of<ExpenseData>(context, listen: false)
          .sortExpensesByCurrentSortOption();
    }
    Navigator.of(context).pop();
    clear();
  }

  // cancel
  void cancel(BuildContext context) {
    if (mounted) {
      Navigator.of(context).pop();
      clear();
    }
  }

  // clear controllers
  void clear() {
    newExpenseNameController.clear();
    newExpenseAmountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    String getMonthNameInRussian(String monthName) {
      switch (monthName) {
        case 'January':
          return 'январе';
        case 'February':
          return 'феврале';
        case 'March':
          return 'марте';
        case 'April':
          return 'апреле';
        case 'May':
          return 'мае';
        case 'June':
          return 'июне';
        case 'July':
          return 'июле';
        case 'August':
          return 'августе';
        case 'September':
          return 'сентябре';
        case 'October':
          return 'октябре';
        case 'November':
          return 'ноябре';
        case 'December':
          return 'декабре';
        default:
          return monthName;
      }
    }

    String monthName =
        getMonthNameInRussian(DateFormat('MMMM').format(currentDate));

    List<String> generateMonthNames(DateTime currentDate) {
      // Получаем текущий месяц и год
      int currentMonth = currentDate.month;
      int currentYear = currentDate.year;

      // Формируем список месяцев выше текущего месяца
      List<String> monthsBefore = [];
      for (int i = currentMonth - 1; i >= 1; i--) {
        monthsBefore
            .add(DateFormat.MMMM('ru').format(DateTime(currentYear, i)));
      }

      // Формируем список месяцев после текущего месяца
      List<String> monthsAfter = [];
      for (int i = currentMonth + 1; i <= 12; i++) {
        monthsAfter.add(DateFormat.MMMM('ru').format(DateTime(currentYear, i)));
      }

      // Формируем итоговый список месяцев
      List<String> monthNames = [];
      monthNames.addAll(monthsBefore
          .reversed); // Добавляем месяцы до текущего месяца в обратном порядке
      monthNames.add(
          DateFormat.MMMM('ru').format(currentDate)); // Добавляем текущий месяц
      monthNames.addAll(monthsAfter); // Добавляем месяцы после текущего месяца

      return monthNames;
    }

    List<String> monthNames = generateMonthNames(DateTime.now());
    List<String> russianMonthNames = monthNames.map((monthName) {
      return getMonthNameInRussian(monthName);
    }).toList();
    int selectedMonthIndex = DateTime.now().month - 1;
    // Получите текущий выбранный месяц из провайдера
    DateTime selectedMonth = Provider.of<ExpenseData>(context).selectedMonth;

// 2. Фильтрация расходов по выбранному месяцу
    List<ExpenseItem> filteredExpenses = Provider.of<ExpenseData>(context)
        .getFilteredExpenseListByMonth(selectedMonth);

    // Получаем данные о расходах по категориям
    final categoryExpenses =
        Provider.of<ExpenseData>(context).getCategoryExpenses();
    return Consumer<ExpenseData>(
        builder: (context, value, child) => Scaffold(
              backgroundColor: Colors.white,
              floatingActionButton: FloatingActionButton(
                backgroundColor: const Color(0xFF3A86FF),
                onPressed: addNewExpense,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: Center(
                        child: PageView(
                          controller: _controller,
                          children: [
                            ExpenseSummary(
                                startOfWeek: value.startOfWeekDate()),
                            MyHeatMap(),
                            MyPieChart(
                              categoryExpenses: categoryExpenses,
                              colors: const [
                                Colors.blue,
                                Color.fromARGB(255, 33, 243, 79),
                                Color.fromARGB(255, 170, 243, 33),
                                Color.fromARGB(255, 229, 33, 243),
                                Color.fromARGB(255, 239, 73, 73),
                                Color.fromARGB(255, 20, 30, 218),
                                // Добавьте другие цвета по мере необходимости
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SmoothPageIndicator(
                      controller: _controller,
                      count: 3,
                      effect: const ExpandingDotsEffect(
                          dotColor: Color.fromARGB(255, 193, 206, 220),
                          activeDotColor: Color(0xFF3A86FF),
                          dotHeight: 3,
                          dotWidth: 40),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 16, right: 16), // Добавляем отступ слева
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Используем RichText для добавления разных стилей к слову "Расходы"
                          RichText(
                            key: ValueKey(Provider.of<ExpenseData>(context)
                                .russianMonthName),
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Расходы в ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: Provider.of<ExpenseData>(context)
                                      .russianMonthName, // Дополнительный текст
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(
                                        0xFF3A86FF), // Цвет для дополнительного текста
                                    fontSize:
                                        18, // Размер шрифта для дополнительного текста
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => showCupertinoModalPopup(
                                        context: context,
                                        builder: (_) => SizedBox(
                                              width: double.infinity,
                                              height: 200,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8,
                                                    right: 8,
                                                    left: 8),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  child:
                                                      CupertinoPicker.builder(
                                                    backgroundColor:
                                                        Colors.white,
                                                    itemExtent: 30,
                                                    scrollController:
                                                        FixedExtentScrollController(
                                                      initialItem: Provider.of<
                                                                  ExpenseData>(
                                                              context)
                                                          .selectedMonthIndex,
                                                    ),
                                                    childCount: 12,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      // Строим каждый элемент выбора для второго столбца
                                                      return Text(monthNames[
                                                          index]); // monthNames - список названий месяцев
                                                    },
                                                    onSelectedItemChanged:
                                                        (int value) {
                                                      setState(() {
                                                        Provider.of<ExpenseData>(
                                                                context,
                                                                listen: false)
                                                            .updateExpensesByMonth(
                                                                value);
                                                        print(value);
                                                      });

                                                      // Устанавливаем русское название месяца
                                                      String russianMonthName =
                                                          Provider.of<ExpenseData>(
                                                                  context,
                                                                  listen: false)
                                                              .getRussianMonthName(
                                                                  value);
                                                      Provider.of<ExpenseData>(
                                                                  context,
                                                                  listen: false)
                                                              .monthName =
                                                          monthNames[value];
                                                      Provider.of<ExpenseData>(
                                                              context,
                                                              listen: false)
                                                          .setRussianMonthName(
                                                              russianMonthName);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            )),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.tune),
                            onSelected: (String value) {
                              setState(() {
                                _currentSortOption = value;

                                if (_currentSortOption == 'date') {
                                  Provider.of<ExpenseData>(context,
                                          listen: false)
                                      .sortExpensesByDate();
                                } else if (_currentSortOption == 'amount') {
                                  Provider.of<ExpenseData>(context,
                                          listen: false)
                                      .sortExpensesByAmount();
                                }
                                // Сохранение текущего значения сортировки
                                Provider.of<ExpenseData>(context, listen: false)
                                    .saveSortOption(_currentSortOption!);
                              });
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'date',
                                child: Text('По дате'),
                              ),
                              PopupMenuItem<String>(
                                value: 'amount',
                                child: Text('По сумме'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          filteredExpenses.isEmpty
                              ? Container(
                                  margin: EdgeInsets.only(
                                      top: 100,
                                      right: 120,
                                      left: 120), // Отступ сверху
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEEF0F4),
                                    borderRadius: BorderRadius.circular(
                                        16), // Загругленные края
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Center(
                                    child: Text(
                                      'Расходов нет',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                          Expanded(
                            child: ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              shrinkWrap: true,
                              itemCount: filteredExpenses.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const SizedBox(height: 12);
                              },
                              itemBuilder: (BuildContext context, int index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ExpenseTile(
                                    name: filteredExpenses[index].name,
                                    amount: filteredExpenses[index].amount,
                                    dateTime: filteredExpenses[index].dateTime,
                                    category: filteredExpenses[index].category,
                                    deleteTapped: (p0) =>
                                        deleteExpense(filteredExpenses[index]),
                                    onTap: (name, amount, dateTime, category) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ExpenseDetail(
                                            expense: filteredExpenses[index],
                                            onDelete: deleteExpense,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
  }
}
