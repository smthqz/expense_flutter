import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/models/account_item.dart';
import 'package:expense_flutter_app/components/account_tile.dart';
import 'package:expense_flutter_app/pages/add_account_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

String formatDouble(double value) {
  String formattedValue = value.toString();

  // Проверяем, если значение является целым числом
  if (value == value.toInt()) {
    formattedValue =
        value.toInt().toString(); // Преобразуем в строку без дробной части
  } else {
    formattedValue = formattedValue.replaceAll(RegExp(r'(?<=\.\d*?)0*?$'), '');
  }

  return formattedValue;
}

String formatDouble2(double value) {
    final formatter = NumberFormat('#,##0', 'en_US');
    // Format the number and replace commas with spaces
    return formatter.format(value).replaceAll(',', ' ');
  }

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final expenseData = Provider.of<ExpenseData>(context);
    List<Account> accountList = expenseData.accountList;
    double totalBalance =
        accountList.fold(0.0, (sum, account) => sum + account.balance);
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
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Всего на счетах:',
                        style: TextStyle(color: Color(0xFF8393A5), fontSize: 16),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${formatDouble2(totalBalance)} $currencySymbol',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Счета',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10), // Отступ между заголовком "Счета" и списком
                      Consumer<ExpenseData>(
                        builder: (context, expenseData, child) {
                          List<Account> accountList = expenseData.accountList;
                          if (accountList.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Регулирует вертикальное положение контейнера
                                  Container(
                                    margin: EdgeInsets.only(top: 120),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEEF0F4),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'Счетов нет',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Column(
                            children: accountList.map((account) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: AccountTile(
                                  accountName: account.name,
                                  accountBalance: account.balance,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Кнопка "Добавить счет" с отступом сверху
              ElevatedButton(
                onPressed: () {
                  // Действие при нажатии кнопки
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddAccountPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A86FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Добавить счет',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
