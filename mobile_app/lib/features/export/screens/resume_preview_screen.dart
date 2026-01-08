import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/features/export/services/pdf_generator_service.dart';
import 'package:mobile_app/core/ui/custom_snackbar.dart';
import 'package:mobile_app/features/resume/models/resume_model.dart';
import 'package:printing/printing.dart';
import 'package:mobile_app/features/resume/providers/resume_provider.dart';
import 'package:mobile_app/features/monetization/services/ad_manager_service.dart';

class ResumePreviewScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ResumePreviewScreen> createState() =>
      _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends ConsumerState<ResumePreviewScreen> {
  late String _selectedTheme;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.theme;
    AdManagerService.instance.preloadAd();
  }

  Future<void> _handleExport(BuildContext context, ResumeData data) async {
    if (AdManagerService.instance.isExportUnlocked()) {
      _proceedWithExport(context, data);
      return;
    }

    // Show better ads policy intro dialog
    final shouldWatch = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_open, color: AppColors.strategicGold),
            const SizedBox(width: 12),
            Expanded(
              child: Text("Unlock Professional Export",
                  style: AppTypography.header3.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.midnightNavy)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Watch a short video to export your resume in this premium theme for free.",
              style: AppTypography.bodySmall.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.strategicGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 16, color: AppColors.strategicGold),
                  const SizedBox(width: 8),
                  Text("Unlocks unlimited exports for 30m",
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.strategicGold,
                          fontWeight: FontWeight.bold))
                ],
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.strategicGold,
              foregroundColor: AppColors.midnightNavy,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.play_circle_fill),
            label: const Text("Watch Ad to Export"),
          ),
        ],
      ),
    );

    if (shouldWatch == true) {
      AdManagerService.instance.showRewardedAd(
        onReward: () {
          _proceedWithExport(context, data);
        },
        onDismiss: () {
          // User closed ad without reward
        },
        onError: () {
          // Ad failed, maybe let them through as a fallback or show error
          CustomSnackBar.show(
            context,
            message: "Unable to load ad. Please try again.",
            type: SnackBarType.error,
          );
        },
      );
    }
  }

  void _proceedWithExport(BuildContext context, ResumeData data) async {
    setState(() => _isExporting = true);

    try {
      final pdfBytes =
          await PdfGeneratorService().generateResumePdf(data, _selectedTheme);
      await Printing.sharePdf(
          bytes: pdfBytes,
          filename: 'Resume_${data.fullName ?? "Candidate"}.pdf');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.midnightNavy;

    // Logic: Use provided data OR find by ID
    ResumeData? activeData = widget.resumeData;
    if (activeData == null && widget.resumeId != null) {
      final resumes = ref.watch(resumesProvider).valueOrNull ?? [];
      try {
        final match = resumes
            .firstWhere((element) => element.resumeId == widget.resumeId);
        activeData = match.data;
      } catch (e) {
        // Not found
      }
    }

    if (activeData == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Resume Preview', style: TextStyle(color: textColor)),
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
                    "GENERATING RESUME...",
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
        title: Text('Resume Preview', style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.strategicGold),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: PdfPreview(
                    build: (format) => PdfGeneratorService()
                        .generateResumePdf(activeData!, _selectedTheme),
                    canDebug: false,
                    useActions: false, // We provide our own export button
                    loadingWidget: const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.strategicGold)),
                    actions: const [
                      // No default actions, we use the FAB or custom button below
                    ],
                  ),
                ),
              ),
              if (_isExporting)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      LinearProgressIndicator(color: AppColors.strategicGold),
                ),

              // Template Selector + Export Button
              Container(
                color: isDark ? Colors.black26 : Colors.white24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        children: [
                          _buildTemplateOption(
                              "Executive", Icons.article_outlined, isDark),
                          const SizedBox(width: 16),
                          _buildTemplateOption(
                              "Modern", Icons.view_sidebar_outlined, isDark),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isExporting
                              ? null
                              : () => _handleExport(context, activeData!),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.strategicGold,
                              foregroundColor: AppColors.midnightNavy,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 8,
                              shadowColor:
                                  AppColors.strategicGold.withOpacity(0.5)),
                          icon: const Icon(Icons.download_rounded),
                          label: Text("EXPORT PDF",
                              style: AppTypography.labelSmall
                                  .copyWith(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateOption(String themeName, IconData icon, bool isDark) {
    final isSelected = _selectedTheme == themeName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTheme = themeName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
            color: isSelected
                ? AppColors.strategicGold
                : (isDark ? Colors.grey[800] : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSelected
                    ? AppColors.strategicGold
                    : Colors.grey.withOpacity(0.3),
                width: 2)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? AppColors.midnightNavy : Colors.grey),
            const SizedBox(height: 4),
            Text(
              themeName,
              style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? AppColors.midnightNavy : Colors.grey,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
