import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/market/models/market_card_model.dart';
import 'package:mobile_app/core/services/gemini_service.dart';

class MarketService {
  final GeminiService? _geminiService;

  static const String _apiKey = '82608568-43f8-4566-971f-a242711dc749';
  static const String _baseUrl = 'https://jooble.org/api/';

  MarketService({GeminiService? geminiService})
      : _geminiService = geminiService;

  Future<List<MarketCardModel>> fetchFeed(String role, String location) async {
    try {
      final url = Uri.parse('$_baseUrl$_apiKey');

      final requestBody = jsonEncode({
        'keywords': role,
        'location': location,
      });

      // print("JOOBLE REQUEST: $url");
      // print("JOOBLE BODY: $requestBody");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      // print("JOOBLE RESPONSE CODE: ${response.statusCode}");
      // print("JOOBLE RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> jobs = data['jobs'] ?? [];

        if (jobs.isNotEmpty) {
          return jobs.map((job) {
            return MarketCardModel(
              id: job['id']?.toString() ?? DateTime.now().toString(),
              type: MarketCardType.job,
              title: job['title'] ?? 'Unknown Role',
              company: job['company'] ?? 'Confidential',
              location: job['location'] ?? location,
              salaryRange: job['salary'] ?? 'Competitive',
              description: _cleanSnippet(job['snippet'] ?? ''),
              tags: _extractTags(job['snippet'] ?? ''),
              url: job['link'] ?? 'https://jooble.org',
            );
          }).toList();
        }
      }
    } catch (e) {
      // print("Jooble Error: $e");
    }

    // Fallback: Use Gemini Grounding if Jooble failed or returned 0
    if (_geminiService != null) {
      try {
        // print("FALLBACK: Using Gemini Grounding for $role in $location");
        final groundJobs =
            await _geminiService.searchJobsWithGrounding(role, location);

        return groundJobs.map((job) {
          return MarketCardModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() +
                (job['title'] ?? ''),
            type: MarketCardType.job,
            title: job['title'] ?? 'Unknown Role',
            company: job['company'] ?? 'Google Search Result',
            location: job['location'] ?? location,
            salaryRange: job['salary'] ?? 'Competitive',
            description: _cleanSnippet(job['description'] ?? ''),
            tags: List<String>.from(job['tags'] ?? []),
            url: job['link'] ?? 'https://google.com',
          );
        }).toList();
      } catch (e) {
        // print("Gemini Fallback Error: $e");
      }
    }

    return [];
  }

  String _cleanSnippet(String snippet) {
    // Remove HTML tags often present in Jooble snippets
    return snippet.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  List<String> _extractTags(String snippet) {
    // Simple extraction of common keywords from description for tags
    final keywords = [
      'Remote',
      'Hybrid',
      'Senior',
      'Junior',
      'Contract',
      'Full-time'
    ];
    return keywords.where((k) => snippet.contains(k)).take(3).toList();
  }
}

final marketServiceProvider = Provider<MarketService>((ref) {
  final gemini = ref.read(geminiServiceProvider);
  return MarketService(geminiService: gemini);
});
