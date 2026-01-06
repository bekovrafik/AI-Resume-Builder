import 'package:uuid/uuid.dart';

enum MarketCardType { job, ad }

class MarketCardModel {
  final String id;
  final MarketCardType type;

  // Job Properties
  final String? title;
  final String? company;
  final String? location;
  final String? salaryRange;
  final List<String>? tags;
  final String? description;
  final String? logoUrl;
  final String? url;

  // Ad Properties
  final String? adHeadline;
  final String? adBody;
  final String? adCta;

  MarketCardModel({
    required this.id,
    required this.type,
    this.title,
    this.company,
    this.location,
    this.salaryRange,
    this.tags,
    this.description,
    this.logoUrl,
    this.url,
    this.adHeadline,
    this.adBody,
    this.adCta,
  });

  factory MarketCardModel.job({
    required String title,
    required String company,
    required String location,
    required String salaryRange,
    required List<String> tags,
    required String description,
    String? logoUrl,
    String? url,
  }) {
    return MarketCardModel(
      id: const Uuid().v4(),
      type: MarketCardType.job,
      title: title,
      company: company,
      location: location,
      salaryRange: salaryRange,
      tags: tags,
      description: description,
      logoUrl: logoUrl,
      url: url,
    );
  }

  factory MarketCardModel.ad() {
    return MarketCardModel(
      id: const Uuid().v4(),
      type: MarketCardType.ad,
      adHeadline: "Premium Career Coaching",
      adBody: "Unlock your full potential with executive coaching sessions.",
      adCta: "Learn More",
      url: "https://www.google.com/search?q=career+coaching",
    );
  }
}
