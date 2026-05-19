import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/resource_model.dart';
import '../../../../core/models/triage_result_model.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/resource_visuals.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../data/repositories/resource_repository.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final ResourceRepository _repository = ResourceRepository();
  final TextEditingController _searchController = TextEditingController();

  List<ResourceModel> _resources = [];
  List<ResourceModel> _recommendedResources = [];
  Set<String> _favoriteIds = {};
  TriageResultModel? _latestResult;
  String _selectedThematic = 'Todos';
  String _selectedFormat = 'Todos';
  String _selectedLevel = 'Todos';
  bool _favoritesOnly = false;
  bool _isLoading = true;
  bool _hasRestrictedAccessAcknowledgement = false;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadResources() async {
    final resources = await _repository.searchResources();
    final recommended = await _repository.getRecommendedResources();
    final favorites = await _repository.getFavoriteIds();
    final latest = await _repository.getLatestTriageResult();
    final acknowledged = await _repository.hasRestrictedAccessAcknowledgement();
    if (!mounted) return;
    setState(() {
      _resources = resources;
      _recommendedResources = recommended;
      _favoriteIds = favorites;
      _latestResult = latest;
      _hasRestrictedAccessAcknowledgement = acknowledged;
      _isLoading = false;
    });
  }

  Future<void> _applyFilters() async {
    final resources = await _repository.searchResources(
      query: _searchController.text,
      thematic: _selectedThematic,
      format: _selectedFormat,
      level: _selectedLevel,
      favoritesOnly: _favoritesOnly,
    );
    final favorites = await _repository.getFavoriteIds();
    if (!mounted) return;
    setState(() {
      _resources = resources;
      _favoriteIds = favorites;
    });
  }

  Future<void> _toggleFavorite(ResourceModel resource) async {
    final isFavorite = await _repository.toggleFavorite(resource.id);
    await _applyFilters();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isFavorite ? 'Recurso guardado en favoritos' : 'Recurso eliminado de favoritos')),
    );
  }

  Future<void> _acknowledgeRestrictedAccess() async {
    await _repository.acknowledgeRestrictedAccess();
    if (!mounted) return;
    setState(() => _hasRestrictedAccessAcknowledgement = true);
  }

  bool get _mustShowRestrictedGate {
    final level = _latestResult?.riskLevel;
    return !_hasRestrictedAccessAcknowledgement && (level == RiskLevel.red || level == RiskLevel.critical);
  }

  List<String> get _thematics => _repository.getThematics();
  List<String> get _formats => _repository.getFormats();
  List<String> get _levels => _repository.getLevels();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(onBack: () => Navigator.pop(context))),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              if (_mustShowRestrictedGate)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    child: _RestrictedAccessCard(onContinue: _acknowledgeRestrictedAccess),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    child: _TriageRecommendationNotice(latestResult: _latestResult),
                  ),
                ),
                if (_recommendedResources.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                      child: _RecommendedSection(
                        resources: _recommendedResources,
                        favoriteIds: _favoriteIds,
                        onOpen: _openResource,
                        onFavorite: _toggleFavorite,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                    child: _SearchBox(
                      controller: _searchController,
                      onChanged: (_) => _applyFilters(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    child: _FilterWrap(
                      title: 'Temática',
                      options: _thematics,
                      selected: _selectedThematic,
                      onSelected: (value) {
                        setState(() => _selectedThematic = value);
                        _applyFilters();
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                    child: _CompactFilters(
                      selectedFormat: _selectedFormat,
                      selectedLevel: _selectedLevel,
                      favoritesOnly: _favoritesOnly,
                      formats: _formats,
                      levels: _levels,
                      onFormatChanged: (value) {
                        setState(() => _selectedFormat = value);
                        _applyFilters();
                      },
                      onLevelChanged: (value) {
                        setState(() => _selectedLevel = value);
                        _applyFilters();
                      },
                      onFavoritesChanged: (value) {
                        setState(() => _favoritesOnly = value);
                        _applyFilters();
                      },
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: _resources.length,
                  itemBuilder: (context, index) {
                    final resource = _resources[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(18, index == 0 ? 18 : 6, 18, 12),
                      child: _ResourceCard(
                        resource: resource,
                        isFavorite: _favoriteIds.contains(resource.id),
                        onTap: () => _openResource(resource),
                        onFavorite: () => _toggleFavorite(resource),
                      ),
                    );
                  },
                ),
                if (_resources.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(child: Text('No se encontraron recursos con esos filtros.')),
                    ),
                  ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 106)),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavigation(currentRoute: AppRoutes.articles),
          ),
        ],
      ),
    );
  }

  void _openResource(ResourceModel resource) {
    Navigator.pushNamed(context, AppRoutes.articleDetail, arguments: resource).then((_) => _applyFilters());
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
        bottom: 38,
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
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 2),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                Text(
                  'Biblioteca de Recursos',
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 7),
                Text(
                  'Recursos de psicoeducación, autocuidado y apoyo institucional.',
                  style: TextStyle(color: Color(0xFFDBEAFE), fontSize: 14, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TriageRecommendationNotice extends StatelessWidget {
  const _TriageRecommendationNotice({required this.latestResult});

  final TriageResultModel? latestResult;

  @override
  Widget build(BuildContext context) {
    final levelText = latestResult?.riskLevel.label ?? 'sin triaje reciente';
    final message = latestResult == null
        ? 'Realiza el triaje para recibir recomendaciones más ajustadas a tu estado actual.'
        : 'Recursos priorizados según tu último resultado: nivel $levelText.';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.textDark, fontSize: 13.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestrictedAccessCard extends StatelessWidget {
  const _RestrictedAccessCard({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.emergency_share_rounded, color: AppColors.red, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Antes de explorar la biblioteca',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Tu último resultado indica que primero debes visualizar los contactos de emergencia y la derivación a Psicología UTB. Los recursos de la biblioteca son complementarios y no sustituyen apoyo profesional.',
            style: TextStyle(color: AppColors.textDark, height: 1.45),
          ),
          const SizedBox(height: 14),
          const Text('Línea 192 · Salud Mental Colombia 24/7\nLínea 123 · Emergencias\nPsicología UTB · bienestar@utb.edu.co', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w800, height: 1.5)),
          const SizedBox(height: 18),
          PrimaryButton(
            text: 'Ya visualicé los recursos de ayuda',
            icon: Icons.check_rounded,
            gradientColors: const [AppColors.red, AppColors.orange],
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection({
    required this.resources,
    required this.favoriteIds,
    required this.onOpen,
    required this.onFavorite,
  });

  final List<ResourceModel> resources;
  final Set<String> favoriteIds;
  final ValueChanged<ResourceModel> onOpen;
  final ValueChanged<ResourceModel> onFavorite;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recomendados para ti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ...resources.map((resource) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MiniResourceTile(
                resource: resource,
                isFavorite: favoriteIds.contains(resource.id),
                onTap: () => onOpen(resource),
                onFavorite: () => onFavorite(resource),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: 'Buscar recursos...',
        prefixIcon: Icon(Icons.search_rounded),
      ),
    );
  }
}

class _FilterWrap extends StatelessWidget {
  const _FilterWrap({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark)),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option == selected;
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.w800),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                showCheckmark: false,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                onSelected: (_) => onSelected(option),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CompactFilters extends StatelessWidget {
  const _CompactFilters({
    required this.selectedFormat,
    required this.selectedLevel,
    required this.favoritesOnly,
    required this.formats,
    required this.levels,
    required this.onFormatChanged,
    required this.onLevelChanged,
    required this.onFavoritesChanged,
  });

  final String selectedFormat;
  final String selectedLevel;
  final bool favoritesOnly;
  final List<String> formats;
  final List<String> levels;
  final ValueChanged<String> onFormatChanged;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<bool> onFavoritesChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallWidth = constraints.maxWidth < 390;

        final formatDropdown = _DropdownFilter(
          label: 'Formato',
          value: selectedFormat,
          values: formats,
          onChanged: onFormatChanged,
        );

        final levelDropdown = _DropdownFilter(
          label: 'Nivel',
          value: selectedLevel,
          values: levels,
          onChanged: onLevelChanged,
        );

        return Column(
          children: [
            if (isSmallWidth)
              Column(
                children: [
                  formatDropdown,
                  const SizedBox(height: 10),
                  levelDropdown,
                ],
              )
            else
              Row(
                children: [
                  Expanded(child: formatDropdown),
                  const SizedBox(width: 10),
                  Expanded(child: levelDropdown),
                ],
              ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: favoritesOnly,
              onChanged: onFavoritesChanged,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Mostrar solo favoritos',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              activeColor: AppColors.primary,
            ),
          ],
        );
      },
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ).copyWith(labelText: label),
      selectedItemBuilder: (context) {
        return values.map((item) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          );
        }).toList();
      },
      items: values.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.resource, required this.isFavorite, required this.onTap, required this.onFavorite});

  final ResourceModel resource;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final color = ResourceVisuals.colorForLevel(resource.level);
    final icon = ResourceVisuals.iconForFormat(resource.format);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(color: color.withOpacity(.14), borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _LevelChip(level: resource.level),
                      const SizedBox(width: 6),
                      Expanded(child: Text(resource.format, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(resource.title, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                  const SizedBox(height: 5),
                  Text(resource.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 13.5, height: 1.35)),
                  const SizedBox(height: 8),
                  Text(resource.thematic, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            IconButton(
              onPressed: onFavorite,
              icon: Icon(isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: isFavorite ? color : AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniResourceTile extends StatelessWidget {
  const _MiniResourceTile({required this.resource, required this.isFavorite, required this.onTap, required this.onFavorite});

  final ResourceModel resource;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final color = ResourceVisuals.colorForLevel(resource.level);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(.12))),
        child: Row(
          children: [
            Icon(ResourceVisuals.iconForFormat(resource.format), color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resource.title, style: const TextStyle(fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${resource.thematic} · ${resource.level}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onFavorite,
              icon: Icon(isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: isFavorite ? color : AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    final color = ResourceVisuals.colorForLevel(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(30)),
      child: Text(level, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w900)),
    );
  }
}
