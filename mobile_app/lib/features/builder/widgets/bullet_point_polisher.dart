import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/premium/providers/polish_token_provider.dart';
import 'package:mobile_app/core/services/ad_synchronization_service.dart';

class BulletPointPolisher extends ConsumerStatefulWidget {
  final String initialText;
  final Function(String) onPolished;

  const BulletPointPolisher({
    super.key,
    required this.initialText,
    required this.onPolished,
  });

  @override
  ConsumerState<BulletPointPolisher> createState() =>
      _BulletPointPolisherState();
}

class _BulletPointPolisherState extends ConsumerState<BulletPointPolisher> {
  late TextEditingController _controller;
  bool _isPolishing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  Future<void> _polishBullet() async {
    final creditNotifier = ref.read(polishTokenProvider.notifier);
    final hasCredit = await creditNotifier.spendCredit();

    if (hasCredit) {
      _performPolish();
    } else {
      _showAdPrompt();
    }
  }

  void _showAdPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Insufficient AI Credits"),
        content: const Text("Watch a quick ad to earn 5 AI Polish Credits?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final adService = ref.read(adSynchronizationProvider);
              adService.showRewardedAd(
                onUserEarnedReward: (reward) {
                  ref.read(polishTokenProvider.notifier).addCredits(5);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Earned 5 Credits! Ready to Polish.")),
                  );
                },
              );
            },
            child: const Text("Watch Ad"),
          )
        ],
      ),
    );
  }

  Future<void> _performPolish() async {
    setState(() => _isPolishing = true);

    // Simulate AI Call (Replace with GeminiService.getBulletAlternatives)
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isPolishing = false;
      // Mock result - in real app, use Gemini response
      _controller.text =
          "Streamlined operations by 20% through strategic implementation of ${_controller.text}";
    });

    widget.onPolished(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final credits = ref.watch(polishTokenProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Bullet Point", style: AppTextStyles.bodySmall),
              Row(
                children: [
                  const Icon(Icons.bolt,
                      size: 16, color: AppColors.strategicGold),
                  Text("$credits Credits",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(8),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isPolishing ? null : _polishBullet,
              icon: _isPolishing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_fix_high, size: 16),
              label: const Text("Polish (1 Credit)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.midnightNavy,
                foregroundColor: AppColors.strategicGold,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          )
        ],
      ),
    );
  }
}
