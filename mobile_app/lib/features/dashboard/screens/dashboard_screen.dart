import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/features/profile/providers/profile_provider.dart';
import 'package:mobile_app/shared/widgets/banner_ad_widget.dart';
import 'package:mobile_app/features/auth/services/auth_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final profileData = profileAsync.value;
    final fullName = profileData?.fullName?.isNotEmpty == true
        ? profileData!.fullName
        : 'Career Architect';
    final targetRole = profileData?.targetRole?.isNotEmpty == true
        ? profileData!.targetRole
        : 'Identity Not Synced';

    // Calculate simple progress (approximate based on filled fields if possible, else dummy)
    final progress = (profileData?.fullName?.isNotEmpty == true ? 20 : 0) +
        (profileData?.targetRole?.isNotEmpty == true ? 20 : 0) +
        (profileData?.email?.isNotEmpty == true ? 20 : 0) +
        (profileData?.experiences?.isNotEmpty == true ? 20 : 0) +
        (profileData?.skills?.isNotEmpty == true ? 20 : 0);

    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              GlassContainer(
                padding: const EdgeInsets.all(24),
                borderRadius: BorderRadius.circular(40),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.midnightNavy.withOpacity(0.1),
                        border: Border.all(
                            color: AppColors.strategicGold.withOpacity(0.3),
                            width: 2),
                      ),
                      child: profileData?.avatarUrl != null
                          ? ClipOval(
                              child: Image.network(profileData!
                                  .avatarUrl!)) // Placeholder for network image logic
                          : const Icon(Icons.person,
                              size: 40, color: Colors.grey),
                    ),
                    const SizedBox(width: 20),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fullName!,
                              style: AppTypography.header3
                                  .copyWith(color: AppColors.midnightNavy)),
                          const SizedBox(height: 4),
                          Text(targetRole!,
                              style: AppTypography.labelSmall.copyWith(
                                  color: Colors.grey, letterSpacing: 1.5)),
                          const SizedBox(height: 12),
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              backgroundColor: Colors.black12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.strategicGold),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Settings Section: Identity
              _buildSectionHeader("PERSONALIZATION"),
              const SizedBox(height: 16),
              GlassContainer(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    _buildSettingRow(
                      context,
                      title: "Identity Standard",
                      subtitle: "Profile, Role, Contact",
                      icon: Icons.person_outline,
                      onTap: () => context.push('/profile'),
                      isFirst: true,
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    _buildSettingRow(
                      context,
                      title: "Career Vault",
                      subtitle: "Narratives Indexed",
                      icon: Icons.inventory_2_outlined,
                      onTap: () => context.push('/vault'),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Settings Section: Architecture
              _buildSectionHeader("ARCHITECTURE CONTROLS"),
              const SizedBox(height: 16),
              GlassContainer(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    _buildSettingRow(
                      context,
                      title: "Market Radar",
                      subtitle: "Initialize Job Search",
                      icon: Icons.radar,
                      iconColor: AppColors.strategicGold,
                      onTap: () => context.push('/market'),
                      isFirst: true,
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    _buildSettingRow(
                      context,
                      title: "Narrative Refinement",
                      subtitle: "Synthesize with AI Architect",
                      icon: Icons.chat_bubble_outline,
                      iconColor: AppColors.strategicGold,
                      onTap: () => context.push('/chat'),
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Settings Section: Preferences (Mock)
              _buildSectionHeader("PREFERENCES"),
              const SizedBox(height: 16),
              GlassContainer(
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(24),
                  child: Column(children: [
                    _buildSettingRow(
                      context,
                      title: "Terminate Session",
                      subtitle: "Logout securely",
                      icon: Icons.logout,
                      iconColor: Colors.red,
                      titleColor: Colors.red,
                      onTap: () async {
                        await ref.read(authServiceProvider).signOut();
                        if (context.mounted) context.go('/login');
                      },
                      isFirst: true,
                      isLast: true,
                    ),
                  ])),

              const SizedBox(height: 24),
              const BannerAdWidget(),
              const SizedBox(height: 24),

              Center(
                child: Column(
                  children: [
                    Text("AI RESUME BUILDER PROFESSIONAL SUITE V2.0",
                        style: AppTypography.labelSmall
                            .copyWith(color: Colors.grey, fontSize: 8)),
                    const SizedBox(height: 4),
                    Text("End-to-End Career Architecture",
                        style: AppTypography.labelSmall
                            .copyWith(color: Colors.grey[400], fontSize: 7)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: AppTypography.labelSmall.copyWith(
          color: Colors.grey,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildSettingRow(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required VoidCallback onTap,
      Color iconColor = AppColors.midnightNavy,
      Color titleColor = AppColors.midnightNavy,
      bool isFirst = false,
      bool isLast = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(24) : Radius.zero,
        bottom: isLast ? const Radius.circular(24) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600, color: titleColor)),
                  Text(subtitle,
                      style: AppTypography.labelSmall.copyWith(
                          color: Colors.grey, fontSize: 9, letterSpacing: 1.0)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
