import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mood_record_model.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/mood_visuals.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/repositories/mood_repository.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final MoodRepository _moodRepository = MoodRepository();
  late Future<List<MoodRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _moodRepository.getMoodHistory();
  }

  void _reload() {
    setState(() {
      _recordsFuture = _moodRepository.getMoodHistory();
    });
  }

  void _showDetail(BuildContext context, MoodRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HistoryDetailSheet(
        record: record,
        onDelete: () async {
          await _moodRepository.deleteMoodRecord(record.id);
          if (!context.mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro emocional eliminado')),
          );
          _reload();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<List<MoodRecord>>(
            future: _recordsFuture,
            builder: (context, snapshot) {
              final records = snapshot.data ?? <MoodRecord>[];
              final isLoading = snapshot.connectionState == ConnectionState.waiting;

              return RefreshIndicator(
                onRefresh: () async => _reload(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _Header(onBack: () => Navigator.pop(context))),
                    if (isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      SliverToBoxAdapter(child: _SummaryCards(records: records)),
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
                                    Icon(Icons.storage_rounded, size: 17, color: AppColors.textMuted),
                                    SizedBox(width: 5),
                                    Text('Local', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (records.isEmpty)
                        SliverToBoxAdapter(child: _EmptyHistory(onCreate: () => Navigator.pushNamed(context, AppRoutes.moodLog)))
                      else
                        SliverList.builder(
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final record = records[index];
                            return Padding(
                              padding: EdgeInsets.fromLTRB(18, index == 0 ? 0 : 8, 18, 10),
                              child: _HistoryCard(record: record, onTap: () => _showDetail(context, record)),
                            );
                          },
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 104)),
                    ],
                  ],
                ),
              );
            },
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
                  'Consulta tus registros guardados localmente y observa tu evolución.',
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
  const _SummaryCards({required this.records});

  final List<MoodRecord> records;

  @override
  Widget build(BuildContext context) {
    final total = records.length;
    final average = records.isEmpty
        ? '0.0/5'
        : '${(records.fold<int>(0, (sum, record) => sum + record.level) / records.length).toStringAsFixed(1)}/5';

    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            Expanded(
              child: _MiniSummaryCard(
                title: '$total ${total == 1 ? 'día' : 'días'}',
                subtitle: 'registrados',
                icon: Icons.calendar_today_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniSummaryCard(
                title: average,
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
  const _HistoryCard({required this.record, required this.onTap});

  final MoodRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = MoodVisuals.colorFor(record.mood);
    final icon = MoodVisuals.iconFor(record.mood);

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
              decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, color: color, size: 30),
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
                          record.mood,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textDark),
                        ),
                      ),
                      Text(DateFormatter.dayLabel(record.createdAt), style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(DateFormatter.readableDateTime(record.createdAt), style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                  const SizedBox(height: 8),
                  Text(
                    record.note.isEmpty ? 'Sin nota personal.' : record.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textDark, fontSize: 13, height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: record.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(30)),
                        child: Text(tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
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

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: AppCard(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), shape: BoxShape.circle),
              child: const Icon(Icons.favorite_border_rounded, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aún no tienes registros emocionales',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Registra cómo te sientes hoy para comenzar a construir tu historial.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, height: 1.35),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear registro'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryDetailSheet extends StatelessWidget {
  const _HistoryDetailSheet({required this.record, required this.onDelete});

  final MoodRecord record;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final color = MoodVisuals.colorFor(record.mood);
    final icon = MoodVisuals.iconFor(record.mood);

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
                decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(20)),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.mood, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    Text(DateFormatter.readableDateTime(record.createdAt), style: const TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color.withOpacity(.15), shape: BoxShape.circle),
                child: Text('${record.level}', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 17)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(MoodVisuals.interpretationForLevel(record.level), style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 20),
          const Text('Etiquetas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          if (record.tags.isEmpty)
            const Text('Sin etiquetas seleccionadas.', style: TextStyle(color: AppColors.textMuted))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: record.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: const Color(0xFFF3F4F6),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                );
              }).toList(),
            ),
          const SizedBox(height: 18),
          const Text('Nota personal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(record.note.isEmpty ? 'Sin nota personal.' : record.note, style: const TextStyle(height: 1.45, color: AppColors.textDark)),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Eliminar registro local'),
            ),
          ),
        ],
      ),
    );
  }
}
