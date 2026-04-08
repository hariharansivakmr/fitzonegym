import 'package:fitzone_app/pages/members/member_detail/member_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../member_viewmodel.dart';

class MemberListView extends StatelessWidget {
  const MemberListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MemberViewModel>();

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
        final lastPayment = vm.getLastPayment(member.id!);

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

                /// 🔥 Last Payment Info
                Text(
                  lastPayment != null
                      ? "Last Paid: ₹${lastPayment.amountPaid} (${lastPayment.forMonth})"
                      : "No Payments Yet",
                  style: const TextStyle(fontSize: 12),
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

                /// 🔥 Paid / Unpaid
                Text(
                  member.isPaid ? "Paid" : "Unpaid",
                  style: TextStyle(
                    color: member.isPaid ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
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
}