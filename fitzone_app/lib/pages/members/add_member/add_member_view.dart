import 'package:fitzone_app/pages/members/add_member/add_member_viewmodel.dart';
import 'package:fitzone_app/pages/members/member_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utilities/constants/app_colors.dart';


class AddMemberView extends StatefulWidget {
  final bool isEdit;
  final MemberModel? member;

  const AddMemberView({super.key, this.isEdit = false, this.member});

  @override
  State<AddMemberView> createState() => _AddMemberViewState();
}

class _AddMemberViewState extends State<AddMemberView> {
  



  void clearAll(AddMemberViewModel vm) {
    vm.nameController.clear();
    vm.mobileController.clear();
    vm.selectedDate = DateTime.now();
    vm.selectedPlanId = null;
    vm.setPaymentType(PaymentType.none);
    vm.amountController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddMemberViewModel>();
    if (vm.isEdit && (vm.isLoading || vm.plans.isEmpty)) {
              return const Center(child: CircularProgressIndicator());
            }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEdit ? "Edit Member" : "New Member"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textField("Full Name", vm.nameController),
                  const SizedBox(height: 12),

                  _textField(
                    "Mobile Number",
                    vm.mobileController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),

                  _dateField(vm),
                  const SizedBox(height: 12),

                  _planDropdown(vm),
                  const SizedBox(height: 12),

                  /// 🔥 NEW: PAYMENT TYPE
                  _paymentTypeDropdown(vm),
                  const SizedBox(height: 12),

                  /// 🔥 NEW: AMOUNT FIELD
                  if (vm.showAmountField) _amountField(vm),

                  const SizedBox(height: 12),

                  _nextDueDate(vm),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "WhatsApp welcome message will be sent automatically.",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            final plan = vm.plans.firstWhere(
                                (p) => p.id == vm.selectedPlanId,
                                orElse: () => vm.plans.first,
                              );

                            final dueDate = vm.calculateNextDueDate(
                              vm.selectedDate,
                              plan.duration,
                            );

                            final member = MemberModel(
                              id: widget.member?.id ?? "",
                              name: vm.nameController.text.trim(),
                              phone: vm.mobileController.text.trim(),
                              planId: plan.id!,
                              joinDate: vm.selectedDate,
                              lastPaidMonth:
                                  vm.formatMonth(vm.selectedDate),
                              dueDate: dueDate,
                              pendingAmount: vm.selectedPaymentType == PaymentType.fullyPaid
    ? 0
    : plan.fees -
        (double.tryParse(vm.amountController.text) ?? 0),
                            );

                            await vm.saveMember(
                              member: member,
                              plan: plan,
                              isEdit: widget.isEdit,
                            );

                            if (widget.isEdit) {
                              Navigator.pop(context);
                            } else {
                              clearAll(vm);
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(widget.isEdit
                                    ? "Member Updated"
                                    : "Member Added"),
                              ),
                            );
                          },
                          child: Text(
                              widget.isEdit ? "Update" : "Add Member"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              clearAll(context.read<AddMemberViewModel>()),
                          child: const Text("Clear"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================

  Widget _paymentTypeDropdown(AddMemberViewModel vm) {
    return DropdownButtonFormField<PaymentType>(
      value: vm.selectedPaymentType,
      items: const [
        DropdownMenuItem(
            value: PaymentType.fullyPaid, child: Text("Fully Paid")),
        DropdownMenuItem(
            value: PaymentType.partiallyPaid,
            child: Text("Partially Paid")),
        DropdownMenuItem(
            value: PaymentType.none, child: Text("None")),
      ],
      onChanged: (value) => vm.setPaymentType(value!),
      decoration: InputDecoration(
        hintText: "Payment Type",
        filled: true,
        fillColor: Colors.white10,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _amountField(AddMemberViewModel vm) {
    return TextField(
      controller: vm.amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: "Enter Amount",
        filled: true,
        fillColor: Colors.white10,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _planDropdown(AddMemberViewModel vm) {
    final validValue = vm.plans.any((p) => p.id == vm.selectedPlanId)
        ? vm.selectedPlanId
        : null;

    return DropdownButtonFormField<String>(
      value: validValue,
      items: vm.plans.map((e) {
        return DropdownMenuItem(
          value: e.id,
          child: Text("${e.type} - ₹${e.fees}"),
        );
      }).toList(),
      onChanged: (value) {
      vm.selectPlan(value);

      // 🔥 Find selected plan
      final selectedPlan = vm.plans.firstWhere(
  (p) => p.id == value,
  orElse: () => vm.plans.first,
);

      // 🔥 Set amount
      vm.amountController.text =
          selectedPlan.fees.toStringAsFixed(0);
    },
      decoration: InputDecoration(
        hintText: "Select Plan",
        filled: true,
        fillColor: Colors.white10,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _nextDueDate(AddMemberViewModel vm) {
    if (vm.selectedPlanId == null) {
      return _fakeField("Next Due Date", "Auto-calculated");
    }

    final plan = vm.plans.firstWhere(
  (p) => p.id == vm.selectedPlanId,
  orElse: () => vm.plans.first,
);

    final nextDate =
        vm.calculateNextDueDate(vm.selectedDate, plan.duration);

    return _fakeField(
      "Next Due Date",
      "${nextDate.day}/${nextDate.month}/${nextDate.year}",
    );
  }

  Widget _dateField(AddMemberViewModel vm) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: vm.selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          setState(() => vm.selectedDate = picked);
        }
      },
      child: _fakeField(
        "Join Date",
        "${vm.selectedDate.day}/${vm.selectedDate.month}/${vm.selectedDate.year}",
      ),
    );
  }

  Widget _fakeField(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text("$title: $value"),
    );
  }

  Widget _textField(String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white10,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _card({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
}
}