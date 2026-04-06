import 'package:fitzone_app/pages/members/members_view.dart';
import 'package:flutter/material.dart';
import '../dashboard/dashboard_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {

  int currentIndex = 0;

  final List<Widget> pages = const [
    DashboardView(),
    MembersView(),
    Center(child: Text("Payments")),
    Center(child: Text("Broadcast")),
    Center(child: Text("More")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed, // 🔥 important for 5 items
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Members",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_rupee),
            label: "Payments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: "Broadcast",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: "More",
          ),
        ],
      ),
    );
  }
}