import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/services/gemini_service.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/core/ui/custom_snackbar.dart';
import 'package:mobile_app/features/resume/providers/resume_provider.dart';
import 'package:mobile_app/l10n/app_localizations.dart';

class InterviewPrepScreen extends ConsumerStatefulWidget {
  const InterviewPrepScreen({super.key});

  @override
  ConsumerState<InterviewPrepScreen> createState() =>
      _InterviewPrepScreenState();
}

class _InterviewPrepScreenState extends ConsumerState<InterviewPrepScreen> {
  bool _isLoading = false;
  List<Map<String, String>> _questions = [];

  Future<void> _generateQuestions() async {
    final resumesAsync = ref.read(resumesProvider);
    final resumes = resumesAsync.value;

    if (resumes == null || resumes.isEmpty) {
      CustomSnackBar.show(
        context,
        message: AppLocalizations.of(context)!.noResumeFoundError,
        type: SnackBarType.error,
      );
      return;
    }

    // Use the latest resume
    final latestResume = resumes.first.data;

    setState(() => _isLoading = true);

    try {
      final gemini = ref.read(geminiServiceProvider);
      final results = await gemini.generateInterviewPrep(latestResume);
      if (mounted) {
        setState(() {
          _questions = results;
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: AppLocalizations.of(context)!.strategyError(e.toString()),
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.interviewStrategy,
            style: AppTypography.header3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                if (_questions.isEmpty && !_isLoading)
                  _buildEmptyState()
                else if (_isLoading)
                  _buildLoadingState()
                else
                  Expanded(child: _buildQuestionsList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          const Icon(Icons.psychology,
              size: 48, color: AppColors.strategicGold),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.tacticalAnalysis,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.strategicGold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.generateQuestionsDesc,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _generateQuestions,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.strategicGold,
              foregroundColor: AppColors.midnightNavy,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              _isLoading
                  ? AppLocalizations.of(context)!.analyzing
                  : AppLocalizations.of(context)!.generateStrategy,
              style: AppTypography.labelSmall
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Text(
          AppLocalizations.of(context)!.awaitingDeployment,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white30,
            letterSpacing: 4.0,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.strategicGold),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.preparingScenarios,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.strategicGold,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsList() {
    return ListView.separated(
      itemCount: _questions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final q = _questions[index];
        return GlassContainer(
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!
                    .questionLabel((index + 1).toString()),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.strategicGold,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                q['question'] ?? '',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white10),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.intentLabel(q['intent'] ?? ''),
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white70,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
