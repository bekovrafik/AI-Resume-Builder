import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/features/profile/providers/profile_provider.dart';

import 'package:mobile_app/core/ui/custom_snackbar.dart';
import 'package:mobile_app/features/auth/services/auth_service.dart';
import 'package:mobile_app/l10n/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientBackground(
      child: SafeArea(
        child: profileAsync.when(
          data: (profileData) {
            final fullName = profileData.fullName?.isNotEmpty == true
                ? profileData.fullName!
                : AppLocalizations.of(context)!.careerAiDefaultName;
            final targetRole = profileData.targetRole?.isNotEmpty == true
                ? profileData.targetRole!
                : AppLocalizations.of(context)!.identityNotSynced;

            final progress =
                (profileData.fullName?.isNotEmpty == true ? 20 : 0) +
                    (profileData.targetRole?.isNotEmpty == true ? 20 : 0) +
                    (profileData.email?.isNotEmpty == true ? 20 : 0) +
                    (profileData.experiences?.isNotEmpty == true ? 20 : 0) +
                    (profileData.skills?.isNotEmpty == true ? 20 : 0);

            final textColor = isDark ? Colors.white : AppColors.midnightNavy;
            final iconColor =
                isDark ? AppColors.strategicGold : AppColors.midnightNavy;

            return SingleChildScrollView(
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
                            color: isDark
                                ? Colors.white10
                                : AppColors.midnightNavy.withValues(alpha: 0.1),
                            border: Border.all(
                                color: AppColors.strategicGold
                                    .withValues(alpha: 0.3),
                                width: 2),
                          ),
                          child: profileData.avatarUrl != null
                              ? ClipOval(
                                  child: Image.network(profileData.avatarUrl!))
                              : Icon(Icons.person,
                                  size: 40,
                                  color: isDark ? Colors.white54 : Colors.grey),
                        ),
                        const SizedBox(width: 20),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.header3
                                      .copyWith(color: textColor)),
                              const SizedBox(height: 4),
                              Text(targetRole,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.labelSmall.copyWith(
                                      color:
                                          isDark ? Colors.white54 : Colors.grey,
                                      letterSpacing: 1.5)),
                              const SizedBox(height: 12),
                              // Progress Bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress / 100,
                                  backgroundColor:
                                      isDark ? Colors.white12 : Colors.black12,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
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
                  _buildSectionHeader(
                      AppLocalizations.of(context)!.personalizationSection,
                      isDark),
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      children: [
                        _buildSettingRow(
                          context,
                          title: AppLocalizations.of(context)!
                              .identityStandardTitle,
                          subtitle: AppLocalizations.of(context)!
                              .identityStandardSubtitle,
                          icon: Icons.person_outline,
                          onTap: () => context.push('/profile'),
                          isFirst: true,
                          defaultIconColor: iconColor,
                          defaultTitleColor: textColor,
                        ),
                        Divider(
                            height: 1,
                            color: isDark ? Colors.white12 : Colors.black12),
                        _buildSettingRow(
                          context,
                          title: AppLocalizations.of(context)!.careerVaultTitle,
                          subtitle:
                              AppLocalizations.of(context)!.careerVaultSubtitle,
                          icon: Icons.inventory_2_outlined,
                          onTap: () => context.push('/vault'),
                          isLast: true,
                          defaultIconColor: iconColor,
                          defaultTitleColor: textColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Settings Section: Architecture
                  _buildSectionHeader(
                      AppLocalizations.of(context)!.aiControlsSection, isDark),
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      children: [
                        _buildSettingRow(
                          context,
                          title: AppLocalizations.of(context)!.marketRadarTitle,
                          subtitle:
                              AppLocalizations.of(context)!.marketRadarSubtitle,
                          icon: Icons.radar,
                          iconColor: AppColors.strategicGold,
                          onTap: () => context.push('/market'),
                          isFirst: true,
                          defaultTitleColor: textColor,
                        ),
                        Divider(
                            height: 1,
                            color: isDark ? Colors.white12 : Colors.black12),
                        _buildSettingRow(
                          context,
                          title:
                              AppLocalizations.of(context)!.interviewPrepTitle,
                          subtitle: AppLocalizations.of(context)!
                              .interviewPrepSubtitle,
                          icon: Icons.psychology_outlined,
                          iconColor: AppColors.strategicGold,
                          onTap: () => context.push('/strategy'),
                          defaultTitleColor: textColor,
                        ),
                        Divider(
                            height: 1,
                            color: isDark ? Colors.white12 : Colors.black12),
                        _buildSettingRow(
                          context,
                          title:
                              AppLocalizations.of(context)!.chatAssistantTitle,
                          subtitle: AppLocalizations.of(context)!
                              .chatAssistantSubtitle,
                          icon: Icons.record_voice_over,
                          iconColor: AppColors.strategicGold,
                          onTap: () => context.push('/chat'),
                          isLast: true,
                          defaultTitleColor: textColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Settings Section: Preferences
                  _buildSectionHeader(
                      AppLocalizations.of(context)!.preferencesSection, isDark),
                  const SizedBox(height: 16),
                  GlassContainer(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(24),
                      child: Column(children: [
                        _buildSettingRow(
                          context,
                          title: AppLocalizations.of(context)!.conciergeTitle,
                          subtitle:
                              AppLocalizations.of(context)!.conciergeSubtitle,
                          icon: Icons.support_agent,
                          onTap: () {
                            CustomSnackBar.show(
                              context,
                              message: AppLocalizations.of(context)!
                                  .conciergeComingSoon,
                              type: SnackBarType.info,
                            );
                          },
                          isFirst: true,
                          defaultIconColor: iconColor,
                          defaultTitleColor: textColor,
                        ),
                        Divider(
                            height: 1,
                            color: isDark ? Colors.white12 : Colors.black12),
                        _buildSettingRow(
                          context,
                          title: AppLocalizations.of(context)!.legalTitle,
                          subtitle: AppLocalizations.of(context)!.legalSubtitle,
                          icon: Icons.policy_outlined,
                          onTap: () {
                            CustomSnackBar.show(
                              context,
                              message: AppLocalizations.of(context)!
                                  .privacyPolicyMessage,
                              type: SnackBarType.info,
                            );
                          },
                          defaultIconColor: iconColor,
                          defaultTitleColor: textColor,
                        ),
                        Divider(
                            height: 1,
                            color: isDark ? Colors.white12 : Colors.black12),
                        _buildSettingRow(
                          context,
                          title: AppLocalizations.of(context)!
                              .terminateSessionTitle,
                          subtitle: AppLocalizations.of(context)!
                              .terminateSessionSubtitle,
                          icon: Icons.logout,
                          iconColor: Colors.red,
                          titleColor: Colors.red,
                          onTap: () async {
                            await ref.read(authServiceProvider).signOut();
                            if (context.mounted) context.go('/login');
                          },
                          isLast: true,
                          defaultIconColor: iconColor,
                        ),
                      ])),

                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Text(AppLocalizations.of(context)!.suiteVersion,
                            style: AppTypography.labelSmall
                                .copyWith(color: Colors.grey, fontSize: 8)),
                        const SizedBox(height: 4),
                        Text(
                            AppLocalizations.of(context)!
                                .comprehensiveCareerBuilding,
                            style: AppTypography.labelSmall.copyWith(
                                color: Colors.grey[400], fontSize: 7)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Spacing for fab/bottom nav
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.strategicGold),
          ),
          error: (err, stack) => Center(
            child: Text(
              AppLocalizations.of(context)!.syncError(err.toString()),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: AppTypography.labelSmall.copyWith(
          color: isDark ? Colors.white54 : Colors.grey,
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
      Color? iconColor,
      Color? titleColor,
      Color? defaultIconColor,
      Color? defaultTitleColor,
      bool isFirst = false,
      bool isLast = false}) {
    final effectiveIconColor =
        iconColor ?? defaultIconColor ?? AppColors.midnightNavy;
    final effectiveTitleColor =
        titleColor ?? defaultTitleColor ?? AppColors.midnightNavy;

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
                color: effectiveIconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: effectiveIconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: effectiveTitleColor)),
                  Text(subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
