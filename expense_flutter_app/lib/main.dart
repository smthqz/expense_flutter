import 'package:expense_flutter_app/models/account_item.dart';
import 'package:expense_flutter_app/models/goal_item.dart';
import 'package:expense_flutter_app/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/pages/login_page.dart';
import 'package:expense_flutter_app/pages/settings_page.dart';
import 'package:expense_flutter_app/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: 'AIzaSyB0mWfZ9C215XSpt-YrciPxzxJR7HNsveg',
          appId: '1:184642570505:android:373ce3be2c6232ef3f2bd8',
          messagingSenderId: '184642570505',
          projectId: 'expenseappauth'));
  // initialize hive
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  Hive.registerAdapter(AmountHistoryItemAdapter());
  Hive.registerAdapter(AccountAdapter());
  // open a hive box
  await Hive.openBox('expense_database');
  await Hive.openBox<Account>('accounts');

  await initializeDateFormatting('ru');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExpenseData()..loadUserEmail(),
      builder: (context, child) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        //home: HomeWithBarApp(),
        home: AuthPage(),
      ),
    );
  }
}
