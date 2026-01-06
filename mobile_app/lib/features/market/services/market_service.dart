import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/market/models/market_card_model.dart';
import 'package:mobile_app/core/services/gemini_service.dart';

import 'package:html_unescape/html_unescape.dart';

class MarketService {
  final GeminiService? _geminiService;
  final _unescape = HtmlUnescape();

  static const String _apiKey = '82608568-43f8-4566-971f-a242711dc749';
  static const String _baseUrl = 'https://jooble.org/api/';

  MarketService({GeminiService? geminiService})
      : _geminiService = geminiService;

  Future<List<MarketCardModel>> fetchFeed(String role, String location) async {
    // Unified list processing
    List<MarketCardModel> rawJobs = [];

    // 1. Try Jooble
    if (rawJobs.isEmpty) {
      try {
        final url = Uri.parse('$_baseUrl$_apiKey');
        final requestBody = jsonEncode({
          'keywords': role,
          'location': location,
        });

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> jobs = data['jobs'] ?? [];
          rawJobs = jobs.map((job) {
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
      } catch (e) {
        // Fallthrough
      }
    }

    // 2. Fallback to Gemini Grounding
    if (rawJobs.isEmpty && _geminiService != null) {
      try {
        final groundJobs =
            await _geminiService.searchJobsWithGrounding(role, location);
        rawJobs = groundJobs.map((job) {
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
        // Fallthrough
      }
    }

    return _injectAds(rawJobs);
  }

  List<MarketCardModel> _injectAds(List<MarketCardModel> jobs) {
    if (jobs.isEmpty) return [];

    final List<MarketCardModel> feed = [];
    for (int i = 0; i < jobs.length; i++) {
      feed.add(jobs[i]);
      // Inject Ad after every 3rd card (indices 2, 5, 8...)
      if ((i + 1) % 3 == 0) {
        feed.add(MarketCardModel(
          id: "ad_slab_${i ~/ 3}",
          type: MarketCardType.ad,
          // Ad properties can be generic here, view handles the BannerAd widget
          adHeadline: "Featured Opportunity",
          adBody: "Apply with one tap using our AI.",
        ));
      }
    }
    return feed;
  }

  String _cleanSnippet(String snippet) {
    // Remove HTML tags often present in Jooble snippets
    final text = snippet.replaceAll(RegExp(r'<[^>]*>'), '');
    // Decode entities like &nbsp;
    return _unescape.convert(text).trim();
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
