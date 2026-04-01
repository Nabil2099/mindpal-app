import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:mindpal_app/features/chat/presentation/chat_screen.dart';
import 'package:mindpal_app/features/insights/presentation/insights_screen.dart';
import 'package:mindpal_app/features/recommendations/presentation/recommendations_screen.dart';
import 'package:mindpal_app/features/settings/presentation/settings_screen.dart';
import 'package:mindpal_app/theme.dart';

final router = GoRouter(
  initialLocation: '/chat',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/chat', builder: (c, s) => const ChatScreen()),
        GoRoute(path: '/insights', builder: (c, s) => const InsightsScreen()),
        GoRoute(
          path: '/recommendations',
          builder: (c, s) => const RecommendationsScreen(),
        ),
        GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      ],
    ),
  ],
);

class MainShell extends StatelessWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final destinations = [
      '/chat',
      '/insights',
      '/recommendations',
      '/settings',
    ];
    final selectedIndex = destinations.indexOf(currentPath).clamp(0, 3);

    return Scaffold(
      body: child,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: ColoredBox(
            color: MindPalColors.sand50.withValues(alpha: 0.88),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.chat_bubble_outline,
                      label: 'Chat',
                      active: selectedIndex == 0,
                      onTap: () => context.go(destinations[0]),
                    ),
                    _NavItem(
                      icon: Icons.analytics_outlined,
                      label: 'Insights',
                      active: selectedIndex == 1,
                      onTap: () => context.go(destinations[1]),
                    ),
                    _NavItem(
                      icon: Icons.auto_awesome_outlined,
                      label: 'Today',
                      active: selectedIndex == 2,
                      onTap: () => context.go(destinations[2]),
                    ),
                    _NavItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      active: selectedIndex == 3,
                      onTap: () => context.go(destinations[3]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? MindPalColors.ink900 : MindPalColors.ink700;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: active ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color:
              active
                  ? MindPalColors.sage100.withValues(alpha: 0.85)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
