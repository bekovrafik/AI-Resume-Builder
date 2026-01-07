import 'package:flutter_riverpod/flutter_riverpod.dart';

class AtsScoreState {
  final double totalScore; // 0-100
  final double quantitativeScore;
  final double keywordScore;
  final double densityScore;
  final List<String> missingKeywords;

  const AtsScoreState({
    this.totalScore = 0,
    this.quantitativeScore = 0,
    this.keywordScore = 0,
    this.densityScore = 0,
    this.missingKeywords = const [],
  });
}

final atsScoreProvider =
    Provider.family<AtsScoreState, ({String history, String specs})>(
        (ref, arg) {
  final history = arg.history;
  final specs = arg.specs;

  if (history.isEmpty) return const AtsScoreState();

  // 1. Quantitative Score (Presence of numbers, %, $)
  // Regex to find digits, %, $
  final quantityMatches = RegExp(r'\d+|%|\$').allMatches(history);
  // Cap at 10 matches for full score (arbitrary heuristic)
  final quantScore = (quantityMatches.length / 10).clamp(0.0, 1.0) * 100;

  // 2. Keyword Match Score
  double keyScore = 100; // Default high if no specs
  final List<String> missing = [];

  if (specs.isNotEmpty) {
    // Simple mock keyword extraction (splitting by space, filtering small words)
    // In production, we'd use Gemini or a better NLP library
    final potentialKeywords = specs
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 4) // Filter short words
        .map((w) => w.replaceAll(RegExp(r'[^\w]'), '').toLowerCase())
        .toSet();

    int matches = 0;
    final historyLower = history.toLowerCase();

    for (final k in potentialKeywords) {
      if (historyLower.contains(k)) {
        matches++;
      } else {
        if (missing.length < 5) missing.add(k);
      }
    }

    if (potentialKeywords.isNotEmpty) {
      keyScore = (matches / potentialKeywords.length).clamp(0.0, 1.0) * 100;
    }
  }

  // 3. Layout Density (Length check for now)
  // Ideal: 500-1000 characters for a solid chunk of history
  final densityScore = (history.length / 600).clamp(0.0, 1.0) * 100;

  // Weighted Total
  // Quant: 40%, Keyword: 40%, Density: 20%
  final total = (quantScore * 0.4) + (keyScore * 0.4) + (densityScore * 0.2);

  return AtsScoreState(
    totalScore: total,
    quantitativeScore: quantScore,
    keywordScore: keyScore,
    densityScore: densityScore,
    missingKeywords: missing,
  );
});
