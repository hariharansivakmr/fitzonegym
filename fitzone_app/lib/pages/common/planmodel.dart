import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  final String? id;

  final String type;        // Monthly, Quarterly
  final int duration;       // in months
  final double fees;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  PlanModel({
    this.id,
    required this.type,
    required this.duration,
    required this.fees,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================================
  // 🔥 FROM FIRESTORE
  // ============================================================

  factory PlanModel.fromMap(Map<String, dynamic> map) {
    return PlanModel(
      id: map['id'],
      type: map['type'] ?? '',
      duration: map['duration'] ?? 1,
      fees: (map['fees'] ?? 0).toDouble(),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // ============================================================
  // 🔥 TO FIRESTORE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "type": type,
      "duration": duration,
      "fees": fees,
    };
  }

  // ============================================================
  // 🔁 COPY WITH
  // ============================================================

  PlanModel copyWith({
    String? type,
    int? duration,
    double? fees,
  }) {
    return PlanModel(
      id: id,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      fees: fees ?? this.fees,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}