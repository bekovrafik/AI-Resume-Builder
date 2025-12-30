import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/glass_container.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/features/profile/providers/profile_provider.dart';
import 'package:mobile_app/features/market/services/market_service.dart';
import 'package:mobile_app/features/market/models/job_model.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final MarketService _marketService = MarketService();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<JobOpportunity> _jobs = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).value;
    if (profile?.targetRole != null) {
      _roleController.text = profile!.targetRole!;
      _searchJobs();
    }
  }

  Future<void> _searchJobs() async {
    if (_roleController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    // Simulate Network Delay & Fetch
    try {
      final results = await _marketService.fetchJobs(_roleController.text);
      if (mounted) {
        setState(() {
          _jobs = results;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              // Header
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                        text: "Market ",
                        style: AppTypography.header1
                            .copyWith(color: Colors.white, fontSize: 32)),
                    TextSpan(
                        text: "Radar.",
                        style: AppTypography.header1.copyWith(
                            color: AppColors.strategicGold, fontSize: 32)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text("REAL-TIME OPPORTUNITY DISCOVERY",
                  style: AppTypography.labelSmall
                      .copyWith(color: Colors.white54, letterSpacing: 2.0)),

              const SizedBox(height: 32),

              // Search Box
              GlassContainer(
                padding: const EdgeInsets.all(24),
                borderRadius: BorderRadius.circular(30),
                child: Column(
                  children: [
                    _buildInputField("TARGET PROFESSIONAL ROLE",
                        _roleController, "Ex: Executive Creative Director"),
                    const SizedBox(height: 20),
                    _buildInputField("GEOGRAPHICAL FOCUS", _locationController,
                        "Ex: NYC, London, or Remote"),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _searchJobs,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.strategicGold,
                          foregroundColor: AppColors.midnightNavy,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: Text(
                          _isLoading
                              ? "SCANNING INSTITUTIONAL PORTALS..."
                              : "SCAN JOBS",
                          style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.midnightNavy),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Results
              if (_isLoading)
                const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.strategicGold))
              else if (_jobs.isEmpty && _hasSearched)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.radar, size: 48, color: Colors.white24),
                      const SizedBox(height: 16),
                      Text("NO OPPORTUNITIES DETECTED",
                          style: AppTypography.labelSmall
                              .copyWith(color: Colors.white24)),
                    ],
                  ),
                )
              else if (_jobs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Column(
                      children: [
                        Icon(Icons.search, size: 48, color: Colors.white10),
                        const SizedBox(height: 16),
                        Text("AWAITING SEARCH QUERY",
                            style: AppTypography.labelSmall
                                .copyWith(color: Colors.white10)),
                      ],
                    ),
                  ),
                )
              else
                ..._jobs.map((job) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildJobCard(job),
                    )),

              // Bottom spacing for Navbar
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelSmall
                .copyWith(color: Colors.white54, fontSize: 9)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildJobCard(JobOpportunity job) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title,
                        style: AppTypography.header3
                            .copyWith(color: Colors.white, height: 1.2)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(job.company.toUpperCase(),
                            style: AppTypography.labelSmall.copyWith(
                                color: AppColors.strategicGold, fontSize: 9)),
                        const SizedBox(width: 8),
                        Text("•", style: TextStyle(color: Colors.white30)),
                        const SizedBox(width: 8),
                        Text(job.location.toUpperCase(),
                            style: AppTypography.labelSmall
                                .copyWith(color: Colors.white54, fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.strategicGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_outward,
                    color: AppColors.strategicGold, size: 20),
              )
            ],
          ),
          const SizedBox(height: 20),
          Text(job.description,
              style: AppTypography.bodySmall.copyWith(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 24),
          InkWell(
            onTap: () async {
              final uri = Uri.parse(job.url);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("INITIATE APPLICATION",
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.midnightNavy,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Icon(Icons.check, size: 14, color: AppColors.midnightNavy)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
