class JobOpportunity {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salaryRange;
  final String logoUrl;
  final List<String> tags;
  final String description;
  final bool isRemote;
  final String url;

  JobOpportunity({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salaryRange,
    required this.logoUrl,
    required this.tags,
    required this.description,
    required this.isRemote,
    this.url = 'https://linkedin.com',
  });
}
