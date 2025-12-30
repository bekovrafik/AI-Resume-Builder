import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/features/profile/providers/profile_provider.dart';
import 'package:mobile_app/core/providers/theme_provider.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/builder')) return 1;
    if (location.startsWith('/market')) return 2;
    if (location.startsWith('/preview')) return 3; // Future route
    if (location == '/') return 0;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        // For now, assuming builder/resume-editor is a main tab or navigating to a list
        // context.go('/builder/MASTER_PROFILE'); // Default or list
        // Actually, React "Build" is "BlueprintDraft".
        // We will map it to existing ResumeEditor for now.
        context.go('/builder/MASTER_PROFILE');
        break;
      case 2:
        context.go('/market');
        break;
      case 3:
        // context.go('/preview'); // Need to create this route
        context.go('/vault'); // Temporarily map to Vault or a placeholder
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      extendBody: true, // For glass effect behind navbar
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.description, color: AppColors.strategicGold),
            const SizedBox(width: 8),
            Text("AI RESUME BUILDER",
                style: AppTypography.header3
                    .copyWith(fontSize: 14, letterSpacing: 2)),
          ],
        ),
        centerTitle: false,
        backgroundColor: isDark
            ? AppColors.midnightNavy.withOpacity(0.8)
            : Colors.white.withOpacity(0.8),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? AppColors.strategicGold : Colors.grey),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: child,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(30),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, "Dash", Icons.dashboard_outlined),
              _buildNavItem(context, 1, "Build", Icons.construction_outlined),
              _buildNavItem(context, 2, "Market", Icons.radar),
              _buildNavItem(context, 3, "Preview", Icons.description_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, int index, String label, IconData icon) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isSelected = selectedIndex == index;
    final color = isSelected ? AppColors.strategicGold : Colors.grey;

    return InkWell(
      onTap: () => _onItemTapped(index, context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label,
              style:
                  AppTypography.labelSmall.copyWith(color: color, fontSize: 8)),
        ],
      ),
    );
  }
}
