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

  Future<String?> handleImport() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
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

        return const ResumeEditorState(
            resultMessage: "Analysis Complete. Data Extracted.");
      } else {
        return const ResumeEditorState(); // Canceled, reset processing
      }
    });

    if (state.hasValue &&
        state.value!.resultMessage == "Analysis Complete. Data Extracted.") {
      // Return text separately?
      // AsyncNotifier isn't designed to return values from mutations easily *and* update state.
      // We'll rely on the side-effect or return null and let the UI read the text from a separate provider if needed?
      // For now, to keep API similar:
      // We unfortunately can't return the text *from* this void/state-updating method cleanly if we are fully `guard`ing.
      // So we will just return null here and let the UI handle the state change?
      // Actually, checking original usage: `final importedText = await handleImport();`
      // We need to return the text.
      // So we can't just strictly use `state = await AsyncValue.guard(...)` for the *return* value if it's diff from state.
      // We'll do a hybrid.
    }
    return null; // Refactor to just update state?
  }

  // Rectified approach for handleImport to return value AND update state:
  Future<String?> handleImportWithReturn() async {
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

      state = const AsyncData(
          ResumeEditorState(resultMessage: "Blueprint Synthesized & Vaulted."));
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
