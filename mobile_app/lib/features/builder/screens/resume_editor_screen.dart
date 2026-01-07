import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/features/builder/providers/resume_editor_provider.dart';
import 'package:mobile_app/features/builder/widgets/xyz_auditor_widget.dart';
import 'package:mobile_app/features/builder/widgets/chat_architect_sheet.dart';

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
    ref.listen(resumeEditorProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
        // No need to clear messages in AsyncValue pattern usually, but if we want to reset:
        // ref.read(resumeEditorProvider.notifier).clearMessages();
      }
      if (next.hasValue && next.value!.resultMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.value!.resultMessage!)),
        );
        ref.read(resumeEditorProvider.notifier).clearMessages();
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
    final importedText =
        await ref.read(resumeEditorProvider.notifier).handleImportWithReturn();
    if (importedText != null && mounted) {
      setState(() {
        _historyController.text = importedText;
      });
    }
  }

  Future<void> _onBuildTap() async {
    final newId =
        await ref.read(resumeEditorProvider.notifier).handleBuildResume(
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
    final editorState = ref.watch(resumeEditorProvider);
    final isProcessing = editorState.isLoading;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.midnightNavy;
    final subTextColor =
        isDark ? Colors.white54 : AppColors.midnightNavy.withOpacity(0.6);
    final glassColor = isDark
        ? Colors.white.withOpacity(0.05)
        : AppColors.midnightNavy.withOpacity(0.05);

    // 1. Header with Progress
    Widget buildHeader() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                      text: "Career ",
                      style: AppTypography.header1
                          .copyWith(color: textColor, fontSize: 32)),
                  TextSpan(
                      text: "Forge.",
                      style: AppTypography.header1.copyWith(
                          color: AppColors.strategicGold, fontSize: 32)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
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
                      width:
                          MediaQuery.of(context).size.width * (_progress / 100),
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
                Text("${_progress.toInt()}% SYNCED",
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.strategicGold, fontSize: 9)),
              ],
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
              _buildSegmentBtn("WORK HISTORY", 'history', isDark, textColor),
              _buildSegmentBtn("TARGET SPECS", 'specs', isDark, textColor),
            ],
          ),
        ),
      );
    }

    // 3. Content Area
    Widget buildContent() {
      if (_activeSegment == 'history') {
        return _buildHistoryInput(
            isDark, textColor, subTextColor, isProcessing);
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
                                  "IMPACT FIRST",
                                  "Quantitative data leads to 3x higher interview rates.",
                                  isDark)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildInfoCard(
                                  "ATS READY",
                                  "Synchronizing inputs with 500+ industry algorithms.",
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
                              color: AppColors.strategicGold.withOpacity(0.5)),
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
                                  Text("SYNTHESIZING...",
                                      style: AppTypography.labelSmall.copyWith(
                                          color: Colors.white,
                                          letterSpacing: 3)),
                                ],
                              )
                            : Text(
                                "BUILD RESUME",
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
                      : textColor.withOpacity(0.5),
                  fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }

  Widget _buildHistoryInput(
      bool isDark, Color textColor, Color subTextColor, bool isProcessing) {
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
                        color: AppColors.strategicGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.description_outlined,
                        color: AppColors.strategicGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("CAREER LEGACY DATA",
                          style: AppTypography.labelSmall
                              .copyWith(color: textColor, fontSize: 9)),
                      Text("Input raw history or upload.",
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
                    color: isProcessing ? textColor.withOpacity(0.1) : null,
                    border: Border.all(color: textColor.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isProcessing
                      ? SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                              strokeWidth: 1, color: textColor))
                      : Text("IMPORT FILE",
                          style: AppTypography.labelSmall
                              .copyWith(color: subTextColor, fontSize: 8)),
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
              hintText:
                  "Ex: Led engineering team at Tech Corp. Launched mobile app reaching 1M users...",
              hintStyle: TextStyle(color: subTextColor.withOpacity(0.4)),
              border: InputBorder.none,
            ),
            onChanged: (v) => setState(() {}),
          ),
          // STAR-K Refinement Button
          if (_historyController.text.length > 50) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _openChatArchitect(),
                icon: const Icon(Icons.psychology,
                    color: AppColors.strategicGold, size: 16),
                label: Text("REFINE WITH AI (STAR-K)",
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.strategicGold)),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.strategicGold.withOpacity(0.1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Divider(color: textColor.withOpacity(0.1)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _showAudit = !_showAudit),
                icon: Icon(_showAudit ? Icons.close : Icons.auto_awesome,
                    color: AppColors.strategicGold, size: 16),
                label: Text(_showAudit ? "CLOSE AUDITOR" : "AUDIT IMPACT (XYZ)",
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.strategicGold)),
              ),
              GestureDetector(
                onTap: () => setState(() => _activeSegment = 'specs'),
                child: Row(
                  children: [
                    Text("NEXT STAGE",
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
                    color: AppColors.strategicGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.gps_fixed,
                    color: AppColors.strategicGold, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("OPPORTUNITY SPECS",
                      style: AppTypography.labelSmall
                          .copyWith(color: textColor, fontSize: 9)),
                  Text("Keyword synchronization.",
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
              hintText:
                  "Paste the Job Description or key requirements here to enable precise ATS alignment...",
              hintStyle: TextStyle(color: subTextColor.withOpacity(0.4)),
              border: InputBorder.none,
            ),
            onChanged: (v) => setState(() {}),
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
            ? Colors.white.withOpacity(0.05)
            : AppColors.midnightNavy.withOpacity(0.05),
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
                      : AppColors.midnightNavy.withOpacity(0.6),
                  fontSize: 10,
                  height: 1.4)),
        ],
      ),
    );
  }
}
