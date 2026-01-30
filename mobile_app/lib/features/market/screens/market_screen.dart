import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/core/ui/app_typography.dart';
import 'package:mobile_app/core/ui/gradient_background.dart';
import 'package:mobile_app/features/profile/providers/profile_provider.dart';
import 'package:mobile_app/core/ui/custom_snackbar.dart';
import 'package:mobile_app/features/market/services/market_service.dart';
import 'package:mobile_app/features/market/models/market_card_model.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app/l10n/app_localizations.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  List<MarketCardModel> _cards = [];
  bool _isLoading = true;

  // Filter State
  String? _selectedRole;
  String? _selectedLocation;
  final TextEditingController _roleFilterCtrl = TextEditingController();
  final TextEditingController _locFilterCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Delay to allow provider to read
    Future.microtask(() {
      final profile = ref.read(profileProvider).value;
      setState(() {
        _selectedRole = profile?.targetRole ?? "General Manager";
        _selectedLocation = "Remote";

        _roleFilterCtrl.text = _selectedRole!;
        _locFilterCtrl.text = _selectedLocation!;
      });
      _loadFeed();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadFeed() async {
    setState(() => _isLoading = true);

    final role = _selectedRole ?? "General Manager";
    final location = _selectedLocation ?? "Remote";

    final marketService = ref.read(marketServiceProvider);

    final newCards = await marketService.fetchFeed(role, location);
    if (mounted) {
      setState(() {
        _cards = newCards;
        _isLoading = false;
      });
    }
  }

  void _openFilterModal(Color textColor, bool isDark) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom +
              20;
          return Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(AppLocalizations.of(context)!.marketRadarSettings,
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.strategicGold, letterSpacing: 2)),
                  const SizedBox(height: 24),
                  _buildFilterInput(
                      AppLocalizations.of(context)!.targetRoleLabel,
                      _roleFilterCtrl,
                      textColor),
                  const SizedBox(height: 16),
                  _buildFilterInput(
                      AppLocalizations.of(context)!.linkedInLabel,
                      _locFilterCtrl,
                      textColor), // Note: LinkedInLabel used as Location preference seems slightly off in original code but sticking to it or mapping to a better one
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedRole = _roleFilterCtrl.text;
                          _selectedLocation = _locFilterCtrl.text;
                        });
                        Navigator.pop(context);
                        _loadFeed();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.strategicGold,
                          foregroundColor: AppColors.midnightNavy,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16))),
                      child: Text(AppLocalizations.of(context)!.applyFilters,
                          style: AppTypography.labelSmall
                              .copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        });
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (direction == CardSwiperDirection.right) {
      // Launch URL
      final card = _cards[previousIndex];
      if (card.url != null) {
        _launchJobUrl(card.url!);
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      CustomSnackBar.show(
        context,
        message: card.type == MarketCardType.job
            ? AppLocalizations.of(context)!.openingJobApplication
            : AppLocalizations.of(context)!.openingOffer,
        type: SnackBarType.success,
      );
    }
    return true;
  }

  Future<void> _launchJobUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.midnightNavy;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.marketRadarDot,
                        style: AppTypography.header1.copyWith(
                            color: AppColors.strategicGold, fontSize: 32),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _openFilterModal(textColor, isDark),
                          icon: Icon(Icons.tune, color: textColor),
                        ),
                        IconButton(
                          onPressed: () => _loadFeed(),
                          icon: Icon(Icons.refresh,
                              color: textColor.withValues(alpha: 0.5)),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14, color: textColor.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(
                        "${_selectedRole ?? 'Loading...'} in ${_selectedLocation ?? '...'}",
                        style: AppTypography.bodySmall.copyWith(
                            color: textColor.withValues(alpha: 0.5),
                            fontSize: 12)),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.strategicGold))
                    : _cards.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 64,
                                    color: textColor.withValues(alpha: 0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!
                                      .noOpportunitiesFound,
                                  style: AppTypography.header3
                                      .copyWith(color: textColor),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .noOpportunitiesDesc,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodySmall.copyWith(
                                        color:
                                            textColor.withValues(alpha: 0.5)),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _launchJobUrl(
                                        "https://jooble.org/SearchResult?p=$_selectedRole&rg=$_selectedLocation");
                                  },
                                  icon: const Icon(Icons.public,
                                      color: AppColors.midnightNavy),
                                  label: Text(
                                      AppLocalizations.of(context)!
                                          .searchOnJoobleWeb,
                                      style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.midnightNavy,
                                          fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.strategicGold,
                                      foregroundColor: AppColors.midnightNavy,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12)),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () =>
                                      _openFilterModal(textColor, isDark),
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .adjustFilters,
                                      style: TextStyle(
                                          color: textColor.withValues(
                                              alpha: 0.7))),
                                )
                              ],
                            ),
                          )
                        : CardSwiper(
                            controller: _swiperController,
                            cardsCount: _cards.length,
                            onSwipe: _onSwipe,
                            numberOfCardsDisplayed:
                                _cards.length < 3 ? _cards.length : 3,
                            backCardOffset: const Offset(0, 40),
                            padding: const EdgeInsets.all(24.0),
                            cardBuilder: (context, index, percentThresholdX,
                                percentThresholdY) {
                              final card = _cards[index];
                              return _buildJobCard(card, isDark, textColor);
                            },
                          ),
              ),

              const SizedBox(height: 100), // Nav spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterInput(
      String label, TextEditingController controller, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelSmall.copyWith(
                fontSize: 10, color: textColor.withValues(alpha: 0.6))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: textColor.withValues(alpha: 0.1))),
          child: TextField(
            controller: controller,
            style: TextStyle(color: textColor),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        )
      ],
    );
  }

  Widget _buildJobCard(MarketCardModel card, bool isDark, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.strategicGold,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.strategicGold.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      size: 14, color: AppColors.midnightNavy),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.matchScore(
                        _calculateMatchScore(card).toInt().toString()),
                    style: AppTypography.labelSmall.copyWith(
                        color: AppColors.midnightNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            // Increased bottom padding to avoid overlap with buttons
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.business,
                                  size: 30, color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            // Constrain the text so it doesn't overflow
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(card.company ?? "Company",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.strategicGold,
                                          fontSize: 12)),
                                  Text(card.location ?? "Remote",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodySmall.copyWith(
                                          color: textColor.withValues(
                                              alpha: 0.6))),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          card.title ?? "Job Title",
                          style: AppTypography.header1.copyWith(
                              color: textColor, fontSize: 24, height: 1.1),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          card.salaryRange ?? "\$100k - \$150k",
                          style: AppTypography.header3.copyWith(
                              color: textColor.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (card.tags ?? [])
                              .map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                        color:
                                            textColor.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: textColor.withValues(
                                                alpha: 0.1))),
                                    child: Text(tag,
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                                color: textColor.withValues(
                                                    alpha: 0.8),
                                                fontSize: 10)),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          card.description ?? "",
                          style: AppTypography.bodySmall.copyWith(
                              color: textColor.withValues(alpha: 0.7),
                              height: 1.6),
                          // No maxLines here or increased to allow full read via scroll
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionBtn(Icons.close, Colors.redAccent,
                    () => _swiperController.swipe(CardSwiperDirection.left)),
                _buildActionBtn(Icons.work, AppColors.strategicGold,
                    () => _swiperController.swipe(CardSwiperDirection.right)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  double _calculateMatchScore(MarketCardModel card) {
    // Mission 3: Simulation of Keyword Matching from Cloud Function
    // In production, this would compare card.keywords with profile.targetKeywords
    final mockTargetKeywords = [
      "Leadership",
      "Strategy",
      "P&L",
      "Agile",
      "Python",
      "Flutter",
      "Management",
      "Vision",
      "Growth",
      "Scale"
    ];

    if (card.description == null) return 0;

    int matches = 0;
    final descLower = card.description!.toLowerCase();

    for (final k in mockTargetKeywords) {
      if (descLower.contains(k.toLowerCase())) {
        matches++;
      }
    }

    // Heuristic: 5+ matches = 100%, each match = 20%
    return (matches * 20.0).clamp(0.0, 100.0);
  }
}
