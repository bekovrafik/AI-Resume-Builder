import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/features/resume/providers/resume_provider.dart';
import 'package:go_router/go_router.dart';

class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumesAsync = ref.watch(resumesProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                          text: "Career ",
                          style: AppTypography.header1
                              .copyWith(color: Colors.white, fontSize: 32)),
                      TextSpan(
                          text: "Vault.",
                          style: AppTypography.header1.copyWith(
                              color: AppColors.strategicGold, fontSize: 32)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: resumesAsync.when(
                  data: (resumes) {
                    if (resumes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white10),
                              ),
                              child: const Icon(Icons.folder_open,
                                  size: 48, color: Colors.white24),
                            ),
                            const SizedBox(height: 24),
                            Text("ARCHIVE EMPTY",
                                style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white24, letterSpacing: 2)),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(resumesProvider.notifier)
                                  .createResume(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.strategicGold,
                                foregroundColor: AppColors.midnightNavy,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                              ),
                              child: Text("CREATE RESUME",
                                  style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.midnightNavy,
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: resumes.length,
                      itemBuilder: (context, index) {
                        final resume = resumes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () => GoRouter.of(context)
                                .push('/builder/${resume.resumeId}'),
                            child: GlassContainer(
                              padding: const EdgeInsets.all(20),
                              borderRadius: BorderRadius.circular(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.strategicGold
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                        Icons.description_outlined,
                                        color: AppColors.strategicGold),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            resume.data.targetRole ??
                                                'Untitled Resume',
                                            style: AppTypography.header3
                                                .copyWith(
                                                    color: Colors.white,
                                                    fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${resume.theme} • ${DateFormat.yMMMd().format(resume.createdAt)}',
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.white24),
                                    onPressed: () => ref
                                        .read(resumesProvider.notifier)
                                        .deleteResume(resume.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.strategicGold)),
                  error: (err, stack) => Center(
                      child: Text('Error: $err',
                          style: const TextStyle(color: AppColors.errorRed))),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.strategicGold,
        onPressed: () => ref.read(resumesProvider.notifier).createResume(),
        child: const Icon(Icons.add, color: AppColors.midnightNavy),
      ),
    );
  }
}
