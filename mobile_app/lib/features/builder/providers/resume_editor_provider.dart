import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:mobile_app/core/services/gemini_service.dart';
import 'package:mobile_app/features/profile/providers/profile_provider.dart';
import 'package:mobile_app/features/resume/providers/resume_provider.dart';

// State class for the editor (Simplified for AsyncValue usage)
class ResumeEditorState {
  final String? resultMessage;

  const ResumeEditorState({this.resultMessage});

  ResumeEditorState copyWith({String? resultMessage}) {
    return ResumeEditorState(resultMessage: resultMessage);
  }
}

// Controller class using AsyncNotifier
class ResumeEditorController
    extends AutoDisposeAsyncNotifier<ResumeEditorState> {
  @override
  FutureOr<ResumeEditorState> build() {
    return const ResumeEditorState();
  }

  // Rectified approach for handleImport to return value AND update state:
  Future<String?> handleImport() async {
    state = const AsyncLoading();
    try {
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

        state = const AsyncData(ResumeEditorState(
            resultMessage: "Analysis Complete. Data Extracted."));
        return text;
      }
      state = const AsyncData(ResumeEditorState());
      return null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<String?> handleBuildResume({
    required String historyText,
    required String specsText,
    required String theme,
  }) async {
    if (historyText.isEmpty) {
      state =
          AsyncError("Please input work history first.", StackTrace.current);
      return null;
    }

    state = const AsyncLoading();

    try {
      final gemini = ref.read(geminiServiceProvider);
      // Accessing future provider value if profileProvider is async?
      // It was: ref.read(profileProvider).value;
      // We should watch it or read it.
      final profile = ref.read(profileProvider).value;

      final resumeData = await gemini.optimizeResume(
        historyText,
        jobDescription: specsText.isNotEmpty ? specsText : null,
        profileData: profile,
      );

      final newResumeId = await ref.read(resumesProvider.notifier).createResume(
            theme: theme,
            data: resumeData,
          );

      state =
          const AsyncData(ResumeEditorState(resultMessage: "Resume Saved."));
      return newResumeId;
    } catch (e, st) {
      state = AsyncError("Synthesis Error: $e", st);
      return null;
    }
  }

  void clearMessages() {
    state = const AsyncData(ResumeEditorState());
  }
}

// Provider
final resumeEditorProvider =
    AutoDisposeAsyncNotifierProvider<ResumeEditorController, ResumeEditorState>(
        () {
  return ResumeEditorController();
});
