import 'package:expense_flutter_app/pages/budget_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/models/goal_item.dart';

class GoalHistoryPage extends StatefulWidget {
  final GoalItem goal;

  GoalHistoryPage({required this.goal});

  @override
  _GoalHistoryPageState createState() => _GoalHistoryPageState();
}

class _GoalHistoryPageState extends State<GoalHistoryPage> {
  List<AmountHistoryItem> amountHistory = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    List<AmountHistoryItem> history =
        Provider.of<ExpenseData>(context, listen: false)
            .getAmountHistoryForGoal(widget.goal.name);
    setState(() {
      amountHistory = history;
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

    return '+$formattedValue';
  }

  String formatDouble2(double value) {
    final formatter = NumberFormat('#,##0', 'en_US');
    // Format the number and replace commas with spaces
    return formatter.format(value).replaceAll(',', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final expenseData = Provider.of<ExpenseData>(context);
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('История пополнений',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<ExpenseData>(context, listen: false)
                  .deleteGoal(widget.goal);
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: amountHistory.isNotEmpty
            ? amountHistory.length * 2 - 1
            : 0, // Учитываем разделители
        itemBuilder: (context, index) {
          if (index.isOdd) {
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Divider(
                color: Color(0xFF8393A5),
                thickness: 0.2,
              ),
            ); // Вставляем разделитель на нечетных позициях
          }
          var reversedIndex =
              amountHistory.length * 2 - index - 1; // Переворачиваем индекс
          var item = amountHistory.elementAt(
              reversedIndex ~/ 2); // Получаем элемент с перевернутым индексом
          String formattedAmount =
              formatDouble2(item.amount) + ' $currencySymbol';
          String formattedDate = DateFormat('dd.MM.yyyy').format(item.date);
          return ListTile(
            title: Text(
              formattedDate,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            trailing: Text(
              formattedAmount,
              style: TextStyle(
                  color: item.amount > 0 ? Color(0xFF3CB96A) : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
