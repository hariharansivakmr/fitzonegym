import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'member_list/member_list_view.dart';
import 'member_list/member_list_viewmodel.dart';

import 'add_member/add_member_view.dart';
import 'add_member/add_member_viewmodel.dart';

import '../../../utilities/constants/app_colors.dart';

class MembersView extends StatefulWidget {
  const MembersView({super.key});

  @override
  State<MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends State<MembersView>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Members"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Member List"),
            Tab(text: "Add Member"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          /// 🔥 MEMBER LIST VM
          ChangeNotifierProvider(
            create: (_) => MemberListViewModel(),
            child: const MemberListView(),
          ),

          /// 🔥 ADD MEMBER VM
          ChangeNotifierProvider(
            create: (_) => AddMemberViewModel('',false),
            child: const AddMemberView(),
          ),
        ],
      ),
    );
  }
}