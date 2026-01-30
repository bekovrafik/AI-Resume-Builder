import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  bool _isInteracted = false;

  // Steps moved to build method for context access

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    GoRouter.of(context).go('/login');
  }

  void _nextPage(int stepsCount) {
    setState(() {
      if (_currentPage < stepsCount - 1) {
        _currentPage++;
        _isInteracted = false; // Reset interaction state
      } else {
        _completeOnboarding();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<Map<String, dynamic>> steps = [
      {
        "title": l10n.step1Title,
        "description": l10n.step1Desc,
        "icon": Icons.verified_user_outlined,
        "color": AppColors.strategicGold,
      },
      {
        "title": l10n.step2Title,
        "content": l10n.step2Desc,
        "icon": Icons.trending_up,
        "color": AppColors.strategicGold,
      },
      {
        "title": l10n.step3Title,
        "content": l10n.step3Desc,
        "icon": Icons.manage_search,
        "color": AppColors.strategicGold,
      },
      {
        "title": l10n.step4Title,
        "description": l10n.step4Desc,
        "icon": Icons.diamond_outlined,
        "color": AppColors.strategicGold,
      }
    ];

    // Determine the content/description key based on the step
    final String contentKey =
        (_currentPage == 0 || _currentPage == 3) ? "description" : "content";
    final step = steps[_currentPage];

    // Build Interaction Widget based on step
    Widget buildInteraction() {
      if (_currentPage == 1) {
        // XYZ Formula Step
        return Column(
          children: [
            // Standard Bullet (Fades out)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 700),
              opacity: _isInteracted ? 0.3 : 1.0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.standardBulletLabel,
                        style: AppTypography.labelSmall
                            .copyWith(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(AppLocalizations.of(context)!.standardBulletExample,
                        style: AppTypography.bodySmall
                            .copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // XYZ Bullet (Fades in)
            AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              transform:
                  Matrix4.translationValues(0, _isInteracted ? 0 : 20, 0),
              decoration: BoxDecoration(
                color: AppColors.strategicGold.withValues(alpha: 0.05),
                border: Border.all(
                    color: AppColors.strategicGold.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 700),
                opacity: _isInteracted ? 1.0 : 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.aiResumeLabel,
                        style: AppTypography.labelSmall
                            .copyWith(color: Colors.white54)),
                    const SizedBox(height: 4),
                    Text(AppLocalizations.of(context)!.aiResumeExample,
                        style: AppTypography.bodySmall.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            if (!_isInteracted)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextButton(
                  onPressed: () => setState(() => _isInteracted = true),
                  child: Text(
                    AppLocalizations.of(context)!.clickToApplyLogic,
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.strategicGold),
                  ),
                ),
              )
          ],
        );
      } else if (_currentPage == 2) {
        // ATS Optimization Step
        return Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Stack(
            children: [
              Center(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    'Strategic Planning',
                    'Leadership',
                    'Revenue Growth',
                    'Agile'
                  ]
                      .map((kw) => AnimatedOpacity(
                            duration: const Duration(milliseconds: 1000),
                            opacity: _isInteracted ? 1.0 : 0.2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.strategicGold
                                    .withValues(alpha: 0.1),
                                border: Border.all(
                                    color: AppColors.strategicGold
                                        .withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(kw,
                                  style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.strategicGold,
                                      fontSize: 8)),
                            ),
                          ))
                      .toList(),
                ),
              ),
              if (!_isInteracted)
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _isInteracted = true),
                    child: Text(AppLocalizations.of(context)!.simulateAtsScan,
                        style: AppTypography.labelSmall
                            .copyWith(color: Colors.white)),
                  ),
                ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return GradientBackground(
      child: SafeArea(
        // Added SafeArea to prevent overlap with status bar
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: GlassContainer(
              padding: const EdgeInsets.all(32),
              borderRadius: BorderRadius.circular(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gold Top Bar
                  Container(
                    width: double.infinity,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.goldDark,
                          AppColors.strategicGold,
                          AppColors.goldDark
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(step['icon'], size: 48, color: Colors.white),
                          const SizedBox(height: 24),
                          Text(
                            step['title'].toString(),
                            style: AppTypography.header2.copyWith(
                              color: Colors.white,
                              letterSpacing: 2.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            step[contentKey].toString(),
                            style: AppTypography.bodyMedium
                                .copyWith(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          // Custom Interaction
                          buildInteraction(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Progress Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      steps.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 4,
                        width: _currentPage == index ? 40 : 16,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.strategicGold
                              : Colors.white12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Main Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _nextPage(steps.length),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 10,
                        shadowColor: Colors.black26,
                      ),
                      child: Text(
                        _currentPage == steps.length - 1
                            ? l10n.startBuilding
                            : l10n.next,
                        style: AppTypography.labelLarge
                            .copyWith(color: Colors.black),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Skip Button
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      l10n.skipOnboarding,
                      style:
                          AppTypography.labelSmall.copyWith(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
