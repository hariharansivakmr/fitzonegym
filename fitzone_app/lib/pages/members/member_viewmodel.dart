import 'package:fitzone_app/pages/common/planmodel.dart';
import 'package:fitzone_app/pages/members/member_model.dart';
import 'package:fitzone_app/pages/payments/payment_model.dart';
import 'package:fitzone_app/services/FirebaseServices/MemberService.dart';
import 'package:fitzone_app/services/FirebaseServices/PaymentService.dart';
import 'package:fitzone_app/services/FirebaseServices/PlanService.dart';
import 'package:flutter/material.dart';

class MemberViewModel extends ChangeNotifier {
  final MemberService _memberService = MemberService();
  final PaymentService _paymentService = PaymentService();

  /// 🔥 State
  List<MemberModel> members = [];
  Map<String, PaymentModel?> lastPayments = {}; // 🔥 memberId -> last payment

  bool isLoading = false;
  String? errorMessage;

  /// 🔥 Selected Plan (UI only)
  String? selectedPlanId;

  final PlanService _planService = PlanService();

  List<PlanModel> plans = [];

  MemberViewModel() {
    fetchMembers();
    listenMembers();
    fetchPlans();
  }

  // ============================================================
  // 🔥 FETCH MEMBERS + LAST PAYMENT
  // ============================================================

  Future<void> fetchMembers() async {
    try {
      isLoading = true;
      notifyListeners();

      final data = await _memberService.getMembers();

      members = data.map((e) => MemberModel.fromMap(e)).toList();
      print("Fetched ${members.length} members");
      // 🔥 Fetch last payment for each member
      await _fetchLastPayments();

      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // 🔥 REAL-TIME MEMBERS
  // ============================================================

  void listenMembers() {
    _memberService.streamMembers().listen((data) async {
      members = data.map((e) => MemberModel.fromMap(e)).toList();

      await _fetchLastPayments();

      notifyListeners();
    });
  }

  // ============================================================
  // 🔥 FETCH LAST PAYMENT PER MEMBER
  // ============================================================

  Future<void> _fetchLastPayments() async {
    for (var member in members) {
      final payments =
          await _paymentService.getPaymentsByMember(member.id!);

      if (payments.isNotEmpty) {
        lastPayments[member.id!] = payments.first; // latest payment
      } else {
        lastPayments[member.id!] = null;
      }
    }
  }

  // ============================================================
  // 🔥 ADD MEMBER
  // ============================================================

  Future<void> addMember(MemberModel member) async {
    try {
      isLoading = true;
      notifyListeners();

      await _memberService.addMember(member.toMap());

      await fetchMembers();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // 🔥 UPDATE MEMBER
  // ============================================================

  Future<void> updateMember(MemberModel member) async {
    try {
      isLoading = true;
      notifyListeners();

      await _memberService.updateMember(member.id!, member.toMap());

      await fetchMembers();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // 🔥 DELETE MEMBER
  // ============================================================

  Future<void> deleteMember(MemberModel member) async {
    try {
      isLoading = true;
      notifyListeners();

      await _memberService.deleteMember(member.id!);

      await fetchMembers();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // 🔥 GET LAST PAYMENT (FOR UI)
  // ============================================================

  PaymentModel? getLastPayment(String memberId) {
    return lastPayments[memberId];
  }

  void selectPlan(String? planId) {
      selectedPlanId = planId;
      notifyListeners();
    }

  // ============================================================
  // 🔥 VALIDATION
  // ============================================================

  String? validateMember({
    required String name,
    required String mobile,
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

    if (selectedPlanId == null) {
      return "Please select a plan";
    }

    return null;
  }

  DateTime calculateNextDueDate(DateTime date, int months) {
    return DateTime(date.year, date.month + months, date.day);
  }

  Future<void> fetchPlans() async {
    try {
      plans = await _planService.getPlans();
      for (var plan in plans) {
        print("Plan: ${plan.type}, Duration: ${plan.duration} months, Price: ${plan.fees}");
      }
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
    }
  }
}