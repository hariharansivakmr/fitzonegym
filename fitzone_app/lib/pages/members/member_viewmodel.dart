import 'package:flutter/material.dart';
import 'member_model.dart';

class PlanModel {
  final String name;
  final double price;
  final int durationMonths;

  PlanModel({
    required this.name,
    required this.price,
    required this.durationMonths,
  });
}

class MemberViewModel extends ChangeNotifier {
  List<MemberModel> members = [];

  /// 🔥 Plans (USED for dropdown + suggested)
  List<PlanModel> plans = [
    PlanModel(name: "Monthly", price: 1500, durationMonths: 1),
    PlanModel(name: "Quarterly", price: 4000, durationMonths: 3),
    PlanModel(name: "Yearly", price: 12000, durationMonths: 12),
  ];

  /// 🔥 Selected values
  String? selectedPlan;
  double? selectedFees;

  DateTime calculateNextDueDate(DateTime joinDate, int months) {
    return DateTime(joinDate.year, joinDate.month + months, joinDate.day);
  }

  void fetchMembers() {
    members = [
      MemberModel(
        name: "Hariharan",
        mobile: "9876543210",
        plan: "Monthly",
        fees: 1500,
        isPaid: true,
        joinDate: DateTime.now(),
        nextDueDate: DateTime.now().add(const Duration(days: 30)),
      ),
      MemberModel(
        name: "Arjun",
        mobile: "9876543211",
        plan: "Quarterly",
        fees: 3500,
        isPaid: false,
        joinDate: DateTime.now(),
        nextDueDate: DateTime.now().add(const Duration(days: 30)),
      ),
    ];

    notifyListeners();
  }

  void selectPlan(PlanModel plan) {
    selectedPlan = plan.name;
    selectedFees = plan.price;
    notifyListeners();
  }

  void addMember(MemberModel member) {
    members.add(member);
    notifyListeners();
  }

  void clearForm() {
    selectedPlan = null;
    selectedFees = null;
    notifyListeners();
  }

  String? validateMember({
    required String name,
    required String mobile,
    required String feesText,
  }) {
    if (name.trim().isEmpty) {
      return "Name is required";
    }

    if (mobile.trim().isEmpty) {
      return "Mobile number is required";
    }

    if (mobile.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      return "Enter valid 10-digit mobile number";
    }

    if (selectedPlan == null) {
      return "Please select a plan";
    }

    final fees = double.tryParse(feesText);
    if (fees == null || fees <= 0) {
      return "Enter valid fees amount";
    }

    return null; // ✅ valid
  }

  void deleteMember(MemberModel member) {
    members.remove(member);
    notifyListeners();
  }

  void updateMember(MemberModel oldMember, MemberModel updatedMember) {
    final index = members.indexOf(oldMember);
    if (index != -1) {
      members[index] = updatedMember;
      notifyListeners();
    }
  }
}
