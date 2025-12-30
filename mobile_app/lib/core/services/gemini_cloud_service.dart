import 'package:cloud_functions/cloud_functions.dart';

class GeminiCloudService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// This is the recommended architecture for Production.
  /// Instead of calling Gemini API directly from the client (which exposes the API Key),
  /// we call a Firebase Cloud Function.
  Future<String> generateResumeSection(String prompt) async {
    try {
      final result =
          await _functions.httpsCallable('generateResumeSection').call({
        'prompt': prompt,
      });
      return result.data as String;
    } catch (e) {
      // Handle error
      return "Error calling cloud function: $e";
    }
  }

  /// Example for XYZ Audit
  Future<String> performXyzAudit(String resumeText) async {
    final result = await _functions.httpsCallable('performXyzAudit').call({
      'text': resumeText,
    });
    return result.data as String;
  }
}
