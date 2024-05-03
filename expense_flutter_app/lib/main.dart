import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/models/goal_item.dart';
import 'package:expense_flutter_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() async {
  // initialize hive
  await Hive.initFlutter();
  Hive.registerAdapter(AmountHistoryItemAdapter());
  // open a hive box
  await Hive.openBox('expense_database');
  await initializeDateFormatting('ru');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExpenseData(),
      builder: (context, child) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeWithBarApp(),
      ),
    );
  }
}



