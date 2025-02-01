import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/Authentication/login_or_register_page.dart';
import 'package:uber_clone/Home.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // The user is logged in
            final userEmail = snapshot.data?.email ?? '';

            // Pass the email to the Home page
            return Home(userEmail: userEmail);
          } else {
            // The user is not logged in
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
