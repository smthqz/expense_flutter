import 'package:expense_flutter_app/data/expense_data.dart';
import 'package:expense_flutter_app/data/hive_user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_flutter_app/pages/settings_page.dart';
import 'package:provider/provider.dart';

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstPasswordController =
      TextEditingController();
  final TextEditingController _secondPasswordController =
      TextEditingController();

  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  void _loadUserEmail() {
    String? userEmail = HiveUser.getUserEmail();
    if (userEmail != null) {
      _emailController.text = userEmail;
    }
  }

  bool _validateEmail(String email) {
    const pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  void createUser() async {
    if (!_validateEmail(_emailController.text)) {
      setState(() {
        _emailError = 'Введите правильный адрес электронной почты';
      });
      return;
    }

    if (_firstPasswordController.text != _secondPasswordController.text) {
      setState(() {
        _passwordError = 'Пароли не совпадают';
      });
      return;
    }

    if (_firstPasswordController.text.length < 6) {
      setState(() {
        _passwordError = 'Пароль должен быть не менее 6 символов';
      });
      return;
    }

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _secondPasswordController.text);
      Provider.of<ExpenseData>(context, listen: false)
          .setUserEmail(_emailController.text);
      await HiveUser.saveUserEmail(_emailController.text);
      Navigator.pop(context);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showErrorDialog('Ошибка при создании аккаунта. Попробуйте снова.');
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ошибка'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ОК'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Создание аккаунта',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'почта',
                  labelStyle: const TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF8393A5)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  errorText: _emailError,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _firstPasswordController,
                decoration: InputDecoration(
                  labelText: 'пароль',
                  labelStyle: const TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF8393A5)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _secondPasswordController,
                decoration: InputDecoration(
                  labelText: 'подтвердите пароль',
                  labelStyle: const TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF8393A5)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  errorText: _passwordError,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: createUser,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFF3A86FF)),
                  minimumSize: MaterialStateProperty.all(
                      const Size(double.infinity, 50)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                child: const Text(
                  'Создать аккаунт',
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
