import 'package:fitzone_app/pages/dashboard/dashboard_view.dart';
import 'package:fitzone_app/pages/navigation/main_navigation_view.dart';
import 'package:flutter/material.dart';

class NavigationHelper {
  static void goToDashboard(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationView(),
      ),
      (route) => false,
    );
  }
}