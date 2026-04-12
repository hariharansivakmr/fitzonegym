import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_payment_viewmodel.dart';

class AddPaymentView extends StatelessWidget {
  const AddPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddPaymentViewModel>();

    if (vm.isInitLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 👤 MEMBER
            DropdownButtonFormField(
              hint: const Text("Select Member"),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: vm.selectedMember,
              items: vm.members.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(m.name),
                );
              }).toList(),
              onChanged: (m) => vm.selectMember(m!),
            ),
        
            const SizedBox(height: 12),
        
            /// 📦 PLAN
            DropdownButtonFormField(
              hint: const Text("Select Plan"),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: vm.selectedPlan,
              items: vm.plans.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text("${p.type} (₹${p.fees})"),
                );
              }).toList(),
              onChanged: (p) => vm.selectPlan(p!),
            ),
        
            const SizedBox(height: 15),
        
            /// 📅 MONTH
            TextField(
              readOnly: true,
              controller: TextEditingController(text: vm.selectedMonth),
              decoration: const InputDecoration(
                labelText: "For Month (yyyy-MM)",
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
        
                if (picked != null) {
                  vm.selectMonth(
                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}",
                  );
                }
              },
            ),
        
            const SizedBox(height: 12),
        
            /// 💰 PLAN TOTAL
            if (vm.selectedPlan != null)
              _info("Plan Amount", "₹${vm.selectedPlan!.fees}"),
              const SizedBox(height: 12),
        
            /// 💳 MODE
            DropdownButtonFormField<String>(
              value: vm.paymentMode,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "cash", child: Text("Cash")),
                DropdownMenuItem(value: "upi", child: Text("UPI")),
                DropdownMenuItem(value: "card", child: Text("Card")),
              ],
              onChanged: (v) => vm.paymentMode = v!,
            ),
        
            const SizedBox(height: 12),
        
            /// 💰 AMOUNT
            TextField(
              controller: vm.amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter Amount",
                border: OutlineInputBorder(),
              ),
            ),
        
            const SizedBox(height: 20),
        
            /// 🔥 PAY
            ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      await vm.makePayment();
        
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Payment Success")),
                      );
                    },
              child: vm.isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Pay"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text("$title: $value"),
    );
  }
}