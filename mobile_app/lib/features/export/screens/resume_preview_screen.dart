import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/features/export/services/pdf_generator_service.dart';
import 'package:mobile_app/features/resume/models/resume_model.dart';
import 'package:printing/printing.dart';
import 'package:mobile_app/features/resume/providers/resume_provider.dart';

class ResumePreviewScreen extends ConsumerWidget {
  final ResumeData? resumeData;
  final String? resumeId;
  final String theme;

  const ResumePreviewScreen({
    super.key,
    this.resumeData,
    this.resumeId,
    this.theme = 'Executive',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.midnightNavy;

    // Logic: Use provided data OR find by ID
    ResumeData? activeData = resumeData;
    if (activeData == null && resumeId != null) {
      final resumes = ref.watch(resumesProvider).valueOrNull ?? [];
      try {
        final match =
            resumes.firstWhere((element) => element.resumeId == resumeId);
        activeData = match.data;
      } catch (e) {
        // Not found
      }
    }

    if (activeData == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Blueprint Preview', style: TextStyle(color: textColor)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: AppColors.strategicGold),
        ),
        body: GradientBackground(
          child: Center(
            child: GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.visibility_off_outlined,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "AWAITING BLUEPRINT SYNTHESIS",
                    style: AppTypography.labelSmall
                        .copyWith(color: Colors.grey, letterSpacing: 3.0),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Blueprint Preview', style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.strategicGold),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: PdfPreview(
              build: (format) =>
                  PdfGeneratorService().generateResumePdf(activeData!, theme),
              canDebug: false,
              useActions:
                  false, // Hide default buttons if we want custom UI, but true is fine for now
              actions: const [
                // Custom actions if needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}
