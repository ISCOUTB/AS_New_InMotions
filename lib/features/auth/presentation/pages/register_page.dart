import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              AppLogo(size: 112, padding: 18, backgroundColor: Colors.white.withOpacity(.95)),
              const SizedBox(height: 14),
              const Text(
                'InMotions',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'Crea tu cuenta y cuida tu bienestar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(.82), fontSize: 15),
              ),
              const SizedBox(height: 24),
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
                      'Registro',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Nombre completo',
                      hint: 'Nombre del estudiante',
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Correo institucional',
                      hint: 'estudiante@utb.edu.co',
                      controller: _emailController,
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Teléfono opcional',
                      hint: '+57 300 000 0000',
                      controller: _phoneController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Contraseña',
                      hint: '••••••••',
                      controller: _passwordController,
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Confirmar contraseña',
                      hint: '••••••••',
                      controller: _confirmPasswordController,
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(color: AppColors.textMuted, height: 1.35, fontSize: 13),
                                children: [
                                  TextSpan(text: 'Acepto los '),
                                  TextSpan(text: 'términos y condiciones', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                                  TextSpan(text: ' y la '),
                                  TextSpan(text: 'política de privacidad', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      text: 'Crear Cuenta',
                      enabled: _acceptedTerms,
                      onPressed: _register,
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text('¿Ya tienes cuenta? ', style: TextStyle(color: AppColors.textMuted)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                            child: const Text(
                              'Inicia sesión',
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
    );
  }
}
