import 'package:cloud_firestore/cloud_firestore.dart';

class MemberService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _collection = "members";

  /// 🔥 ADD MEMBER
  Future<String> addMember(Map<String, dynamic> data) async {
    try {
      final docRef = _firestore.collection(_collection).doc();

      data['id'] = docRef.id;
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.set(data);
      return docRef.id;
    } catch (e) {
      throw Exception("Error adding member: $e");
    }
  }

  /// 🔥 GET ALL MEMBERS (ONE TIME)
  Future<List<Map<String, dynamic>>> getMembers() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception("Error fetching members: $e");
    }
  }

  /// 🔥 STREAM MEMBERS (REAL-TIME)
  Stream<List<Map<String, dynamic>>> streamMembers() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// 🔥 GET SINGLE MEMBER
  Future<Map<String, dynamic>?> getMemberById(String id) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(id).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception("Error fetching member: $e");
    }
  }

  /// 🔥 UPDATE MEMBER
  Future<void> updateMember(
      String id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_collection)
          .doc(id)
          .update(data);
    } catch (e) {
      throw Exception("Error updating member: $e");
    }
  }

  /// 🔥 DELETE MEMBER (SOFT DELETE ✅)
  Future<void> deleteMember(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        "status": "inactive",
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error deleting member: $e");
    }
  }
}