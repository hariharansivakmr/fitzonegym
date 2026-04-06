import 'package:fitzone_app/pages/dashboard/dashboard_viewmodel.dart';
import 'package:fitzone_app/pages/members/member_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'utilities/theme/app_theme.dart';
import 'pages/auth/login/login_view.dart';
import 'pages/auth/login/login_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => MemberViewModel(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const LoginView(),
      ),
    );
  }
}