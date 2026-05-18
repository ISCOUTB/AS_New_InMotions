import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../data/repositories/auth_repository.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final isLoggedIn = await _authRepository.isLoggedIn();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      isLoggedIn ? AppRoutes.dashboard : AppRoutes.welcome,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogo(size: 128, padding: 20),
              SizedBox(height: 18),
              Text(
                AppConfig.appDisplayName,
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 8),
              Text(
                AppConfig.appSlogan,
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              SizedBox(height: 28),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
