import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/models/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';



class ExpenseTile extends StatelessWidget {
  final String name;
  final String amount;
  final DateTime dateTime;
  final String category;
  final void Function(BuildContext)? deleteTapped;
  final Function(String, String, DateTime, String) onTap;

  

  ExpenseTile({
    Key? key,
    required this.name,
    required this.amount,
    required this.dateTime,
    required this.category,
    required this.deleteTapped,
    required this.onTap,
  }) : super(key: key);

  String _selectedCurrency = '';

  

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


    Map<String, IconData> categoryIcons = {
      'Еда': Icons.restaurant_outlined,
      'Транспорт': Icons.directions_car_outlined,
      'Жилье': Icons.house_outlined,
      'Развлечения': Icons.confirmation_num_outlined,
      'Здоровье': Icons.health_and_safety_outlined,
      'Без категории': Icons.hide_source_outlined,
      // Добавьте другие категории и соответствующие им иконки
    };
    IconData iconData = categoryIcons[category] ?? Icons.category;

    return GestureDetector(
      onTap: () {
        onTap(name, amount, dateTime, category);
      },
      child: Slidable(
        endActionPane: ActionPane(motion: StretchMotion(), children: [
          SlidableAction(
            onPressed: deleteTapped,
            icon: Icons.delete,
            backgroundColor: Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          
        ]),
        child: Container(
          color: const Color(0xFFEEF0F4),
          child: ListTile(
            leading: Icon(iconData, color: Colors.black,),
            title: Text(
              name,
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    dateTime.day.toString() +
                        ' / ' +
                        dateTime.month.toString() +
                        ' / ' +
                        dateTime.year.toString(),
                    style: TextStyle(
                      color: const Color(0xFF8393A5),
                      fontSize: 16,
                    )),
              ],
            ),
            trailing: Text(
              '$currencySymbol$amount',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
