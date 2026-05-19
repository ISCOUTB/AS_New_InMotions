import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/resource_model.dart';
import '../../../../core/utils/resource_visuals.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../data/repositories/resource_repository.dart';

class ArticleDetailPage extends StatefulWidget {
  const ArticleDetailPage({super.key});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  final ResourceRepository _repository = ResourceRepository();
  bool _isFavorite = false;
  ResourceModel? _resource;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ResourceModel && _resource == null) {
      _resource = args;
      _loadFavorite(args.id);
    }
  }

  Future<void> _loadFavorite(String id) async {
    final favoriteIds = await _repository.getFavoriteIds();
    if (!mounted) return;
    setState(() => _isFavorite = favoriteIds.contains(id));
  }

  Future<void> _toggleFavorite() async {
    final resource = _resource;
    if (resource == null) return;
    final favorite = await _repository.toggleFavorite(resource.id);
    if (!mounted) return;
    setState(() => _isFavorite = favorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(favorite ? 'Recurso guardado en favoritos' : 'Recurso eliminado de favoritos')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resource = _resource;

    if (resource == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_outlined, color: AppColors.primary, size: 42),
                const SizedBox(height: 12),
                const Text('No se pudo abrir este recurso.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 18),
                PrimaryButton(text: 'Volver', icon: Icons.arrow_back_rounded, onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(resource: resource, isFavorite: _isFavorite, onFavorite: _toggleFavorite)),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: _ResourceMetaCard(resource: resource),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: _ValidationCard(resource: resource),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: AppCard(
                child: Text(
                  resource.content,
                  style: const TextStyle(color: AppColors.textDark, fontSize: 15, height: 1.55),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 32),
              child: AppCard(
                child: Text(
                  'Descargo de responsabilidad: los recursos de esta biblioteca son herramientas de apoyo y psicoeducación. No constituyen tratamiento psicológico ni sustituyen una evaluación profesional. Si experimentas malestar persistente, contacta a Psicología UTB.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13.5, height: 1.45),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.resource, required this.isFavorite, required this.onFavorite});

  final ResourceModel resource;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final color = ResourceVisuals.colorForLevel(resource.level);

    return Container(
      padding: EdgeInsets.fromLTRB(8, MediaQuery.of(context).padding.top + 8, 18, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.72)]),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _WhiteChip(text: resource.level),
                    _WhiteChip(text: resource.format),
                  ],
                ),
                const SizedBox(height: 10),
                Text(resource.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1.12)),
                const SizedBox(height: 8),
                Text(resource.thematic, style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          IconButton(
            onPressed: onFavorite,
            icon: Icon(isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _WhiteChip extends StatelessWidget {
  const _WhiteChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(30)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
    );
  }
}

class _ResourceMetaCard extends StatelessWidget {
  const _ResourceMetaCard({required this.resource});

  final ResourceModel resource;

  @override
  Widget build(BuildContext context) {
    final color = ResourceVisuals.colorForLevel(resource.level);
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
            child: Icon(ResourceVisuals.iconForFormat(resource.format), color: color, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(resource.description, style: const TextStyle(color: AppColors.textDark, fontSize: 14.5, height: 1.35)),
          ),
        ],
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  const _ValidationCard({required this.resource});

  final ResourceModel resource;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Validación y fuente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark)),
          const SizedBox(height: 10),
          Text(resource.validation, style: const TextStyle(color: AppColors.textDark, height: 1.4)),
          if (resource.author != null) ...[
            const SizedBox(height: 8),
            Text('Autor / referencia: ${resource.author}', style: const TextStyle(color: AppColors.textMuted, fontSize: 13.5)),
          ],
          if (resource.isInstitutional) ...[
            const SizedBox(height: 8),
            const Text('Recurso institucional UTB', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
          ],
        ],
      ),
    );
  }
}
