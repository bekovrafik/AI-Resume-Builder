import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/features/premium/providers/polish_token_provider.dart';
import 'package:mobile_app/core/ui/custom_snackbar.dart';

class TokenHUD extends ConsumerWidget {
  const TokenHUD({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credits = ref.watch(polishTokenProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: InkWell(
        onTap: () => _showRefillDialog(context, ref),
        borderRadius: BorderRadius.circular(20),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          borderRadius: BorderRadius.circular(20),
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.midnightNavy.withValues(alpha: 0.1),
          border: Border.all(
            color: AppColors.strategicGold.withValues(alpha: 0.3),
            width: 1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bolt,
                size: 16,
                color: AppColors.strategicGold,
              ),
              const SizedBox(width: 4),
              Text(
                credits.toString(),
                style: AppTypography.labelMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.midnightNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRefillDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.midnightNavy,
        title: Text(
          "AI Credits",
          style: AppTypography.header3.copyWith(color: Colors.white),
        ),
        content: Text(
          "You use credits for premium AI polishing and smart suggestions. Refill for free today?",
          style: AppTypography.bodySmall.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Maybe Later", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.strategicGold,
              foregroundColor: AppColors.midnightNavy,
            ),
            onPressed: () {
              Navigator.pop(context);
              ref.read(polishTokenProvider.notifier).addCredits(5);
              CustomSnackBar.show(
                context,
                message: "Refilled 5 Credits (Free Beta Offer)",
                type: SnackBarType.success,
              );
            },
            child: const Text("Refill (+5)"),
          )
        ],
      ),
    );
  }
}
