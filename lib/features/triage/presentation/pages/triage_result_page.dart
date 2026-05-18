import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';

class TriageResultPage extends StatelessWidget {
  const TriageResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    int score = 8;
    if (args is Map && args['score'] is int) score = args['score'] as int;

    final result = _ResultInfo.fromScore(score);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(result: result, score: score)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
              child: _MessageCard(result: result),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: _RecommendationsCard(result: result),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: _SupportCard(showUrgent: result.level == 'Alto'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 36),
              child: Column(
                children: [
                  PrimaryButton(
                    text: 'Volver al inicio',
                    icon: Icons.home_rounded,
                    gradientColors: [result.color, result.color.withOpacity(.75)],
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.triage),
                    child: const Text('Repetir triaje', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultInfo {
  const _ResultInfo({
    required this.level,
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
    required this.recommendations,
  });

  final String level;
  final String title;
  final String message;
  final Color color;
  final IconData icon;
  final List<String> recommendations;

  factory _ResultInfo.fromScore(int score) {
    if (score >= 11) {
      return const _ResultInfo(
        level: 'Alto',
        title: 'Se recomienda apoyo profesional',
        message: 'Tus respuestas indican un nivel alto de malestar emocional. Es importante que no lo manejes en soledad y busques acompañamiento.',
        color: AppColors.red,
        icon: Icons.priority_high_rounded,
        recommendations: [
          'Contactar al área de Psicología UTB.',
          'Hablar con una persona de confianza hoy.',
          'Evitar tomar decisiones importantes mientras te sientes sobrecargado.',
        ],
      );
    }
    if (score >= 6) {
      return const _ResultInfo(
        level: 'Medio',
        title: 'Necesitas fortalecer tu autocuidado',
        message: 'Tus respuestas muestran señales moderadas de tensión emocional. Puedes beneficiarte de hábitos de regulación y seguimiento.',
        color: AppColors.orange,
        icon: Icons.warning_amber_rounded,
        recommendations: [
          'Registrar tus emociones durante la semana.',
          'Practicar respiración o pausas activas.',
          'Buscar orientación si el malestar se mantiene.',
        ],
      );
    }
    return const _ResultInfo(
      level: 'Bajo',
      title: 'Tu resultado está en rango bajo',
      message: 'Tus respuestas no muestran señales fuertes de riesgo en este momento. Mantén hábitos de bienestar y seguimiento emocional.',
      color: AppColors.green,
      icon: Icons.check_circle_rounded,
      recommendations: [
        'Continuar con tu registro emocional diario.',
        'Mantener descanso, actividad física y redes de apoyo.',
        'Consultar recursos educativos de bienestar.',
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.result, required this.score});

  final _ResultInfo result;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 24, 18, 34),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [result.color, result.color.withOpacity(.72)]),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Resultado del Triaje',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: Colors.white.withOpacity(.20), shape: BoxShape.circle),
            child: Icon(result.icon, color: Colors.white, size: 54),
          ),
          const SizedBox(height: 18),
          Text(
            'Riesgo ${result.level}',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text('Puntaje visual: $score', style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 14)),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.result});

  final _ResultInfo result;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(result.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark)),
          const SizedBox(height: 10),
          Text(result.message, style: const TextStyle(color: AppColors.textDark, height: 1.45, fontSize: 14.5)),
        ],
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  const _RecommendationsCard({required this.result});

  final _ResultInfo result;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recomendaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          ...result.recommendations.map((text) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded, color: result.color, size: 21),
                  const SizedBox(width: 10),
                  Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.35))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({required this.showUrgent});

  final bool showUrgent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: showUrgent ? AppColors.red.withOpacity(.10) : AppColors.primary.withOpacity(.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: showUrgent ? AppColors.red.withOpacity(.20) : AppColors.primary.withOpacity(.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(showUrgent ? Icons.local_hospital_rounded : Icons.support_agent_rounded, color: showUrgent ? AppColors.red : AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showUrgent ? 'Contacto con Psicología UTB' : 'Acompañamiento disponible',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  showUrgent
                      ? 'En la versión con backend, este flujo enviará una derivación automática o mostrará el canal institucional de apoyo.'
                      : 'Puedes consultar recursos y solicitar apoyo si sientes que lo necesitas.',
                  style: const TextStyle(fontSize: 13.5, height: 1.35, color: AppColors.textDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
