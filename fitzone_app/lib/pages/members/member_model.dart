import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  String id = "";

  final String name;
  final String phone;

  final String planId; // 🔥 reference to plan

  final DateTime joinDate;

  final String lastPaidMonth; // format: yyyy-MM
  final DateTime dueDate;

  final double pendingAmount;

  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  MemberModel({
    this.id = "",
    required this.name,
    required this.phone,
    required this.planId,
    required this.joinDate,
    required this.lastPaidMonth,
    required this.dueDate,
    required this.pendingAmount,
    this.status = "active",
    this.createdAt,
    this.updatedAt,
  });

  // ============================================================
  // 🔥 FROM FIRESTORE
  // ============================================================

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'],
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      planId: map['planId'] ?? '',
      joinDate: DateTime.parse(map['joinDate']),
      lastPaidMonth: map['lastPaidMonth'] ?? '',
      dueDate: DateTime.parse(map['dueDate']),
      pendingAmount: (map['pendingAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'active',
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
      "name": name,
      "phone": phone,
      "planId": planId,
      "joinDate": joinDate.toIso8601String(),
      "lastPaidMonth": lastPaidMonth,
      "dueDate": dueDate.toIso8601String(),
      "pendingAmount": pendingAmount,
      "status": status,
    };
  }

  // ============================================================
  // 🔥 DERIVED VALUES
  // ============================================================

  /// ✅ Paid or not
  bool get isPaid => pendingAmount == 0;

  /// 🚨 Overdue check
  bool get isOverdue => DateTime.now().isAfter(dueDate);

  /// 📅 Current due month
  String get dueMonth {
    return "${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}";
  }

  // ============================================================
  // 🔁 COPY WITH
  // ============================================================

  MemberModel copyWith({
    String? name,
    String? phone,
    String? planId,
    DateTime? joinDate,
    String? lastPaidMonth,
    DateTime? dueDate,
    double? pendingAmount,
    String? status,
  }) {
    return MemberModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      planId: planId ?? this.planId,
      joinDate: joinDate ?? this.joinDate,
      lastPaidMonth: lastPaidMonth ?? this.lastPaidMonth,
      dueDate: dueDate ?? this.dueDate,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}