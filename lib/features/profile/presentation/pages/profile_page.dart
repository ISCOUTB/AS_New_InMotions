import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(onBack: () => Navigator.pop(context))),
              const SliverToBoxAdapter(child: _ProfileInfoCard()),
              const SliverToBoxAdapter(child: _StatsRow()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _MenuTile(
                          icon: Icons.notifications_rounded,
                          color: AppColors.orange,
                          title: 'Recordatorios',
                          subtitle: 'Gestionar notificaciones',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.reminders),
                        ),
                        const _DividerLine(),
                        _MenuTile(
                          icon: Icons.lock_rounded,
                          color: AppColors.primary,
                          title: 'Privacidad y seguridad',
                          subtitle: 'Opciones de cuenta',
                          onTap: () {},
                        ),
                        const _DividerLine(),
                        _MenuTile(
                          icon: Icons.help_outline_rounded,
                          color: AppColors.purple,
                          title: 'Ayuda y soporte',
                          subtitle: 'Canales de orientación',
                          onTap: () {},
                        ),
                        const _DividerLine(),
                        _MenuTile(
                          icon: Icons.logout_rounded,
                          color: AppColors.red,
                          title: 'Cerrar sesión',
                          subtitle: 'Volver a la pantalla de bienvenida',
                          onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (_) => false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 108)),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavigation(currentRoute: AppRoutes.profile),
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
        bottom: 78,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Perfil',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -54),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: AppCard(
          child: Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.purple]),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 54),
              ),
              const SizedBox(height: 14),
              const Text(
                'Estudiante UTB',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark),
              ),
              const SizedBox(height: 4),
              const Text('estudiante@utb.edu.co', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Cuenta institucional activa',
                  style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -34),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            Expanded(child: _StatCard(value: '12', label: 'registros', icon: Icons.favorite_rounded, color: AppColors.pink)),
            SizedBox(width: 10),
            Expanded(child: _StatCard(value: '3', label: 'triajes', icon: Icons.psychology_rounded, color: AppColors.purple)),
            SizedBox(width: 10),
            Expanded(child: _StatCard(value: '8', label: 'artículos', icon: Icons.menu_book_rounded, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.icon, required this.color});

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 7),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: Colors.grey.shade200, indent: 76);
  }
}
