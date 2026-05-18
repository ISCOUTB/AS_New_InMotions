import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../data/mock/mock_data.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header()),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: _QuickActionsCard(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: _WeekSummaryCard()),
              const SliverToBoxAdapter(child: _ReminderCard()),
              const SliverToBoxAdapter(child: _RecommendedArticles()),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: AppBottomNavigation(currentRoute: AppRoutes.dashboard)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 18,
        right: 18,
        bottom: 46,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hola, bienvenida', style: TextStyle(color: Color(0xFFDBEAFE), fontSize: 14)),
                SizedBox(height: 6),
                Text(
                  '¿Cómo te sientes hoy?',
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
                ),
              ],
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

class _WeekSummaryCard extends StatelessWidget {
  const _WeekSummaryCard();

  @override
  Widget build(BuildContext context) {
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
              children: MockData.weekMoods.map((item) {
                return Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color, size: 24),
                    ),
                    const SizedBox(height: 7),
                    Text(item.day, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
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
              child: const Row(
                children: [
                  Icon(Icons.trending_up_rounded, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '¡Buen progreso! ', style: TextStyle(fontWeight: FontWeight.w800)),
                          TextSpan(text: 'Has registrado 5 días esta semana'),
                        ],
                      ),
                      style: TextStyle(color: AppColors.primaryDark, fontSize: 13.5, height: 1.25),
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
              'Meditación diaria',
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

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded, label: 'Inicio', selected: true, onTap: () {}),
          _NavItem(icon: Icons.favorite_border_rounded, label: 'Registro', onTap: () => Navigator.pushNamed(context, AppRoutes.moodLog)),
          _NavItem(icon: Icons.menu_book_rounded, label: 'Artículos', onTap: () => Navigator.pushNamed(context, AppRoutes.articles)),
          _NavItem(icon: Icons.person_outline_rounded, label: 'Perfil', onTap: () => Navigator.pushNamed(context, AppRoutes.profile)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.onTap, this.selected = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? AppColors.primary : Colors.grey.shade500;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: selected ? FontWeight.w800 : FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
