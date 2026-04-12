import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitzone_app/pages/payments/payment_model.dart';
import 'package:fitzone_app/services/FirebaseServices/PaymentService.dart';
import 'package:flutter/material.dart';

class PaymentHistoryViewModel extends ChangeNotifier {
  final PaymentService _service = PaymentService();

  List<PaymentModel> allPayments = [];
  List<PaymentModel> filteredPayments = [];

  bool isLoading = false;

  String searchQuery = "";
  String filterType = "all"; // full / partial / all
  String sortType = "latest"; // latest / oldest / amount

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    final snapshot = await FirebaseFirestore.instance
        .collection('payments')
        .orderBy('paidDate', descending: true)
        .limit(10)
        .get();

    allPayments = snapshot.docs
        .map((e) => PaymentModel.fromMap(e.data()))
        .toList();

    applyFilters();

    isLoading = false;
    notifyListeners();
  }

  void applyFilters() {
    filteredPayments = allPayments.where((p) {
      final matchesSearch =
          p.forMonth.contains(searchQuery);

      final matchesFilter =
          filterType == "all" || p.paymentType == filterType;

      return matchesSearch && matchesFilter;
    }).toList();

    if (sortType == "latest") {
      filteredPayments.sort(
          (a, b) => b.paidDate.compareTo(a.paidDate));
    } else if (sortType == "oldest") {
      filteredPayments.sort(
          (a, b) => a.paidDate.compareTo(b.paidDate));
    } else if (sortType == "amount") {
      filteredPayments.sort(
          (a, b) => b.amountPaid.compareTo(a.amountPaid));
    }

    notifyListeners();
  }
}