import 'package:flutter/material.dart';
import 'package:fitzone_app/pages/members/member_model.dart';
import 'package:fitzone_app/pages/common/planmodel.dart';
import 'package:fitzone_app/services/FirebaseServices/PaymentService.dart';
import 'package:fitzone_app/services/FirebaseServices/MemberService.dart';
import 'package:fitzone_app/services/FirebaseServices/PlanService.dart';

class AddPaymentViewModel extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  final MemberService _memberService = MemberService();
  final PlanService _planService = PlanService();

  List<MemberModel> members = [];
  List<PlanModel> plans = [];

  MemberModel? selectedMember;
  PlanModel? selectedPlan;

  String selectedMonth = ""; // yyyy-MM

  TextEditingController amountController = TextEditingController();

  String paymentMode = "cash";

  bool isLoading = false;
  bool isInitLoading = true;

  // ============================================================

  AddPaymentViewModel() {
    init();
  }

  Future<void> init() async {
    final memberData = await _memberService.getMembers();
    members = memberData.map((e) => MemberModel.fromMap(e)).toList();

    plans = await _planService.getPlans();

    selectedMonth = _formatMonth(DateTime.now());

    isInitLoading = false;
    notifyListeners();
  }

  // ============================================================

  void selectMember(MemberModel member) {
    selectedMember = member;

    selectedPlan = plans.firstWhere(
      (p) => p.id == member.planId,
      orElse: () => plans.first,
    );

    notifyListeners();
  }

  void selectPlan(PlanModel plan) {
    selectedPlan = plan;
    notifyListeners();
  }

  void selectMonth(String month) {
    selectedMonth = month;
    notifyListeners();
  }

  // ============================================================

  Future<void> makePayment() async {
    final amount = double.tryParse(amountController.text) ?? 0;

    if (selectedMember == null || selectedPlan == null) return;
    if (amount <= 0) return;

    isLoading = true;
    notifyListeners();

    await _paymentService.makePayment(
      member: selectedMember!,
      amount: amount,
      planAmount: selectedPlan!.fees,
      planDuration: selectedPlan!.duration,
      paymentMode: paymentMode,
    );

    amountController.clear();

    isLoading = false;
    notifyListeners();
  }

  // ============================================================

  String _formatMonth(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }
}