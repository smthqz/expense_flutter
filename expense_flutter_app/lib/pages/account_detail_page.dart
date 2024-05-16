import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AccountDetailPage extends StatelessWidget {
  final String accountName;
  final double accountBalance;

  const AccountDetailPage({
    Key? key,
    required this.accountName,
    required this.accountBalance,
  }) : super(key: key);

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
                  '$accountName',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  width: 7,
                ),
                Container(
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
              ],
            ),
            Column(
              children: [
                IntrinsicWidth(
                  child: TextFormField(
                    keyboardType: TextInputType.numberWithOptions(),
                    initialValue: formatDouble(accountBalance),
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      suffix: Text(currencySymbol),
                      border: InputBorder.none,
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
            )
          ],
        ),
      ),
    );
  }
}
