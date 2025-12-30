import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:mobile_app/core/services/isar_service.dart';
import 'package:mobile_app/features/resume/models/resume_model.dart';
import 'package:mobile_app/core/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

final resumesProvider =
    StateNotifierProvider<ResumesNotifier, AsyncValue<List<ResumeIteration>>>(
        (ref) {
  final isarService = ref.watch(isarServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  return ResumesNotifier(isarService, firestoreService);
});

class ResumesNotifier extends StateNotifier<AsyncValue<List<ResumeIteration>>> {
  final IsarService _isarService;
  final FirestoreService _firestoreService;

  ResumesNotifier(this._isarService, this._firestoreService)
      : super(const AsyncValue.loading()) {
    loadResumes();
  }

  Future<void> loadResumes() async {
    try {
      final resumes = await _isarService.isar.resumeIterations
          .filter()
          .not()
          .resumeIdEqualTo('MASTER_PROFILE')
          .sortByCreatedAtDesc()
          .findAll();

      state = AsyncValue.data(resumes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createResume({String? theme}) async {
    try {
      final newResume = ResumeIteration()
        ..resumeId = const Uuid().v4()
        ..createdAt = DateTime.now()
        ..theme = theme ?? 'Executive'
        ..data =
            (ResumeData()..targetRole = 'New Role'); // Initialize with empty

      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.resumeIterations.put(newResume);
      });

      // Sync to Cloud (Fire & Forget)
      _firestoreService.syncResumeToCloud(newResume);

      await loadResumes(); // Reload list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteResume(int id) async {
    try {
      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.resumeIterations.delete(id);
      });
      await loadResumes();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
