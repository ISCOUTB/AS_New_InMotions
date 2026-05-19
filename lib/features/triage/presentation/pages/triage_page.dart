import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/models/triage_question_model.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../data/repositories/triage_repository.dart';

class TriagePage extends StatefulWidget {
  const TriagePage({super.key});

  @override
  State<TriagePage> createState() => _TriagePageState();
}

class _TriagePageState extends State<TriagePage> {
  final TriageRepository _repository = TriageRepository();
  final Map<String, TriageOptionModel> _selectedOptions = {};

  List<TriageQuestionModel> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isLast => _questions.isNotEmpty && _currentIndex == _questions.length - 1;

  bool get _hasAnswer {
    if (_questions.isEmpty) return false;
    return _selectedOptions.containsKey(_questions[_currentIndex].id);
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _repository.getActiveQuestions();
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _next() async {
    if (!_hasAnswer || _isSubmitting) return;

    if (!_isLast) {
      setState(() => _currentIndex++);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _repository.submitAnswers(_selectedOptions);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.triageResult, arguments: result);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = error.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 48),
                const SizedBox(height: 12),
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 18),
                PrimaryButton(
                  text: 'Volver',
                  onPressed: () => Navigator.pop(context),
                  icon: Icons.arrow_back_rounded,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final selectedOption = _selectedOptions[question.id];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(onBack: _previous)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 22, 18, 0),
              child: _IntroNotice(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: _ProgressCard(
                current: _currentIndex + 1,
                total: _questions.length,
                progress: progress,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: _QuestionCard(
                question: question,
                selectedOptionId: selectedOption?.id,
                onSelected: (option) => setState(() => _selectedOptions[question.id] = option),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 36),
              child: Column(
                children: [
                  PrimaryButton(
                    text: _isSubmitting ? 'Calculando...' : (_isLast ? 'Ver resultado' : 'Siguiente'),
                    icon: _isLast ? Icons.analytics_rounded : Icons.arrow_forward_rounded,
                    enabled: _hasAnswer && !_isSubmitting,
                    gradientColors: const [AppColors.purple, AppColors.primary],
                    onPressed: _next,
                  ),
                  const SizedBox(height: 10),
                  if (_currentIndex > 0)
                    TextButton(
                      onPressed: _isSubmitting ? null : _previous,
                      child: const Text(
                        'Volver a la pregunta anterior',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
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
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 18,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.purple, AppColors.primary]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
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
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 7),
                Text(
                  '23 ítems · Últimas dos semanas · Escala de 1 a 5.',
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
  const _IntroNotice();

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
              'Este test es una herramienta de orientación y no reemplaza una evaluación psicológica o psiquiátrica profesional. Los resultados se calculan localmente durante esta fase.',
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
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(color: AppColors.purple, fontWeight: FontWeight.w900),
              ),
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
  const _QuestionCard({
    required this.question,
    required this.selectedOptionId,
    required this.onSelected,
  });

  final TriageQuestionModel question;
  final String? selectedOptionId;
  final ValueChanged<TriageOptionModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuestionChip(text: question.area, color: AppColors.purple),
              if (question.isCritical) const _QuestionChip(text: 'Ítem crítico', color: AppColors.red),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          if (question.isCritical) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.red.withOpacity(.15)),
              ),
              child: const Text(
                'Esta pregunta ayuda a priorizar recursos de apoyo inmediato si los necesitas.',
                style: TextStyle(color: AppColors.textDark, fontSize: 13.2, height: 1.35),
              ),
            ),
          ],
          const SizedBox(height: 18),
          ...question.options.map((option) {
            final bool selected = selectedOptionId == option.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onSelected(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.purple.withOpacity(.12) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected ? AppColors.purple : AppColors.border,
                      width: selected ? 1.6 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? AppColors.purple : Colors.white,
                          border: Border.all(
                            color: selected ? AppColors.purple : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.text,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, height: 1.25),
                            ),
                            if (option.interpretation != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                option.interpretation!,
                                style: const TextStyle(fontSize: 12.2, color: AppColors.textMuted, height: 1.25),
                              ),
                            ],
                          ],
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


class _QuestionChip extends StatelessWidget {
  const _QuestionChip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(.16)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900)),
    );
  }
}
