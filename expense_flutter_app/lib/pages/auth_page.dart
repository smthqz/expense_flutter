import 'package:expense_flutter_app/pages/home_page.dart';
import 'package:expense_flutter_app/pages/login_page.dart';
import 'package:expense_flutter_app/pages/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomeWithBarApp();
        }
        else {
          return HomeWithBarApp();
        }
      },),
    );
  }
}