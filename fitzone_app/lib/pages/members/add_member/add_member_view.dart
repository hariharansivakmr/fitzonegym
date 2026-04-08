import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utilities/constants/app_colors.dart';
import '../member_viewmodel.dart';
import '../member_model.dart';

class AddMemberView extends StatefulWidget {
  final bool isEdit;
  final MemberModel? member;

  const AddMemberView({super.key, this.isEdit = false, this.member});

  @override
  State<AddMemberView> createState() => _AddMemberViewState();
}

class _AddMemberViewState extends State<AddMemberView> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    final vm = context.read<MemberViewModel>();
    vm.selectedPlanId = null; // 🔥 RESET
    vm.fetchPlans();

    if (widget.isEdit && widget.member != null) {
      final m = widget.member!;

      nameController.text = m.name;
      mobileController.text = m.phone;

      selectedDate = m.joinDate;

      vm.selectedPlanId = m.planId;
    }
  }

  void clearAll(MemberViewModel vm) {
    nameController.clear();
    mobileController.clear();
    selectedDate = DateTime.now();
    vm.selectedPlanId = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MemberViewModel>();

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
                  _textField("Full Name", nameController),
                  const SizedBox(height: 12),

                  _textField(
                    "Mobile Number",
                    mobileController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),

                  _dateField(),
                  const SizedBox(height: 12),

                  _planDropdown(vm),
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
                            final error = vm.validateMember(
                              name: nameController.text,
                              mobile: mobileController.text,
                            );

                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error)),
                              );
                              return;
                            }

                            final plan = vm.plans
                                .firstWhere((p) => p.id == vm.selectedPlanId);

                            final dueDate = vm.calculateNextDueDate(
                              selectedDate,
                              plan.duration,
                            );

                            final newMember = MemberModel(
                              name: nameController.text.trim(),
                              phone: mobileController.text.trim(),
                              planId: plan.id!,
                              joinDate: selectedDate,
                              lastPaidMonth: _formatMonth(selectedDate),
                              dueDate: dueDate,
                              pendingAmount: 0,
                            );

                            if (widget.isEdit) {
                              await vm.updateMember(newMember);
                              Navigator.pop(context);
                            } else {
                              await vm.addMember(newMember);
                              clearAll(vm);
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  widget.isEdit
                                      ? "Member Updated"
                                      : "Member Added",
                                ),
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
                              clearAll(context.read<MemberViewModel>()),
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

  Widget _textField(
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _dateField() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          setState(() => selectedDate = picked);
        }
      },
      child: _fakeField(
        "Join Date",
        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
      ),
    );
  }

  Widget _planDropdown(MemberViewModel vm) {
  final validValue = vm.plans.any((p) => p.id == vm.selectedPlanId)
      ? vm.selectedPlanId
      : null;

  return DropdownButtonFormField<String>(
    value: validValue, // ✅ IMPORTANT (NOT initialValue)

    items: vm.plans.map((e) {
      return DropdownMenuItem<String>(
        value: e.id,
        child: Text(e.type),
      );
    }).toList(),

    onChanged: (value) {
      vm.selectPlan(value); // ✅ uses notifyListeners
    },

    decoration: InputDecoration(
      hintText: "Select Plan",
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

  Widget _nextDueDate(MemberViewModel vm) {
    if (vm.selectedPlanId == null) {
      return _fakeField("Next Due Date", "Auto-calculated");
    }

    final plan =
        vm.plans.firstWhere((p) => p.id == vm.selectedPlanId);

    final nextDate =
        vm.calculateNextDueDate(selectedDate, plan.duration);

    return _fakeField(
      "Next Due Date",
      "${nextDate.day}/${nextDate.month}/${nextDate.year}",
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

  // ============================================================

  String _formatMonth(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }
}