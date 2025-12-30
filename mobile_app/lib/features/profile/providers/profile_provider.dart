import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:mobile_app/core/services/isar_service.dart';
import 'package:mobile_app/features/resume/models/resume_model.dart';

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<ResumeData>>((ref) {
  // We need to wait for IsarService to be initialized or use the one provided.
  // Assuming isarServiceProvider returns a valid instance (it throws Unimplemented if not overridden,
  // but we override it in main).
  final isarService = ref.watch(isarServiceProvider);
  return ProfileNotifier(isarService);
});

class ProfileNotifier extends StateNotifier<AsyncValue<ResumeData>> {
  final IsarService _isarService;

  ProfileNotifier(this._isarService) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final profile = await _isarService.isar.resumeIterations
          .filter()
          .resumeIdEqualTo('MASTER_PROFILE')
          .findFirst();

      state = AsyncValue.data(profile?.data ?? ResumeData());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveProfile(ResumeData data) async {
    // Optimistic update or wait? Let's wait.
    // state = const AsyncValue.loading(); // preserve current data if possible or loading
    try {
      final existing = await _isarService.isar.resumeIterations
          .filter()
          .resumeIdEqualTo('MASTER_PROFILE')
          .findFirst();

      final iteration = existing ?? ResumeIteration()
        ..resumeId = 'MASTER_PROFILE'
        ..createdAt = DateTime.now()
        ..theme = 'Executive';

      iteration.data = data;

      await _isarService.isar.writeTxn(() async {
        await _isarService.isar.resumeIterations.put(iteration);
      });

      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
