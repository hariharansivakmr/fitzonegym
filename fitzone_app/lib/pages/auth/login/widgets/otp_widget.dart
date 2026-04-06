import 'package:fitzone_app/pages/dashboard/dashboard_view.dart';
import 'package:fitzone_app/utilities/helpers/navigation_helper.dart';
import 'package:flutter/material.dart';

class OtpWidget extends StatelessWidget {
  final Function(String) onVerify;

  const OtpWidget({super.key, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Enter OTP",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter OTP",
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
          onPressed: () {
            
              NavigationHelper.goToDashboard(context);
            
          },
          child: const Text("Verify OTP"),
        ))
      ],
    );
  }
}