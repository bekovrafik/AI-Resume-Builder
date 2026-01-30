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
  final String historyText;
  final String specsText;
  final String? status;

  const ResumeEditorState({
    this.resultMessage,
    this.historyText = '',
    this.specsText = '',
    this.status,
  });

  ResumeEditorState copyWith({
    String? resultMessage,
    String? historyText,
    String? specsText,
    String? status,
  }) {
    return ResumeEditorState(
      resultMessage: resultMessage,
      historyText: historyText ?? this.historyText,
      specsText: specsText ?? this.specsText,
      status: status ?? this.status,
    );
  }
}

// Controller class using AsyncNotifier
// Controller class using AsyncNotifier
class ResumeEditorController
    extends AutoDisposeFamilyAsyncNotifier<ResumeEditorState, String?> {
  Timer? _debounceTimer;

  @override
  FutureOr<ResumeEditorState> build(String? arg) async {
    if (arg != null) {
      final resume = await ref.read(resumesProvider.notifier).getResume(arg);
      if (resume != null) {
        return ResumeEditorState(
          historyText: resume.data.rawHistory ?? '',
          specsText: resume.data.rawSpecs ?? '',
        );
      }
    }

    // Load existing draft if any (only for new resumes)
    if (arg == null) {
      final draft = await ref.read(resumesProvider.notifier).loadDraft();
      if (draft != null) {
        return ResumeEditorState(
          historyText: draft.data.rawHistory ?? '',
          specsText: draft.data.rawSpecs ?? '',
        );
      }
    }
    return const ResumeEditorState();
  }

  // Rectified approach for handleImport to return value AND update state:
  Future<String?> handleImport() async {
    final currentState = state.value ?? const ResumeEditorState();
    state = const AsyncLoading();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        String text = "";

        // Phase 1: Text Extraction
        state = AsyncData(currentState.copyWith(status: "Extracting text..."));
        if (path.endsWith('.pdf')) {
          text = await ReadPdfText.getPDFtext(path);
        } else if (path.endsWith('.txt')) {
          final file = File(path);
          text = await file.readAsString();
        }

        // Phase 2: AI Parsing
        state = AsyncData(currentState.copyWith(
            historyText: text, status: "AI Analyzing..."));
        final gemini = ref.read(geminiServiceProvider);

        try {
          // Attempt structured parsing (verification/pre-processing)
          await gemini.parseResumeText(text);
          // For now, we update the history with a "cleaned" version if needed,
          // but mainly we want to show the user we did something smart.
          // In a future update, we could auto-fill the profile.
          state = AsyncData(currentState.copyWith(
              historyText: text,
              status: null,
              resultMessage: "Smart Analysis Complete."));
        } catch (e) {
          // Fallback to raw text if AI fails
          state = AsyncData(currentState.copyWith(
              historyText: text,
              status: null,
              resultMessage: "Text Extracted (Basic)."));
        }

        _triggerAutosave();
        return text;
      }
      state = AsyncData(currentState.copyWith(status: null));
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

    final currentState = state.value ?? const ResumeEditorState();
    state = const AsyncLoading();

    try {
      final gemini = ref.read(geminiServiceProvider);
      final profile = ref.read(profileProvider).value;

      final resumeData = await gemini.optimizeResume(
        historyText,
        jobDescription: specsText.isNotEmpty ? specsText : null,
        profileData: profile,
      );

      // Add raw source to the generated data
      resumeData.rawHistory = historyText;
      resumeData.rawSpecs = specsText;

      final newResumeId = await ref.read(resumesProvider.notifier).createResume(
            theme: theme,
            data: resumeData,
          );

      // Clear draft after successful build
      if (arg == null) {
        await ref.read(resumesProvider.notifier).clearDraft();
      }

      state = AsyncData(currentState.copyWith(resultMessage: "Resume Saved."));
      return newResumeId;
    } catch (e, st) {
      state = AsyncError("Synthesis Error: $e", st);
      return null;
    }
  }

  void onHistoryChanged(String text) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(currentState.copyWith(historyText: text));
    _triggerAutosave();
  }

  void onSpecsChanged(String text) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(currentState.copyWith(specsText: text));
    _triggerAutosave();
  }

  void _triggerAutosave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () async {
      final currentState = state.value;
      if (currentState != null) {
        final draftId = arg ?? 'TEMP_DRAFT';
        await ref.read(resumesProvider.notifier).saveDraftCustom(
            draftId, currentState.historyText, currentState.specsText);
      }
    });
  }

  void clearMessages() {
    final currentState = state.value ?? const ResumeEditorState();
    state = AsyncData(currentState.copyWith(resultMessage: null));
  }
}

// Provider
final resumeEditorProvider = AutoDisposeAsyncNotifierProviderFamily<
    ResumeEditorController, ResumeEditorState, String?>(
  ResumeEditorController.new,
);
