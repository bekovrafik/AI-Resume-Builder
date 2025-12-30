import 'package:uuid/uuid.dart';
import 'package:mobile_app/features/market/models/job_model.dart';

class MarketService {
  final _uuid = const Uuid();

  // Mock Data Generator
  List<JobOpportunity> fetchJobs(String targetRole) {
    // In a real app, this would call an API (Indeed, LinkedIn, Glassdoor, etc.)
    // For now, we generate realistic dummy data tailored to the role.

    final List<JobOpportunity> jobs = [];
    final roles = [
      targetRole,
      'Senior $targetRole',
      'Lead $targetRole',
      '$targetRole Consultant',
      'Director of $targetRole'
    ];

    final companies = [
      'TechCorp',
      'InnovateX',
      'Global Solutions',
      'StartUp Inc',
      'Enterprise Systems',
      'Creative Minds',
      'Future Vision',
      'Data Heavy',
      'Cloud Nine',
      'Security First'
    ];

    final locations = [
      'New York, NY',
      'San Francisco, CA',
      'Austin, TX',
      'Remote',
      'London, UK'
    ];

    for (int i = 0; i < 20; i++) {
      jobs.add(JobOpportunity(
        id: _uuid.v4(),
        title: roles[i % roles.length],
        company: companies[i % companies.length],
        location: locations[i % locations.length],
        salaryRange: '\$${(80 + (i * 5))}k - \$${(120 + (i * 5))}k',
        logoUrl:
            'https://via.placeholder.com/100?text=${companies[i % companies.length][0]}',
        tags: ['Full-time', i % 3 == 0 ? 'Remote' : 'On-site', 'Senior'],
        description:
            'We are looking for a talented $targetRole to join our team. You will be responsible for leading key initiatives and driving growth.',
        isRemote: i % 3 == 0,
      ));
    }

    return jobs;
  }
}
