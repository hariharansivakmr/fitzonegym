  import 'package:flutter/material.dart';
  import 'package:fitzone_app/pages/members/member_model.dart';
  import 'package:fitzone_app/pages/payments/payment_model.dart';
  import 'package:fitzone_app/pages/common/planmodel.dart';
  import 'package:fitzone_app/services/FirebaseServices/PaymentService.dart';
  import 'package:fitzone_app/services/FirebaseServices/PlanService.dart';

  class MemberDetailViewModel extends ChangeNotifier {
    final PaymentService _paymentService = PaymentService();
    final PlanService _planService = PlanService();

    MemberModel? member;
    List<PaymentModel> payments = [];

    PaymentModel? lastPayment;
    PlanModel? memberPlan;

    bool isLoading = false;
    String? errorMessage;

    MemberDetailViewModel();

    // ============================================================
    // 🔥 INIT
    // ============================================================

    Future<void> loadMember(MemberModel selectedMember) async {
      member = selectedMember;

      try {
        isLoading = true;
        notifyListeners();

        await Future.wait([
          fetchPayments(),
          fetchPlan(),
        ]);
      } catch (e) {
        errorMessage = "Failed to load member details";
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }

    // ============================================================
    // 🔥 FETCH PLAN
    // ============================================================

    Future<void> fetchPlan() async {
      try {
        print(  "Fetching plan for member: ${member?.name}, planId: ${member?.planId}"); // ✅ Debug log
        if (member?.planId == null) return;

        memberPlan = await _planService.getPlanById(member!.planId);
        
      } catch (e) {
        errorMessage = "Failed to load plan";
      }
    }

    // ============================================================
    // 🔥 FETCH PAYMENTS
    // ============================================================

    Future<void> fetchPayments() async {
      if (member == null || member!.id == null) return;

      try {
        isLoading = true;
        notifyListeners();

        final data =
            await _paymentService.getPaymentsByMember(member!.id!);

        payments = data;

        if (payments.isNotEmpty) {
          payments.sort((a, b) => b.paidDate.compareTo(a.paidDate));
          lastPayment = payments.first;
        } else {
          lastPayment = null;
        }
      } catch (e) {
        payments = [];
        lastPayment = null;
        errorMessage = "No payment data found yet.";
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }

    // ============================================================
    // 🔥 PAYMENT LOGIC
    // ============================================================

    /// ✅ Total amount paid
    double get totalPaid {
      return payments.fold<double>(
        0,
        (sum, p) => sum + p.amountPaid,
      );
    }

    /// ✅ Check full payment
    bool get isFullyPaid {
    if (memberPlan == null || member == null) return false;

    return (member!.pendingAmount) <= 0;
  }

    // ============================================================
    // 🔥 DUE DATE (JOIN DATE BASED)
    // ============================================================
  DateTime? get nextDueDate {
    if (member == null || memberPlan == null) return null;

    final joinDate = member!.joinDate;

    // ✅ Monthly
    if (memberPlan!.duration == 1) {
      return _calculateCycleDueDate(joinDate, 1);
    }

    // ✅ Quarterly / Yearly
    if (isFullyPaid) {
      return _addMonths(joinDate, memberPlan!.duration);
    } else {
      // ❗ Partial → next month
      return _calculateCycleDueDate(joinDate, 1);
    }
  }

    /// 🔁 Finds next upcoming cycle date
    DateTime _calculateCycleDueDate(DateTime startDate, int monthsToAdd) {
    DateTime now = DateTime.now();

    DateTime dueDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    while (dueDate.isBefore(now)) {
      dueDate = _addMonths(dueDate, monthsToAdd);
    }

    return dueDate;
  }

    /// 📅 Add months safely
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

    // ============================================================
    // 🔥 STATUS
    // ============================================================

    bool get isActive {
      if (nextDueDate == null) return false;
      return nextDueDate!.isAfter(DateTime.now());
    }

    int get remainingDays {
    if (nextDueDate == null) return 0;

    final now = DateTime.now();
    final diff = nextDueDate!.difference(now).inDays;

    return diff < 0 ? 0 : diff;
  }

    bool get isDueSoon {
      if (nextDueDate == null) return false;

      final days =
          nextDueDate!.difference(DateTime.now()).inDays;

      return days <= 3 && days >= 0;
    }

    bool get isExpired {
      if (nextDueDate == null) return false;
      return nextDueDate!.isBefore(DateTime.now());
    }

    /// ✅ UI-friendly status text
    String get statusText {
      if (nextDueDate == null) return "NOT STARTED";
      if (isExpired) return "EXPIRED";
      if (isDueSoon) return "DUE SOON";
      return "ACTIVE";
    }

    String get planName {
    if (memberPlan == null) return "Not Assigned";

    switch (memberPlan!.duration) {
      case 1:
        return "Monthly";
      case 3:
        return "Quarterly";
      case 6:
        return "Half-Yearly";
      case 12:
        return "Yearly";
      default:
        return memberPlan!.type; // fallback
    }
  }
  }