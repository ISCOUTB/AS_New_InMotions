import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/models/triage_result_model.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/triage_visuals.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../data/repositories/triage_repository.dart';

class TriageResultPage extends StatefulWidget {
  const TriageResultPage({super.key});

  @override
  State<TriageResultPage> createState() => _TriageResultPageState();
}

class _TriageResultPageState extends State<TriageResultPage> {
  final TriageRepository _repository = TriageRepository();
  TriageResultModel? _fallbackResult;
  bool _isLoadingFallback = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argResult = _argumentResult;
    if (argResult == null && !_isLoadingFallback && _fallbackResult == null) {
      _loadLatestResult();
    }
  }

  TriageResultModel? get _argumentResult {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is TriageResultModel) return args;
    if (args is Map<String, dynamic>) return TriageResultModel.fromMap(args);
    return null;
  }

  Future<void> _loadLatestResult() async {
    setState(() => _isLoadingFallback = true);
    final result = await _repository.getMyLatestResult();
    if (!mounted) return;
    setState(() {
      _fallbackResult = result;
      _isLoadingFallback = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _argumentResult ?? _fallbackResult;

    if (_isLoadingFallback) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (result == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.analytics_outlined, color: AppColors.purple, size: 42),
                const SizedBox(height: 14),
                const Text(
                  'Aún no hay un resultado de triaje guardado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  text: 'Realizar triaje',
                  icon: Icons.psychology_rounded,
                  gradientColors: const [AppColors.purple, AppColors.primary],
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.triage),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final color = TriageVisuals.colorForRiskLevel(result.riskLevel);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(result: result)),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
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
              child: _SupportCard(result: result),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: _AnswersSummaryCard(result: result),
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
                    gradientColors: [color, color.withValues(alpha: 0.75)],
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.triage),
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

class _Header extends StatelessWidget {
  const _Header({required this.result});

  final TriageResultModel result;

  @override
  Widget build(BuildContext context) {
    final color = TriageVisuals.colorForRiskLevel(result.riskLevel);
    final icon = TriageVisuals.iconForRiskLevel(result.riskLevel);

    return Container(
      padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 10, 18, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.72)]),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
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
          const SizedBox(height: 10),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.20), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 42),
          ),
          const SizedBox(height: 12),
          Text(
            'Riesgo ${result.riskLevel.label}',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Puntaje: ${result.score} · ${DateFormatter.shortDate(result.createdAt)}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.result});

  final TriageResultModel result;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.riskLevel.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 10),
          Text(
            result.riskLevel.message,
            style: const TextStyle(color: AppColors.textDark, height: 1.45, fontSize: 14.5),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'Nota: este resultado es orientativo y no reemplaza una valoración profesional.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  const _RecommendationsCard({required this.result});

  final TriageResultModel result;

  @override
  Widget build(BuildContext context) {
    final color = TriageVisuals.colorForRiskLevel(result.riskLevel);

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
                  Icon(Icons.check_circle_rounded, color: color, size: 21),
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
  const _SupportCard({required this.result});

  final TriageResultModel result;

  @override
  Widget build(BuildContext context) {
    final showUrgent = result.requiresReferral;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: showUrgent ? AppColors.red.withValues(alpha: 0.10) : AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: showUrgent ? AppColors.red.withValues(alpha: 0.20) : AppColors.primary.withValues(alpha: 0.18)),
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
                  showUrgent ? 'Derivación a ${AppConfig.psychologyDepartmentName}' : 'Acompañamiento disponible',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  showUrgent
                      ? 'En esta fase quedó registrada localmente como ${result.referralStatus ?? 'pendiente'}. En el backend se enviará al correo o endpoint oficial: ${AppConfig.psychologyEmail}.'
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

class _AnswersSummaryCard extends StatelessWidget {
  const _AnswersSummaryCard({required this.result});

  final TriageResultModel result;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen de respuestas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ...result.answers.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final answer = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text('$index', style: const TextStyle(color: AppColors.purple, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      answer.optionText,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('+${answer.score}', style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w800)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
