import 'package:fitzone_app/pages/payments/payment_history/payment_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'payment_history_viewmodel.dart';

class PaymentHistoryView extends StatelessWidget {
  const PaymentHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentHistoryViewModel()..load(),
      child: const _PaymentHistoryBody(),
    );
  }
}

class _PaymentHistoryBody extends StatelessWidget {
  const _PaymentHistoryBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentHistoryViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment History"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔍 SEARCH
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Search by month (yyyy-MM)",
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  vm.searchQuery = v;
                  vm.applyFilters();
                },
              ),
            ),
        
            /// 🎛 FILTER + SORT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  /// FILTER
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: vm.filterType,
                      items: const [
                        DropdownMenuItem(value: "all", child: Text("All")),
                        DropdownMenuItem(value: "full", child: Text("Full")),
                        DropdownMenuItem(value: "partial", child: Text("Partial")),
                      ],
                      onChanged: (v) {
                        vm.filterType = v!;
                        vm.applyFilters();
                      },
                      decoration: const InputDecoration(
                        labelText: "Filter",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
        
                  const SizedBox(width: 10),
        
                  /// SORT
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: vm.sortType,
                      items: const [
                        DropdownMenuItem(value: "latest", child: Text("Latest")),
                        DropdownMenuItem(value: "oldest", child: Text("Oldest")),
                        DropdownMenuItem(value: "amount", child: Text("Amount")),
                      ],
                      onChanged: (v) {
                        vm.sortType = v!;
                        vm.applyFilters();
                      },
                      decoration: const InputDecoration(
                        labelText: "Sort",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        
            const SizedBox(height: 10),
        
            /// 📜 LIST
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.filteredPayments.isEmpty
                      ? const Center(child: Text("No Payments Found"))
                      : ListView.builder(
                          itemCount: vm.filteredPayments.length,
                          itemBuilder: (context, index) {
                            final p = vm.filteredPayments[index];
        
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: ListTile(
                                title: Text(
                                  "₹${p.amountPaid.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                    "${p.forMonth} • ${_formatDate(p.paidDate)}"),
                                trailing: Text(
                                  p.paymentType.toUpperCase(),
                                  style: TextStyle(
                                    color: p.paymentType == "full"
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
        
                                /// 🔥 NAVIGATE TO DETAIL
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PaymentDetailView(payment: p),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}