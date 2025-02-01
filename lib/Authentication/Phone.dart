import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _verificationId = '';
  bool _isCodeSent = false;

  void _sendCodeToPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        print("Phone number automatically verified and user signed in: ${_auth.currentUser}");
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Phone number verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isCodeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  void _verifyOTP() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _otpController.text.trim(),
    );

    try {
      final userCredential = await _auth.signInWithCredential(credential);
      print("User signed in successfully: ${userCredential.user}");
    } catch (e) {
      print("Failed to sign in: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Authentication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_isCodeSent)
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+',
                ),
                keyboardType: TextInputType.phone,
              ),
            if (_isCodeSent)
              Pinput(
                controller: _otpController,
                length: 6,
                onCompleted: (pin) => _verifyOTP(),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isCodeSent ? _verifyOTP : _sendCodeToPhoneNumber,
              child: Text(_isCodeSent ? 'Verify OTP' : 'Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
