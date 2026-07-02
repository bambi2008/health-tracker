import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/symptoms')) return 0;
    if (loc.startsWith('/logs')) return 1;
    if (loc.startsWith('/analysis')) return 2;
    if (loc.startsWith('/community')) return 3;
    if (loc.startsWith('/knowledge')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          if (i == index) return;
          switch (i) {
            case 0:
              context.go('/symptoms');
              break;
            case 1:
              context.go('/logs');
              break;
            case 2:
              context.go('/analysis');
              break;
            case 3:
              context.go('/community');
              break;
            case 4:
              context.go('/knowledge');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.healing_outlined),
            selectedIcon: Icon(Icons.healing),
            label: '症状',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '日志',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: '分析',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: '社区',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: '知识库',
          ),
        ],
      ),
    );
  }
}
