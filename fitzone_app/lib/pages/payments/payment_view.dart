import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'payment_history/payment_history_view.dart';
import 'payment_history/payment_history_viewmodel.dart';

import 'add_payment_view/add_payment_view.dart';
import 'add_payment_view/add_payment_viewmodel.dart';

class PaymentsView extends StatefulWidget {
  const PaymentsView({super.key});

  @override
  State<PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends State<PaymentsView>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => PaymentHistoryViewModel()..load()),
        ChangeNotifierProvider(create: (_) => AddPaymentViewModel()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Payments"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "History"),
              Tab(text: "Add Payment"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            PaymentHistoryView(),
            AddPaymentView(),
          ],
        ),
      ),
    );
  }
}