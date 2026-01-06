import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:mobile_app/core/services/gemini_service.dart';
import 'package:mobile_app/features/profile/providers/profile_provider.dart';
import 'package:mobile_app/features/resume/providers/resume_provider.dart';

// State class for the editor
class ResumeEditorState {
  final bool isProcessing;
  final String? errorMessage;
  final String? resultMessage;

  const ResumeEditorState({
    this.isProcessing = false,
    this.errorMessage,
    this.resultMessage,
  });

  ResumeEditorState copyWith({
    bool? isProcessing,
    String? errorMessage,
    String? resultMessage, // Nullable to clear it
  }) {
    return ResumeEditorState(
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage, // Direct assignment to allow clearing
      resultMessage: resultMessage,
    );
  }
}

// Controller class
class ResumeEditorController extends StateNotifier<ResumeEditorState> {
  final Ref _ref;

  ResumeEditorController(this._ref) : super(const ResumeEditorState());

  Future<String?> handleImport() async {
    try {
      state = state.copyWith(
          isProcessing: true, errorMessage: null, resultMessage: null);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        String text = "";

        if (path.endsWith('.pdf')) {
          text = await ReadPdfText.getPDFtext(path);
        } else if (path.endsWith('.txt')) {
          final file = File(path);
          text = await file.readAsString();
        }

        state = state.copyWith(
          isProcessing: false,
          resultMessage: "Analysis Complete. Data Extracted.",
        );
        return text;
      } else {
        state = state.copyWith(isProcessing: false);
        return null; // Canceled
      }
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: "Import Failed: $e",
      );
      return null;
    }
  }

  Future<String?> handleBuildResume({
    required String historyText,
    required String specsText,
    required String theme,
  }) async {
    if (historyText.isEmpty) {
      state = state.copyWith(errorMessage: "Please input work history first.");
      return null;
    }

    try {
      state = state.copyWith(
          isProcessing: true, errorMessage: null, resultMessage: null);

      final gemini = _ref.read(geminiServiceProvider);
      final profile = _ref.read(profileProvider).value;

      // 1. Optimize/Generate Resume
      final resumeData = await gemini.optimizeResume(
        historyText,
        jobDescription: specsText.isNotEmpty ? specsText : null,
        profileData: profile,
      );

      // 2. Save to Vault (Create new iteration)
      final newResumeId =
          await _ref.read(resumesProvider.notifier).createResume(
                theme: theme,
                data: resumeData,
              );

      state = state.copyWith(
        isProcessing: false,
        resultMessage: "Blueprint Synthesized & Vaulted.",
      );

      return newResumeId;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: "Synthesis Error: $e",
      );
      return null;
    }
  }

  void clearMessages() {
    state = ResumeEditorState(isProcessing: state.isProcessing);
  }
}

// Provider
final resumeEditorProvider =
    StateNotifierProvider<ResumeEditorController, ResumeEditorState>((ref) {
  return ResumeEditorController(ref);
});
