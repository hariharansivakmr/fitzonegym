import 'package:fitzone_app/pages/members/member_detail/member_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../member_viewmodel.dart';

class MemberListView extends StatelessWidget {
  const MemberListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MemberViewModel>();

    return ListView.builder(
      itemCount: vm.members.length,
      itemBuilder: (context, index) {
        final member = vm.members[index];

        return ListTile(
          title: Text(member.name),
          subtitle: Text(member.mobile),

          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("₹${member.fees}"),
              Text(
                member.isPaid ? "Paid" : "Unpaid",
                style: TextStyle(
                  color: member.isPaid ? Colors.green : Colors.red,
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
        );
      },
    );
  }
}
