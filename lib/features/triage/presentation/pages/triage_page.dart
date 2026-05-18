import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../data/mock/mock_data.dart';

class TriagePage extends StatefulWidget {
  const TriagePage({super.key});

  @override
  State<TriagePage> createState() => _TriagePageState();
}

class _TriagePageState extends State<TriagePage> {
  int _currentIndex = 0;
  final Map<int, int> _answers = {};

  bool get _isLast => _currentIndex == MoreMockData.triageQuestions.length - 1;
  bool get _hasAnswer => _answers.containsKey(_currentIndex);

  void _next() {
    if (!_hasAnswer) return;

    if (_isLast) {
      final int score = _answers.values.fold(0, (sum, value) => sum + value);
      Navigator.pushNamed(context, AppRoutes.triageResult, arguments: {'score': score});
      return;
    }

    setState(() => _currentIndex++);
  }

  void _previous() {
    if (_currentIndex == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() => _currentIndex--);
  }

  @override
  Widget build(BuildContext context) {
    final question = MoreMockData.triageQuestions[_currentIndex];
    final progress = (_currentIndex + 1) / MoreMockData.triageQuestions.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(onBack: _previous)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
              child: _IntroNotice(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: _ProgressCard(
                current: _currentIndex + 1,
                total: MoreMockData.triageQuestions.length,
                progress: progress,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: _QuestionCard(
                question: question,
                selectedScore: _answers[_currentIndex],
                onSelected: (score) => setState(() => _answers[_currentIndex] = score),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 36),
              child: Column(
                children: [
                  PrimaryButton(
                    text: _isLast ? 'Ver Resultado' : 'Siguiente',
                    icon: _isLast ? Icons.analytics_rounded : Icons.arrow_forward_rounded,
                    enabled: _hasAnswer,
                    gradientColors: const [AppColors.purple, AppColors.primary],
                    onPressed: _next,
                  ),
                  const SizedBox(height: 10),
                  if (_currentIndex > 0)
                    TextButton(
                      onPressed: _previous,
                      child: const Text('Volver a la pregunta anterior', style: TextStyle(fontWeight: FontWeight.w800)),
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
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 8,
        right: 18,
        bottom: 28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.purple, AppColors.primary]),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 2),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6),
                Text(
                  'Triaje Emocional',
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 7),
                Text(
                  'Responde con honestidad para recibir una orientación inicial.',
                  style: TextStyle(color: Color(0xFFEDE9FE), fontSize: 14, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.purple.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.purple.withOpacity(.18)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.purple),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este test no reemplaza la atención profesional. Sirve como guía visual para identificar tu nivel de bienestar emocional.',
              style: TextStyle(color: AppColors.textDark, fontSize: 13.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.current, required this.total, required this.progress});

  final int current;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pregunta $current de $total',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              Text('${(progress * 100).round()}%', style: const TextStyle(color: AppColors.purple, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.purple),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.selectedScore, required this.onSelected});

  final TriageQuestion question;
  final int? selectedScore;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w900, height: 1.25),
          ),
          const SizedBox(height: 18),
          ...question.options.map((option) {
            final bool selected = selectedScore == option.score;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onSelected(option.score),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.purple.withOpacity(.12) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: selected ? AppColors.purple : AppColors.border, width: selected ? 1.6 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? AppColors.purple : Colors.white,
                          border: Border.all(color: selected ? AppColors.purple : AppColors.border, width: 1.5),
                        ),
                        child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option.text,
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.25),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
