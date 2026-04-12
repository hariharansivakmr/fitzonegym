import 'package:fitzone_app/pages/members/add_member/add_member_viewmodel.dart';
import 'package:fitzone_app/pages/members/member_detail/member_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../member_model.dart';
import '../../../utilities/constants/app_colors.dart';
import '../add_member/add_member_view.dart';

class MemberDetailView extends StatelessWidget {
  final MemberModel member;

  const MemberDetailView({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MemberDetailViewModel()..loadMember(member),
      child: const _MemberDetailBody(),
    );
  }
}

class _MemberDetailBody extends StatelessWidget {
  const _MemberDetailBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MemberDetailViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Member Details")),

      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// 🔥 PROFILE HEADER
                  _profileHeader(vm),

                  const SizedBox(height: 20),

                  /// 🔥 PAYMENT SUMMARY
                  _card(
                    title: "Payment Summary",
                    children: [
                      _row("Plan", vm.planName),
                      _row("Next Due Date",
                          _formatDate(vm.nextDueDate)),
                      _row("Remaining Days",
                          "${vm.remainingDays} days"),
                      _row("Status", _statusText(vm)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 LAST PAYMENT
                  _card(
                    title: "Last Payment",
                    children: [
                      _row("Amount",
                          vm.lastPayment != null
                              ? "₹${vm.lastPayment!.amountPaid}"
                              : "Not Started"),
                      _row("Month",
                          vm.lastPayment?.forMonth ?? "Not Started"),
                      _row("Date",
                          _formatDate(vm.lastPayment?.paidDate)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 ACTION BUTTONS
                  _actions(context, vm),
                ],
              ),
            ),
    );
  }

  // ============================================================

  Widget _profileHeader(MemberDetailViewModel vm) {
    final member = vm.member!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.primary,
            child: Text(
              member.name.isNotEmpty ? member.name[0] : "A",
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(height: 12),
          Text(member.name,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          Text(member.phone,
              style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 12),

          /// 🔥 STATUS (NEW LOGIC)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(vm).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusText(vm),
              style: TextStyle(
                color: _statusColor(vm),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

Text(
  vm.planName,
  style: const TextStyle(
    color: Colors.grey,
    fontSize: 14,
  ),
),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context, MemberDetailViewModel vm) {
    final member = vm.member!;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text("Edit"),
            onPressed: () {
           Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) {
      return ChangeNotifierProvider(
        create: (_) {
          final vm = AddMemberViewModel();

          vm.init(widgetMember: member); // ✅ DIRECT CALL (NO POST FRAME)

          return vm;
        },
        child: AddMemberView(
          isEdit: true,
          member: member,
        ),
      );
    },
  ),
); },
          ),
        ),
      ],
    );
  }

  // ============================================================

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Not Started";
    return "${date.day}/${date.month}/${date.year}";
  }

  // ============================================================
  // 🔥 STATUS HELPERS
  // ============================================================

  String _statusText(MemberDetailViewModel vm) {
    if (vm.isExpired) return "EXPIRED";
    if (vm.isDueSoon) return "DUE SOON";
    return "ACTIVE";
  }

  Color _statusColor(MemberDetailViewModel vm) {
    if (vm.isExpired) return Colors.red;
    if (vm.isDueSoon) return Colors.orange;
    return Colors.green;
  }
}