import 'package:flutter/material.dart';
import 'package:fitzone_app/pages/members/member_model.dart';
import 'package:fitzone_app/services/FirebaseServices/MemberService.dart';

class MemberListViewModel extends ChangeNotifier {
  final MemberService _memberService = MemberService();

  List<MemberModel> members = [];

  bool isLoading = false;
  String? errorMessage;

  MemberListViewModel() {
    init();
  }

  Future<void> init() async {
    await fetchMembers();
    listenMembers();
  }

  // ============================================================
  // 🔥 FETCH MEMBERS
  // ============================================================

  Future<void> fetchMembers() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final data = await _memberService.getMembers();

      members = data.map((e) => MemberModel.fromMap(e)).toList();
    } catch (e) {
      members = [];
      errorMessage = "Failed to load members";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // 🔥 REALTIME LISTENER
  // ============================================================

  void listenMembers() {
    _memberService.streamMembers().listen(
      (data) {
        members = data.map((e) => MemberModel.fromMap(e)).toList();
        notifyListeners();
      },
      onError: (error) {
        errorMessage = "Realtime sync failed";
        notifyListeners();
      },
    );
  }

  // ============================================================
  // 🔥 STATUS HELPERS (FROM MODEL)
  // ============================================================

  String getStatus(MemberModel member) {
    if (member.isOverdue) return "EXPIRED";
    if (!member.isPaid) return "PENDING";
    return "ACTIVE";
  }

  Color getStatusColor(MemberModel member) {
    final status = getStatus(member);

    switch (status) {
      case "ACTIVE":
        return Colors.green;
      case "PENDING":
        return Colors.orange;
      case "EXPIRED":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}