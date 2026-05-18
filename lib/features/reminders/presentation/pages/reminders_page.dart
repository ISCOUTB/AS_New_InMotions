import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../data/mock/mock_data.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  late final List<bool> _enabled = MoreMockData.reminders.map((item) => item.enabled).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(onBack: () => Navigator.pop(context))),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
              child: _MainReminderCard(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 22, 18, 10),
              child: Text(
                'Mis recordatorios',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.textDark),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: MoreMockData.reminders.length,
            itemBuilder: (context, index) {
              final item = MoreMockData.reminders[index];
              return Padding(
                padding: EdgeInsets.fromLTRB(18, index == 0 ? 0 : 6, 18, 12),
                child: _ReminderCard(
                  item: item,
                  enabled: _enabled[index],
                  onChanged: (value) => setState(() => _enabled[index] = value),
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 36),
              child: PrimaryButton(
                text: 'Guardar cambios',
                icon: Icons.save_rounded,
                gradientColors: const [AppColors.orange, AppColors.pink],
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recordatorios guardados visualmente')),
                  );
                },
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
        bottom: 30,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.orange, AppColors.pink]),
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
                  'Recordatorios',
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 7),
                Text(
                  'Configura alertas para cuidar tu bienestar emocional.',
                  style: TextStyle(color: Color(0xFFFFEDD5), fontSize: 14, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainReminderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.purple, AppColors.pink]),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 31),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Próximo recordatorio', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800)),
                SizedBox(height: 5),
                Text('Registro emocional', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
                SizedBox(height: 3),
                Text('Hoy · 8:00 PM', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.item, required this.enabled, required this.onChanged});

  final ReminderItem item;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(color: item.color.withOpacity(.14), borderRadius: BorderRadius.circular(18)),
            child: Icon(item.icon, color: item.color, size: 29),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                const SizedBox(height: 3),
                Text(item.subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(item.time, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.days, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeColor: item.color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
