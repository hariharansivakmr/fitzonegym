import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String? id;

  final String memberId;
  final String forMonth; // yyyy-MM

  final double amountPaid;
  final double totalAmount;

  final String paymentType; // full / partial

  final String paymentMode; // cash / upi / card

  final DateTime paidDate;

  final DateTime? createdAt;

  PaymentModel({
    this.id,
    required this.memberId,
    required this.forMonth,
    required this.amountPaid,
    required this.totalAmount,
    required this.paymentType,
    required this.paymentMode,
    required this.paidDate,
    this.createdAt,
  });

  // ============================================================
  // 🔥 FROM FIRESTORE
  // ============================================================

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'],
      memberId: map['memberId'],
      forMonth: map['forMonth'],
      amountPaid: (map['amountPaid'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paymentType: map['paymentType'],
      paymentMode: map['paymentMode'],
      paidDate: DateTime.parse(map['paidDate']),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // ============================================================
  // 🔥 TO FIRESTORE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "memberId": memberId,
      "forMonth": forMonth,
      "amountPaid": amountPaid,
      "totalAmount": totalAmount,
      "paymentType": paymentType,
      "paymentMode": paymentMode,
      "paidDate": paidDate.toIso8601String(),
    };
  }
}