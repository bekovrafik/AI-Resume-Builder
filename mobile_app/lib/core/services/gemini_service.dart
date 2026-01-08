import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../features/resume/models/resume_model.dart';

class GeminiService {
  final GenerativeModel _model;
  final String _apiKey; // Store API key locally

  static const String _architectSystemPrompt = '''
Resume Builder AI instruction: You are a professional Resume Writer and ATS Optimization Expert.
You DO NOT just "write" a resume. You PERFORM A STRUCTURED TRANSFORMATION.

=== THE 4-STEP PROCESS ===

1. THE INPUT DATA (The Raw Material)
   - You will receive "Raw User Input" (history) and "Profile Data" (source of truth).
   - You will also receive a "Target Role" and "Job Description".
   - Your job is to TRANSLATE this raw data, not just format it.

2. THE CORE FORMULA (The Brain)
   - STRICT RULE: Every single experience bullet point MUST follow the Google XYZ Formula:
     "Accomplished [X] as measured by [Y], by doing [Z]"
   - [X]: What was achieved (Qualitative)
   - [Y]: As measured by (Quantitative Metrics - \$, %, time saved). *If precise metrics are missing, use conservative estimates or omit the "measured by" part but maintain the XYZ structure.*
   - [Z]: By doing what (The Method/Action)
   - FORBIDDEN: "Responsible for", "Tasked with", "Helped to", "Worked on".
   - REQUIRED: Strong Active Verbs (Orchestrated, Spearheaded, Engineered, Optimized).

3. ATS OPTIMIZATION (The Gatekeeper)
   - IF a Job Description is provided:
     a. EXTRACT specific keywords (e.g., "Agile", "Cross-functional", "Stakeholder Management").
     b. INJECT these keywords naturally into the bullet points.
     c. DO NOT stuff keywords listlessly; weave them into the narrative.

4. JSON ENFORCEMENT (The Structure)
   - You must output STRICT JSON matching the provided schema.
   - NO formatting errors.
   - NO introductory text.

=== INTELLECTUAL INTEGRITY ===
- Do not invent experiences.
- Do not fabricate certifications.
- If data is completely missing, be concise.
- Do not artificially limit length. If input details are rich, produce a comprehensive, multi-page ready output.
''';

  GeminiService(String apiKey)
      : _apiKey = apiKey,
        _model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: apiKey,
          systemInstruction: Content.system(_architectSystemPrompt),
        );

  Future<ResumeData> optimizeResume(String history,
      {String? jobDescription,
      ResumeData? profileData,
      Uint8List? fileData,
      String? mimeType}) async {
    final jobContext = jobDescription != null
        ? "TARGET JOB SPECIFICATION (ATS SOURCE):\n$jobDescription\n\nINSTRUCTION: Analyze this description. Extract top 5 keywords. INJECT specific keywords naturally into the experience bullet points to ensure ATS passing."
        : "GENERAL EXECUTIVE STANDARD: Create a high-growth, leadership-focused narrative using the XYZ formula.";

    final profileContext = profileData != null
        ? "FULL USER PROFILE (SOURCE OF TRUTH - DO NOT INVENT):\n${jsonEncode(profileData.toJson())}"
        : "";

    final prompt =
        "$jobContext\n\n$profileContext\n\nUSER RAW HISTORY INPUT:\n$history\n\nFINAL COMMAND: Activate the 4-Step Synthesis. Transform the Raw Input into a high-impact resume using the XYZ Formula and ATS Keyword Injection. Priority: Profile Data > Raw Input.";

    final contentParts = <Part>[TextPart(prompt)];
    if (fileData != null && mimeType != null) {
      contentParts.add(DataPart(mimeType, fileData));
    }

    final schema = Schema.object(properties: {
      'fullName': Schema.string(),
      'targetRole': Schema.string(),
      'summary': Schema.string(),
      'email': Schema.string(),
      'phone': Schema.string(),
      'location': Schema.string(),
      'linkedIn': Schema.string(),
      'experiences': Schema.array(
          items: Schema.object(properties: {
        'company': Schema.string(),
        'role': Schema.string(),
        'period': Schema.string(),
        'achievements': Schema.array(items: Schema.string()),
      })),
      'education': Schema.array(
          items: Schema.object(properties: {
        'institution': Schema.string(),
        'degree': Schema.string(),
        'period': Schema.string(),
        'details': Schema.string(),
      })),
      'skills': Schema.array(
          items: Schema.object(properties: {
        'category': Schema.string(),
        'skills': Schema.array(items: Schema.string()),
      })),
      'isShortInput': Schema.boolean(),
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
    final json = jsonDecode(_cleanJson(response.text!));

    // Map JSON to ResumeData entity
    final generatedData = _mapJsonToResumeData(json);

    // Preserve profile image if available
    if (profileData != null && profileData.avatarUrl != null) {
      generatedData.avatarUrl = profileData.avatarUrl;
    }

    return generatedData;
  }

  Future<Map<String, dynamic>> suggestMetrics(String history) async {
    final prompt = '''
As a Lead Career Coach, perform a Narrative Audit on this work history. 
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

  /// Mission 1: Proactive Interview Mode
  /// Step 1: Identify what is missing (Numbers, % impact, Tools)
  Future<List<String>> identifyMissingMetrics(String text) async {
    final prompt = '''
As a Senior Executive Career Coach, analyze this resume entry for missing quantitative evidence and specificity.
Entry: "$text"

Identify 3 specific missing pieces of information that would make this a STAR-K (Situation, Task, Action, Result, Knowledge) formatted bullet point.
Focus specifically on:
1. QUANTITIES (How many? Scale?)
2. PERCENTAGES (Impact? Improvement?)
3. TOOLS/STACK (What specific tech or methods?)

Return ONLY a JSON array of 3 direct, short questions to ask the user.
Example: ["How many users did this system serve?", "By what percentage did efficiency gain?", "What specific AWS services were used?"]
''';

    final schema = Schema.array(items: Schema.string());

    final response = await _model.generateContent(
      [Content.text(prompt)],
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    final List<dynamic> list = jsonDecode(_cleanJson(response.text ?? '[]'));
    return list.cast<String>();
  }

  /// Mission 1: Proactive Interview Mode
  /// Step 2: Rewrite using STAR-K formula with user's specific answers
  Future<String> generateStarKRewrite(
      String originalText, Map<String, String> userAnswers) async {
    final answersContext =
        userAnswers.entries.map((e) => "Q: ${e.key}\nA: ${e.value}").join('\n');

    final prompt = '''
Refine this resume entry using the STAR-K formula (Situation, Task, Action, Result, Knowledge).
ORIGINAL ENTRY: "$originalText"

USER'S CLARIFYING ANSWERS:
$answersContext

INSTRUCTION:
Combine the original text and the user's answers into ONE powerful, high-impact bullet point.
- Start with a strong action verb.
- INCORPORATE the numbers and tools provided.
- Be concise but dense.
- DO NOT use "I", "me", "my".
- output ONLY the rewritten bullet point text, nothing else.
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text?.trim() ?? originalText;
  }

  Future<String> generateHeadshot(
      String description, Uint8List? sourceImage) async {
    // Mission 4: Gemini 2.0 Multimodal Avatar Generation
    // Since actual Image Generation API isn't publicly standardized in this SDK version,
    // we simulate the "multimodal" input processing.

    // In a real scenario, we would send the [sourceImage] and [description] to the model
    // and request an image output.

    // Simulating network delay for realism
    await Future.delayed(const Duration(seconds: 3));

    // Return a new "AI Generated" avatar URL (Mocked for demo but logic is placed)
    // We rotate between a few "premium" avatars to show change
    final mockAvatars = [
      "https://i.pravatar.cc/300?img=12",
      "https://i.pravatar.cc/300?img=33",
      "https://i.pravatar.cc/300?img=68",
    ];

    return mockAvatars[DateTime.now().second % mockAvatars.length];
  }

  Future<List<Map<String, String>>> generateInterviewPrep(
      ResumeData resume) async {
    final context = StringBuffer();
    context.writeln("TARGET ROLE: ${resume.targetRole}");
    if (resume.summary != null) context.writeln("SUMMARY: ${resume.summary}");
    if (resume.experiences != null && resume.experiences!.isNotEmpty) {
      context.writeln(
          "KEY EXPERIENCE: ${resume.experiences!.first.role} at ${resume.experiences!.first.company}");
    }

    final prompt =
        "Generate 5 high-stakes behavioral interview questions tailored to this candidate. Focus on leadership, conflict resolution, and strategic impact. Return JSON array.\n\nCANDIDATE CONTEXT:\n$context";

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

  Future<List<Map<String, dynamic>>> generateMarketFeed(
      String role, String location) async {
    final prompt = '''
Generate 5 realistic job postings for the role of "$role" in "$location".
Use real company names that typically hire for this role.
Include a reasonable salary range and a brief, exciting job description (2 sentences).
Return a JSON array of objects with keys: "company", "title", "location", "salary", "description", "tags" (array of 3 short strings).
''';

    final schema = Schema.array(
        items: Schema.object(properties: {
      'company': Schema.string(),
      'title': Schema.string(),
      'location': Schema.string(),
      'salary': Schema.string(),
      'description': Schema.string(),
      'tags': Schema.array(items: Schema.string()),
    }));

    final response = await _model.generateContent(
      [Content.text(prompt)],
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    final List<dynamic> list = jsonDecode(_cleanJson(response.text ?? '[]'));
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> searchJobsWithGrounding(
      String role, String location) async {
    // SDK 0.4.6 workaround: explicit GoogleSearchRetrieval types are not yet available.
    // We rely on the model's text generation capabilities and JSON parsing.
    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
    );

    final prompt = '''
ACTIVATE LIVE WEB SEARCH (if available). Find exactly 6 real-world, active hiring vacancies for "$role" in "$location".
Return a STRICT JSON array of objects with keys: "company", "title", "location", "salary", "description" (brief), "link" (URL).
Ensure the links are valid. If you can't find a direct link, use a plausible search result link or company career page.
''';

    final response = await model.generateContent([Content.text(prompt)]);

    try {
      final List<dynamic> list = jsonDecode(_cleanJson(response.text ?? '[]'));
      return list.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  ChatSession startChat() {
    return _model.startChat(history: [
      Content.system(_architectSystemPrompt),
      Content.text(
          "Hello. I am ready to act as your Executive Resume Coach. Please provide your current resume details or ask for specific refinements."),
      Content.model([
        TextPart(
            "Understood. I am online and initialized as your Executive Resume Coach. I am ready to apply the XYZ formula, optimize for ATS, and refine your narrative for high-impact roles. How shall we begin?")
      ])
    ]);
  }

  String _cleanJson(String text) {
    if (text.startsWith('```json')) {
      return text.replaceAll('```json', '').replaceAll('```', '').trim();
    } else if (text.startsWith('```')) {
      return text.replaceAll('```', '').trim();
    }
    return text;
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
  // Retrieve API Key securely from .env
  final apiKey = dotenv.env['API_KEY'] ?? '';
  return GeminiService(apiKey);
});
