import 'dart:async';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/resume/models/resume_model.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  throw UnimplementedError('IsarService must be initialized');
});

class IsarService {
  final Completer<Isar> _isarCompleter = Completer<Isar>();

  Future<Isar> get isar => _isarCompleter.future;

  Future<void> init() async {
    try {
      if (_isarCompleter.isCompleted) return;

      final dir = await getApplicationDocumentsDirectory();
      final isarInstance = await Isar.open(
        [UserSchema, ResumeIterationSchema],
        directory: dir.path,
      );
      _isarCompleter.complete(isarInstance);
    } catch (e, st) {
      if (!_isarCompleter.isCompleted) {
        _isarCompleter.completeError(e, st);
      }
      rethrow;
    }
  }

  Future<void> clean() async {
    final instance = await isar;
    await instance.writeTxn(() async {
      await instance.clear();
    });
  }
}
