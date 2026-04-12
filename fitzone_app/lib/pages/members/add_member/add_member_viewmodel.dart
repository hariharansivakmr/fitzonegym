import 'package:fitzone_app/services/FirebaseServices/PlanService.dart';
import 'package:flutter/material.dart';
import 'package:fitzone_app/pages/common/planmodel.dart';
import 'package:fitzone_app/pages/members/member_model.dart';
import 'package:fitzone_app/services/FirebaseServices/MemberService.dart';
import 'package:fitzone_app/services/FirebaseServices/PaymentService.dart';

enum PaymentType { fullyPaid, partiallyPaid, none }

class AddMemberViewModel extends ChangeNotifier {
  final MemberService _memberService = MemberService();
  final PaymentService _paymentService = PaymentService();

  bool isLoading = false;
  String? errorMessage;

  String? selectedPlanId;
  PaymentType? selectedPaymentType;

  TextEditingController amountController = TextEditingController();

  final PlanService _planService = PlanService();

  List<PlanModel> plans = [];

  AddMemberViewModel() {
  fetchPlans(); // ✅ important
}

 void init({MemberModel? widgetMember}) {
  if (widgetMember == null) return;

  selectedPlanId = widgetMember.planId;
  selectedPaymentType = PaymentType.none;

}
  void selectPlan(String? id) {
    selectedPlanId = id;
    notifyListeners();
  }

  void setPaymentType(PaymentType type) {
    selectedPaymentType = type;
    if (type == PaymentType.none) {
      amountController.clear();
    }
    notifyListeners();
  }

  bool get showAmountField =>
      selectedPaymentType != PaymentType.none;

  // ============================================================
  // 🔥 MAIN SAVE METHOD
  // ============================================================

  Future<void> saveMember({
    required MemberModel member,
    required PlanModel plan,
    required bool isEdit,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      /// 🔥 1. SAVE MEMBER
      if (isEdit) {
        await _memberService.updateMember(
            member.id!, member.toMap());
      } else {
        var memberId = await _memberService.addMember(member.toMap());
        member.id = memberId;
      }

      /// 🔥 2. PAYMENT (if any)
      if (selectedPaymentType != PaymentType.none) {
        final amount =
            double.tryParse(amountController.text) ?? 0;
        print("making payment with membert data: ${member.toMap()} and amount: $amount");
        if (amount > 0) {
          await _paymentService.makePayment(
            member: member,
            amount: amount,
            planAmount: plan.fees,
            planDuration: plan.duration,
            paymentMode: "cash", // you can extend later
          );
        }
      }

      amountController.clear();
      selectedPaymentType = PaymentType.none;

    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================

  DateTime calculateNextDueDate(
  DateTime joinDate,
  int duration,
) {
  // ✅ Monthly
  if (duration == 1) {
    return _addMonths(joinDate, 1);
  }

  // ✅ Quarterly / Yearly
  if (selectedPaymentType == PaymentType.fullyPaid) {
    return _addMonths(joinDate, duration);
  } else {
    // ❗ Partial OR none → monthly cycle
    return _addMonths(joinDate, 1);
  }
}

DateTime _addMonths(DateTime date, int months) {
  int newMonth = date.month + months;
  int newYear = date.year + ((newMonth - 1) ~/ 12);
  newMonth = ((newMonth - 1) % 12) + 1;

  int newDay = date.day;

  final lastDayOfMonth = DateTime(newYear, newMonth + 1, 0).day;
  if (newDay > lastDayOfMonth) {
    newDay = lastDayOfMonth;
  }

  return DateTime(newYear, newMonth, newDay);
}

  String formatMonth(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }

  Future<void> fetchPlans() async {
  try {
    plans = await _planService.getPlans();
    notifyListeners();
  } catch (e) {
    errorMessage = e.toString();
  }
}
}