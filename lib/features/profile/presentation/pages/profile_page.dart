import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/local_profile_image_storage.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/mood_repository.dart';
import '../../../../data/repositories/resource_repository.dart';
import '../../../../data/repositories/triage_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthRepository _authRepository = AuthRepository();
  final MoodRepository _moodRepository = MoodRepository();
  final TriageRepository _triageRepository = TriageRepository();
  final ResourceRepository _resourceRepository = ResourceRepository();
  final LocalProfileImageStorage _profileImageStorage = LocalProfileImageStorage();

  late Future<_ProfileData> _profileFuture;
  bool _isUpdatingImage = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<_ProfileData> _loadProfile() async {
    final user = await _authRepository.getCurrentUser();
    final moodHistory = await _moodRepository.getMoodHistory();
    final triageResults = await _triageRepository.getMyResults();
    final favoriteResources = await _resourceRepository.getFavoriteIds();

    return _ProfileData(
      user: user,
      moodCount: moodHistory.length,
      triageCount: triageResults.length,
      favoriteCount: favoriteResources.length,
    );
  }

  void _reload() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  void _showPrivacySheet() {
    _showInfoSheet(
      title: 'Privacidad y seguridad',
      icon: Icons.lock_rounded,
      color: AppColors.primary,
      content: const [
        'Por ahora la app guarda la sesión, registros emocionales, resultados de triaje, favoritos y recordatorios de forma local en el dispositivo.',
        'Cuando se conecte el backend, cada petición privada deberá usar token de sesión y conexión segura por HTTPS.',
        'El triaje no reemplaza atención psicológica profesional. En resultados de riesgo alto o crítico se deben mostrar recursos de ayuda y contacto institucional.',
      ],
    );
  }

  void _showSupportSheet() {
    _showInfoSheet(
      title: 'Ayuda y soporte',
      icon: Icons.support_agent_rounded,
      color: AppColors.purple,
      content: const [
        'Psicología UTB: bienestar@utb.edu.co',
        'Línea 192: orientación nacional en salud mental.',
        'Línea 123: emergencias generales si existe peligro inmediato.',
        'Campus UTB: Bienestar Universitario – Área de Psicología.',
      ],
    );
  }

  void _showInfoSheet({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> content,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(16)),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...content.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Icon(Icons.circle, size: 7, color: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(item, style: const TextStyle(color: AppColors.textDark, fontSize: 14.5, height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _changeProfileImage() async {
    final currentUser = await _authRepository.getCurrentUser();
    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para actualizar tu foto de perfil.')),
      );
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _isUpdatingImage = true);

      final pickedFile = result.files.single;
      final bytes = pickedFile.bytes ?? (pickedFile.path == null ? null : await File(pickedFile.path!).readAsBytes());

      if (bytes == null) {
        throw Exception('No se pudo leer la imagen seleccionada.');
      }

      final imagePath = await _profileImageStorage.saveProfileImage(
        userId: currentUser.id,
        originalFileName: pickedFile.name,
        bytes: bytes,
      );

      final updatedUser = currentUser.copyWith(profileImagePath: imagePath);
      await _authRepository.updateCurrentUser(updatedUser);

      if (!mounted) return;
      setState(() {
        _isUpdatingImage = false;
        _profileFuture = _loadProfile();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isUpdatingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la imagen: $error')),
      );
    }
  }

  Future<void> _logout() async {
    await _authRepository.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async => _reload(),
            child: FutureBuilder<_ProfileData>(
              future: _profileFuture,
              builder: (context, snapshot) {
                final data = snapshot.data ?? const _ProfileData.empty();

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _Header(onBack: () => Navigator.pop(context))),
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),
                    SliverToBoxAdapter(
                      child: _ProfileInfoCard(
                        user: data.user,
                        isUpdatingImage: _isUpdatingImage,
                        onChangeImage: _changeProfileImage,
                      ),
                    ),
                    SliverToBoxAdapter(child: _StatsRow(data: data)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                        child: AppCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _MenuTile(
                                icon: Icons.notifications_rounded,
                                color: AppColors.orange,
                                title: 'Recordatorios',
                                subtitle: 'Gestionar momentos de autocuidado',
                                onTap: () => Navigator.pushNamed(context, AppRoutes.reminders).then((_) => _reload()),
                              ),
                              const _DividerLine(),
                              _MenuTile(
                                icon: Icons.lock_rounded,
                                color: AppColors.primary,
                                title: 'Privacidad y seguridad',
                                subtitle: 'Ver manejo local de datos y sesión',
                                onTap: _showPrivacySheet,
                              ),
                              const _DividerLine(),
                              _MenuTile(
                                icon: Icons.help_outline_rounded,
                                color: AppColors.purple,
                                title: 'Ayuda y soporte',
                                subtitle: 'Canales de orientación y emergencia',
                                onTap: _showSupportSheet,
                              ),
                              const _DividerLine(),
                              _MenuTile(
                                icon: Icons.logout_rounded,
                                color: AppColors.red,
                                title: 'Cerrar sesión',
                                subtitle: 'Volver a la pantalla de bienvenida',
                                onTap: _logout,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 108)),
                  ],
                );
              },
            ),
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

class _ProfileData {
  const _ProfileData({
    required this.user,
    required this.moodCount,
    required this.triageCount,
    required this.favoriteCount,
  });

  const _ProfileData.empty()
      : user = null,
        moodCount = 0,
        triageCount = 0,
        favoriteCount = 0;

  final UserModel? user;
  final int moodCount;
  final int triageCount;
  final int favoriteCount;
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
        bottom: 22,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Perfil',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 3),
                Text(
                  'Cuenta y configuración',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFDBEAFE), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({
    required this.user,
    required this.isUpdatingImage,
    required this.onChangeImage,
  });

  final UserModel? user;
  final bool isUpdatingImage;
  final VoidCallback onChangeImage;

  @override
  Widget build(BuildContext context) {
    final imagePath = user?.profileImagePath;
    final hasImage = imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: AppCard(
        child: Column(
          children: [
            GestureDetector(
              onTap: isUpdatingImage ? null : onChangeImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: hasImage ? null : const LinearGradient(colors: [AppColors.primary, AppColors.purple]),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: hasImage
                          ? Image.file(
                              File(imagePath),
                              width: 92,
                              height: 92,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.person_rounded, color: Colors.white, size: 52),
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: isUpdatingImage
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 17),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: isUpdatingImage ? null : onChangeImage,
              icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
              label: Text(hasImage ? 'Cambiar foto de perfil' : 'Añadir foto de perfil'),
            ),
            const SizedBox(height: 6),
            Text(
              user?.fullName ?? 'Estudiante UTB',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'estudiante@utb.edu.co',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            const Text(
              'Perfil local del estudiante',
              style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data});

  final _ProfileData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: Row(
        children: [
          Expanded(child: _StatCard(value: data.moodCount.toString(), label: 'registros', icon: Icons.favorite_rounded, color: AppColors.pink)),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(value: data.triageCount.toString(), label: 'triajes', icon: Icons.psychology_rounded, color: AppColors.purple)),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(value: data.favoriteCount.toString(), label: 'favoritos', icon: Icons.bookmark_rounded, color: AppColors.primary)),
        ],
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
