import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController(text: 'estudiante@utb.edu.co');
  final TextEditingController _passwordController = TextEditingController(text: 'Test@12345');
  final AuthRepository _authRepository = AuthRepository();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      await _authRepository.login(
        email: _emailController.text,
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false);
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo iniciar sesión. Inténtalo nuevamente.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                const AppLogo(size: 128, padding: 20),
                const SizedBox(height: 16),
                const Text(
                  'InMotions',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tu bienestar mental en movimiento',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(.80), fontSize: 15),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.18),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 22),
                      CustomTextField(
                        label: 'Correo institucional',
                        hint: 'estudiante@utb.edu.co',
                        controller: _emailController,
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Contraseña',
                        hint: '••••••••',
                        controller: _passwordController,
                        icon: Icons.lock_outline_rounded,
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            onChanged: (value) => setState(() => _rememberMe = value ?? false),
                          ),
                          const Text('Recordarme', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(text: _isLoading ? 'Ingresando...' : 'Iniciar Sesión', enabled: !_isLoading, onPressed: _login),
                      const SizedBox(height: 18),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            const Text('¿No tienes cuenta? ', style: TextStyle(color: AppColors.textMuted)),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                              child: const Text(
                                'Regístrate aquí',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
