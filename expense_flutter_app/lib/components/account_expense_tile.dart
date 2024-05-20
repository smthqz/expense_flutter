import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AccountExpenseTile extends StatelessWidget {
  final String accountName;
  final String category;
  final DateTime date;
  final String amount;

  const AccountExpenseTile({
    Key? key,
    required this.accountName,
    required this.category,
    required this.date,
    required this.amount,
  }) : super(key: key);

  // Define the categoryIcons map inside the AccountExpenseTile class
  static const Map<String, IconData> categoryIcons = {
    'Еда': Icons.restaurant_outlined,
    'Транспорт': Icons.directions_car_outlined,
    'Жилье': Icons.house_outlined,
    'Развлечения': Icons.confirmation_num_outlined,
    'Здоровье': Icons.health_and_safety_outlined,
    'Без категории': Icons.hide_source_outlined,
  };

  @override
  Widget build(BuildContext context) {
    String currencySymbol = Provider.of<ExpenseData>(context).currencySymbol;
    ExpenseData expenseData = Provider.of<ExpenseData>(context);
    if (expenseData.selectedCurrency == 'RUB') {
      currencySymbol = '₽';
    } else if (expenseData.selectedCurrency == 'USD') {
      currencySymbol = '\$';
    } else if (expenseData.selectedCurrency == 'EUR') {
      currencySymbol = '€';
    }
    IconData iconData = categoryIcons[category] ?? Icons.category;

    return Container(
      padding: EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color(0xFFEEF0F4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: Colors.black,
            size: 24,
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                accountName,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                DateFormat('dd.MM.yyyy').format(date),
                style: TextStyle(
                  color: const Color(0xFF8393A5),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Spacer(),
          Text(
            '$amount $currencySymbol',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
