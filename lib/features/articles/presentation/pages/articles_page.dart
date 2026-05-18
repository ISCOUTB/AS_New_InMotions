import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/mock/mock_data.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  String _selectedCategory = 'Todos';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _categories => [
        'Todos',
        ...MoreMockData.articles.map((item) => item.category).toSet(),
      ];

  List<ArticleItem> get _filteredArticles {
    final query = _searchController.text.trim().toLowerCase();
    return MoreMockData.articles.where((article) {
      final matchesCategory = _selectedCategory == 'Todos' || article.category == _selectedCategory;
      final matchesSearch = query.isEmpty ||
          article.title.toLowerCase().contains(query) ||
          article.description.toLowerCase().contains(query) ||
          article.category.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(onBack: () => Navigator.pop(context))),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
                  child: _SearchBox(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 54,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final selected = category == _selectedCategory;
                      return ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        onSelected: (_) => setState(() => _selectedCategory = category),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: _categories.length,
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: _filteredArticles.length,
                itemBuilder: (context, index) {
                  final article = _filteredArticles[index];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(18, index == 0 ? 18 : 6, 18, 12),
                    child: _ArticleCard(
                      article: article,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.articleDetail,
                        arguments: article,
                      ),
                    ),
                  );
                },
              ),
              if (_filteredArticles.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(
                      child: Text('No se encontraron artículos con esos filtros.'),
                    ),
                  ),
                ),
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
                SizedBox(height: 6),
                Text(
                  'Artículos Educativos',
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 7),
                Text(
                  'Recursos de bienestar emocional validados para estudiantes.',
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
        hintText: 'Buscar artículos...',
        prefixIcon: Icon(Icons.search_rounded),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article, required this.onTap});

  final ArticleItem article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
              decoration: BoxDecoration(
                color: article.color.withOpacity(.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(article.icon, color: article.color, size: 32),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: article.color.withOpacity(.11),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          article.category,
                          style: TextStyle(color: article.color, fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Spacer(),
                      Text(article.readTime, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    article.title,
                    style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900, color: AppColors.textDark, height: 1.18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.25),
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
