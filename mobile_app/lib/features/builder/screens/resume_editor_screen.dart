import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/features/builder/providers/resume_editor_provider.dart';
import 'package:mobile_app/core/ui/custom_snackbar.dart';
import 'package:mobile_app/features/builder/widgets/xyz_auditor_widget.dart';
import 'package:mobile_app/features/builder/widgets/chat_architect_sheet.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:mobile_app/features/premium/widgets/token_hud.dart';

class ResumeEditorScreen extends ConsumerStatefulWidget {
  final String? resumeId;
  const ResumeEditorScreen({super.key, required this.resumeId});

  @override
  ConsumerState<ResumeEditorScreen> createState() => _ResumeEditorScreenState();
}

class _ResumeEditorScreenState extends ConsumerState<ResumeEditorScreen> {
  String _activeSegment = 'history'; // history | specs
  // We keep text controllers local for performance, but actions go to provider
  final TextEditingController _historyController = TextEditingController();
  final TextEditingController _specsController = TextEditingController();
  bool _showAudit = false;

  @override
  void initState() {
    super.initState();
    // FUTURE: If widget.resumeId is set, load data here or in provider
  }

  @override
  void dispose() {
    _historyController.dispose();
    _specsController.dispose();
    super.dispose();
  }

  void _listenToState() {
    ref.listen(resumeEditorProvider(widget.resumeId), (previous, next) {
      if (next.hasError) {
        CustomSnackBar.show(
          context,
          message: next.error.toString(),
          type: SnackBarType.error,
        );
      }
      if (next.hasValue && next.value!.resultMessage != null) {
        CustomSnackBar.show(
          context,
          message: next.value!.resultMessage!,
          type: SnackBarType.success,
        );
        ref
            .read(resumeEditorProvider(widget.resumeId).notifier)
            .clearMessages();
      }

      // Initialize controllers ONLY ONCE when data is first loaded
      if (next.hasValue && (previous == null || !previous.hasValue)) {
        final state = next.value!;
        if (_historyController.text.isEmpty && state.historyText.isNotEmpty) {
          _historyController.text = state.historyText;
        }
        if (_specsController.text.isEmpty && state.specsText.isNotEmpty) {
          _specsController.text = state.specsText;
        }
      }
    });
  }

  // Calculate generic progress based on text length
  double get _progress {
    final historyScore = (_historyController.text.length / 200).clamp(0.0, 0.5);
    final specsScore = (_specsController.text.length / 100).clamp(0.0, 0.5);
    return (historyScore + specsScore) * 100;
  }

  Future<void> _onImportTap() async {
    final importedText = await ref
        .read(resumeEditorProvider(widget.resumeId).notifier)
        .handleImport();
    if (importedText != null && mounted) {
      setState(() {
        _historyController.text = importedText;
      });
      ref
          .read(resumeEditorProvider(widget.resumeId).notifier)
          .onHistoryChanged(importedText);
    }
  }

  Future<void> _onBuildTap() async {
    final newId = await ref
        .read(resumeEditorProvider(widget.resumeId).notifier)
        .handleBuildResume(
          historyText: _historyController.text,
          specsText: _specsController.text,
          theme: 'Executive', // Default theme
        );

    if (newId != null && mounted) {
      context.go('/preview/$newId');
    }
  }

  @override
  Widget build(BuildContext context) {
    _listenToState();
    final editorState = ref.watch(resumeEditorProvider(widget.resumeId));
    final isProcessing = editorState.isLoading;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.midnightNavy;
    final subTextColor =
        isDark ? Colors.white54 : AppColors.midnightNavy.withValues(alpha: 0.6);
    final glassColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : AppColors.midnightNavy.withValues(alpha: 0.05);

    // 1. Header with Progress
    Widget buildHeader() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: "Career ",
                            style: AppTypography.header1
                                .copyWith(color: textColor, fontSize: 32)),
                        TextSpan(
                            text: AppLocalizations.of(context)!.careerForge,
                            style: AppTypography.header1.copyWith(
                                color: AppColors.strategicGold, fontSize: 32)),
                      ],
                    ),
                  ),
                ),
                const TokenHUD(),
              ],
            ),
            const SizedBox(height: 12),
            // Optimization: Only rebuild progress bar when text changes
            ListenableBuilder(
              listenable:
                  Listenable.merge([_historyController, _specsController]),
              builder: (context, _) {
                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black12,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        alignment: Alignment.centerLeft,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: MediaQuery.of(context).size.width *
                              (_progress / 100),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              AppColors.goldDark,
                              AppColors.strategicGold
                            ]),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                        "${_progress.toInt()}% ${AppLocalizations.of(context)!.synced}",
                        style: AppTypography.labelSmall.copyWith(
                            color: AppColors.strategicGold, fontSize: 9)),
                  ],
                );
              },
            )
          ],
        ),
      );
    }

    // 2. Segmented Toggle
    Widget buildToggle() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          child: Row(
            children: [
              _buildSegmentBtn(AppLocalizations.of(context)!.workHistorySegment,
                  'history', isDark, textColor),
              _buildSegmentBtn(AppLocalizations.of(context)!.targetSpecsSegment,
                  'specs', isDark, textColor),
            ],
          ),
        ),
      );
    }

    // 3. Content Area
    Widget buildContent() {
      if (_activeSegment == 'history') {
        return _buildHistoryInput(
            isDark, textColor, subTextColor, isProcessing, editorState);
      } else {
        return _buildSpecsInput(isDark, textColor, subTextColor);
      }
    }

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              buildHeader(),
              buildToggle(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      buildContent(),
                      if (_showAudit && _activeSegment == 'history')
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: XyzAuditorWidget(
                            textToAnalyze: _historyController.text,
                            targetSpecs: _specsController.text,
                            onDismiss: () => setState(() => _showAudit = false),
                          ),
                        ),
                      const SizedBox(height: 32),
                      // Action Grid
                      Row(
                        children: [
                          Expanded(
                              child: _buildInfoCard(
                                  AppLocalizations.of(context)!
                                      .impactFirstTitle,
                                  AppLocalizations.of(context)!.impactFirstDesc,
                                  isDark)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildInfoCard(
                                  AppLocalizations.of(context)!.atsReadyTitle,
                                  AppLocalizations.of(context)!.atsReadyDesc,
                                  isDark)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Build Button
                      ElevatedButton(
                        onPressed: isProcessing ? null : _onBuildTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.midnightNavy,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          side: BorderSide(
                              color: AppColors.strategicGold
                                  .withValues(alpha: 0.5)),
                          elevation: 10,
                        ),
                        child: isProcessing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: AppColors.strategicGold,
                                          strokeWidth: 2)),
                                  const SizedBox(width: 12),
                                  Text(
                                      AppLocalizations.of(context)!
                                          .synthesizing,
                                      style: AppTypography.labelSmall.copyWith(
                                          color: Colors.white,
                                          letterSpacing: 3)),
                                ],
                              )
                            : Text(
                                AppLocalizations.of(context)!.buildResume,
                                style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white, letterSpacing: 3),
                              ),
                      ),
                      const SizedBox(height: 100), // Spacing for Bottom Nav
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentBtn(
      String label, String value, bool isDark, Color textColor) {
    final isActive = _activeSegment == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeSegment = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? Colors.white : AppColors.midnightNavy)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isActive
                ? [const BoxShadow(color: Colors.black12, blurRadius: 10)]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: AppTypography.labelSmall.copyWith(
                  color: isActive
                      ? (isDark ? AppColors.midnightNavy : Colors.white)
                      : textColor.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }

  Widget _buildHistoryInput(bool isDark, Color textColor, Color subTextColor,
      bool isProcessing, AsyncValue<ResumeEditorState> editorState) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.strategicGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.description_outlined,
                        color: AppColors.strategicGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.careerLegacyData,
                          style: AppTypography.labelSmall
                              .copyWith(color: textColor, fontSize: 9)),
                      Text(AppLocalizations.of(context)!.inputRawHistory,
                          style: AppTypography.labelSmall
                              .copyWith(color: subTextColor, fontSize: 8)),
                    ],
                  )
                ],
              ),
              GestureDetector(
                onTap: isProcessing ? null : _onImportTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        isProcessing ? textColor.withValues(alpha: 0.1) : null,
                    border: Border.all(color: textColor.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isProcessing
                      ? SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                              strokeWidth: 1, color: textColor))
                      : Text(
                          editorState.value?.status != null
                              ? editorState.value!.status!
                              : AppLocalizations.of(context)!.importFile,
                          style: AppTypography.labelSmall.copyWith(
                              color: editorState.value?.status != null
                                  ? AppColors.strategicGold
                                  : subTextColor,
                              fontSize: 8,
                              fontWeight: editorState.value?.status != null
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          TextField(
            controller: _historyController,
            maxLines: 10,
            style: TextStyle(color: textColor, height: 1.5),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.historyHint,
              hintStyle: TextStyle(color: subTextColor.withValues(alpha: 0.4)),
              border: InputBorder.none,
            ),
            onChanged: (v) {
              // Removed setState to prevent full page rebuilds
              ref
                  .read(resumeEditorProvider(widget.resumeId).notifier)
                  .onHistoryChanged(v);
            },
          ),
          // STAR-K Refinement Button
          // Optimization: Only rebuild this button when text length passes threshold
          ListenableBuilder(
            listenable: _historyController,
            builder: (context, _) {
              if (_historyController.text.length <= 50) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _openChatArchitect(),
                      icon: const Icon(Icons.psychology,
                          color: AppColors.strategicGold, size: 16),
                      label: Text(AppLocalizations.of(context)!.refineWithAi,
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.strategicGold)),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            AppColors.strategicGold.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Divider(color: textColor.withValues(alpha: 0.1)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _showAudit = !_showAudit),
                icon: Icon(_showAudit ? Icons.close : Icons.auto_awesome,
                    color: AppColors.strategicGold, size: 16),
                label: Text(
                    _showAudit
                        ? AppLocalizations.of(context)!.closeAuditor
                        : AppLocalizations.of(context)!.auditImpact,
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.strategicGold)),
              ),
              GestureDetector(
                onTap: () => setState(() => _activeSegment = 'specs'),
                child: Row(
                  children: [
                    Text(AppLocalizations.of(context)!.nextStage,
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.strategicGold)),
                    const Icon(Icons.chevron_right,
                        color: AppColors.strategicGold, size: 16),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void _openChatArchitect() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatArchitectSheet(
        originalText: _historyController.text,
        onApply: (newText) {
          setState(() {
            _historyController.text = newText;
          });
          ref
              .read(resumeEditorProvider(widget.resumeId).notifier)
              .onHistoryChanged(newText);
        },
      ),
    );
  }

  Widget _buildSpecsInput(bool isDark, Color textColor, Color subTextColor) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppColors.strategicGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.gps_fixed,
                    color: AppColors.strategicGold, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.opportunitySpecs,
                      style: AppTypography.labelSmall
                          .copyWith(color: textColor, fontSize: 9)),
                  Text(AppLocalizations.of(context)!.keywordSynchronization,
                      style: AppTypography.labelSmall
                          .copyWith(color: subTextColor, fontSize: 8)),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _specsController,
            maxLines: 10,
            style: TextStyle(color: textColor, height: 1.5),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.specsHint,
              hintStyle: TextStyle(color: subTextColor.withValues(alpha: 0.4)),
              border: InputBorder.none,
            ),
            onChanged: (v) {
              // Removed setState to prevent full page rebuilds
              ref
                  .read(resumeEditorProvider(widget.resumeId).notifier)
                  .onSpecsChanged(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String desc, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.midnightNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.strategicGold, fontSize: 9)),
          const SizedBox(height: 4),
          Text(desc,
              style: TextStyle(
                  color: isDark
                      ? Colors.white54
                      : AppColors.midnightNavy.withValues(alpha: 0.6),
                  fontSize: 10,
                  height: 1.4)),
        ],
      ),
    );
  }
}
