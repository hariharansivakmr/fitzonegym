import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final VoidCallback onSendOtp;

  const LoginForm({super.key, required this.onSendOtp});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: "Mobile Number",
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(
            hintText: "Password",
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
          
          onPressed: onSendOtp,
          child: const Text("Send OTP & Continue"),
        ))
      ],
    );
  }
}