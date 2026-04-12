import 'package:fitzone_app/pages/dashboard/dashboard_model.dart';
import 'package:fitzone_app/pages/members/member_model.dart';
import 'package:fitzone_app/services/FirebaseServices/MemberService.dart';
import 'package:fitzone_app/services/FirebaseServices/PaymentService.dart';
import 'package:flutter/material.dart';

class DashboardViewModel extends ChangeNotifier {

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

  var memberService = MemberService();
  var paymentService = PaymentService();

  bool isLoading = true;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

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

    await memberService.getMembers().then((data) {
      final members = data.map((e) => MemberModel.fromMap(e)).toList();
      totalMembers = members.length;
      paidMembers = members.where((m) => m.isPaid).length;
      unpaidMembers = totalMembers - paidMembers;
      newMembers = members.where((m) {
        final now = DateTime.now();
        return m.joinDate.year == now.year && m.joinDate.month == now.month;
      }).length;
    }).catchError((e) {
      print("Error fetching members: $e");
    });

    totalRevenue = await paymentService.getTotalRevenue(); // ✅ implement this in PaymentService

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