import 'package:expense_flutter_app/models/account_item.dart';

class ExpenseItem {
   String name;
   String amount;
   DateTime dateTime;
   String category;
   Account? account;

  ExpenseItem(
      {required this.name, required this.amount, required this.dateTime, required this.category, this.account});
}
