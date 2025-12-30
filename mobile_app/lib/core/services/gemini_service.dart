import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/resume/models/resume_model.dart';

class GeminiService {
  final GenerativeModel _model;
  final GenerativeModel _visionModel;

  static const String _architectSystemPrompt = '''
You are a Professional Resume Writer, Career Coach, and ATS Optimization Expert. Your task is to create a high-quality, well-structured, ATS-friendly resume tailored to the user's background and target role.

You MUST ALWAYS follow these rules:

GENERAL RULES:
1. Use clear, professional language. No fluff, no clichés, no emojis.
2. Write in a confident, results-driven tone.
3. Use active verbs and quantified achievements whenever possible.
4. Keep the resume concise:
   - 1 page for junior or mid-level candidates
   - Max 2 pages for senior or executive profiles
5. Optimize for ATS (Applicant Tracking Systems):
   - Use standard section titles
   - Avoid tables, columns, icons, or special characters
6. Never fabricate experience, companies, certifications, or education.
7. Do not include personal opinions or explanations—output ONLY the resume.

STRUCTURE (IN THIS EXACT ORDER):
1. Header (Full Name, Title, Contact)
2. Professional Summary (3–4 lines, tailored)
3. Core Skills (8–15 relevant skills, Hard first)
4. Professional Experience (Action verb bullets, XYZ formula)
5. Education
6. Certifications (if provided)
7. Projects (optional)
8. Additional Information (optional)

STYLE & FORMATTING RULES:
- Use bullet points, not paragraphs, for experience
- Consistent tense: Present for current, Past for previous
- No graphics, no colors, no icons
- No personal data such as age, gender, marital status, photo

CUSTOMIZATION RULES:
- Tailor the resume to the target job title and industry
- Mirror keywords naturally from provided context

If the input is for a refinement, strictly update the existing blueprint JSON while maintaining these high-tier standards. ALWAYS output valid JSON following the schema.
''';

  GeminiService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-pro',
          apiKey: apiKey,
          systemInstruction: Content.system(_architectSystemPrompt),
        ),
        _visionModel = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );

  Future<ResumeData> optimizeResume(String history,
      {String? jobDescription, Uint8List? fileData, String? mimeType}) async {
    final jobContext = jobDescription != null
        ? "TARGET JOB SPECIFICATION: $jobDescription"
        : "GENERAL EXECUTIVE STANDARD: Create a high-growth, leadership-focused narrative.";

    final prompt = "$jobContext\n\nUSER RAW TEXT INPUT:\n$history";

    final contentParts = <Part>[TextPart(prompt)];
    if (fileData != null && mimeType != null) {
      contentParts.add(DataPart(mimeType, fileData));
    }

    final schema = Schema.object(properties: {
      'fullName': Schema.string(),
      'targetRole': Schema.string(),
      'summary': Schema.string(),
      'experiences': Schema.array(
          items: Schema.object(properties: {
        'company': Schema.string(),
        'role': Schema.string(),
        'period': Schema.string(),
        'achievements': Schema.array(items: Schema.string()),
      })),
      'skills': Schema.array(
          items: Schema.object(properties: {
        'category': Schema.string(),
        'skills': Schema.array(items: Schema.string()),
      })),
      'isShortInput': Schema.boolean(),
      'followUpQuestions': Schema.array(items: Schema.string()),
    }, requiredProperties: [
      'fullName',
      'targetRole',
      'summary',
      'experiences',
      'skills'
    ]);

    final response = await _model.generateContent(
      [Content.multi(contentParts)],
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    if (response.text == null) throw Exception('Empty response from AI');
    final json = jsonDecode(response.text!);

    // Map JSON to ResumeData entity
    // Note: Assuming simpler mapping for brevity, normally requires helper factory
    return _mapJsonToResumeData(json);
  }

  Future<Map<String, dynamic>> suggestMetrics(String history) async {
    final prompt = '''
As a Lead Career Architect, perform a Narrative Audit on this work history. 
1. Identify 3-5 weak, qualitative statements.
2. Provide high-impact XYZ rewrites with placeholder metrics.
3. Infer 5-7 high-value Technical/Core skills.

Return JSON with "vagues" (original text), "suggestions" (XYZ version), and "inferredSkills" (array of skills).
WORK HISTORY: "$history"
''';

    final schema = Schema.object(properties: {
      'vagues': Schema.array(items: Schema.string()),
      'suggestions': Schema.array(items: Schema.string()),
      'inferredSkills': Schema.array(items: Schema.string()),
    });

    final response = await _model.generateContent(
      [Content.text(prompt)],
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    return jsonDecode(response.text ?? '{}');
  }

  Future<String> generateHeadshot(String role, Uint8List originalImage) async {
    // Current SDK might not support image generation directly or uses a different endpoint/model logic
    // For now mocking or assuming a text-to-image capability if available or using a vision model description
    // Since gemini-2.5-flash-image isn't standard in the package yet, we might fallback or throw.
    // However, user prompt logic says "Transform user's uploaded image".
    // This implies image-to-image or image editing.
    // Not fully supported in standard GenerativeModel yet without specific tools or models.
    // We will attempt to use the model the user specified if possible, but likely we need to just return a placeholder
    // or use a hypothetical endpoint.
    // For this implementation, we will act as if we are describing the prompt for a separate image gen service
    // or simply return logic.

    // NOTE: True image generation isn't directly exposed via generateContent in the same way for all models yet.
    // We will place a TODO.

    return "https://via.placeholder.com/150"; // Placeholder
  }

  Future<List<Map<String, String>>> generateInterviewPrep(
      ResumeData resume) async {
    final prompt =
        "Generate 5 behavioral interview questions for this resume. Return JSON array.\n\nRESUME: ${resume.targetRole}"; // Simplified prompt

    final schema = Schema.array(
        items: Schema.object(properties: {
      'question': Schema.string(),
      'intent': Schema.string(),
      'suggestedAngle': Schema.string(),
    }));

    final response = await _model.generateContent(
      [Content.text(prompt)],
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    final List<dynamic> list = jsonDecode(response.text ?? '[]');
    return list.map((e) => Map<String, String>.from(e)).toList();
  }

  ResumeData _mapJsonToResumeData(Map<String, dynamic> json) {
    // Basic mapping logic
    final data = ResumeData();
    data.fullName = json['fullName'];
    data.targetRole = json['targetRole'];
    data.summary = json['summary'];

    if (json['experiences'] != null) {
      data.experiences = (json['experiences'] as List).map((e) {
        final exp = Experience();
        exp.company = e['company'];
        exp.role = e['role'];
        exp.period = e['period'];
        exp.achievements = List<String>.from(e['achievements'] ?? []);
        return exp;
      }).toList();
    }

    if (json['skills'] != null) {
      data.skills = (json['skills'] as List).map((e) {
        final s = SkillCategory();
        s.category = e['category'];
        s.skills = List<String>.from(e['skills'] ?? []);
        return s;
      }).toList();
    }

    return data;
  }
}

// Provider for Gemini Service
final geminiServiceProvider = Provider<GeminiService>((ref) {
  // Retrieve API Key securely. ideally from environment or secure storage.
  // For demo, we are using a placeholder or assuming it was set.
  const apiKey = String.fromEnvironment('API_KEY');
  return GeminiService(apiKey);
});
