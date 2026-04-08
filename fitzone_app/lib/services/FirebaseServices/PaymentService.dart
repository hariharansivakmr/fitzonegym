import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitzone_app/pages/members/member_model.dart';
import 'package:fitzone_app/pages/payments/payment_model.dart';


class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String paymentCollection = "payments";
  final String memberCollection = "members";

  // ============================================================
  // 🔥 MAIN BUSINESS LOGIC → MAKE PAYMENT
  // ============================================================

  Future<void> makePayment({
    required MemberModel member,
    required double amount,
    required double planAmount,
    required int planDuration,
    required String paymentMode,
  }) async {
    try {
      double remainingAmount = amount;

      DateTime dueDate = member.dueDate;
      String lastPaidMonth = member.lastPaidMonth;

      WriteBatch batch = _firestore.batch();

      while (remainingAmount > 0) {
        String currentMonth = _formatMonth(dueDate);

        if (remainingAmount >= planAmount) {
          // ✅ FULL PAYMENT

          final paymentDoc =
              _firestore.collection(paymentCollection).doc();

          batch.set(
              paymentDoc,
              PaymentModel(
                id: paymentDoc.id,
                memberId: member.id!,
                forMonth: currentMonth,
                amountPaid: planAmount,
                totalAmount: planAmount,
                paymentType: "full",
                paymentMode: paymentMode,
                paidDate: DateTime.now(),
              ).toMap());

          remainingAmount -= planAmount;

          lastPaidMonth = currentMonth;
          dueDate = _addMonths(dueDate, planDuration);
        } else {
          // ⚠️ PARTIAL PAYMENT

          final paymentDoc =
              _firestore.collection(paymentCollection).doc();

          batch.set(
              paymentDoc,
              PaymentModel(
                id: paymentDoc.id,
                memberId: member.id!,
                forMonth: currentMonth,
                amountPaid: remainingAmount,
                totalAmount: planAmount,
                paymentType: "partial",
                paymentMode: paymentMode,
                paidDate: DateTime.now(),
              ).toMap());

          remainingAmount = 0;
        }
      }

      // 🔥 UPDATE MEMBER SNAPSHOT

      double newPending =
          member.pendingAmount - amount < 0 ? 0 : member.pendingAmount - amount;

      batch.update(
        _firestore.collection(memberCollection).doc(member.id),
        {
          "lastPaidMonth": lastPaidMonth,
          "dueDate": dueDate.toIso8601String(),
          "pendingAmount": newPending,
          "updatedAt": FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
    } catch (e) {
      throw Exception("Payment failed: $e");
    }
  }

  // ============================================================
  // 📥 GET PAYMENTS BY MEMBER
  // ============================================================

  Future<List<PaymentModel>> getPaymentsByMember(String memberId) async {
    try {
      final snapshot = await _firestore
          .collection(paymentCollection)
          .where('memberId', isEqualTo: memberId)
          .orderBy('paidDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PaymentModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception("Error fetching payments: $e");
    }
  }

  // ============================================================
  // 🔄 STREAM PAYMENTS (REAL-TIME)
  // ============================================================

  Stream<List<PaymentModel>> streamPayments(String memberId) {
    return _firestore
        .collection(paymentCollection)
        .where('memberId', isEqualTo: memberId)
        .orderBy('paidDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromMap(doc.data()))
            .toList());
  }

  // ============================================================
  // 📄 GET SINGLE PAYMENT
  // ============================================================

  Future<PaymentModel?> getPaymentById(String id) async {
    try {
      final doc =
          await _firestore.collection(paymentCollection).doc(id).get();

      if (doc.exists) {
        return PaymentModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception("Error fetching payment: $e");
    }
  }

  // ============================================================
  // ✏️ UPDATE PAYMENT (USE RARELY ⚠️)
  // ============================================================

  Future<void> updatePayment(
      String id, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(paymentCollection)
          .doc(id)
          .update(data);
    } catch (e) {
      throw Exception("Error updating payment: $e");
    }
  }

  // ============================================================
  // 🗑️ DELETE PAYMENT
  // ============================================================

  Future<void> deletePayment(String id) async {
    try {
      await _firestore
          .collection(paymentCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception("Error deleting payment: $e");
    }
  }

  // ============================================================
  // 🔧 HELPERS
  // ============================================================

  String _formatMonth(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }

  DateTime _addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, date.day);
  }
}