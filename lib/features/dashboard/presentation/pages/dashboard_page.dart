import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mood_record_model.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/mood_visuals.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/mock/mock_data.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/mood_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final MoodRepository _moodRepository = MoodRepository();
  late Future<_DashboardMoodData> _moodDataFuture;

  @override
  void initState() {
    super.initState();
    _moodDataFuture = _loadMoodData();
  }

  Future<_DashboardMoodData> _loadMoodData() async {
    final todayRecord = await _moodRepository.getTodayMoodRecord();
    final weekRecords = await _moodRepository.getCurrentWeekRecords();
    final history = await _moodRepository.getMoodHistory();
    final average = await _moodRepository.getWeeklyAverage();
    return _DashboardMoodData(
      todayRecord: todayRecord,
      weekRecords: weekRecords,
      history: history,
      weeklyAverage: average,
    );
  }

  void _reload() {
    setState(() {
      _moodDataFuture = _loadMoodData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async => _reload(),
            child: FutureBuilder<_DashboardMoodData>(
              future: _moodDataFuture,
              builder: (context, snapshot) {
                final data = snapshot.data ?? const _DashboardMoodData.empty();

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _Header()),
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: _QuickActionsCard(),
                      ),
                    ),
                    SliverToBoxAdapter(child: _TodayMoodCard(todayRecord: data.todayRecord)),
                    SliverToBoxAdapter(child: _WeekSummaryCard(data: data)),
                    const SliverToBoxAdapter(child: _ReminderCard()),
                    const SliverToBoxAdapter(child: _RecommendedArticles()),
                    const SliverToBoxAdapter(child: SizedBox(height: 96)),
                  ],
                );
              },
            ),
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: AppBottomNavigation(currentRoute: AppRoutes.dashboard)),
        ],
      ),
    );
  }
}

class _DashboardMoodData {
  const _DashboardMoodData({
    required this.todayRecord,
    required this.weekRecords,
    required this.history,
    required this.weeklyAverage,
  });

  const _DashboardMoodData.empty()
      : todayRecord = null,
        weekRecords = const <MoodRecord>[],
        history = const <MoodRecord>[],
        weeklyAverage = 0;

  final MoodRecord? todayRecord;
  final List<MoodRecord> weekRecords;
  final List<MoodRecord> history;
  final double weeklyAverage;
}

class _Header extends StatelessWidget {
  _Header();

  final AuthRepository _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 18,
        right: 18,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FutureBuilder(
              future: _authRepository.getCurrentUser(),
              builder: (context, snapshot) {
                final firstName = snapshot.data?.fullName.split(' ').first ?? 'estudiante';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hola, $firstName', style: const TextStyle(color: Color(0xFFDBEAFE), fontSize: 14)),
                    const SizedBox(height: 6),
                    const Text(
                      '¿Cómo te sientes hoy?',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ],
                );
              },
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 27),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones rápidas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            itemCount: MockData.quickActions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.08,
            ),
            itemBuilder: (context, index) {
              final item = MockData.quickActions[index];
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Navigator.pushNamed(context, item.route),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
                        child: Icon(item.icon, color: Colors.white, size: 26),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TodayMoodCard extends StatelessWidget {
  const _TodayMoodCard({required this.todayRecord});

  final MoodRecord? todayRecord;

  @override
  Widget build(BuildContext context) {
    final record = todayRecord;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: AppCard(
        child: record == null
            ? Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: AppColors.pink.withOpacity(.12), borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.favorite_border_rounded, color: AppColors.pink, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Aún no registras tu emoción de hoy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        SizedBox(height: 4),
                        Text('Haz tu registro diario para alimentar tu historial.', style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.25)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.moodLog),
                    icon: const Icon(Icons.add_circle_rounded, color: AppColors.pink, size: 32),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: MoodVisuals.colorFor(record.mood).withOpacity(.14), borderRadius: BorderRadius.circular(18)),
                    child: Icon(MoodVisuals.iconFor(record.mood), color: MoodVisuals.colorFor(record.mood), size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hoy: ${record.mood}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text('Nivel ${record.level}/5 · ${record.tags.isEmpty ? 'sin etiquetas' : record.tags.take(2).join(', ')}', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
                    icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 18),
                  ),
                ],
              ),
      ),
    );
  }
}

class _WeekSummaryCard extends StatelessWidget {
  const _WeekSummaryCard({required this.data});

  final _DashboardMoodData data;

  @override
  Widget build(BuildContext context) {
    final weekDays = _buildWeekDays(data.weekRecords);
    final registeredDays = data.weekRecords.length;
    final average = data.weeklyAverage == 0 ? '0.0' : data.weeklyAverage.toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Tu semana',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
                  child: const Text('Ver historial', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekDays.map((item) {
                return Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: item.record == null ? const Color(0xFFF3F4F6) : item.color.withOpacity(.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color, size: 23),
                    ),
                    const SizedBox(height: 7),
                    Text(item.dayLabel, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Resumen semanal: ', style: TextStyle(fontWeight: FontWeight.w800)),
                          TextSpan(text: '$registeredDays registros esta semana · promedio $average/5'),
                        ],
                      ),
                      style: const TextStyle(color: AppColors.primaryDark, fontSize: 13.5, height: 1.25),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_WeekMoodView> _buildWeekDays(List<MoodRecord> weekRecords) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final day = startOfWeek.add(Duration(days: index));
      MoodRecord? record;
      for (final item in weekRecords) {
        if (DateFormatter.isSameDay(item.createdAt, day)) {
          record = item;
          break;
        }
      }

      return _WeekMoodView(
        dayLabel: DateFormatter.shortWeekday(day),
        record: record,
        icon: record == null ? Icons.add_rounded : MoodVisuals.iconFor(record.mood),
        color: record == null ? AppColors.textMuted : MoodVisuals.colorFor(record.mood),
      );
    });
  }
}

class _WeekMoodView {
  const _WeekMoodView({required this.dayLabel, required this.record, required this.icon, required this.color});

  final String dayLabel;
  final MoodRecord? record;
  final IconData icon;
  final Color color;
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.purple, AppColors.pink]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withOpacity(.25),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'PRÓXIMO RECORDATORIO',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: .2),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Registro emocional diario',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text('Hoy a las 8:00 PM', style: TextStyle(color: Colors.white.withOpacity(.80), fontSize: 14)),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.reminders),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.purple,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('Ver detalles', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedArticles extends StatelessWidget {
  const _RecommendedArticles();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Artículos recomendados',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.textDark),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.articles),
                child: const Text('Ver todos', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _ArticleTile(
            icon: Icons.psychology_rounded,
            iconColor: AppColors.primary,
            title: 'Manejo de la ansiedad',
            subtitle: 'Técnicas efectivas para reducir la ansiedad en tu vida diaria',
            time: '5 min de lectura',
          ),
          const SizedBox(height: 12),
          const _ArticleTile(
            icon: Icons.favorite_rounded,
            iconColor: AppColors.green,
            title: 'Importancia del autocuidado',
            subtitle: 'Por qué dedicar tiempo a ti mismo es fundamental para tu bienestar',
            time: '7 min de lectura',
          ),
        ],
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Navigator.pushNamed(context, AppRoutes.articles),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [iconColor.withOpacity(.75), iconColor]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5, height: 1.25),
                  ),
                  const SizedBox(height: 7),
                  Text(time, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
