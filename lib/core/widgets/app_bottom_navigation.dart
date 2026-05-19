import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../routes/app_routes.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({super.key, required this.currentRoute});

  final String currentRoute;

  void _go(BuildContext context, String route) {
    if (route == currentRoute) return;
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Inicio',
            selected: currentRoute == AppRoutes.dashboard,
            onTap: () => _go(context, AppRoutes.dashboard),
          ),
          _NavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Historial',
            selected: currentRoute == AppRoutes.history,
            onTap: () => _go(context, AppRoutes.history),
          ),
          _NavItem(
            icon: Icons.psychology_rounded,
            label: 'Triaje',
            selected: currentRoute == AppRoutes.triage,
            onTap: () => _go(context, AppRoutes.triage),
          ),
          _NavItem(
            icon: Icons.menu_book_rounded,
            label: 'Artículos',
            selected: currentRoute == AppRoutes.articles,
            onTap: () => _go(context, AppRoutes.articles),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Perfil',
            selected: currentRoute == AppRoutes.profile,
            onTap: () => _go(context, AppRoutes.profile),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

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
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
