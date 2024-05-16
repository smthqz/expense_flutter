import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/pages/account_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class AccountTile extends StatelessWidget {
  final String accountName;
  final double accountBalance;// Функция обработки удаления

  const AccountTile({
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountDetailPage(
              accountName: accountName,
              accountBalance: accountBalance,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEEF0F4),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.credit_card,
                  color: Colors.blue,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  accountName,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Text(
              '${formatDouble(accountBalance)} $currencySymbol',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
