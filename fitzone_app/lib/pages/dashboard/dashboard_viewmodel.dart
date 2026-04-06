import 'package:fitzone_app/pages/dashboard/dashboard_model.dart';
import 'package:flutter/material.dart';

import '../../pages/common/base_viewmodel.dart';

class DashboardViewModel extends BaseViewModel {

  // 🔥 STATS
  int totalMembers = 0;
  int newMembers = 0;
  int paidMembers = 0;
  int unpaidMembers = 0;

  // 🔥 REVENUE
  double totalRevenue = 0;

  // 🔥 CHART DATA
  List<double> monthlyRevenue = [];
  List<String> months = [];
  List<LegendItem> legends = [];

  // 🔥 PIE DATA
  double paidPercentage = 0;
  double unpaidPercentage = 0;

  // 🔥 ACTIONS (functions)
  void addMember() {
    print("Add Member Clicked");
  }

  void recordPayment() {
    print("Record Payment Clicked");
  }

  void viewMembers() {
    print("View Members Clicked");
  }

  // 🔥 FETCH DATA
  Future<void> fetchDashboardData() async {
    setLoading(true);

    await Future.delayed(const Duration(seconds: 2)); // simulate API

    // 🔥 MOCK DATA (replace with API later)
    totalMembers = 8;
    newMembers = 0;
    paidMembers = 5;
    unpaidMembers = 3;

    totalRevenue = 30500;

    monthlyRevenue = [10000, 15000, 12000, 20000, 18000, 25000];
    months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];

    paidPercentage = 0.6;
    unpaidPercentage = 0.4;

    legends = [
      LegendItem("Paid", Colors.green),
      LegendItem("Unpaid", Colors.red),
    ];

    setLoading(false);
  }
}