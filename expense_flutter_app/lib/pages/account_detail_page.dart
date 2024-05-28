import 'package:expense_flutter_app/components/account_expense_tile.dart';
import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/models/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AccountDetailPage extends StatefulWidget {
  final String accountName;
  final double accountBalance;

  const AccountDetailPage({
    Key? key,
    required this.accountName,
    required this.accountBalance,
  }) : super(key: key);

  @override
  _AccountDetailPageState createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  late String accountName;
  late double accountBalance;

  @override
  void initState() {
    super.initState();
    accountName = widget.accountName;
    accountBalance = widget.accountBalance;
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

  String formatDouble2(double value) {
    final formatter = NumberFormat('#,##0', 'en_US');
    // Format the number and replace commas with spaces
    return formatter.format(value).replaceAll(',', ' ');
  }

  void _showEditAccountNameDialog(BuildContext context) {
    final expenseData = Provider.of<ExpenseData>(context, listen: false);
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Новое название счета'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Введите новое название"),
          ),
          actions: [
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Сохранить'),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  setState(() {
                    accountName = _controller.text;
                  });
                  expenseData.updateAccountName(
                      widget.accountName, _controller.text);
                  _controller.clear(); // Очистка контроллера
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseData = Provider.of<ExpenseData>(context);
    final List<ExpenseItem> expensesForAccount =
        expenseData.getExpensesForAccount(accountName);
    String currency = Provider.of<ExpenseData>(context).selectedCurrency;
    String currencySymbol = Provider.of<ExpenseData>(context).currencySymbol;
    if (expenseData.selectedCurrency == 'RUB') {
      currencySymbol = '₽';
    } else if (expenseData.selectedCurrency == 'USD') {
      currencySymbol = '\$';
    } else if (expenseData.selectedCurrency == 'EUR') {
      currencySymbol = '€';
    } // Ваш символ валюты

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Детали счета',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.black,
            size: 30,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              int index = expenseData.accountList
                  .indexWhere((account) => account.name == accountName);
              expenseData.deleteAccount(index);
              expenseData.loadAccounts();
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 30,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  accountName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 7,
                ),
                GestureDetector(
                  onTap: () => _showEditAccountNameDialog(context),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Color(0xFF3A86FF), // Синий цвет круга
                      shape: BoxShape.circle, // Круглая форма
                    ),
                    child: Center(
                      child: Icon(
                        Icons.edit, // Замените на нужную иконку
                        size: 11,
                        color: Colors.white, // Белый цвет иконки
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                IntrinsicWidth(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    initialValue: formatDouble2(accountBalance),
                    maxLength: 10,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      suffix: Text(currencySymbol),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    onTap: () {
                      // Действие при нажатии на текстовое поле
                    },
                    onChanged: (newValue) {
                      double newBalance = double.tryParse(newValue) ?? 0.0;
                      Provider.of<ExpenseData>(context, listen: false)
                          .updateAccountBalance(accountName, newBalance);
                    },
                  ),
                ),
              ],
            ),
            Text(
              'История расходов',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10), // Добавим небольшой отступ после текста "История расходов"
            // Проверка списка расходов на пустоту
            expensesForAccount.isEmpty
                ? Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 120), // Отступ сверху
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                          decoration: BoxDecoration(
                            color: Color(0xFFEEF0F4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Расходов пока нет',
                            style: TextStyle(
                                fontSize: 16,),
                          ),
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: expensesForAccount.length,
                      itemBuilder: (context, index) {
                        final expenseItem = expensesForAccount[index];
                        return Column(
                          children: [
                            AccountExpenseTile(
                              accountName: expenseItem.name,
                              category: expenseItem.category,
                              date: expenseItem.dateTime,
                              amount: expenseItem.amount,
                            ),
                            SizedBox(height: 12)
                          ],
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
