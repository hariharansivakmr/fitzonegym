import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitzone_app/pages/common/planmodel.dart';

class PlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String collection = "plans";

  // ============================================================
  // ➕ ADD PLAN
  // ============================================================

  Future<void> addPlan(PlanModel plan) async {
    try {
      final docRef = _firestore.collection(collection).doc();

      await docRef.set({
        "id": docRef.id,
        "type": plan.type,
        "duration": plan.duration,
        "fees": plan.fees,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error adding plan: $e");
    }
  }

  // ============================================================
  // 📥 GET ALL PLANS
  // ============================================================

  Future<List<PlanModel>> getPlans() async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .orderBy('duration')
          .get();

      return snapshot.docs
          .map((doc) => PlanModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception("Error fetching plans: $e");
    }
  }

  // ============================================================
  // 🔄 STREAM PLANS (REAL-TIME)
  // ============================================================

  Stream<List<PlanModel>> streamPlans() {
    return _firestore
        .collection(collection)
        .orderBy('duration')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PlanModel.fromMap(doc.data())).toList());
  }

  // ============================================================
  // 📄 GET SINGLE PLAN
  // ============================================================

  Future<PlanModel?> getPlanById(String id) async {
  try {
    final snapshot = await _firestore
        .collection(collection)
        .where('id', isEqualTo: id)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return PlanModel.fromMap(snapshot.docs.first.data());
    } else {
      print("Plan with id: $id not found");
      return null;
    }
  } catch (e) {
    throw Exception("Error fetching plan: $e");
  }
}

  // ============================================================
  // ✏️ UPDATE PLAN
  // ============================================================

  Future<void> updatePlan(String id, PlanModel plan) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "type": plan.type,
        "duration": plan.duration,
        "fees": plan.fees,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error updating plan: $e");
    }
  }

  // ============================================================
  // 🗑️ DELETE PLAN
  // ============================================================

  Future<void> deletePlan(String id) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "isDeleted": true,
      });
    } catch (e) {
      throw Exception("Error deleting plan: $e");
    }
  }
}