import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/components/my_button.dart';
import 'package:uber_clone/components/my_textfield.dart';
import 'package:uber_clone/components/square_tile.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
  

  try {
    final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );

    // Retrieve additional user data from Firestore


    // Delay for 1 second to show the circular indicator
    await Future.delayed(Duration(seconds: 1));

    // Navigate to home page or perform other actions
  
  } on FirebaseAuthException catch (e) {
    // Close the dialog if an exception occurs
    showErrorMessage(e.code);
  }
}

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF588157),
          title: Center(
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(
                  Icons.mail,
                  size: 100,
                  color: Colors.black,
                ),
                const SizedBox(height: 50),
                Text(
                  'Welcome back you\'ve been missed!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                MyButton(
                  text: "Sign in",
                  onTap: signUserIn,
                ),
                const SizedBox(height: 50),
              //   Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 25.0),
              //     child: Row(
              //       children: [
              //         Expanded(
              //           child: Divider(
              //             thickness: 0.5,
              //             color: Colors.grey[400],
              //           ),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.symmetric(horizontal: 10.0),
              //           child: Text(
              //             'Or continue with',
              //             style: TextStyle(color: Colors.grey[700]),
              //           ),
              //         ),
              //         Expanded(
              //           child: Divider(
              //             thickness: 0.5,
              //             color: Colors.grey[400],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              //   const SizedBox(height: 50),
              // //  Row(
              // //     mainAxisAlignment: MainAxisAlignment.center,
              // //     children: [
              // //       // google button
              // //       SquareTile(
              // //           onTap: () {},
              // //           imagePath: 'lib/images/google.png'),
              // //     ],
              // //   ),

                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}