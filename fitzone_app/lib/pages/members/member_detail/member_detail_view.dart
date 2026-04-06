import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../member_model.dart';
import '../member_viewmodel.dart';
import '../../../utilities/constants/app_colors.dart';
import '../add_member/add_member_view.dart';

class MemberDetailView extends StatelessWidget {
  final MemberModel member;

  const MemberDetailView({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<MemberViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Member Details"),
        
      ),

      /// 🔥 SCROLLABLE BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔥 PROFILE HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  /// Avatar
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      member.name.isNotEmpty ? member.name[0] : "A",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Name
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// Mobile
                  Text(
                    member.mobile,
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 12),

                  /// Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: member.isPaid
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      member.isPaid ? "PAID" : "UNPAID",
                      style: TextStyle(
                        color:
                            member.isPaid ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 DETAILS CARD
            _card(
              title: "Membership Details",
              children: [
                _row("Plan", member.plan),
                _row("Fees", "₹${member.fees}"),
                _row("Join Date", _formatDate(member.joinDate)),
                _row("Next Due Date", _formatDate(member.nextDueDate)),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔥 ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddMemberView(
                            isEdit: true,
                            member: member,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete"),
                    onPressed: () => _showDeleteDialog(context, vm),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 🔥 COMMON CARD
  Widget _card({
    required String title,
    required List<Widget> children,
  }) {
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
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return "${date.day}/${date.month}/${date.year}";
  }

  /// 🔥 DELETE CONFIRMATION
  void _showDeleteDialog(BuildContext context, MemberViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Member"),
        content: const Text("Are you sure you want to delete this member?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              vm.deleteMember(member);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Delete",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}