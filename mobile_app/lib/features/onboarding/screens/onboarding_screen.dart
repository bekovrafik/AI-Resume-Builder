import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  bool _isInteracted = false;

  final List<Map<String, dynamic>> _steps = [
    {
      "title": "THE AI STANDARD",
      "content":
          "Welcome to AI Resume Builder. We don't just build resumes; we architect institutional-grade career legacies using executive AI models.",
      "icon": Icons.verified_user_outlined,
      "color": AppColors.strategicGold,
    },
    {
      "title": "THE XYZ FORMULA",
      "content":
          "Google-recommended logic: 'Accomplished [X] as measured by [Y], by doing [Z]'. Watch the transformation below.",
      "icon": Icons.trending_up,
      "color": AppColors.strategicGold,
    },
    {
      "title": "ATS OPTIMIZATION",
      "content":
          "Our engine automatically injects high-traffic industry keywords to ensure your narrative clears every digital gatekeeper.",
      "icon": Icons.manage_search,
      "color": AppColors.strategicGold,
    },
    {
      "title": "NARRATIVE POLISH",
      "content":
          "Your dashboard is interactive. Click any achievement to refine it, or chat with the Architect for real-time legacy synthesis.",
      "icon": Icons.diamond_outlined,
      "color": AppColors.strategicGold,
    }
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    GoRouter.of(context).go('/login');
  }

  void _nextPage() {
    setState(() {
      if (_currentPage < _steps.length - 1) {
        _currentPage++;
        _isInteracted = false; // Reset interaction state
      } else {
        _completeOnboarding();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentPage];

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
                    Text("STANDARD BULLET",
                        style: AppTypography.labelSmall
                            .copyWith(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('"I helped my team with sales targets."',
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
                color: AppColors.strategicGold.withOpacity(0.05),
                border:
                    Border.all(color: AppColors.strategicGold.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 700),
                opacity: _isInteracted ? 1.0 : 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("XYZ BLUEPRINT",
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.strategicGold)),
                    const SizedBox(height: 4),
                    Text(
                        '"Spearheaded a new sales methodology that boosted quarterly revenue by 22% (\$450k)."',
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
                    "CLICK TO APPLY LOGIC",
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
            color: Colors.white.withOpacity(0.05),
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
                                color: AppColors.strategicGold.withOpacity(0.1),
                                border: Border.all(
                                    color: AppColors.strategicGold
                                        .withOpacity(0.3)),
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
                    child: Text("SIMULATE ATS SCAN",
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
                      gradient: LinearGradient(
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

                  // Icon
                  Icon(step['icon'], size: 48, color: Colors.white),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    step['title'].toString(),
                    style: AppTypography.header2.copyWith(
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Content
                  Text(
                    step['content'].toString(),
                    style: AppTypography.bodyMedium
                        .copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Custom Interaction
                  buildInteraction(),

                  const SizedBox(height: 32),

                  // Progress Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
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
                      onPressed: _nextPage,
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
                        _currentPage == _steps.length - 1
                            ? "BEGIN ARCHITECTURE"
                            : "NEXT MILESTONE",
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
                      "SKIP ONBOARDING",
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
