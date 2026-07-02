import 'package:go_router/go_router.dart';
import '../screens/main_shell.dart';
import '../screens/symptoms/symptom_list_screen.dart';
import '../screens/symptoms/add_symptom_screen.dart';
import '../screens/symptoms/symptom_detail_screen.dart';
import '../screens/logs/log_dashboard_screen.dart';
import '../screens/logs/add_diet_screen.dart';
import '../screens/logs/add_sleep_screen.dart';
import '../screens/logs/add_stress_screen.dart';
import '../screens/analysis/analysis_screen.dart';
import '../screens/community/community_list_screen.dart';
import '../screens/knowledge/knowledge_list_screen.dart';
import '../screens/knowledge/questionnaire_screen.dart';
import '../screens/export/export_report_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/profile_screen.dart';
import '../screens/login_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        // Tab 1: 症状
        GoRoute(
          path: '/symptoms',
          builder: (context, state) => const SymptomListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddSymptomScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  SymptomDetailScreen(symptomId: state.pathParameters['id']!),
            ),
          ],
        ),
        // Tab 2: 日志
        GoRoute(
          path: '/logs',
          builder: (context, state) => const LogDashboardScreen(),
          routes: [
            GoRoute(
              path: 'diet/add',
              builder: (context, state) => const AddDietScreen(),
            ),
            GoRoute(
              path: 'sleep/add',
              builder: (context, state) => const AddSleepScreen(),
            ),
            GoRoute(
              path: 'stress/add',
              builder: (context, state) => const AddStressScreen(),
            ),
          ],
        ),
        // Tab 3: AI 分析
        GoRoute(
          path: '/analysis',
          builder: (context, state) => const AnalysisScreen(),
        ),
        // Tab 4: 社区
        GoRoute(
          path: '/community',
          builder: (context, state) => const CommunityListScreen(),
        ),
        // Tab 5: 知识库
        GoRoute(
          path: '/knowledge',
          builder: (context, state) => const KnowledgeListScreen(),
          routes: [
            GoRoute(
              path: 'self-check/:id',
              builder: (context, state) => QuestionnaireScreen(
                questionnaireId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    // 独立页面（无底部导航）
    GoRoute(
      path: '/export',
      builder: (context, state) => const ExportReportScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
