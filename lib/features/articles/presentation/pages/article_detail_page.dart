import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/mock/mock_data.dart';

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final ArticleItem article = args is ArticleItem ? args : MoreMockData.articles.first;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(article: article)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
              child: _ArticleMetaCard(article: article),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
              child: AppCard(
                child: Text(
                  article.content,
                  style: const TextStyle(color: AppColors.textDark, fontSize: 15, height: 1.55),
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
  const _Header({required this.article});

  final ArticleItem article;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, MediaQuery.of(context).padding.top + 12, 18, 34),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [article.color, article.color.withOpacity(.72)]),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(30)),
                  child: Text(article.category, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 14),
                Text(
                  article.title,
                  style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900, height: 1.12),
                ),
                const SizedBox(height: 8),
                Text(article.readTime, style: TextStyle(color: Colors.white.withOpacity(.85), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleMetaCard extends StatelessWidget {
  const _ArticleMetaCard({required this.article});

  final ArticleItem article;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: article.color.withOpacity(.14), borderRadius: BorderRadius.circular(20)),
            child: Icon(article.icon, color: article.color, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              article.description,
              style: const TextStyle(color: AppColors.textDark, fontSize: 14.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
