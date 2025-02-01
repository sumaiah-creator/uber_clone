import 'package:flutter/material.dart';
import 'package:uber_clone/Authentication/Register_page.dart';
import 'package:uber_clone/Authentication/login_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool showLoginPage = true;

  void togglepages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: togglepages,
      );
    } else {
      return RegisterPage(onTap:togglepages);
    }
  }
}
