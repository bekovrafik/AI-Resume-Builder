import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/services/gemini_service.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/core/ui/glass_container.dart';

class ChatArchitectSheet extends ConsumerStatefulWidget {
  final String originalText;
  final Function(String) onApply;

  const ChatArchitectSheet({
    super.key,
    required this.originalText,
    required this.onApply,
  });

  @override
  ConsumerState<ChatArchitectSheet> createState() => _ChatArchitectSheetState();
}

class _ChatArchitectSheetState extends ConsumerState<ChatArchitectSheet> {
  bool _isLoading = true;
  List<String> _questions = [];
  final Map<String, String> _answers = {};
  final List<TextEditingController> _controllers = [];
  String? _rewrittenText;
  bool _isRewriting = false;

  @override
  void initState() {
    super.initState();
    _analyzeText();
  }

  Future<void> _analyzeText() async {
    try {
      final gemini = ref.read(geminiServiceProvider);
      final questions =
          await gemini.identifyMissingMetrics(widget.originalText);
      setState(() {
        _questions = questions;
        _isLoading = false;
        for (var _ in questions) {
          _controllers.add(TextEditingController());
        }
      });
    } catch (e) {
      // Handle error gracefully
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _generateRewrite() async {
    setState(() => _isRewriting = true);
    for (int i = 0; i < _questions.length; i++) {
      if (_controllers[i].text.isNotEmpty) {
        _answers[_questions[i]] = _controllers[i].text;
      }
    }

    try {
      final gemini = ref.read(geminiServiceProvider);
      final newText =
          await gemini.generateStarKRewrite(widget.originalText, _answers);
      setState(() {
        _rewrittenText = newText;
        _isRewriting = false;
      });
    } catch (e) {
      setState(() => _isRewriting = false);
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.midnightNavy;

    return Container(
      padding: const EdgeInsets.all(24)
          .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavy : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.strategicGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome,
                    color: AppColors.midnightNavy, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("PROACTIVE INTERVIEW",
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.strategicGold, fontSize: 10)),
                  Text("STAR-K Refinement",
                      style: AppTypography.header3
                          .copyWith(color: textColor, fontSize: 16)),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: textColor.withOpacity(0.5)),
              )
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(30.0),
              child: CircularProgressIndicator(color: AppColors.strategicGold),
            ))
          else if (_rewrittenText != null)
            Column(
              children: [
                Text("OPTIMIZED ENTRY:",
                    style: AppTypography.labelSmall.copyWith(
                        color: AppColors.strategicGold, letterSpacing: 2)),
                const SizedBox(height: 12),
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(16),
                  child: Text(_rewrittenText!,
                      style: AppTypography.bodyMedium
                          .copyWith(color: textColor, height: 1.5)),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _rewrittenText = null),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: textColor),
                        child: const Text("TRY AGAIN"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApply(_rewrittenText!);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.strategicGold,
                          foregroundColor: AppColors.midnightNavy,
                        ),
                        child: const Text("APPLY CHANGE"),
                      ),
                    ),
                  ],
                )
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "To reach Executive Standard, we need specific metrics:",
                  style: AppTypography.bodySmall.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ...List.generate(_questions.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("• ${_questions[index]}",
                            style: AppTypography.labelSmall.copyWith(
                                color: textColor, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                            controller: _controllers[index],
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: "Ex: 30%, \$1M, Python/React...",
                              hintStyle:
                                  TextStyle(color: textColor.withOpacity(0.3)),
                              filled: true,
                              fillColor: textColor.withOpacity(0.05),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            )),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isRewriting ? null : _generateRewrite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.midnightNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isRewriting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text("SYNTHESIZE STAR-K",
                            style: AppTypography.labelSmall.copyWith(
                                color: Colors.white, letterSpacing: 2)),
                  ),
                )
              ],
            )
        ],
      ),
    );
  }
}
