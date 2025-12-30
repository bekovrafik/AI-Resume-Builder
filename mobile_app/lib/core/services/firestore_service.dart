import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/resume/models/resume_model.dart';
import 'package:mobile_app/features/auth/services/auth_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(ref);
});

class FirestoreService {
  final Ref _ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirestoreService(this._ref);

  Future<void> syncResumeToCloud(ResumeIteration resume) async {
    final user = _ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    try {
      // Structure: users/{uid}/resumes/{resumeId}
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('resumes')
          .doc(resume.resumeId)
          .set({
        ...resume.data.toJson(), // Assuming toJson exists or we map manually
        'theme': resume.theme,
        'createdAt': resume.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Handle or log error
      rethrow;
    }
  }

  Future<void> fetchResumesFromCloud() async {
    // This would ideally pull data and update Isar
    // Implementation skipped for MVP simplicity, but this is the hook.
  }
}
