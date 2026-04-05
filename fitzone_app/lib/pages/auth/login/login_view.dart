import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utilities/constants/app_colors.dart';
import 'login_viewmodel.dart';
import 'widgets/login_form.dart';
import 'widgets/otp_widget.dart';
import '../signup/signup_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isOtpSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Consumer<LoginViewModel>(
            builder: (context, vm, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // 🔥 LOGO + TITLE
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.fitness_center,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "FITZONE GYM",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "MANAGEMENT SYSTEM",
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Welcome back 👋",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // 🔥 BODY
                  Expanded(
                    child: vm.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: isOtpSent
                                ? OtpWidget(
                                    key: const ValueKey("otp"),
                                    onVerify: (otp) {
                                      vm.verifyOtp(otp);
                                    },
                                  )
                                : LoginForm(
                                    key: const ValueKey("login"),
                                    onSendOtp: () async {
                                      await vm.sendOtp();
                                      setState(() {
                                        isOtpSent = true;
                                      });
                                    },
                                  ),
                          ),
                  ),

                  // 🔥 NAVIGATION TO SIGNUP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignupView()),
                          );
                        },
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}