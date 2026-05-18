import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/mock/mock_data.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  void _showDetail(BuildContext context, EmotionalHistoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HistoryDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(onBack: () => Navigator.pop(context))),
              const SliverToBoxAdapter(child: _SummaryCards()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Registros recientes',
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.textDark),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.filter_list_rounded, size: 17, color: AppColors.textMuted),
                            SizedBox(width: 5),
                            Text('Filtrar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: MoreMockData.historyItems.length,
                itemBuilder: (context, index) {
                  final item = MoreMockData.historyItems[index];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(18, index == 0 ? 0 : 8, 18, 10),
                    child: _HistoryCard(item: item, onTap: () => _showDetail(context, item)),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 104)),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavigation(currentRoute: AppRoutes.history),
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
        bottom: 32,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.purple],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
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
                  'Historial Emocional',
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 7),
                Text(
                  'Consulta tus registros y observa cómo evoluciona tu bienestar.',
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

class _SummaryCards extends StatelessWidget {
  const _SummaryCards();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: const [
            Expanded(
              child: _MiniSummaryCard(
                title: '5 días',
                subtitle: 'registrados',
                icon: Icons.calendar_today_rounded,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MiniSummaryCard(
                title: '3.8/5',
                subtitle: 'promedio',
                icon: Icons.trending_up_rounded,
                color: AppColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSummaryCard extends StatelessWidget {
  const _MiniSummaryCard({required this.title, required this.subtitle, required this.icon, required this.color});

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, required this.onTap});

  final EmotionalHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: item.color.withOpacity(.15), borderRadius: BorderRadius.circular(18)),
              child: Icon(item.icon, color: item.color, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.mood,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textDark),
                        ),
                      ),
                      Text(item.dayLabel, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.date, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                  const SizedBox(height: 8),
                  Text(
                    item.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textDark, fontSize: 13, height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: item.activities.take(3).map((activity) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(30)),
                        child: Text(activity, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryDetailSheet extends StatelessWidget {
  const _HistoryDetailSheet({required this.item});

  final EmotionalHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22, 12, 22, MediaQuery.of(context).padding.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(color: item.color.withOpacity(.15), borderRadius: BorderRadius.circular(20)),
                child: Icon(item.icon, color: item.color, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.mood, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    Text(item.date, style: const TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: item.color.withOpacity(.15), shape: BoxShape.circle),
                child: Text('${item.level}', style: TextStyle(color: item.color, fontWeight: FontWeight.w900, fontSize: 17)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Actividades', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: item.activities.map((activity) {
              return Chip(
                label: Text(activity),
                backgroundColor: const Color(0xFFF3F4F6),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          const Text('Nota personal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(item.note, style: const TextStyle(height: 1.45, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
