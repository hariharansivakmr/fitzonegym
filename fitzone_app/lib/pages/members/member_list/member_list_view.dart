import 'package:fitzone_app/pages/members/member_detail/member_detail_view.dart';
import 'package:fitzone_app/pages/members/member_list/member_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberListView extends StatelessWidget {
  const MemberListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MemberListViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.members.isEmpty) {
      return const Center(child: Text("No Members Found"));
    }

    return ListView.builder(
      itemCount: vm.members.length,
      itemBuilder: (context, index) {
        final member = vm.members[index];
        final status = vm.getStatus(member);
        final color = vm.getStatusColor(member);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(
              member.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.phone),

                const SizedBox(height: 4),

                /// 🔥 STATUS BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// 🔥 Pending Amount
                Text(
                  "₹${member.pendingAmount.toStringAsFixed(0)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                /// 🔥 Due Date
                Text(
                  _formatDate(member.dueDate),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MemberDetailView(member: member),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}