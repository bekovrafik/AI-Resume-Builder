import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/features/resume/providers/resume_provider.dart';
import 'package:mobile_app/features/resume/models/resume_model.dart';
import 'package:mobile_app/features/builder/widgets/xyz_auditor_widget.dart';

class ResumeEditorScreen extends ConsumerStatefulWidget {
  final String? resumeId;
  const ResumeEditorScreen({super.key, required this.resumeId});

  @override
  ConsumerState<ResumeEditorScreen> createState() => _ResumeEditorScreenState();
}

class _ResumeEditorScreenState extends ConsumerState<ResumeEditorScreen> {
  String _activeSegment = 'history'; // history | specs
  final TextEditingController _historyController = TextEditingController();
  final TextEditingController _specsController = TextEditingController();
  bool _isProcessing = false;
  bool _showAudit = false;

  @override
  void initState() {
    super.initState();
    // Load existing data if available
    final resumes = ref.read(resumesProvider).value;
    if (resumes != null && widget.resumeId != null) {
      try {
        final resume = resumes.firstWhere((r) => r.resumeId == widget.resumeId);
        // Pre-fill controllers based on logic, or empty for new draft
        // Logic simplified for UI parity
      } catch (e) {
        // Handle not found
      }
    }
  }

  // Calculate generic progress based on text length
  double get _progress {
    final historyScore = (_historyController.text.length / 200).clamp(0.0, 0.5);
    final specsScore = (_specsController.text.length / 100).clamp(0.0, 0.5);
    return (historyScore + specsScore) * 100;
  }

  @override
  Widget build(BuildContext context) {
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
                          .copyWith(color: Colors.white, fontSize: 32)),
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
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width:
                          MediaQuery.of(context).size.width * (_progress / 100),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
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
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              _buildSegmentBtn("WORK HISTORY", 'history'),
              _buildSegmentBtn("TARGET SPECS", 'specs'),
            ],
          ),
        ),
      );
    }

    // 3. Content Area
    Widget buildContent() {
      if (_activeSegment == 'history') {
        return _buildHistoryInput();
      } else {
        return _buildSpecsInput();
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
                            onDismiss: () => setState(() => _showAudit = false),
                          ),
                        ),
                      const SizedBox(height: 32),
                      // Action Grid
                      Row(
                        children: [
                          Expanded(
                              child: _buildInfoCard("IMPACT FIRST",
                                  "Quantitative data leads to 3x higher interview rates.")),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildInfoCard("ATS READY",
                                  "Synchronizing inputs with 500+ industry algorithms.")),
                        ],
                      ),
                      const SizedBox(height: 120), // Spacing for fab
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ElevatedButton(
          onPressed: _isProcessing
              ? null
              : () {
                  // Logic to process
                  setState(() => _isProcessing = true);
                  // Simulate
                  Future.delayed(const Duration(seconds: 2),
                      () => setState(() => _isProcessing = false));
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.midnightNavy,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide(color: AppColors.strategicGold.withOpacity(0.5)),
            elevation: 10,
          ),
          child: Text(
            _isProcessing ? "SYNTHESIZING ARCHITECTURALLY..." : "BUILD RESUME",
            style: AppTypography.labelSmall
                .copyWith(color: Colors.white, letterSpacing: 3),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentBtn(String label, String value) {
    final isActive = _activeSegment == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeSegment = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black12, blurRadius: 10)]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: AppTypography.labelSmall.copyWith(
                  color: isActive ? AppColors.midnightNavy : Colors.white54,
                  fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }

  Widget _buildHistoryInput() {
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
                    child: Icon(Icons.description_outlined,
                        color: AppColors.strategicGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("CAREER LEGACY DATA",
                          style: AppTypography.labelSmall
                              .copyWith(color: Colors.white, fontSize: 9)),
                      Text("Input raw history or upload.",
                          style: AppTypography.labelSmall
                              .copyWith(color: Colors.white38, fontSize: 8)),
                    ],
                  )
                ],
              ),
              Container(
                // Import Button Mock
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text("IMPORT FILE",
                    style: AppTypography.labelSmall
                        .copyWith(color: Colors.white54, fontSize: 8)),
              )
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _historyController,
            maxLines: 10,
            style: const TextStyle(color: Colors.white, height: 1.5),
            decoration: InputDecoration(
              hintText:
                  "Ex: Led engineering team at Tech Corp. Launched mobile app reaching 1M users...",
              hintStyle: TextStyle(color: Colors.white24),
              border: InputBorder.none,
            ),
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white10),
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
                    Icon(Icons.chevron_right,
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

  Widget _buildSpecsInput() {
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
                child: Icon(Icons.gps_fixed,
                    color: AppColors.strategicGold, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("OPPORTUNITY SPECS",
                      style: AppTypography.labelSmall
                          .copyWith(color: Colors.white, fontSize: 9)),
                  Text("Keyword synchronization.",
                      style: AppTypography.labelSmall
                          .copyWith(color: Colors.white38, fontSize: 8)),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _specsController,
            maxLines: 10,
            style: const TextStyle(color: Colors.white, height: 1.5),
            decoration: InputDecoration(
              hintText:
                  "Paste the Job Description or key requirements here to enable precise ATS alignment...",
              hintStyle: TextStyle(color: Colors.white24),
              border: InputBorder.none,
            ),
            onChanged: (v) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.strategicGold, fontSize: 9)),
          const SizedBox(height: 4),
          Text(desc,
              style:
                  TextStyle(color: Colors.white54, fontSize: 10, height: 1.4)),
        ],
      ),
    );
  }
}
