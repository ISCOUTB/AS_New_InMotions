import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/white_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

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
                const SizedBox(height: 32),
                const AppLogo(size: 156, padding: 24),
                const SizedBox(height: 24),
                const Text(
                  'InMotions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu bienestar mental en movimiento',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.82),
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                const _FeatureCard(
                  icon: Icons.psychology_rounded,
                  title: 'Evaluación personalizada',
                  subtitle: 'Triaje y seguimiento emocional',
                ),
                const SizedBox(height: 14),
                const _FeatureCard(
                  icon: Icons.favorite_rounded,
                  title: 'Registro emocional',
                  subtitle: 'Lleva un diario de tus emociones',
                ),
                const SizedBox(height: 14),
                const _FeatureCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Contenido especializado',
                  subtitle: 'Artículos y recursos de apoyo',
                ),
                const SizedBox(height: 30),
                WhiteButton(
                  text: 'Iniciar Sesión',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(.35), width: 1.5),
                      backgroundColor: Colors.white.withOpacity(.10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Crear Cuenta',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Cuida tu salud mental con ayuda profesional',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(.80), fontSize: 13),
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

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.11),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(.78), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
