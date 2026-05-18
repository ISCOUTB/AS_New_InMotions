import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/articles/presentation/pages/article_detail_page.dart';
import 'features/articles/presentation/pages/articles_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/history/presentation/pages/history_page.dart';
import 'features/mood_log/presentation/pages/mood_log_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/reminders/presentation/pages/reminders_page.dart';
import 'features/triage/presentation/pages/triage_page.dart';
import 'features/triage/presentation/pages/triage_result_page.dart';
import 'features/welcome/presentation/pages/welcome_page.dart';

class InMotionsApp extends StatelessWidget {
  const InMotionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InMotions',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.welcome,
      routes: {
        AppRoutes.welcome: (_) => const WelcomePage(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),
        AppRoutes.dashboard: (_) => const DashboardPage(),
        AppRoutes.moodLog: (_) => const MoodLogPage(),
        AppRoutes.history: (_) => const HistoryPage(),
        AppRoutes.triage: (_) => const TriagePage(),
        AppRoutes.triageResult: (_) => const TriageResultPage(),
        AppRoutes.articles: (_) => const ArticlesPage(),
        AppRoutes.articleDetail: (_) => const ArticleDetailPage(),
        AppRoutes.reminders: (_) => const RemindersPage(),
        AppRoutes.profile: (_) => const ProfilePage(),
      },
    );
  }
}
