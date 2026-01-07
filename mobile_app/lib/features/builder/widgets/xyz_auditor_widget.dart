import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/services/gemini_service.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/features/builder/providers/ats_score_provider.dart';

final xyzAuditProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, history) async {
  final service = ref.watch(geminiServiceProvider);
  return service.suggestMetrics(history);
});

class XyzAuditorWidget extends ConsumerWidget {
  final String textToAnalyze;
  final String targetSpecs; // Mission 2: Needed for ATS Scoring
  final VoidCallback onDismiss;

  const XyzAuditorWidget({
    super.key,
    required this.textToAnalyze,
    required this.onDismiss,
    this.targetSpecs = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (textToAnalyze.length < 50) {
      return GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Text("Add more detail to enable XYZ Audit & ATS Scoring",
            style: AppTypography.labelSmall.copyWith(color: Colors.white54)),
      );
    }

    final auditAsync = ref.watch(xyzAuditProvider(textToAnalyze));
    final atsState = ref
        .watch(atsScoreProvider((history: textToAnalyze, specs: targetSpecs)));

    return Column(
      children: [
        // MISSION 2: ATS SUCCESS METER
        _buildAtsGauge(atsState),
        const SizedBox(height: 24),

        // Existing Narrative Audit
        auditAsync.when(
          data: (data) {
            final suggestions =
                (data['suggestions'] as List?)?.cast<String>() ?? [];
            final skills =
                (data['inferredSkills'] as List?)?.cast<String>() ?? [];
            final vagues = (data['vagues'] as List?)?.cast<String>() ?? [];

            return Column(
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                        child: Container(
                            height: 1,
                            color: AppColors.strategicGold.withOpacity(0.2))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text("NARRATIVE AUDIT RESULTS",
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.strategicGold)),
                    ),
                    Expanded(
                        child: Container(
                            height: 1,
                            color: AppColors.strategicGold.withOpacity(0.2))),
                  ],
                ),
                const SizedBox(height: 16),

                // Suggestions
                if (suggestions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                        "No critical weakness detected. Institutional standard met.",
                        style: AppTypography.bodySmall.copyWith(
                            color: Colors.white70,
                            fontStyle: FontStyle.italic)),
                  )
                else
                  ...List.generate(suggestions.length, (index) {
                    final vague = index < vagues.length
                        ? vagues[index]
                        : "Detected Weakness";
                    final suggestion = suggestions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("WEAK POINT DETECTED:",
                                    style: AppTypography.labelSmall.copyWith(
                                        color: Colors.white38, fontSize: 8)),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text('"$vague"',
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic),
                                        overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.strategicGold,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_forward,
                                      size: 12, color: AppColors.midnightNavy),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("INSTITUTIONAL XYZ CORRECTION:",
                                          style: AppTypography.labelSmall
                                              .copyWith(
                                                  color:
                                                      AppColors.strategicGold,
                                                  fontSize: 9)),
                                      const SizedBox(height: 4),
                                      Text(suggestion,
                                          style: AppTypography.bodySmall
                                              .copyWith(color: Colors.white)),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 16),

                // Skills
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("INFERRED CORE EXPERTISE",
                          style: AppTypography.labelSmall
                              .copyWith(color: Colors.white38, fontSize: 9)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: skills
                            .map((s) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.strategicGold
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppColors.strategicGold
                                            .withOpacity(0.3)),
                                  ),
                                  child: Text(s,
                                      style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.strategicGold)),
                                ))
                            .toList(),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: onDismiss,
                  child: Text("DISMISS NARRATIVE RECOMMENDATIONS",
                      style: AppTypography.labelSmall
                          .copyWith(color: Colors.white38)),
                )
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
                child:
                    CircularProgressIndicator(color: AppColors.strategicGold)),
          ),
          error: (e, s) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text("Audit unavailable: $e",
                style: const TextStyle(color: AppColors.errorRed)),
          ),
        ),
      ],
    );
  }

  Widget _buildAtsGauge(AtsScoreState state) {
    Color scoreColor = AppColors.strategicGold;
    if (state.totalScore < 50) scoreColor = AppColors.errorRed;
    if (state.totalScore > 80) scoreColor = Colors.greenAccent;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          // Circular Progress
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: state.totalScore / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.white10,
                  color: scoreColor,
                ),
              ),
              Text(
                state.totalScore.toInt().toString(),
                style: AppTypography.header3
                    .copyWith(color: scoreColor, fontSize: 18),
              )
            ],
          ),
          const SizedBox(width: 20),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ATS SUCCESS METER",
                    style: AppTypography.labelSmall
                        .copyWith(color: Colors.white54)),
                const SizedBox(height: 8),
                _buildScoreRow("Quantitative Impact", state.quantitativeScore),
                const SizedBox(height: 4),
                _buildScoreRow("Keyword Match", state.keywordScore),
                const SizedBox(height: 4),
                _buildScoreRow("Density", state.densityScore),
                if (state.keywordScore < 70 && state.missingKeywords.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                          "Missing: ${state.missingKeywords.take(3).join(', ')}...",
                          style: const TextStyle(
                              color: AppColors.errorRed, fontSize: 10)))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, double score) {
    Color color = Colors.white70;
    if (score < 50) color = AppColors.errorRed;

    return Row(
      children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.white30, fontSize: 10))),
        Text("${score.toInt()}%",
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
