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
  final feesController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    final vm = context.read<MemberViewModel>();

    if (widget.isEdit && widget.member != null) {
      final m = widget.member!;

      nameController.text = m.name;
      mobileController.text = m.mobile;
      feesController.text = m.fees.toString();

      selectedDate = m.joinDate;

      vm.selectedPlan = m.plan;
      vm.selectedFees = m.fees;
    }
  }

  /// 🔥 CLEAR ALL
  void clearAll(MemberViewModel vm) {
    nameController.clear();
    mobileController.clear();
    feesController.clear();
    selectedDate = DateTime.now();
    vm.clearForm();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MemberViewModel>();

    /// 🔥 AUTO FILL FEES
    if (vm.selectedFees != null &&
        feesController.text != vm.selectedFees?.toStringAsFixed(0)) {
      feesController.text = vm.selectedFees!.toStringAsFixed(0);
    }

    return Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: Text(widget.isEdit
          ? "Edit Member"
          : "New Member Registration"),
    ),
    body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔥 FORM CARD
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
      
                  /// 🔥 FULL WIDTH JOIN DATE
                  _dateField(),
                  const SizedBox(height: 12),
      
                  /// 🔥 DROPDOWN
                  _planDropdown(vm),
                  const SizedBox(height: 12),
      
                  _textField(
                    "Fees Amount (₹)",
                    feesController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
      
                  /// 🔥 NEXT DUE DATE
                  _nextDueDate(vm),
                  const SizedBox(height: 16),
      
                  /// INFO BOX
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "A welcome WhatsApp message will be sent automatically.",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
      
                  const SizedBox(height: 16),
      
                  /// 🔥 BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            final vm = context.read<MemberViewModel>();
      
                            final error = vm.validateMember(
                              name: nameController.text,
                              mobile: mobileController.text,
                              feesText: feesController.text,
                            );
      
                            if (error != null) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(error)));
                              return;
                            }
      
                            final selectedPlanObj = vm.plans.firstWhere(
                              (p) => p.name == vm.selectedPlan,
                            );
      
                            final nextDueDate = vm.calculateNextDueDate(
                              selectedDate,
                              selectedPlanObj.durationMonths,
                            );
      
                            final newMember = MemberModel(
                              name: nameController.text.trim(),
                              mobile: mobileController.text.trim(),
                              plan: vm.selectedPlan!,
                              fees: double.parse(feesController.text),
                              joinDate: selectedDate,
                              nextDueDate: nextDueDate,
                              isPaid: widget.member?.isPaid ?? false,
                            );
      
                            if (widget.isEdit) {
                              vm.updateMember(widget.member!, newMember);
                              Navigator.pop(context); // go back after update
                            } else {
                              vm.addMember(newMember);
                              clearAll(vm);
                            }
      
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  widget.isEdit
                                      ? "Member Updated Successfully"
                                      : "Member Added Successfully",
                                ),
                              ),
                            );
                          },
                          child: Text(
                            widget.isEdit ? "Update Member" : "Add Member",
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            clearAll(context.read<MemberViewModel>());
                          },
                          child: const Text("Clear All"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      
            const SizedBox(height: 20),
      
            /// 🔥 SUGGESTED PRICES
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Suggested Prices",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
      
                  ...vm.plans.map((plan) => _priceCard(plan, vm)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 COMMON CARD
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

  /// 🔥 TEXT FIELD
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

  /// 🔥 DATE PICKER
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

  /// 🔥 DROPDOWN
  Widget _planDropdown(MemberViewModel vm) {
    return DropdownButtonFormField<String>(
      value: vm.selectedPlan,
      items: vm.plans
          .map((e) => DropdownMenuItem(value: e.name, child: Text(e.name)))
          .toList(),
      onChanged: (value) {
        final plan = vm.plans.firstWhere((p) => p.name == value);
        vm.selectPlan(plan);
      },
      decoration: InputDecoration(
        hintText: "Select Plan",
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// 🔥 NEXT DUE DATE
  Widget _nextDueDate(MemberViewModel vm) {
    if (vm.selectedPlan == null) {
      return _fakeField("Next Due Date", "Auto-calculated");
    }

    final plan = vm.plans.firstWhere((p) => p.name == vm.selectedPlan);

    final nextDate = vm.calculateNextDueDate(selectedDate, plan.durationMonths);

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

  /// 🔥 PRICE CARD
  Widget _priceCard(PlanModel plan, MemberViewModel vm) {
    return GestureDetector(
      onTap: () => vm.selectPlan(plan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(plan.name),
            Text(
              "₹${plan.price}",
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
