import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utilities/constants/app_colors.dart';
import 'widgets/monthly_chart.dart';
import 'dashboard_viewmodel.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<DashboardViewModel>().fetchDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<DashboardViewModel>(
          builder: (context, vm, _) {

            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 🔥 HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Dashboard",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "Welcome back!",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person, color: Colors.white),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 STATS
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCardHorizontal(
                              title: "Total Members",
                              value: vm.totalMembers.toString(),
                              icon: Icons.people,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCardHorizontal(
                              title: "New This Month",
                              value: vm.newMembers.toString(),
                              icon: Icons.person_add,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCardHorizontal(
                              title: "Paid Members",
                              value: vm.paidMembers.toString(),
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCardHorizontal(
                              title: "Unpaid Members",
                              value: vm.unpaidMembers.toString(),
                              icon: Icons.warning,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 REVENUE
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.currency_rupee,
                                color: Colors.orange),
                            const SizedBox(width: 10),
                            Text(
                              "₹${vm.totalRevenue.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Total Revenue (All Time)",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                        const SizedBox(height: 15),

                        /// 🔥 ACTION BUTTONS
                        Row(
                          children: [
                            Expanded(
                                child: _ActionBtn(
                                    "Add Member",
                                    Colors.orange,
                                    Icons.person_add,
                                    vm.addMember)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _ActionBtn(
                                    "Record Payment",
                                    Colors.green,
                                    Icons.currency_rupee,
                                    vm.recordPayment)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _ActionBtn(
                                    "View Members",
                                    Colors.blue,
                                    Icons.group,
                                    vm.viewMembers)),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 PAYMENT STATUS
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Payment Status",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: vm.paidPercentage,
                                strokeWidth: 100,
                                backgroundColor: Colors.red,
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.green),
                              ),
                              Text(
                                "${(vm.paidPercentage * 100).toInt()}%",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: vm.legends.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: _Legend(
                                text: item.title,
                                color: item.color,
                              ),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 CHART
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MonthlyRevenueChart(
                      revenues: vm.monthlyRevenue,
                      months: vm.months,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionBtn(this.title, this.color, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60, // 🔥 FIXED HEIGHT
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(height: 4),

            /// 🔥 TEXT (MAX 2 LINES)
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCardHorizontal extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCardHorizontal({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          /// 🔥 ICON BOX
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),

          const SizedBox(width: 12),

          /// 🔥 TEXT (IMPORTANT FIX)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // 🔥 prevents overflow
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final String text;
  final Color color;

  const _Legend({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}