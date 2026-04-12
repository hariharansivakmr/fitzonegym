import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitzone_app/pages/payments/payment_model.dart';

class PaymentDetailView extends StatefulWidget {
  final PaymentModel payment;

  const PaymentDetailView({super.key, required this.payment});

  @override
  State<PaymentDetailView> createState() => _PaymentDetailViewState();
}

class _PaymentDetailViewState extends State<PaymentDetailView> {
  String memberName = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadMemberName();
  }

  Future<void> _loadMemberName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('members')
          .doc(widget.payment.memberId)
          .get();

      if (doc.exists) {
        setState(() {
          memberName = doc.data()?['name'] ?? "Unknown";
        });
      } else {
        memberName = "Unknown";
      }
    } catch (e) {
      memberName = "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payment;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card(
              children: [
                _row("Member", memberName),
                _row("Member ID", p.memberId),
                _row("Amount Paid", "₹${p.amountPaid.toStringAsFixed(0)}"),
                _row("Total Amount", "₹${p.totalAmount.toStringAsFixed(0)}"),
                _row("Month", p.forMonth),
                _row("Payment Type", p.paymentType.toUpperCase()),
                _row("Payment Mode", p.paymentMode.toUpperCase()),
                _row("Paid Date", _formatDate(p.paidDate)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}